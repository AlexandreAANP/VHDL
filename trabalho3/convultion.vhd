library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity convultion is
    Port ( 
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        index: in unsigned(5 downto 0);
        size: in unsigned(5 downto 0);
        convultion_result: out signed(31 downto 0);
        done: out std_logic
    );
end convultion;

architecture Behavioral of convultion is

    signal filter_addr : unsigned(5 downto 0) := (others => '0');
    signal filter_output : signed(15 downto 0):= (others => '0');
    signal signal_addr : unsigned(9 downto 0) := (others => '0');
    signal signal_output : signed(15 downto 0):= (others => '0');

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
    filter_data : filter_rom port map (
        addr => filter_addr,
        data_out => filter_output
    );

    signal_data : noisy_signal port map (
        addr => signal_addr,
        data_out => signal_output
    );


    convultion_process: process(clk, rst)
    variable i : integer := 0;
    variable calc_convultion : signed(31 downto 0) := to_signed(0,32);
    begin     
        if rst = '1' then
            i := 0;
            calc_convultion := to_signed(0,32);
            done <= '0';
        elsif rising_edge(clk) then
            if i < 50 then
                filter_addr <= to_unsigned(i, 6);
                signal_addr <= to_unsigned(i, 10);
                calc_convultion := calc_convultion + filter_output * signal_output;
                i:= i + 1;
            else
                convultion_result <= calc_convultion;
                done <= '1';
            end if;
        end if;
        
    end process;

   

end Behavioral;