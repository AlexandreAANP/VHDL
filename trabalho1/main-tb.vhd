library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_seq_detector is
end tb_seq_detector;

architecture behavior of tb_seq_detector is
    component seq_detector
        Port (
            clk : in std_logic;
            rst : in std_logic;
            x   : in std_logic;
            z   : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal x   : std_logic := '0';
    signal z   : std_logic;

    constant clk_period : time := 10 ns;

begin   
   uut: seq_detector port map(
        clk => clk,
        rst => rst,
        x  => x,
        z => z
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


    -- Stimuls process:
    stim_proc: process
    begin
        -- Global rst
        rst <= '1';
        x   <= '0';
        wait for 20 ns;
        rst <= '0';
        wait for clk_period;

        -- Test Case 1: "10010100101" -> expect 2 detections
        x <= '1'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '1'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '1'; wait for clk_period; -- detection 1.
        x <= '0'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '1'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '1'; wait for clk_period; -- detection 2.


        wait for clk_period * 3;

        -- Test Case 2: "100100101" -> one detection
        rst <= '1'; wait for clk_period; -- Reset
        rst <= '0'; wait for clk_period;

        x <= '1'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '1'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '1'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '1'; wait for clk_period; -- detection 1.


        wait for clk_period * 3;

        -- Test Case 3: "10010" -> no detection
        rst <= '1'; wait for clk_period; -- Reset
        rst <= '0'; wait for clk_period;

        x <= '1'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '0'; wait for clk_period;
        x <= '1'; wait for clk_period;
        x <= '0'; wait for clk_period;

        wait for clk_period * 3;   

        assert false report "End of simulation" severity failure;
        wait;

    end process;

end behavior;