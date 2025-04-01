library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filter_component is
    Port ( 
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic
    );
end filter_component;

architecture Behavioral of filter_component is
    -- states: 
    -- INIT: Initialize the filter and signal data
    -- CALC: Perform the convolution calculation and write the result in the file
    type state_type is (INIT, CALC);
    signal state : state_type := INIT;

    constant filter_size : integer := 50;
    constant signal_size : integer := 1000;
    constant filter_addr_size : integer := 6;
    constant signal_addr_size : integer := 10;
    constant data_size : integer := 16;

    signal filter_addr : unsigned(filter_addr_size - 1 downto 0) := (others => '0');
    signal filter_output : signed(data_size - 1 downto 0):= (others => '0');
    signal signal_addr : unsigned(signal_addr_size - 1 downto 0) := (others => '0');
    signal signal_output : signed(data_size - 1 downto 0):= (others => '0');

    type sample_array is array (0 to filter_size) of signed(data_size - 1 downto 0);
    signal filter_data : sample_array := (others => to_signed(0,data_size));
    signal signal_sample : sample_array := (others =>  to_signed(0,data_size));

    signal index : integer := 0;
    signal calc_convultion : signed((data_size * 2) - 1 downto 0) := (others => '0');

    signal write_file_enable: std_logic := '0';

    component filter_rom is
        Port (
            addr : in unsigned(filter_addr_size - 1 downto 0);
            data_out : out signed(data_size - 1 downto 0)
        );
    end component;

    component noisy_signal is
        Port (
            addr : in unsigned(signal_addr_size - 1 downto 0);
            data_out : out signed(data_size - 1 downto 0)
        );
    end component;
    
    component write_file is
        generic (
            DATA_LENGTH : integer
        );
        Port (
            clk: in std_logic;
            enable: in std_logic;
            data: in signed(DATA_LENGTH - 1 downto 0)
        );
    end component;

begin

    -- Instantiate ROM components
    uui_filter_rom : filter_rom port map (
        addr => filter_addr,
        data_out => filter_output
    );

    uui_signal_rom : noisy_signal port map (
        addr => signal_addr,
        data_out => signal_output
    );

    uut_write_file: write_file 
    generic map (
        DATA_LENGTH => data_size * 2
    )
    port map (
        clk => clk,
        enable => write_file_enable,
        data => calc_convultion
    );


    convultion_process: process(clk, rst, en)
    variable acc : signed((data_size * 2) - 1 downto 0) := (others => '0');
    begin     
        if rst = '1' then
            calc_convultion <= to_signed(0,(data_size * 2));
            state <= INIT;
            index <= 0;
        elsif en = '1' then
            if state = INIT then
                filter_data(to_integer(filter_addr)) <= filter_output;
                signal_sample(to_integer(filter_addr)) <= signal_output;
                if rising_edge(clk) then
                    if filter_addr = filter_size then
                        state <= CALC;
                    else 
                        filter_addr <= filter_addr + 1;
                        signal_addr <= signal_addr + 1;
                    end if;
                end if;
                
            elsif state = CALC then
                if rising_edge(clk) then

                    if index = signal_size - filter_size then
                        write_file_enable <= '0';
                        assert false report "End of simulation" severity failure;
                    end if;

                    acc := (others => '0');
                    for i in 0 to filter_size loop
                        acc := acc + (filter_data(i) * signal_sample(i));
                    end loop;
                    
                    -- write in file
                    write_file_enable <= '1';
                    calc_convultion <= acc;

                    index <= index + 1;
                    
                    -- shift the signal sample
                    signal_addr <= to_unsigned((filter_size + index), 10);
                    signal_sample <= signal_sample(1 to filter_size) & signal_output;
                    
                end if;
            end if;
        end if;
        
    end process;

   

end Behavioral;