library ieee;
use ieee.std_logic_1164.all;
library utils;
use utils.machine_state_type.all;

entity shift_reg is
    PORT (
        CLOCK_50,
        run,
        virt_clk    : IN STD_LOGIC;
        input       : IN STD_LOGIC_VECTOR(7 downto 0);
        state       : BUFFER machine_state_type := ready;
        REG_CLK,
        REG_LATCH,
        REG_DATA    : OUT STD_LOGIC
    );
END entity;
