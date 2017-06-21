library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library utils;
use utils.machine_state_type.all;
use utils.fonts.all;

-- Top-Level entity
entity LEDMatrix is
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        LED_DIN,
        LED_CS,
        LED_CLK  : OUT STD_LOGIC
    );
END entity;
