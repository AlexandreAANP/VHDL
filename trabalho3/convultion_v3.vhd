library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity convultion_v3 is
    Port ( 
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        convultion_result: out signed(31 downto 0)
    );
end convultion_v3;

architecture Behavioral of convultion_v3 is
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

    signal cls_file: std_logic := '0';

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
            cls_file: in std_logic;
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
        cls_file => cls_file,
        enable => write_file_enable,
        data => ram_data_out
    );


    convultion_process: process(clk, rst)
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
                calc_convultion <= to_signed(0,32);
                for i in 0 to 50 loop
                    calc_convultion <= calc_convultion + (filter_data(i) * signal_sample(i));
                end loop;
                --save value in memory
                ram_write_mode <= '1';
                ram_addr <= to_unsigned(index, 10);
                ram_data_in <= calc_convultion; --resize(shift_right(calc_convultion, 15), 16);
                --resize(shift_right(acc, 15), 16);
                convultion_result <= calc_convultion;
                
                index <= index + 1;
                
                signal_addr <= to_unsigned((50 + index), 10);
                signal_sample <= signal_sample(0 to 49) & signal_output;
                
                if index = 949 then
                    state <= DONE;
                    index <= 0;
                end if;
            end if;
        
        elsif state = DONE then
            if rising_edge(clk) then
                ram_write_mode <= '0'; --reading mode
                write_file_enable <= '1';
                ram_addr <= to_unsigned(index, 10);
                index <= index + 1;
                if index = 950 then
                    cls_file <= '1';
                    assert false report "End of simulation" severity failure;
                end if;

            end if;
        end if;
        
    end process;

   

end Behavioral;