library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Testbench entity
entity tb_decripter is
end tb_decripter;

architecture behavior of tb_decripter is

    -- Component declaration for the unit under test (UUT)
    component decripter
        Port (
            data : in std_logic_vector(7 downto 0);
            clk : in std_logic;
            decripted_data : out std_logic_vector(7 downto 0)
        );
    end component;


    -- Signals to connect to the UUT
    signal data          : std_logic_vector(7 downto 0); -- Example input
    signal clk           : std_logic := '0';
    signal decripted_data : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: decripter port map (
        data => data,
        clk => clk,
        decripted_data => decripted_data
    );


    -- Clock generation
    clk_process: process
    begin
       while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus process to drive the inputs and generate a clock
    stim_proc: process
    begin

        data <= (others => '0');
        wait for clk_period;

        wait for clk_period *3;

        -- Apply some test vectors
        -- First input
        data <= "00111111";   -- Example data --expected 10101101
        wait for clk_period * 3;       -- Wait for 10 ns
        
        -- Second input
        data <= "01111111";   -- Another test case --expected 10101010
        wait for clk_period * 3;       -- Wait for 10 ns
        
        -- Third input
        data <= "10001000";   -- Another test case -- expected 11110000
        wait for clk_period * 3;       -- Wait for 10 ns
        
        -- Fourth input
        data <= "00001000";   -- Another test case -- expected 00001111
        wait for clk_period * 3;       -- Wait for 10 ns

        -- End the simulation
        assert false report "End of simulation" severity failure;
        wait;
    end process;

end behavior;
