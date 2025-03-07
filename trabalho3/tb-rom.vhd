library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filter_rom_tb is
end filter_rom_tb;

architecture Behavioral of filter_rom_tb is
    
    -- Component Declaration for the Unit Under Test (UUT)
    component filter_rom
        Port (
            addr : in std_logic_vector(5 downto 0);
            data_out : out std_logic_vector(15 downto 0)
        );
    end component;
    
    -- Signals for testbench
    signal addr_tb : std_logic_vector(5 downto 0) := (others => '0');
    signal data_out_tb : std_logic_vector(15 downto 0);
    
begin
    
    -- Instantiate the Unit Under Test (UUT)
    uut: filter_rom
        port map (
            addr => addr_tb,
            data_out => data_out_tb
        );
    
    -- Stimulus process
    stim_proc: process
    begin        
        -- Apply test values to addr
        for i in 0 to 50 loop
            addr_tb <= std_logic_vector(to_unsigned(i, 6));
            wait for 10 ns; -- Wait for some time to observe the output
        end loop;
        
        -- Stop simulation
        wait;
    end process;
    
end Behavioral;