library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.machine_state_type.all;

entity led_matrix is
    PORT (
        CLOCK_50        : IN STD_LOGIC;
        CLK, DIN, CS    : OUT STD_LOGIC;
        state           : BUFFER machine_state_type := initialize;
        sclk            : BUFFER STD_LOGIC
    );
END entity;

architecture max7219 of led_matrix is
    signal enable : STD_LOGIC := '0';
    signal data   : STD_LOGIC_VECTOR(15 downto 0);
begin
    spi : entity work.spi_master GENERIC MAP (slaves => 1, d_width => 16) PORT MAP (
        clock => sclk, enable => enable, busy => CS, cont => '0',
        reset_n => '1', cpol => '0', cpha => '0', addr => 0,
        tx_data => data, miso => 'Z', mosi => DIN, sclk => CLK, clk_div => 0
    );

    process(CLOCK_50)
        variable sclk_cnt  : unsigned(5 downto 0);
    begin
        if rising_edge(CLOCK_50) then
            sclk_cnt := sclk_cnt + 1;
            if sclk_cnt = 0 then
                sclk <= not sclk;
            end if;
        end if;
    end process;

    process(sclk)
        variable addr  : unsigned(3 downto 0) := (others => '0');
        variable blink : boolean := false;
        procedure run_animation is
            variable blnk   : STD_LOGIC := '0';
        begin
            -- refresh display
            blink := not blink;
            blnk  := To_Std_Logic(blink);
            addr  := addr + 1; -- go over each row
            data <= (
                0 => not blnk, 1 => blnk, 2 => not blnk, 3 => blnk,
                4 => blnk, 5 => not blnk, 6 => blnk, 7 => not blnk,
                8 => addr(0), 9 => addr(1), 10 => addr(2), 11 => addr(3),
                others => '0'
            );
            -- we've got 8 rows, so pause when the addr overflows
            if addr = 8 then
                blink := not blink;
                state <= sleep;
                addr := (others => '0');
            end if;
        end procedure run_animation;

        variable sleep_cnt: unsigned(10 downto 0) := (others => '0');
        procedure run_sleep is
        begin
            -- take a break
            sleep_cnt := sleep_cnt + 1;
            if sleep_cnt = 0 then
                state <= ready;
            end if;
        end procedure;

        variable setup_step_cnt : integer := 13;
        type setup_procedure is array (0 to setup_step_cnt-1) of std_logic_vector(15 downto 0);
        variable setup_steps : setup_procedure := (
            -- disable shutdown
            (0 => '1', 10 => '1', 11 => '1', others => '0'),
            -- reduce intensivity
            (1 => '1', 9 => '1', 11 => '1', others => '0'),
            -- disable display test
            (8 => '1', 9 => '1', 10 => '1', 11 => '1', others => '0'),
            -- disable scan
            (0 => '1', 1 => '1', 2 => '1', 8 => '1', 9 => '1', 11 => '1', others => '0'),
            -- disable decode
            (8 => '1', 11 => '1', others => '0'),
            -- clear screen (8 rows)
            (8 => '1', 9 => '0', 10 => '0', others => '0'),
            (8 => '0', 9 => '1', 10 => '0', others => '0'),
            (8 => '1', 9 => '1', 10 => '0', others => '0'),
            (8 => '0', 9 => '0', 10 => '1', others => '0'),
            (8 => '1', 9 => '0', 10 => '1', others => '0'),
            (8 => '0', 9 => '1', 10 => '1', others => '0'),
            (8 => '1', 9 => '1', 10 => '1', others => '0'),
            (8 => '0', 9 => '0', 10 => '0', 11 => '1', others => '0')
        );
        variable setup_step : integer range 0 to setup_step_cnt-1 := 0;
        procedure run_setup is
        begin
            data <= setup_steps(setup_step);
            setup_step := setup_step + 1;
            if setup_step = 0 then
                state <= ready;
            end if;
        end procedure run_setup;

        variable cnt : unsigned(5 downto 0);
    begin
        if rising_edge(sclk) then
            enable <= '0';
            if cnt = 0 then
                enable <= '1';
                CASE state IS
                    WHEN initialize =>
                        run_setup;
                    WHEN ready =>
                        run_animation;
                    WHEN sleep =>
                        run_sleep;
                end CASE;
            end if;
            cnt := cnt + 1;
        end if;
    end process;
end max7219;
