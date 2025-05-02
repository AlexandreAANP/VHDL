library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_main is
end tb_main;

architecture testbench of tb_main is
    constant clk_period : time := 10 ns;

    -- CONSTANTS
    -- You can change these constants to have the desired behavior for data bigger or smaller
    -- make sure if you change filter or noisy filter sizes, change also the rom components
    constant FILTER_SIZE : integer := 51;
    constant FILTER_ADDR_SIZE : integer := 6;
    constant NOISY_SIGNAL_SIZE : integer := 1000;
    constant NOISY_SIGNAL_ADDR_SIZE : integer := 10;
    constant UART_DATA_SIZE : integer := 8;
    constant DATA_SIZE : integer := 16;  

    -- CONTROL SIGNALS
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal en : std_logic := '0';
    signal encripted_rx_data : std_logic;

    component controller1
        Generic (
            gen_rom_size : integer := NOISY_SIGNAL_SIZE;
            gen_rom_addr_size : integer := NOISY_SIGNAL_ADDR_SIZE; 
            gen_rom_data_size : integer := DATA_SIZE; 
            gen_uart_data_size : integer := UART_DATA_SIZE -- number of bits of uart in
        );
        Port (
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            tx : out std_logic
        );
    end component;

    component controller2
        Generic (
            gen_filter_size : integer := FILTER_SIZE;
            gen_rom_addr_size : integer := FILTER_ADDR_SIZE;
            gen_rom_data_size : integer := DATA_SIZE;
            gen_uart_data_size : integer := UART_DATA_SIZE;
            gen_noisy_signal_size : integer := NOISY_SIGNAL_SIZE
        );
        Port (
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            rx : in std_logic
        );
    end component;
    
begin
    -- Instantiate the UART module
    uui_controller1: controller1 port map (
        clk => clk,
        rst => rst,
        en => en,
        tx => encripted_rx_data
    );

    uui_controller2: controller2 port map(
        clk => clk,
        rst => rst,
        en => en,
        rx => encripted_rx_data

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
        assert false report "End of simulation" severity failure;
    end process;
    
    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset sequence
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        en <= '1';

        -- End of simulation
        wait;
    end process;
end testbench;
