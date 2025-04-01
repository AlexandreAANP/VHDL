library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filter_tb is
end filter_tb;

architecture Behavioral of filter_tb is

    -- Component declaration
    component filter
        Port ( 
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            filter_bytes_out: out signed(15 downto 0);
            signal_bytes_out: out signed(15 downto 0);
            filter_addr_out: out unsigned(5 downto 0);
            signal_addr_out: out unsigned(9 downto 0);
            filter_out : out signed(31 downto 0)
        );
    end component;

    -- Testbench signals
    signal clk_tb   : std_logic := '0';
    signal rst_tb   : std_logic := '1';
    signal en_tb    : std_logic := '0';
    signal filter_bytes_out_tb : signed(15 downto 0);
    signal signal_bytes_out_tb : signed(15 downto 0);
    signal filter_addr_out_tb : unsigned(5 downto 0);
    signal signal_addr_out_tb : unsigned(9 downto 0);
    signal filter_out_tb : signed(31 downto 0);

    -- Clock process: Generates a clock with 10ns period (50MHz)
    constant CLK_PERIOD : time := 10 ns;
    
begin

    -- Instantiate the filter module
    uut: filter port map (
        clk => clk_tb,
        rst => rst_tb,
        en  => en_tb,
        filter_bytes_out => filter_bytes_out_tb,
        signal_bytes_out => signal_bytes_out_tb,
        filter_addr_out => filter_addr_out_tb,
        signal_addr_out => signal_addr_out_tb,
        filter_out => filter_out_tb
    );

    -- Clock Generation
    clk_process : process
    begin
        while now < 2000 ns loop  -- Run for a reasonable simulation time
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Apply Reset
        rst_tb <= '1';
        wait for 20 ns;
        rst_tb <= '0';
        
        -- Enable the filter after reset
        wait for 10 ns;
        en_tb <= '1';

        -- Let the filter process for some time
        wait for 1000 ns;

        -- Disable the filter
        -- en_tb <= '0';
        -- wait for 200 ns;

        -- End the simulation
        assert false report "Simulation Complete" severity failure;
        wait;
    end process;

end Behavioral;
