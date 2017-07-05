architecture SPI of shift_reg is
    signal data             : STD_LOGIC_VECTOR(7 downto 0);
    signal enable, spi_busy : STD_LOGIC := '0';
begin
    spi_driver : entity work.spi_master GENERIC MAP (slaves => 1, d_width => 8) PORT MAP (
        clock => CLOCK_50, enable => enable, busy => spi_busy, cont => '0',
        reset_n => '1', cpol => '0', cpha => '0', addr => 0,
        tx_data => data, miso => 'Z', mosi => REG_DATA, sclk => REG_CLK, clk_div => 10
    );

    process(virt_clk, state)
    begin
        if rising_edge(virt_clk) then
            if state = ready and run = '1' then
                data <= input;
                state <= execute;
                enable <= '1';
                REG_LATCH <= '0';
            elsif state = execute then
                state <= busy;
                enable <= '0';
            elsif state = busy and spi_busy = '0' then
                state <= ready;
                -- remember to flip the latch when we're done
                REG_LATCH <= '1';
            end if;
        end if;
    end process;
end SPI;
