library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tb_communication_channel is 
end tb_communication_channel;

architecture behavioral of tb_communication_channel is
    
    component communication_channel
        PORT(
            data_in: in std_logic_vector(7 downto 0);
            data_out: out std_logic_vector(7 downto 0)
        );
    end component;


    signal data_in: std_logic_vector(7 downto 0);
    signal data_out: std_logic_vector(7 downto 0);
begin

    uut: communication_channel port map (
        data_in => data_in,
        data_out => data_out
    );
    stim_proc: process
    begin
        data_in <= "11110000";
        wait for 100 ns;
        
        data_in <= "00001111";
        wait for 100 ns;
        
        data_in <= "10101010";
        
        assert false report "End of simulation" severity failure;
        wait;
    end process;

end behavioral;