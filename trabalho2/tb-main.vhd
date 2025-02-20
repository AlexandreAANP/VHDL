library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity tb_main is
end tb_main;


architecture behavioral of tb_main is

    component encripter
        Port ( 
            data : in std_logic_vector(7 downto 0);
            clk: in std_logic;
            encripted_data : out std_logic_vector(7 downto 0)
        );
    end component;


    component decripter
        Port ( 
            data : in std_logic_vector(7 downto 0);
            clk: in std_logic;
            decripted_data : out std_logic_vector(7 downto 0)
        );
    end component;


    -- Signals to connect to the UUT
    signal data          : std_logic_vector(7 downto 0); -- Example input
    signal clk           : std_logic := '0';
    signal encripted_data : std_logic_vector(7 downto 0);
    signal decrepted_data : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT) encripter
    uut: encripter port map (
        data => data,
        clk => clk,
        encripted_data => encripted_data
    );

    -- Instantiate the Unit Under Test (UUT) decripter
    uut2: decripter port map (
        data => encripted_data,
        clk => clk,
        decripted_data => decrepted_data
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
        -- First input expected 00111111 in encripted_data signal
        data <= "11010101";   -- Example data
        wait for clk_period * 3;       -- Wait for 10 ns
        
        -- Second input expected 01111111 in encripted_data signal
        data <= "10101010";   -- Another test case
        wait for clk_period * 3;       -- Wait for 10 ns
        
        -- Third input expected 10001000 in encripted_data signal
        data <= "11110000";   -- Another test case
        wait for clk_period * 3;       -- Wait for 10 ns
        
        -- Fourth input expected 00001000 in encripted_data signal
        data <= "00001111";   -- Another test case
        wait for clk_period * 3;       -- Wait for 10 ns

        assert false report "End of simulation" severity failure;
        wait;

    end process;

end behavioral;