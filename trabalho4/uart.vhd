library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart is
    Port (
        clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        rx : in std_logic;   --reception
        data_in : in std_logic;
        is_busy: out std_logic := '0';
        data_invalid: out std_logic := '0';
        tx : out std_logic; --transmission
        data_out : out std_logic
    );
end uart;


architecture Behavioral of uart is
    constant data_width : integer := 8; 
    type uart_state is (INIT, BUSY, SEND);
    
    signal state : uart_state := INIT;

    signal tx_data : std_logic_vector(data_width - 1 downto 0) := (others => '0');
    signal rx_data : std_logic_vector(0 to data_width - 1) := (others => '0');

begin

    state_machine: process(clk)
    variable parity : std_logic := '0';
    variable index : integer := 0;
    begin
        if rising_edge(clk) then
            case state is
                when INIT =>
                    data_invalid <= '0';
                    rx_data <= (others => '0');
                    index := 0;
                    if rx = '0' then
                        state <= BUSY;
                    end if;

                when BUSY =>
                    rx_data(index) <= rx;
                    index := index + 1;
                    
                    if index = data_width then
                        state <= SEND;
                    end if;

                when SEND =>
                    parity := rx_data(0);
                    for i in 1 to data_width-1 loop
                        parity := parity xor rx_data(i);
                    end loop;
                    data_invalid <= parity xor rx;
                    state <= INIT;

                when others =>
                    state <= INIT;
            end case;
        end if;
    end process;


end Behavioral;
