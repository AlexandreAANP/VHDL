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
    signal rx : std_logic := '1';
    signal data_in : std_logic_vector(0 to data_width_const - 1);
    signal is_busy : std_logic;
    signal data_invalid : std_logic;
    signal tx : std_logic;
    signal data_out : std_logic_vector(0 to data_width_const - 1);
    signal start : std_logic := '0'; -- start signal
    
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
    uut: uart port map (
        clk => clk,
        rst => rst,
        en => en,
        rx => rx,
        start => start, -- Start signal is not used in this testbench
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
        -- initialize values
        data_in <= (others => '0');

        -- Reset sequence
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;
        
        -- Start receiving data
        start <= '1'; -- Start signal
        rx <= '0'; -- Start bit
        wait for clk_period;
        start <= '0'; -- Reset start signal
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

        start <= '1'; -- Start signal
        rx <= '0'; -- Start bit
        wait for clk_period;
        start <= '0'; -- Reset start signal

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

        -- send paralel data
        start <= '1'; -- Start signal
        data_in <= "11100101"; wait for clk_period;
        start <= '0'; -- Reset start signal
        wait for 100 ns;
        start <= '1'; -- Start signal
        data_in <= "10101010"; wait for clk_period;
        start <= '0'; -- Reset start signal

        wait for 100 ns;
        start <= '1'; -- Start signal
        data_in <= "11101010"; wait for clk_period;
        start <= '0'; -- Reset start signal
        wait for 400 ns;
        assert false report "End of simulation" severity failure;
        -- End of simulation
        wait;
    end process;
end testbench;
