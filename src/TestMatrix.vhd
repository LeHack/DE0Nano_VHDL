library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.machine_state_type.all;

entity TestMatrix is
    PORT (
        CLOCK_50     : IN STD_LOGIC;
        DIN, CS, CLK : OUT STD_LOGIC
    );
END entity;

architecture main of TestMatrix is
    signal state            : machine_state_type := initialize;
    signal sclk, run, sleep : STD_LOGIC := '0';
    signal data             : STD_LOGIC_VECTOR(15 downto 0);
begin
    led_matrix : entity work.led_matrix PORT MAP (
        CLOCK_50 => CLOCK_50, DIN => DIN, CS => CS, CLK => CLK,
        state => state, sclk => sclk, input => data, run => run, sleep => sleep
    );

    process(sclk, state)
        variable addr  : unsigned(3 downto 0) := (others => '0');
        variable blink : boolean := false;
        procedure run_animation is
            variable blnk   : STD_LOGIC := '0';
        begin
            addr  := addr + 1; -- go over each row
            -- we've got 8 rows, but we need a 'run' when the last addr is sent
            if addr <= 8 then
                -- refresh display
                blink := not blink;
                blnk  := To_Std_Logic(blink);
                data <= (
                    0 => not blnk, 1 => blnk, 2 => not blnk, 3 => blnk,
                    4 => blnk, 5 => not blnk, 6 => blnk, 7 => not blnk,
                    8 => addr(0), 9 => addr(1), 10 => addr(2), 11 => addr(3),
                    others => '0'
                );
                run <= '1';
            else
                blink := not blink;
                addr  := (others => '0');
                sleep <= '1';
            end if;
        end procedure run_animation;
    begin
        if rising_edge(sclk) and state = ready and run /= '1' and sleep /= '1' then
            run_animation;
        elsif rising_edge(sclk) and state /= ready then
            run   <= '0';
            sleep <= '0';
        end if;
    end process;

end main;
