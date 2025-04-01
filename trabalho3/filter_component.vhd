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
    -- CALC: Perform the convolution calculation and right each result in RAM
    type state_type is (INIT, CALC, DONE);
    signal state : state_type := INIT;
    signal filter_addr : unsigned(5 downto 0) := (others => '0');
    signal filter_output : signed(15 downto 0):= (others => '0');
    signal signal_addr : unsigned(9 downto 0) := (others => '0');
    signal signal_output : signed(15 downto 0):= (others => '0');
    type sample_array is array (0 to 50) of signed(15 downto 0);
    signal filter_data : sample_array := (others => to_signed(0,16));
    signal signal_sample : sample_array := (others =>  to_signed(0,16));
    signal index : integer := 0;
    signal calc_convultion : signed(31 downto 0) := (others => '0');


    signal ram_write_mode : std_logic := '1';
    signal ram_addr : unsigned(9 downto 0) := (others => '0');
    signal ram_data_in : signed(31 downto 0) := (others => '0');
    signal ram_data_out : signed(31 downto 0) := (others => '0');

    signal write_file_enable: std_logic := '0';

    component filter_rom is
        Port (
            addr : in unsigned(5 downto 0);
            data_out : out signed(15 downto 0)
        );
    end component;

    component noisy_signal is
        Port (
            addr : in unsigned(9 downto 0);
            data_out : out signed(15 downto 0)
        );
    end component;

    component ram is
        Port (
            clk: in std_logic;
            write_mode: in std_logic;
            addr: in unsigned(9 downto 0);
            data_in: in signed(31 downto 0);
            data_out: out signed(31 downto 0)
        );
    end component;

    component write_file is
        Port (
            clk: in std_logic;
            enable: in std_logic;
            data: in signed(31 downto 0)
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

    uui_ram : ram port map (
        clk => clk,
        write_mode => ram_write_mode,
        addr => ram_addr,
        data_in => ram_data_in,
        data_out => ram_data_out
    );

    uut_write_file: write_file port map (
        clk => clk,
        enable => write_file_enable,
        data => ram_data_out
    );


    convultion_process: process(clk, rst)
    variable acc : signed(31 downto 0) := (others => '0');
    begin     
        if rst = '1' then
            calc_convultion <= to_signed(0,32);
            state <= INIT;
        elsif state = INIT then
            filter_data(to_integer(filter_addr)) <= filter_output;
            signal_sample(to_integer(filter_addr)) <= signal_output;
            if rising_edge(clk) then
                if filter_addr = 50 then
                    state <= CALC;
                else 
                filter_addr <= filter_addr + 1;
                signal_addr <= signal_addr + 1;
                end if;
            end if;
            
        elsif state = CALC then
            if rising_edge(clk) then
                if index = 949 then
                    index <= -1; -- Reset index after reaching 949
                    ram_write_mode <= '0'; -- Switch to reading mode
                    ram_addr <= to_unsigned(0, 10);
                    state <= DONE;
                else
                    acc := (others => '0');
                    for i in 0 to 50 loop
                        acc := acc + (filter_data(i) * signal_sample(i));
                    end loop;
                    
                    --save value in memory
                    ram_write_mode <= '1';
                    ram_addr <= to_unsigned(index, 10);
                    ram_data_in <= acc;

                    index <= index + 1;
                    
                    signal_addr <= to_unsigned((50 + index), 10);
                    signal_sample <= signal_sample(1 to 50) & signal_output;

                end if;
                
            end if;
        
        elsif state = DONE then
            
            if rising_edge(clk) then
                
                ram_addr <= to_unsigned(index + 1, 10);
                write_file_enable <= '1';

                if index = 949 then  -- Stop at 949 instead of 950
                    write_file_enable <= '0';
                    assert false report "End of simulation" severity failure;
                else
                    index <= index + 1; -- Move this inside the else block
                end if;

                
                
            end if;
        end if;
        
    end process;

   

end Behavioral;