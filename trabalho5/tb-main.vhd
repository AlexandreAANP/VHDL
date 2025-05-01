library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_main is
end tb_main;

architecture testbench of tb_main is
    constant data_width_const : integer := 8;
    constant clk_period : time := 10 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal en : std_logic := '0';
    signal tx : std_logic;

    signal uart_in_data : std_logic_vector(data_width_const - 1 downto 0);
    signal uart_busy : std_logic;
    signal uart_invalid :std_logic;
    signal start_uart : std_logic;
    signal uart_rx : std_logic;
    signal uart_tx : std_logic;
    signal uart_receiving_in_serial: std_logic := '1'; --the uart will always receive in parell
    
    signal encripted_rx_data : std_logic;
    component controller1
        Port (
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            -- rx : in std_logic;
            tx : out std_logic;
            start_uart: out std_logic
        );
    end component;

    component controller2
        Port (
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            rx : in std_logic;
            start_uart: in std_logic
        );
    end component;
    
begin
    -- Instantiate the UART module
    uui_controller1: controller1 port map (
        clk => clk,
        rst => rst,
        en => en,
        tx => encripted_rx_data,
        start_uart => start_uart
    );

    uui_controller2: controller2 port map(
        clk => clk,
        rst => rst,
        en => en,
        start_uart => start_uart,
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
        -- assert false report "End of simulation" severity failure;
        -- End of simulation
        wait;
    end process;
end testbench;
