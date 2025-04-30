library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tb is
end uart_tb;

architecture testbench of uart_tb is
    constant data_width_const : integer := 8;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal en : std_logic := '0';
    signal rx_1 : std_logic := '1';
    signal rx_2 : std_logic;
    signal data_in_1 : std_logic_vector(0 to data_width_const - 1);
    signal data_in_2 : std_logic_vector(0 to data_width_const -1);
    signal is_busy_1 : std_logic;
    signal is_busy_2 : std_logic;
    signal data_invalid_1 : std_logic;
    signal data_invalid_2 : std_logic;
    signal tx_1 : std_logic;
    signal tx_2 : std_logic;
    signal data_out_1 : std_logic_vector(0 to data_width_const - 1);
    signal data_out_2 : std_logic_vector(0 to data_width_const - 1);
    signal start_1 : std_logic := '0';
    signal start_2 : std_logic := '0'; 
    
    
    constant clk_period : time := 10 ns;
    
    component uart
        Generic(
            DATA_WIDTH :integer := data_width_const
        );
        Port (
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            rx : in std_logic;
            start: in std_logic := '0'; -- start signal
            data_in : in std_logic_vector(0 to data_width_const - 1);
            is_busy: out std_logic;
            data_invalid: out std_logic;
            tx : out std_logic;
            data_out : out std_logic_vector(0 to data_width_const - 1)
        );
    end component;
    
begin
    -- Instantiate the UART module
    uut_1: uart port map (
        clk => clk,
        rst => rst,
        en => en,
        rx => rx_1,
        start => start_1,
        data_in => data_in_1,
        is_busy => is_busy_1,
        data_invalid => data_invalid_1,
        tx => tx_1,
        data_out => data_out_1
    );

    uut_2: uart port map (
        clk => clk,
        rst => rst,
        en => en,
        rx => tx_1,
        start => start_2,
        data_in => data_out_1,
        is_busy => is_busy_2,
        data_invalid => data_invalid_2,
        tx => tx_2,
        data_out => data_out_2
    );

    
    -- Clock process
    clk_process: process
    begin
        while true loop  -- Run simulation for a defined time
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;
    
    -- Stimulus process
    stimulus_process: process
    begin
        -- initialize values
        data_in_1 <= (others => '0');

        -- Reset sequence
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;
        
        -- Start receiving data
        rx_1 <= '0'; -- Start bit
        wait for clk_period;
        -- Send data bits (example: 8-bit 10101010)
        rx_1 <= '1'; wait for clk_period;  -- Bit 0
        rx_1 <= '0'; wait for clk_period;  -- Bit 1
        rx_1 <= '1'; wait for clk_period;  -- Bit 2
        rx_1 <= '0'; wait for clk_period;  -- Bit 3
        rx_1 <= '1'; wait for clk_period;  -- Bit 4
        rx_1 <= '0'; wait for clk_period;  -- Bit 5
        rx_1 <= '1'; wait for clk_period;  -- Bit 6
        rx_1 <= '0'; wait for clk_period;  -- Bit 7
        rx_1 <= '1'; wait for clk_period;  -- parity it
        
        rx_1 <= '1'; -- Stop bit
        wait for clk_period;

        rx_1 <= '0'; -- Start bit
        wait for clk_period;

        -- Send data bits (example: 8-bit 10101010)
        rx_1 <= '1'; wait for clk_period;  -- Bit 0
        rx_1 <= '0'; wait for clk_period;  -- Bit 1
        rx_1 <= '1'; wait for clk_period;  -- Bit 2
        rx_1 <= '0'; wait for clk_period;  -- Bit 3
        rx_1 <= '1'; wait for clk_period;  -- Bit 4
        rx_1 <= '0'; wait for clk_period;  -- Bit 5
        rx_1 <= '1'; wait for clk_period;  -- Bit 6
        rx_1 <= '0'; wait for clk_period;  -- Bit 7
        rx_1 <= '0'; wait for clk_period;  -- parity it
        
        rx_1 <= '1'; -- Stop bit
        start_2 <= '1';
        wait for clk_period;
        start_2 <= '0';
        
        -- Wait and observe output
        wait for 100 ns;


        wait for 400 ns;
        assert false report "End of simulation" severity failure;
        -- End of simulation
        wait;
    end process;
end testbench;
