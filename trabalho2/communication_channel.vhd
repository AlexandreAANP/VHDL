library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity communication_channel is 
    PORT (
        data_in: in std_logic_vector(7 downto 0);
        data_out: out std_logic_vector(7 downto 0)
    );
end communication_channel;               

architecture Behavioral of communication_channel is
    signal data : std_logic_vector(7 downto 0);
begin

    data <= data_in;
    data_out <= data_in;

end Behavioral;