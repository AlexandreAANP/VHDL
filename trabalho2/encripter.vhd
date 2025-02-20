library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity encripter is
    Port ( 
        data : in std_logic_vector(7 downto 0);
        clk: in std_logic;
        encripted_data : out std_logic_vector(7 downto 0)
    );
end encripter;


architecture Behavioral of encripter is
    signal updated_data : unsigned(7 downto 0);
    signal encrypted : boolean := false;
begin
    encript: process (clk)
    variable temp_data : unsigned(7 downto 0);
    variable bit_process : std_logic;
    begin

        if rising_edge(clk) then
            temp_data := unsigned(data);
            for i in 0 to 7 loop
                -- get the last bit
                bit_process := temp_data(0);

                -- xor bit_process to the element before the last
                bit_process := bit_process xor temp_data(1);

                -- shift to right one
                temp_data := unsigned(temp_data srl 1);

                -- set the first element with the value of bit_process
                temp_data(7) := bit_process;

            end loop;
            encripted_data <= std_logic_vector(temp_data);

        end if;
        
    end process;


end Behavioral;