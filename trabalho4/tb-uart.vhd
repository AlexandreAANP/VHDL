library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tb is
end uart_tb;

architecture testbench of uart_tb is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal en : std_logic := '0';
    signal rx : std_logic := '1';
    signal data_in : std_logic := '0';
    signal is_busy : std_logic;
    signal data_invalid : std_logic;
    signal tx : std_logic;
    signal data_out : std_logic;
    
    constant clk_period : time := 10 ns;
    
    component uart
        Port (
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            rx : in std_logic;
            data_in : in std_logic;
            is_busy: out std_logic;
            data_invalid: out std_logic;
            tx : out std_logic;
            data_out : out std_logic
        );
    end component;
    
begin
    -- Instantiate the UART module
    uut: uart port map (
        clk => clk,
        rst => rst,
        en => en,
        rx => rx,
        data_in => data_in,
        is_busy => is_busy,
        data_invalid => data_invalid,
        tx => tx,
        data_out => data_out
    );
    
    -- Clock process
    clk_process: process
    begin
        while now < 1000 ns loop  -- Run simulation for a defined time
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;
    
    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset sequence
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;
        
        -- Start receiving data
        rx <= '0'; -- Start bit
        wait for clk_period;
        
        -- Send data bits (example: 8-bit 10101010)
        rx <= '1'; wait for clk_period;  -- Bit 0
        rx <= '0'; wait for clk_period;  -- Bit 1
        rx <= '1'; wait for clk_period;  -- Bit 2
        rx <= '0'; wait for clk_period;  -- Bit 3
        rx <= '1'; wait for clk_period;  -- Bit 4
        rx <= '0'; wait for clk_period;  -- Bit 5
        rx <= '1'; wait for clk_period;  -- Bit 6
        rx <= '0'; wait for clk_period;  -- Bit 7
        rx <= '1'; wait for clk_period;  -- parity it
        
        rx <= '1'; -- Stop bit
        wait for 5*clk_period;


        rx <= '0'; -- Start bit
        wait for clk_period;
        
        -- Send data bits (example: 8-bit 10101010)
        rx <= '1'; wait for clk_period;  -- Bit 0
        rx <= '0'; wait for clk_period;  -- Bit 1
        rx <= '1'; wait for clk_period;  -- Bit 2
        rx <= '0'; wait for clk_period;  -- Bit 3
        rx <= '1'; wait for clk_period;  -- Bit 4
        rx <= '0'; wait for clk_period;  -- Bit 5
        rx <= '1'; wait for clk_period;  -- Bit 6
        rx <= '0'; wait for clk_period;  -- Bit 7
        rx <= '0'; wait for clk_period;  -- parity it
        
        rx <= '1'; -- Stop bit
        
        -- Wait and observe output
        wait for 100 ns;
        assert false report "End of simulation" severity failure;
        -- End of simulation
        wait;
    end process;
end testbench;
