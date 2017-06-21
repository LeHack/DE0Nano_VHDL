library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library utils;
use utils.machine_state_type.all;
use utils.fonts.all;

entity ADC_LEDMatrix is
    PORT (
        CLOCK_50   : IN STD_LOGIC;
        LED_DIN,
        LED_CS,
        LED_CLK    : OUT STD_LOGIC;
        ADC_SDAT   : IN STD_LOGIC;
        ADC_SADDR,
        ADC_CS_N,
        ADC_SCLK   : OUT STD_LOGIC
    );
END entity;
