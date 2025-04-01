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
            en : in std_logic
        );
    end component;

    -- Testbench signals
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    signal en_tb : std_logic := '0';
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the DUT
    uut: filter_component
        port map (
            clk => clk_tb,
            rst => rst_tb,
            en => en_tb
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
        en_tb <= '0';
        rst_tb <= '1';
        wait for 20 ns;
        rst_tb <= '0';
        en_tb <= '1';
        wait; -- Wait for some time to observe the output


        -- End simulation
    end process;

end Behavioral;
