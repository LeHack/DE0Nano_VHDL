library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.machine_state_type.all;

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
    signal data             : STD_LOGIC_VECTOR(31 downto 0);
    shared variable sleep   : unsigned(24 downto 0) := (others => '0');
    type image_type is array (0 to 7) of std_logic_vector(7 downto 0);
    constant image_data : image_type := (
        "00000001",
        "00000011",
        "00000110",
        "00000110",
        "11001100",
        "01101100",
        "00111000",
        "00011000"
    );
begin
    led_matrix : entity work.led_matrix PORT MAP (
        CLOCK_50 => CLOCK_50, DIN => DIN, CS => CS, CLK => CLK,
        state => state, virt_clk => virt_clk, input => data, run => run, sleep => sleep
    );

    process(virt_clk, state)
        variable blink      : boolean := false;
        variable addr       : unsigned(3 downto 0);
        type PWMwidthType is array(1 downto 0) of unsigned(6 downto 0);
        variable PWM_width  : PWMwidthType;
        variable PWM_adj    : unsigned(5 downto 0);
        variable cnt        : unsigned(11 downto 0);
        procedure run_animation is
            constant firstbit   : unsigned(6 downto 0)  := (others => '0');
            variable dat1, dat2 : std_logic_vector(15 downto 0);
        begin
            -- we've got 8 rows
            if addr <= 8 then
                -- refresh display
                dat1 := ( 8 => addr(0), 9 => addr(1), 10 => addr(2), 11 => addr(3), others => '0' );
                dat2 := dat1;
                for I in 0 to 7 loop
                    if image_data(to_integer(addr)-1)(I) = '1' then
                        dat1(I) := PWM_width(0)(6);
                        dat2(I) := PWM_width(1)(6);
                    end if;
                end loop;
                data <= dat1 & dat2;
                run <= '1';
                addr := addr + 1;  -- next row
            else
                -- reset the address to start row
                addr := (0 => '1', others => '0');
                cnt  := cnt + 1;
                PWM_width(0) := '0' & PWM_width(0)(5 downto 0) + PWM_adj;
                PWM_width(1) := '0' & PWM_width(1)(5 downto 0) + not PWM_adj;
                if blink then
                    PWM_adj := cnt(10 downto 5);
                else
                    PWM_adj := not cnt(10 downto 5);
                end if;
                if cnt(11) = '1' then
                    cnt := (10 => '1', others => '0');
                    blink := not blink; -- toggle led state for each row
                end if;
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
