library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity write_file is
    Port ( 
        clk: in std_logic;
        cls_file: in std_logic;
        data: in signed(31 downto 0)
    );
end write_file;

architecture Behavioral of write_file is
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
            -- Write data to file
            write(line_content, to_integer(data));
            writeline(output_file, line_content);
        end if;
        wait; -- End process
    end process;
end Behavioral;