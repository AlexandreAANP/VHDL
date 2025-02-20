library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity decripter is
    Port ( 
        data : in std_logic_vector(7 downto 0);
        clk: in std_logic;
        decripted_data : out std_logic_vector(7 downto 0)
    );
end decripter;


architecture Behavioral of decripter is
begin
    encript: process (clk)
    variable temp_data : unsigned(7 downto 0);
    variable bit_process : std_logic;
    begin

        if falling_edge(clk) then
            temp_data := unsigned(data);
            for i in 0 to 7 loop

                -- xor the first and last element
                bit_process := temp_data(7) xor temp_data(0);

                -- shift to right one
                temp_data := unsigned(temp_data sll 1);

                -- set the first element with the value of bit_process
                temp_data(0) := bit_process;

            end loop;
            decripted_data <= std_logic_vector(temp_data);
        end if;
        
    end process;

end Behavioral;