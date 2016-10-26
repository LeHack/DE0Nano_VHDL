library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.machine_state_type.all;

entity led_matrix is
    PORT (
        CLOCK_50        : IN STD_LOGIC;
        CLK, DIN, CS    : OUT STD_LOGIC;
        LED             : OUT STD_LOGIC_VECTOR(6 downto 0);
        state           : OUT machine_state_type := initialize;
        sclk            : BUFFER STD_LOGIC
    );
END entity;

architecture max7219 of led_matrix is
    signal enable, enable_init, enable_ready    : STD_LOGIC := '0';
    signal data, data_init, data_ready          : STD_LOGIC_VECTOR(15 downto 0);
    shared variable setup_state                 : machine_state_type := initialize;
    shared variable op_state                    : machine_state_type := ready;
begin
    spi : entity work.spi_master GENERIC MAP (slaves => 1, d_width => 16) PORT MAP (
        clock => sclk, enable => enable, busy => CS, cont => '0',
        reset_n => '1', cpol => '0', cpha => '0', addr => 0,
        tx_data => data, miso => 'Z', mosi => DIN, sclk => CLK, clk_div => 0
    );

    process(CLOCK_50)
        variable sclk_cnt  : unsigned(3 downto 0);
        variable tmp_state : machine_state_type;
    begin
        if rising_edge(CLOCK_50) then
            -- handle state
            if setup_state = initialize then
                tmp_state := initialize;
                LED(1) <= '1';
                enable <= enable_init;
                data <= data_init;
            elsif op_state = ready then
                tmp_state := ready;
                LED(1) <= '0';
                LED(2) <= '1';
                enable <= enable_ready;
                data <= data_ready;
            elsif op_state = sleep then
                tmp_state := sleep;
                enable <= enable_ready;
                data <= data_ready;
                LED(2) <= '0';
            end if;
            -- also let the component user know our current state
            state <= tmp_state;

            sclk_cnt := sclk_cnt + 1;
            if sclk_cnt = 0 then
                sclk <= not sclk;
                LED(0) <= sclk;
            end if;
        end if;
    end process;

    process(sclk)
        variable addr       : unsigned(3 downto 0) := (others => '0');
        variable blnk       : STD_LOGIC := '0';
        variable blink      : boolean := false;
        variable ready_cnt  : unsigned(8 downto 0) := (others => '0');
        variable sleep_cnt  : unsigned(18 downto 0) := (others => '0');
    begin
        -- refresh display
        if rising_edge(sclk) and op_state = ready then
            enable_ready <= '0';
            if ready_cnt = 0 then
                blink := not blink;
                blnk  := To_Std_Logic(blink);
                data_ready <= (
                    0 => not blnk, 1 => blnk, 2 => not blnk, 3 => blnk,
                    4 => blnk, 5 => not blnk, 6 => blnk, 7 => not blnk,
                    8 => addr(0), 9 => addr(1), 10 => addr(2), 11 => addr(3),
                    others => '0'
                );
                -- we've got 8 rows
                if addr = 8 then
                    blink := not blink;
                    addr := (others => '0');
                    op_state := sleep;
                end if;
                addr := addr + 1; -- go over each row
                enable_ready <= '1';
            end if;
            ready_cnt := ready_cnt + 1;
        -- take a break
        elsif rising_edge(sclk) then
            sleep_cnt := sleep_cnt + 1;
            if sleep_cnt = 0 then
                op_state := ready;
            end if;
        end if;
    end process;
    
    process(sclk)
        variable cnt : unsigned(17 downto 0);
        variable normal_op, intens_set, decode_set, scan_set, disp_test_set : boolean := false;
    begin
        if rising_edge(sclk) and setup_state = initialize then
            enable_init <= '0';
            if cnt = 0 then
                if not disp_test_set then
                    -- disable display test
                    data_init <= (8 => '1', 9 => '1', 10 => '1', 11 => '1', others => '0');
                    disp_test_set := true;
                elsif not intens_set then
                    -- reduce intensivity
                    data_init <= (1 => '1', 9 => '1', 11 => '1', others => '0');
                    intens_set := true;
                elsif not scan_set then
                    -- disable scan
                    data_init <= (0 => '1', 1 => '1', 2 => '1', 8 => '1', 9 => '1', 11 => '1', others => '0');
                    scan_set := true;
                elsif not decode_set then
                    -- disable decode
                    data_init <= (8 => '1', 11 => '1', others => '0');
                    decode_set := true;
                elsif not normal_op then
                    -- disable shutdown mode
                    data_init <= (0 => '1', 10 => '1', 11 => '1', others => '0');
                    normal_op := true;
                elsif normal_op then
                    setup_state := ready;
                end if;
                enable_init <= '1';
                LED(4) <= To_Std_Logic(intens_set);
                LED(5) <= To_Std_Logic(decode_set);
                LED(6) <= To_Std_Logic(normal_op);
            end if;
            cnt := cnt + 1;
        end if;
    end process;
end max7219;
