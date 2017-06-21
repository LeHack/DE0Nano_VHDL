architecture main of ADC_LEDMatrix is
    signal adc_state, led_state : machine_state_type; -- RO here
    signal virt_clk             : STD_LOGIC := '0';
    signal adc_run, led_run     : STD_LOGIC := '0';
    signal adc_data, led_data   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal adc_addr             : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    vclock : entity utils.virtual_clock PORT MAP (CLOCK_50 => CLOCK_50, virt_clk => virt_clk);

    led_matrix : entity work.max7219 PORT MAP (
        CLOCK_50 => CLOCK_50, DIN => LED_DIN, CS => LED_CS, CLK => LED_CLK,
        state => led_state, virt_clk => virt_clk, input => led_data, run => led_run
    );

    adc : entity work.de0nano_adc PORT MAP (
        input => adc_addr, output => adc_data, run => adc_run,
        state => adc_state, virt_clk => virt_clk,
        CLOCK_50 => CLOCK_50,
        ADC_SADDR => ADC_SADDR, ADC_SDAT => ADC_SDAT,
        ADC_CS_N => ADC_CS_N, ADC_SCLK => ADC_SCLK
    );

    process(virt_clk, adc_state, led_state)
        variable voltage_level : unsigned(5 downto 0) := (others => '0');

        -- ADC vars
        variable sleep : unsigned(10 downto 0) := (others => '0');

        -- LED vars
        variable led_addr           : unsigned(3 downto 0) := (others => '0');
        variable tens, single       : integer := 0;
        variable updating_display,
                 voltage_updated    : boolean := false;

        procedure parse_voltage(voltage : unsigned) is
        begin
            -- now also set the digits
            tens   := to_integer(voltage) / 10;
            single := to_integer(voltage) mod 10;
            -- make sure we don't exceed 99
            if tens > 10 then
                tens := tens mod 10;
            end if;
        end parse_voltage;

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
            -- handle ADC
            if (adc_state = ready and adc_run = '0') then
                if sleep = 0 then
                    -- display only the first 6 bits of the received 12 bit value
                    -- LED <= adc_data(11 downto 6);
                    voltage_level := unsigned(adc_data(11 downto 6));
                    voltage_updated := true;
                    adc_addr <= (others => '0');
                    adc_run <= '1';
                end if;
                sleep := sleep + 1;
            elsif (adc_state = execute and adc_run = '1') then
                -- reset control signals
                adc_run <= '0';
            end if;

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
            elsif led_state = ready and led_run = '0' and not updating_display and voltage_updated then
                -- parse the data from counter
                parse_voltage(voltage_level);
                -- reset led_addr
                led_addr := ( 0 => '1', others => '0');
                -- set display update flag
                updating_display := true;
                -- unset the update flag
                voltage_updated := false;
            end if;
        end if;
    end process;

end main;
