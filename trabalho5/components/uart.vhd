library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart is
    Generic (
        data_width : integer := 8
    );
    Port (
        clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        start: in std_logic := '0'; -- start signal
        receiving_in_serial: in std_logic;
        rx : in std_logic;   --reception
        data_in : in std_logic_vector(data_width - 1  downto 0) := (others => '0');
        is_busy: out std_logic := '0';
        data_invalid: out std_logic := '0';
        tx : out std_logic := '0'; --transmission
        data_out : out std_logic_vector(data_width - 1  downto 0 ) := (others => '0')
    );
end uart;


architecture Behavioral of uart is
    type uart_state is (INIT, BUSY, CALC_PARITY);
    
    signal state : uart_state := INIT;

    signal tx_data : std_logic_vector(data_width - 1  downto 0) := (others => 'U');
    signal rx_data : std_logic_vector(data_width - 1  downto 0) := (others => 'U');

begin

    state_machine: process(clk)
    variable parity : std_logic := '0';
    variable index : integer := 0;
    begin
        if rising_edge(clk) then
            case state is
                when INIT =>
                    data_invalid <= '0';
                    tx <= '1';
                    rx_data <= (others => 'U');
                    tx_data <= (others => 'U');
                    data_out <= (others => 'U');
                    index := 0;
                    if start = '1' then
                        
                        if receiving_in_serial = '1' then
                            if rx = '0' then
                                state <= BUSY;
                            end if;
                        else
                            state <= BUSY;
                            tx <= '0'; -- send the bit to start comunicate
                            tx_data <= data_in; -- save data_in in tx_data 
                        end if;

                    end if;

                when BUSY =>
                    if receiving_in_serial = '1' then
                        rx_data(index) <= rx;
                        index := index + 1;

                        if index = data_width then
                            state <= CALC_PARITY;
                        end if;
                     
                    else
                        tx <= tx_data(index);
                        index := index + 1;

                        if index = data_width then
                            state <= CALC_PARITY;
                        end if;

                    end if;

                when CALC_PARITY =>

                    if receiving_in_serial = '1' then

                        parity := rx_data(0);
                        for i in 1 to data_width-1 loop
                            parity := parity xor rx_data(i);
                        end loop;
                        data_invalid <= parity xor rx; -- rx it's parity bit
                        
                        data_out <= rx_data;
                    
                    else
                       -- create parity bit
                       parity := tx_data(0);
                       for i in 1 to data_width - 1 loop
                           parity := parity xor tx_data(i);
                       end loop;
                       
                       tx <= parity;
                    
                    end if;
                    

                    state <= INIT;

                when others =>
                    state <= INIT;
            end case;
        end if;
    end process;

    is_busy <= '1' when state = BUSY else '0';

end Behavioral;
