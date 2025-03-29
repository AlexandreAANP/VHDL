library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;


entity write_file is
    Port ( 
        clk: in std_logic;
        enable: in std_logic;
        data: in signed(31 downto 0)
    );
end write_file;

architecture Behavioral of write_file is
    file output_file : text open write_mode is "D:/VHDL/trabalho3/output.txt";
    signal result: string(1 to 32) := (others => '0');
    function to_bin_str(x: signed) return string is
        -- string are indexed using natural numbers
        variable result: string(1 to 32) := (others => '0');
    begin
        for i in 0 to 31 loop
            if x(i) = '1' then
                result(i+1) := '1';
            else
                result(i+1) := '0';
            end if;
        end loop;
        return result;
    end function;
begin

    process(clk)    
        variable line_content : line;
    begin
        if rising_edge(clk) then
            if enable = '1' then
                -- Write data to file
                result <= to_bin_str(data);
                write(line_content, result);
                writeline(output_file, line_content);
            end if;
        end if;
    end process;
end Behavioral;