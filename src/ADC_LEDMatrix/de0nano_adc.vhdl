library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library utils;
use utils.machine_state_type.all;

entity de0nano_adc is
    PORT (
        run             : IN STD_LOGIC := '0';
        input           : IN  STD_LOGIC_VECTOR(15 downto 0);
        output          : OUT STD_LOGIC_VECTOR(15 downto 0);

        state           : BUFFER machine_state_type := initialize;
        virt_clk        : IN STD_LOGIC := '0';

        CLOCK_50        : IN STD_LOGIC;
        ADC_SDAT        : IN STD_LOGIC;

        ADC_SCLK,
        ADC_SADDR,
        ADC_CS_N        : OUT STD_LOGIC
    );
END entity;
