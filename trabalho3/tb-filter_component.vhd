library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filter_component_tb is
end filter_component_tb;

architecture Behavioral of filter_component_tb is

    -- Component declaration for the DUT
    component filter_component
        Port (
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            convultion_result : out signed(31 downto 0)
        );
    end component;

    -- Testbench signals
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    signal en_tb : std_logic := '0';
    signal conv_result_tb : signed(31 downto 0);
    signal done_tb : std_logic := '0';
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the DUT
    uut: filter_component
        port map (
            clk => clk_tb,
            rst => rst_tb,
            en => en_tb,
            convultion_result => conv_result_tb
        );



    -- Clock process
    clk_process: process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Apply reset
        rst_tb <= '1';
        wait for 20 ns;
        rst_tb <= '0';





        -- Enable the convolution process
        -- en_tb <= '1';
   

        -- -- Disable convolution
        -- en_tb <= '0';
        wait for 100000 ns;
        assert false report "End of simulation" severity failure;
        -- End simulation
    end process;

end Behavioral;
