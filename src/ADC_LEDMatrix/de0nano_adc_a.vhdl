architecture main of de0nano_adc is
    signal ADC_CS, enable, reset : STD_LOGIC := '0';
begin

    spi_driver : entity work.spi_master GENERIC MAP (slaves => 1, d_width => 16) PORT MAP (
        clock => CLOCK_50, enable => enable, cont => '0',
        reset_n => reset, cpol => '0', cpha => '0', addr => 0,
        tx_data => input, rx_data => output, clk_div => 16,
        sclk => ADC_SCLK, busy => ADC_CS,
        miso => ADC_SDAT, mosi => ADC_SADDR
    );

    -- Toggle the CS signal
    ADC_CS_N <= not ADC_CS;

    process(virt_clk, state)
        variable spi_comm_delay : unsigned(5 downto 0) := (others => '0');
        variable init_delay: unsigned(2 downto 0) := (others => '0');
    begin
        if rising_edge(virt_clk) then
            -- don't wait an extra virt_clk on run
            if state = ready and run = '1' then
                state <= execute;
            end if;
            CASE state IS
                WHEN initialize =>
                    init_delay := init_delay + 1;
                    if init_delay = 0 then
                        reset <= '1';
                        state <= ready;
                    end if;
                WHEN execute =>
                    if spi_comm_delay = 0 then
                        enable <= '1';
                    end if;
                    spi_comm_delay := spi_comm_delay + 1;
                    -- after 3 ticks, remove the enable flag, to make sure spi_driver stops after the read
                    if spi_comm_delay = 3 then
                        enable <= '0';
                    -- we need 7 virt_clk ticks to make sure SPI comms finished
                    elsif spi_comm_delay = 7 then
                        state <= ready;
                        -- reset counter
                        spi_comm_delay := (others => '0');
                    end if;
                WHEN busy =>  -- not used
                WHEN ready => -- not used
            end CASE;
        end if;
    end process;
end main;
