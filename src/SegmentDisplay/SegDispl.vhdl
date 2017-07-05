library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library utils;

entity SegDispl is
    PORT (
        CLOCK_50   : IN STD_LOGIC;
        REG_CLK,
        REG_LATCH,
        REG_DATA   : OUT STD_LOGIC := '0';
        MLTPLX_CH  : OUT STD_LOGIC_VECTOR(3 downto 0) := (others => '0')
    );
END entity;
