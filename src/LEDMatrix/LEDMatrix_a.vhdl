architecture main of LEDMatrix is
    signal led_state : machine_state_type; -- RO here
    signal virt_clk  : STD_LOGIC := '0';
    signal led_run   : STD_LOGIC := '0';
    signal led_data  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    vclock : entity utils.virtual_clock PORT MAP (CLOCK_50 => CLOCK_50, virt_clk => virt_clk);

    led_matrix : entity work.max7219 PORT MAP (
        CLOCK_50 => CLOCK_50, DIN => LED_DIN, CS => LED_CS, CLK => LED_CLK,
        state => led_state, virt_clk => virt_clk, input => led_data, run => led_run
    );

    process(virt_clk, led_state)
        variable counter            : unsigned( 6 downto 0) := (others => '0');
        variable sleep              : unsigned(15 downto 0) := (others => '0');
        variable led_addr           : unsigned( 3 downto 0) := (others => '0');
        variable tens, single       : integer := 0;
        variable updating_display,
                 counter_updated    : boolean := false;

        procedure parse_counter(counter : unsigned) is
        begin
            -- now also set the digits
            tens   := to_integer(counter) / 10;
            single := to_integer(counter) mod 10;
            -- make sure we don't exceed 99
            if tens > 10 then
                tens := tens mod 10;
            end if;
        end parse_counter;

        procedure update_display(led_addr : unsigned) is
        begin
            -- set the address
            led_data <= "0000" & led_addr(3) & led_addr(2) & led_addr(1) & led_addr(0) & "00000000";
            -- set led_data for tens
            if tens > 0 then
                for I in 0 to 3 loop
                    led_data(I+4) <= digits(tens)(to_integer(led_addr)-1)(I);
                end loop;
            end if;
            -- set led_data for singles
            for I in 0 to 3 loop
                led_data(I) <= digits(single)(to_integer(led_addr)-1)(I);
            end loop;
        end update_display;

    begin
        -- check if state allows us to do anything
        if rising_edge(virt_clk) then
            -- handle LED Matrix
            if led_state /= ready and led_run = '1' then
                -- reset control signal
                led_run <= '0';
            elsif led_state = ready and led_run = '0' and updating_display then
                updating_display := (led_addr <= 8);
                if updating_display then
                    -- run the update procedure
                    update_display(led_addr);
                    -- increment the address
                    led_addr := led_addr + 1;
                    -- set control signal
                    led_run <= '1';
                end if;
            elsif led_state = ready and led_run = '0' and not updating_display and counter_updated then
                -- parse the data from counter
                parse_counter(counter);
                -- reset led_addr
                led_addr := ( 0 => '1', others => '0');
                -- set display update flag
                updating_display := true;
                -- unset the update flag
                counter_updated := false;
            end if;

            -- increment the counter
            sleep := sleep + 1;
            if sleep = 0 then
                counter := counter + 1;
                -- reset the counter at 100
                if counter > 99 then
                    counter := (others => '0');
                end if;
                -- set flag to refresh the display
                counter_updated := true;
            end if;
        end if;
    end process;

end main;