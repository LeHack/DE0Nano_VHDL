architecture main of sm410564 is
    signal run        : STD_LOGIC := '0';
    signal state      : machine_state_type;
    signal input      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal div_number, div_quotient,
           div_denominator, div_remainder : STD_LOGIC_VECTOR (13 DOWNTO 0);
begin
    shift_register : entity work.shift_reg PORT MAP (
        CLOCK_50 => CLOCK_50, REG_CLK => REG_CLK, REG_LATCH => REG_LATCH, REG_DATA => REG_DATA,
        state => state, virt_clk => virt_clk, input => input, run => run
    );

    div_inst : entity work.div PORT MAP (
        clock    => CLOCK_50,
		numer	 => div_number,
		denom	 => div_denominator,
		quotient => div_quotient,
		remain	 => div_remainder
	);

    process(virt_clk)
        variable ref_sleep : Unsigned(10 downto 0)  := (others => '0');
        variable digit, next_digit : Integer range 0 to 3 := 0;
        type digitsArr is array(3 downto 0) of Integer range 0 to 9;
        variable digits   : digitsArr := (others => 0);
        variable dividing : Boolean := false;
        variable pval     : Unsigned(13 downto 0) := (others => '0');

        procedure division(step : Unsigned) is
        begin
            case to_integer(step) is
                when 0 =>
                    pval := dvalue;
                    dividing := true;
                    -- val / 1000, val mod 1000
                    div_number <= std_logic_vector(dvalue);
                    -- 1000
                    div_denominator <= (9 => '1', 8 => '1', 7 => '1', 6 => '1', 5 => '1', 3 => '1', others => '0');
                when 1 =>
                    -- rem / 100, rem mod 100
                    digits(3) := to_integer(unsigned(div_quotient));
                    if digits(3) > 9 then
                        digits(3) := digits(3) - 10;
                    end if;
                    div_number <= div_remainder;
                    -- 100
                    div_denominator <= (6 => '1', 5 => '1', 2 => '1', others => '0');
                when 2 =>
                    -- rem / 10, rem mod 10
                    digits(2) := to_integer(unsigned(div_quotient));
                    div_number <= div_remainder;
                    -- 10
                    div_denominator <= (3 => '1', 1 => '1', others => '0');
                when 3 =>
                    -- rem / 10, rem mod 10
                    digits(1) := to_integer(unsigned(div_quotient));
                    digits(0) := to_integer(unsigned(div_remainder));
                    dividing := false;
                when others =>
            end case;
        end division;

    begin
        if rising_edge(virt_clk) then
            if ref_sleep < 4 and next_digit = 0 and (dividing or pval /= dvalue) then
                -- run a 4 step division to get prepare a digit for each segment
                division(ref_sleep);
            elsif ref_sleep = 4 and state = ready then
                -- update the value in the registry to contain the next digit
                input <= Int_to_Seg(digits(next_digit), (dpoint = next_digit));
                run <= '1';
            elsif state = execute then
                run <= '0';
                -- disable the previous segment before writing a new value to the register
                MLTPLX_CH(digit) <= '0';
            -- storing the value in the registry takes 6 virt_clk ticks
            elsif ref_sleep = 10 then
                -- enable the current segment (registry must be set by now)
                MLTPLX_CH(next_digit) <= '1';
                -- increment selected and last digits
                digit := next_digit;
                if next_digit = 3 then
                    next_digit := 0;
                else
                    next_digit := digit + 1;
                end if;
            end if;
            ref_sleep := ref_sleep + 1;
        end if;
    end process;
end main;
