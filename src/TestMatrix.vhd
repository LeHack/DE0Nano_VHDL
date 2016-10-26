library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.machine_state_type.all;

entity TestMatrix is
	PORT (
		CLOCK_50		 : IN STD_LOGIC;
		LED1, LED2, LED3, LED4, LED5, LED6, LED7, DIN, CS, CLK : OUT STD_LOGIC
	);
END entity;

architecture rtl of TestMatrix is
	signal cnt	    : unsigned(19 downto 0);
	signal sclk_cnt : unsigned(3 downto 0);
	signal sclk, blnk : STD_LOGIC := '0';
	signal data_sig, load_sig, clk_sig : STD_LOGIC;
	signal addr   : unsigned(3 downto 0) := (others => '0');
	signal enable : STD_LOGIC := '0';
	signal data   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	shared variable blink, normal_op, intens_set, decode_set, scan_set, disp_test_set : boolean := false;
begin
	spi : entity work.spi_master GENERIC MAP (slaves => 1, d_width => 16) PORT MAP (
		clock => sclk, enable => enable, busy => load_sig, cont => '0',
		reset_n => '1', cpol => '0', cpha => '0', addr => 0,
		tx_data => data, miso => 'Z', mosi => data_sig, sclk => clk_sig, clk_div => 0
	);

	process(CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then
			sclk_cnt <= sclk_cnt + 1;
			if sclk_cnt = 0 then
				sclk <= not sclk;
			end if;
		end if;
	end process;

	process(sclk)
	begin
		if rising_edge(sclk) then
			enable <= '0';
			CLK  <= clk_sig;
			LED4 <= clk_sig;
			CS <= load_sig;
			DIN <= data_sig;
			LED3 <= data_sig;
			LED2 <= load_sig;
			if cnt = 0 then
				if normal_op then
					-- target all leds
					addr <= addr + 1;
					blnk <= To_Std_Logic(blink);
					data <= (
						0 => not blnk, 1 => blnk, 2 => not blnk, 3 => blnk,
						4 => blnk, 5 => not blnk, 6 => blnk, 7 => not blnk,
						8 => addr(0), 9 => addr(1), 10 => addr(2), 11 => addr(3),
						others => '0'
					);
					if addr(3) = '1' then
						blink := not blink;
						addr <= (others => '0');
					end if;
				elsif scan_set then
					data <= (0 => '1', 10 => '1', 11 => '1', others => '0');
					normal_op := true;
				elsif decode_set then
					data <= (0 => '1', 1 => '1', 2 => '1', 8 => '1', 9 => '1', 11 => '1', others => '0');
					scan_set := true;
				elsif intens_set then
					data <= (8 => '1', 11 => '1', others => '0');
					decode_set := true;
				elsif disp_test_set then
					data <= (1 => '1', 9 => '1', 11 => '1', others => '0');
					intens_set := true;
				else
					data <= (8 => '1', 9 => '1', 10 => '1', 11 => '1', others => '0');
					disp_test_set := true;
				end if;
				enable <= '1';
				LED1 <= To_Std_Logic(blink);
				LED5 <= To_Std_Logic(intens_set);
				LED6 <= To_Std_Logic(decode_set);
				LED7 <= To_Std_Logic(normal_op);
			end if;
			cnt <= cnt + 1;
		end if;
	end process;
end rtl;
