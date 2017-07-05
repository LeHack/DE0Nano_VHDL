architecture main of SegDispl is
    signal virt_clk : STD_LOGIC := '0';
    signal i        : Unsigned(13 downto 0) := (others => '0');
begin
    vclock : entity utils.virtual_clock PORT MAP (CLOCK_50 => CLOCK_50, virt_clk => virt_clk);

    seg_displ : entity work.sm410564 PORT MAP (
        CLOCK_50 => CLOCK_50, MLTPLX_CH => MLTPLX_CH,
        REG_CLK => REG_CLK, REG_LATCH => REG_LATCH, REG_DATA => REG_DATA,
        virt_clk => virt_clk, dvalue => i
    );

    process(virt_clk)
        variable cnt_sleep : unsigned(10 downto 0) := (others => '0');
    begin
        if rising_edge(virt_clk) then
            if cnt_sleep = 0 then
                i <= i + 1;
                if i > 9999 then
                    i <= (others => '0');
                end if;
            end if;
            cnt_sleep := cnt_sleep + 1;
        end if;
    end process;
end main;
