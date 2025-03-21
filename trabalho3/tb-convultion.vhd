library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity convultion_tb is
end convultion_tb;

architecture testbench of convultion_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal en: std_logic := '0';
    signal index: unsigned(5 downto 0) := (others => '0');
    signal size: unsigned(5 downto 0) := (others => '0');
    signal convultion_result: signed(31 downto 0);
    signal done: std_logic := '0';
    constant clk_period: time := 10 ns;
    
    component convultion
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
    
    uut: convultion port map (
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
        while now < 2000 ns loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        assert false report "End of simulation" severity failure;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        
        en <= '1';
        index <= to_unsigned(1, 6);
        size <= to_unsigned(50, 6);
        wait until done = '1';
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
              
        
        index <= to_unsigned(2, 6);
        size <= to_unsigned(50, 6);
        wait until done = '1';
        wait for 50 ns;
        assert false report "End of simulation" severity failure;
        wait;
    end process;
    
end testbench;
