library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TestMatrix is
    PORT (
        CLOCK_50     : IN STD_LOGIC;
        DIN, CS, CLK : OUT STD_LOGIC;
        LED          : OUT STD_LOGIC_VECTOR(6 downto 0)
    );
END entity;

architecture main of TestMatrix is
begin
    led_matrix : entity work.led_matrix PORT MAP (
        CLOCK_50 => CLOCK_50, DIN => DIN, CS => CS, CLK => CLK, LED => LED
    );
end main;
