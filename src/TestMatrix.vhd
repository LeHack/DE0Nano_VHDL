library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.machine_state_type.all;
use work.fonts.all;

entity TestMatrix is
    PORT (
        CLOCK_50     : IN STD_LOGIC;
        DIN, CS, CLK : OUT STD_LOGIC
        -- LED          : OUT STD_LOGIC_VECTOR(7 downto 0)
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
        variable count  : unsigned(5 downto 0) := (others => '0');
        variable addr   : unsigned(3 downto 0) := (0 => '1', others => '0');
        variable tens, single : integer := 0;
        procedure run_animation is
        begin
            if addr <= 8 then
                -- first set the address
                data <= "0000" & addr(3) & addr(2) & addr(1) & addr(0) & "00000000";
                if tens > 0 then
                    for I in 0 to 3 loop
                        data(I+4) <= digits(tens)(to_integer(addr)-1)(I);
                    end loop;
                end if;
                for I in 0 to 3 loop
                    data(I) <= digits(single)(to_integer(addr)-1)(I);
                end loop;
                run <= '1';
                addr := addr + 1;
            else
                -- update addr/set sleep time
                addr  := ( 0 => '1', others => '0');
                sleep := (13 => '1', others => '0');
                -- increase count
                count := count + 1;
                -- now also set the digits
                tens   := to_integer(count) / 10;
                single := to_integer(count) mod 10;
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
