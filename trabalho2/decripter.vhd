library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity decripter is
    Port ( 
        data : in std_logic_vector(7 downto 0);
        clk: in std_logic;
        rst: in std_logic;
        decripted_data : out std_logic_vector(7 downto 0);
        encrypt: out boolean
    );
end decripter;


architecture Behavioral of decripter is
    signal updated_data : unsigned(7 downto 0);
    signal invalid_data : std_logic_vector(7 downto 0) := (others => '0');
    signal encrypted : boolean := false;
begin
    encript: process (clk, rst)
    variable temp_data : unsigned(7 downto 0);
    variable bit_process : std_logic;
    begin
        if rst = '1' then
            bit_process := '0';
            updated_data <= (others => '0');
            encrypted <= false;

        elsif rising_edge(clk) and encrypted = false then
            temp_data := unsigned(data);

            for i in 0 to 7 loop

                -- xor the first and last element
                bit_process := temp_data(7) xor temp_data(0);

                -- shift to right one
                temp_data := unsigned(temp_data sll 1);

                -- set the first element with the value of bit_process
                temp_data(0) := bit_process;

            end loop;
            decripted_data <= std_logic_vector(temp_data);
            encrypted <= false;
        end if;
        
    end process;
    encrypt <= encrypted;

end Behavioral;