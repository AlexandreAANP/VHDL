library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity encripter is
    Port ( 
        data : in std_logic_vector(7 downto 0);
        clk: in std_logic;
        rst: in std_logic;
        encripted_data : out std_logic_vector(7 downto 0)
    );
end encripter;


architecture Behavioral of encripter is
    signal bit_process : STD_LOGIC;
    signal updated_data : unsigned(7 downto 0);
begin
    process (data)
    begin 
        if rst = '1' then
            bit_process <= '0';

        elsif rising_edge(clk) then
            updated_data <= unsigned(data);
            for i in 0 to 7 loop

                -- get the last bit
                bit_process <= updated_data(0);

                -- add to ouput encripted_data vector
                encripted_data(i) <= bit_process;

                -- xor bit_process to the element before the last
                bit_process <= bit_process xor data(1);

                -- shift to right one
                updated_data <= unsigned(updated_data srl 1);

                -- set the first element with the value of bit_process
                updated_data(7) <= bit_process;

            end loop;
            encripted_data <= std_logic_vector(updated_data);
        end if;
        
    end process;


end Behavioral;