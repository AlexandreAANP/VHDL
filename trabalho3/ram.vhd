library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram is
    Port ( 
        clk: in std_logic;
        write_mode: in std_logic;
        addr: in unsigned(9 downto 0);
        data_in: in signed(31 downto 0);
        data_out: out signed(31 downto 0)
    );
end ram;

architecture Behavioral of ram is
    type ram_type is array (0 to 949) of signed(31 downto 0);
    signal ram_data : ram_type := (others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if write_mode = '1' then
                ram_data(to_integer(addr)) <= data_in;
            else
                data_out <= ram_data(to_integer(addr));
            end if;
        end if;
    end process;

end Behavioral;