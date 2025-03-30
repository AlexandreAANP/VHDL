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
    -- File declaration, since I'm in diferent disk it's important to use the full path
    file output_file : text open write_mode is "D:/VHDL/trabalho3/output.txt";
    function to_bin_str(x: signed) return string is
        -- string are indexed using natural numbers
        variable result: string(1 to 32) := (others => '0');
    begin
        for i in 0 to 31 loop
            if x(i) = '1' then
                result(x'length - i) := '1';
            elsif x(i) = '0' then
                result(x'length - i) := '0';
            end if;
        end loop;
        return result;
    end function;
begin

    process(clk)    
        variable line_content : line;
    begin
        if falling_edge(clk) then
            if enable = '1' then
                -- Write data to file
                write(line_content, to_bin_str(data));
                writeline(output_file, line_content);
            end if;
        end if;
    end process;
end Behavioral;