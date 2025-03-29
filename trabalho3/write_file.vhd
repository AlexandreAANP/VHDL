library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;


entity write_file is
    Port ( 
        clk: in std_logic;
        cls_file: in std_logic;
        enable: in std_logic;
        data: in signed(31 downto 0)
    );
end write_file;

architecture Behavioral of write_file is


    function to_bin_str(x: signed) return string is
        variable result: string(1 to x'length);
    begin
        for i in x'range loop
            if x(i) = '1' then
                result(i) := '1';
            else
                result(i) := '0';
            end if;
        end loop;
        return result;
    end function;
begin

    process
        file output_file : text open write_mode is "output.txt";
        variable line_content : line;
    begin
        if cls_file = '1' then
            file_close(output_file);
            wait;
        end if;
        if rising_edge(clk) then
            if enable = '1' then
                -- Write data to file
                write(line_content, to_bin_str(data));
                writeline(output_file, line_content);
            end if;

        end if;
        wait; -- End process
    end process;
end Behavioral;