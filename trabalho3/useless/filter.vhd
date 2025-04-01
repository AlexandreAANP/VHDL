library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filter is
end filter;

architecture Behavioral of filter is
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal en: std_logic := '0';
    signal index: unsigned(5 downto 0) := (others => '0');
    signal size: unsigned(5 downto 0) := (others => '0');
    signal convultion_result: signed(31 downto 0);
    signal convultion_sum: signed(31 downto 0) := (others => '0');
    signal done: std_logic := '0';
    signal signal_i : integer := 0;
    constant clk_period: time := 10 ns;
    
    component convultion2
        Port (
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            index: in unsigned(5 downto 0);
            size: in unsigned(5 downto 0);
            convultion_result: out signed(31 downto 0);
            done: out std_logic
        );
    end component;
    
begin
    
    uut: convultion2 port map (
        clk => clk,
        rst => rst,
        en => en,
        index => index,
        size => size,
        convultion_result => convultion_result,
        done => done
    );
    
    -- Clock process
    clk_process: process
    begin
        while now < 10000 ns loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        assert false report "End of simulation" severity failure;
    end process;

    -- Stimulus process
    stim_proc: process
    -- variable sum_convultion : signed(31 downto 0) := to_signed(0,32);
    begin
        index <= to_unsigned(signal_i, 6);
        size <= to_unsigned(50, 6);
        wait until done = '1';
        convultion_sum <= convultion_sum + convultion_result;
        signal_i <= signal_i + 1;
 
    end process;

    -- signal_i <= signal_i + 1 when done = '1' and i < 53 else 0;

    
    rst <= '1' when done = '1' else '0';
    
end Behavioral;
