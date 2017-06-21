-- synthesis library utils
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.machine_state_type.all;

-- the virt_clk drives logic level operations
entity virtual_clock is
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        virt_clk : BUFFER STD_LOGIC := '0'
    );
END entity;

architecture vclock of virtual_clock is
begin
    process(CLOCK_50)
        variable vclk_cnt : unsigned(5 downto 0) := (others => '0');
    begin
        if rising_edge(CLOCK_50) then
            vclk_cnt := vclk_cnt + 1;
            if vclk_cnt = 42 then
                vclk_cnt := (others => '0');
                virt_clk <= not virt_clk;
            end if;
        end if;
    end process;
end vclock;
