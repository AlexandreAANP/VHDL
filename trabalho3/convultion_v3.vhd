library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity convultion_v3 is
    Port ( 
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        convultion_result: out signed(47 downto 0)
    );
end convultion_v3;

architecture Behavioral of convultion_v3 is
    type state_type is (INIT, CALC, DONE);
    signal state : state_type := INIT;
    signal filter_addr : unsigned(5 downto 0) := (others => '0');
    signal filter_output : signed(15 downto 0):= (others => '0');
    signal signal_addr : unsigned(9 downto 0) := (others => '0');
    signal signal_output : signed(15 downto 0):= (others => '0');
    -- signal filter_index: unsigned(5 downto 0) := (others => '0');
    -- signal signal_index: unsigned(5 downto 0) := (others => '0');
    type sample_array is array (0 to 50) of signed(15 downto 0);
    signal filter_data : sample_array := (others => to_signed(0,16));
    signal signal_sample : sample_array := (others =>  to_signed(0,16));
    signal index : integer := 0;

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


    convultion_process: process(clk, rst)
    variable calc_convultion : signed(47 downto 0) := to_signed(0,48);
    begin     
        if rst = '1' then
            calc_convultion := to_signed(0,48);
            state <= INIT;
        elsif state = INIT then
            if rising_edge(clk) then
                filter_data(0) <= filter_output;
                signal_sample(0) <= signal_output;
                filter_addr <= filter_addr + 1;
                signal_addr <= signal_addr + 1;
                if filter_addr < 50 then
                    state <= CALC;
                end if;
            end if;
        elsif state = CALC then

            if rising_edge(clk) then
                for i in 0 to 49 loop
                    calc_convultion := calc_convultion + (filter_data(i) * signal_sample(i));
                end loop;
                --save value in memory
                convultion_result <= calc_convultion;
                index <= index + 1;

                signal_addr <= to_unsigned((50 + index), 10);
                signal_sample <= signal_sample(0 to 49) & signal_output;
                
                if index = 949 then
                    state <= DONE;
                end if;
            end if;
        elsif state = DONE then
            assert false report "End of simulation" severity failure;
        end if;
        
    end process;

   

end Behavioral;