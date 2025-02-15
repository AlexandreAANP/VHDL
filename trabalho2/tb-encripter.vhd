library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Testbench entity
entity tb_encripter is
end tb_encripter;

architecture behavior of tb_encripter is

    -- Component declaration for the unit under test (UUT)
    component encripter
        Port (
            data : in std_logic_vector(7 downto 0);
            encripted_data : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Signals to connect to the UUT
    signal data          : std_logic_vector(7 downto 0) := "10101010"; -- Example input
    signal encripted_data : std_logic_vector(7 downto 0);

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: encripter port map (
        data => data,
        encripted_data => encripted_data
    );

    -- Stimulus process to drive the inputs and generate a clock
    stim_proc: process
    begin
        -- Apply some test vectors
        -- First input
        data <= "11010101";   -- Example data
        wait for 20 ns;       -- Wait for 10 ns
        
        -- Second input
        data <= "10101010";   -- Another test case
        wait for 20 ns;       -- Wait for 10 ns
        
        -- Third input
        data <= "11110000";   -- Another test case
        wait for 20 ns;       -- Wait for 10 ns
        
        -- Fourth input
        data <= "00001111";   -- Another test case
        wait for 20 ns;       -- Wait for 10 ns

        -- End the simulation
        wait;
    end process;

end behavior;
