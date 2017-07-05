library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library utils;
use utils.machine_state_type.all;

entity sm410564 is
    PORT (
        CLOCK_50   : IN STD_LOGIC;
        REG_CLK,
        REG_LATCH,
        REG_DATA   : OUT STD_LOGIC := '0';
        MLTPLX_CH  : OUT STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

        virt_clk   : IN STD_LOGIC;
        dvalue     : IN Unsigned(13 downto 0);
        dpoint     : IN INTEGER range 0 to 4 := 4 -- disabled by default
    );
END entity;
