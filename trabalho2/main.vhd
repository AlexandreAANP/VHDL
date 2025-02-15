library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity encripter is generic (
    DATA_WIDTH : integer := 8
    );
    Port ( 
        data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        encripted_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    );
end encripter;


architecture Behavioral of encripter is
begin
    process (data, encripted_data, DATA_WIDTH)
    variable bit_process : STD_LOGIC;
    begin 
        for i in 0 to DATA_WIDTH-1 loop

            -- get the last bit
            bit_process <= data(0)

            -- add to ouput encripted_data vector
            encripted_data(i) <= bit_process

            -- xor bit_process to the element before the last
            bit_process <= bit_process xor data(1)

            -- shift to right one
            data <= data srl 1

            -- set the first element with the value of bit_process
            data(DATA_WIDTH-1) <= bit_process

        end loop

    end process


end Behavioral;