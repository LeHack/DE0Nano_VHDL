library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.machine_state_type.all;

entity TestMatrix is
    PORT (
        CLOCK_50     : IN STD_LOGIC;
        DIN, CS, CLK : OUT STD_LOGIC;
        LED          : OUT STD_LOGIC_VECTOR(7 downto 0)
    );
END entity;

architecture main of TestMatrix is
    signal state            : machine_state_type := initialize; -- RO here
    signal virt_clk, run    : STD_LOGIC := '0';
    signal data             : STD_LOGIC_VECTOR(15 downto 0);
    shared variable sleep   : unsigned(24 downto 0) := (others => '0');
begin
    led_matrix : entity work.led_matrix PORT MAP (
        CLOCK_50 => CLOCK_50, DIN => DIN, CS => CS, CLK => CLK,
        state => state, virt_clk => virt_clk, input => data, run => run, sleep => sleep
    );

    process(virt_clk, state)
        variable blink : boolean := false;
        variable addr  : unsigned(3 downto 0) := (0 => '1', others => '0');
        procedure run_animation is
            variable blnk       : STD_LOGIC := '0';
            constant sleep_time : unsigned(10 downto 0) := (others => '1');
        begin
            -- we've got 8 rows
            if addr <= 8 then
                -- refresh display
                blink := not blink; -- toggle led state for each row
                blnk  := To_Std_Logic(blink);
                data <= (
                    0 => not blnk, 1 => blnk, 2 => not blnk, 3 => blnk,
                    4 => not blnk, 5 => blnk, 6 => not blnk, 7 => blnk,
                    8 => addr(0), 9 => addr(1), 10 => addr(2), 11 => addr(3),
                    others => '0'
                );
                run <= '1';
                addr := addr + 1;  -- next row
            else
                -- reset the address to start row
                addr  := (0 => '1', others => '0');
                -- set sleep time
                sleep := (others => '0');
                sleep := sleep + sleep_time;
                -- toggle start blink state for the whole next iteration
                blink := not blink;
            end if;
        end procedure run_animation;
    begin
        -- check if state allows us to do anything
        if rising_edge(virt_clk) then
            if state = ready and run = '0' and sleep = 0 then
                run_animation;
            elsif run = '1' or sleep > 0 then
                -- reset control signals
                run   <= '0';
                sleep := (others => '0');
            end if;
        end if;
    end process;

end main;
