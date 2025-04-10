library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity lfsr is
    Port ( 
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        seed : in std_logic_vector(7 downto 0);
        out_bit : out std_logic
    );
end lfsr;


architecture Behavioral of lfsr is
    signal state : std_logic_vector(7 downto 0);
    signal fb : std_logic := '0';
begin
    process(clk, rst, en)
    begin
        if rst = '1' then
            state <= seed;
            fb <= '0';
        elsif rising_edge(clk) then
            if en = '1' then
                fb <= state(7) xor state(5) xor state(4) xor state(3);
                state <= state(6 downto 0) & fb; --shift left and insert fb at LSB
            end if;
        end if;
    end process;

    out_bit <= state(7);
end Behavioral;