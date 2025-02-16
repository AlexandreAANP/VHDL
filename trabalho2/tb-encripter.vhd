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
            clk : in std_logic;
            rst : in std_logic;
            encripted_data : out std_logic_vector(7 downto 0)
        );
    end component;


    -- Signals to connect to the UUT
    signal data          : std_logic_vector(7 downto 0); -- Example input
    signal clk           : std_logic := '0';
    signal rst           : std_logic := '0';
    signal encripted_data : std_logic_vector(7 downto 0);


    constant clk_period : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: encripter port map (
        data => data,
        clk => clk,
        rst => rst,
        encripted_data => encripted_data
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


        clk <= '0';
        rst <= '1';
        wait for clk_period;

        rst <= '0';
        wait for clk_period *3;

        -- Apply some test vectors
        -- First input
        data <= "11010101";   -- Example data
        wait for clk_period * 3;       -- Wait for 10 ns
        
        -- Second input
        data <= "10101010";   -- Another test case
        wait for clk_period * 3;       -- Wait for 10 ns
        
        -- Third input
        data <= "11110000";   -- Another test case
        wait for clk_period * 3;       -- Wait for 10 ns
        
        -- Fourth input
        data <= "00001111";   -- Another test case
        wait for clk_period * 3;       -- Wait for 10 ns

        -- End the simulation
        assert false report "End of simulation" severity failure;
        wait;
    end process;

end behavior;
