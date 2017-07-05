-- synthesis library utils
architecture vclock of virtual_clock is
begin
    process(CLOCK_50)
        variable vclk_cnt : unsigned(24 downto 0) := (others => '0');
    begin
        if rising_edge(CLOCK_50) then
            vclk_cnt := vclk_cnt + 1;
            if vclk_cnt = clk_div then
                vclk_cnt := (others => '0');
                virt_clk <= not virt_clk;
            end if;
        end if;
    end process;
end vclock;
