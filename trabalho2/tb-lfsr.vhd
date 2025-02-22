library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Testbench entity
entity tb_lfsr is
end tb_lfsr;

architecture behavior of tb_lfsr is

    -- Component declaration for the unit under test (UUT)
    component lfsr
        Port (
            rst : in std_logic;
            en : in std_logic;
            clk : in std_logic;
            seed : in std_logic_vector(7 downto 0);
            out_bit : out std_logic
        );
    end component;


    -- Signals to connect to the UUT
    signal seed          : std_logic_vector(7 downto 0); -- Example input
    signal clk           : std_logic := '0';
    signal en            : std_logic := '1';
    signal rst           : std_logic := '0';
    signal out_bit       : std_logic;


    constant clk_period : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: lfsr port map (
        seed => seed,
        clk => clk,
        en => en,
        rst => rst,
        out_bit => out_bit
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

        rst <= '1';
        en <= '0';
        wait for clk_period;
        rst <= '0';
        en <= '1';
        seed <= "10101010"; -- Example seed 

        wait for clk_period *10;

        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        -- Apply some test vectors
        -- First input
        seed <= "11010101";   -- Example seed
        wait for clk_period * 10;       -- Wait for 10 ns
        
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        -- Second input
        seed <= "10101010";   -- Another test case
        wait for clk_period * 10;       -- Wait for 10 ns
        

        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        -- Third input
        seed <= "11110000";   -- Another test case
        wait for clk_period * 3;       -- Wait for 10 ns
        

        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;
        -- Fourth input
        seed <= "00001111";   -- Another test case
        wait for clk_period * 3;       -- Wait for 10 ns


        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;
        -- End the simulation
        assert false report "End of simulation" severity failure;
        wait;
    end process;

end behavior;
