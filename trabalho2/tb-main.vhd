library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Testbench entity
entity tb_main is
end tb_main;

architecture behavior of tb_main is

    -- Component declaration for the unit under test (UUT)
    component chiper
        Port (
            bit_in : in std_logic;
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            bit_out : out std_logic
        );
    end component;


    -- Signals to connect to the UUT
    signal bit_in          : std_logic := '0';
    signal rst             : std_logic := '0';
    signal en_encripter    : std_logic := '0';
    signal en_decripter     : std_logic := '0';
    signal clk             : std_logic := '0';
    signal bit_encripted        : std_logic;
    signal bit_out         : std_logic;

    constant clk_period : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT)
    encripter: chiper port map (
        rst => rst,
        en => en_encripter,
        clk => clk,
        bit_in => bit_in,
        bit_out => bit_encripted
    );


    decripter: chiper port map (
        rst => rst,
        en => en_decripter,
        clk => clk,
        bit_in => bit_encripted,
        bit_out => bit_out
    );



    -- Clock generation
    clk_process: process
    begin
       while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus process to drive the inputs and generate a clock
    stim_proc: process
    begin

        rst <= '1';
        wait for clk_period;
        rst <= '0';
        en_encripter <= '1';
        wait for clk_period;
        en_decripter <= '1';
        

        bit_in <= '1'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;

        

        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;

        

        bit_in <= '1'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;
        bit_in <= '0'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;

        

        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        bit_in <= '1'; wait for clk_period;
        

        -- End the simulation
        assert false report "End of simulation" severity failure;
        wait;
    end process;

end behavior;
