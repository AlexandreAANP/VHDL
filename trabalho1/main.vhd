library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seq_detector is
    Port (
        clk : in std_logic;
        rst : in std_logic;
        x   : in std_logic;
        z   : out std_logic
    );
end seq_detector;

architecture Behavioral of seq_detector is
    type state_type is (s0, s1, s2, s3, s4, s5, s6);
    signal state: state_type;
begin   
    process(clk, rst)
    begin
        if rst = '1' then
            state <= s0;
        elsif rising_edge(clk) then
            case state is
                when s0 =>
                    if x = '1' then
                        state <= s1;
                    else
                        state <= s0;
                    end if;
                when s1 =>
                    if x = '0' then
                        state <= s2;
                    else
                        state <= s1;
                    end if;
                when s2 =>
                    if x = '0' then
                        state <= s3;
                    else
                        state <= s0;
                    end if;
                when s3 =>
                    if x = '1' then
                        state <= s4;
                    else
                        state <= s1;
                    end if;
                when s4 =>
                    if x = '0' then
                        state <= s5;
                    else
                        state <= s0;
                    end if;
                when s5 =>
                    if x = '1' then
                        state <= s6;
                    else
                        state <= s1;
                    end if;
                when s6 =>
                    if x = '0' then
                        state <= s2;
                    else
                        state <= s1;
                    end if;
                when others =>
                    state <= s0;
            end case;
        end if;
    end process;

    -- Moore output: depends only on the state
    z <= '1' when state = s6 else '0';
end Behavioral;