-- synthesis library utils
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package machine_state_type is
    type machine_state_type IS(initialize, ready, execute, busy);
    function To_Std_Logic(L: BOOLEAN) return std_logic;
    function Int_to_Seg(i : integer; dp : boolean) return STD_LOGIC_VECTOR;
end package machine_state_type;

package body machine_state_type is
    function To_Std_Logic(L: BOOLEAN) return std_logic is
    begin
        if L then
            return('1');
        else
            return('0');
        end if;
    end function To_Std_Logic;

    function Int_to_Seg(i : integer; dp : boolean) return STD_LOGIC_VECTOR is
        variable digit : STD_LOGIC_VECTOR(7 downto 0);
    begin
        case i is
            when 1 => digit := "11010111";
            when 2 => digit := "01001100";
            when 3 => digit := "01000101";
            when 4 => digit := "10000111";
            when 5 => digit := "00100101";
            when 6 => digit := "00100100";
            when 7 => digit := "01010111";
            when 8 => digit := "00000100";
            when 9 => digit := "00000101";
            when 0 => digit := "00010100";
            when others => digit := "11111111";
        end case;
        if dp then
            digit(2) := '0';
        end if;
        return digit;
    end Int_to_Seg;
end package body;
