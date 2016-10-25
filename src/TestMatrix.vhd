library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TestMatrix is
	PORT (
		CLOCK_50		 : IN STD_LOGIC;
		LED1, LED2, LED3, LED4, LED5, LED6, LED7, DIN, CS, CLK : OUT STD_LOGIC
	);
END entity;

architecture rtl of TestMatrix is
	component spi_master IS
		GENERIC(
			slaves  : INTEGER := 1; --number of spi slaves
			d_width : INTEGER	:= 16  --data bus width
		);
		PORT(
			clock   : IN     STD_LOGIC;                             --system clock
			reset_n : IN     STD_LOGIC;                             --asynchronous reset
			enable  : IN     STD_LOGIC;                             --initiate transaction
			cpol    : IN     STD_LOGIC;                             --spi clock polarity
			cpha    : IN     STD_LOGIC;                             --spi clock phase
			cont    : IN     STD_LOGIC;                             --continuous mode command
			clk_div : IN     INTEGER;                               --system clock cycles per 1/2 period of sclk
			addr    : IN     INTEGER;                               --address of slave
			tx_data : IN     STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
			miso    : IN     STD_LOGIC;                             --master in, slave out
			sclk    : BUFFER STD_LOGIC;                             --spi clock
			ss_n    : BUFFER STD_LOGIC_VECTOR(slaves-1 DOWNTO 0);   --slave select
			mosi    : OUT    STD_LOGIC;                             --master out, slave in
			busy    : OUT    STD_LOGIC;                             --busy / data ready signal
			rx_data : OUT    STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)	  --data received
		);
	END component;

	signal cnt	    : unsigned(19 downto 0);
	signal sclk_cnt : unsigned(3 downto 0);
	signal sclk, blnk : STD_LOGIC := '0';
	signal data_sig, load_sig, clk_sig : STD_LOGIC;
	signal addr   : unsigned(3 downto 0) := (others => '0');
	signal enable : STD_LOGIC := '0';
	signal data   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	shared variable blink, normal_op, intens_set, decode_set, scan_set, disp_test_set : boolean := false;

	function To_Std_Logic(L: BOOLEAN) return std_logic is
	begin
		if L then
			return('1');
		else
			return('0');
		end if;
	end function To_Std_Logic;

begin
	spi : spi_master PORT MAP (
		clock => sclk, enable => enable, busy => load_sig, cont => '0',
		reset_n => '1', cpol => '1', cpha => '0', addr => 0,
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
			CS <= not load_sig;
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
