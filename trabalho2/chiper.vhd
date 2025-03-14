library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity chiper is
    Port ( 
        bit_in : in std_logic;
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        bit_out : out std_logic
    );
end chiper;


architecture Behavioral of chiper is
    signal key_bit : std_logic;

    component lfsr
        Port (
            rst : in std_logic;
            en : in std_logic;
            clk : in std_logic;
            seed : in std_logic_vector(7 downto 0);
            out_bit : out std_logic
        );
    end component;

    constant seed : std_logic_vector(7 downto 0) := "10101010";
begin
    lsfr_inst: lfsr port map (
        rst => rst,
        en => en,
        clk => clk,
        seed => seed,
        out_bit => key_bit
    );

    process(clk, rst, en, key_bit)
    begin
        if rst = '1' then
            bit_out <= '0';
        elsif rising_edge(clk) then
            if en = '1' then
                bit_out <= bit_in xor key_bit;
            end if;
        end if;
    end process;

end Behavioral;
