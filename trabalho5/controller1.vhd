library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller1 is
    Port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        tx: out std_logic
    );
end controller1;

architecture Behavioral of controller1 is
    -- CONSTANTS
    -- You can change this constantes to have the disered behavior for data bigger or smaller
    constant ROM_SIZE :integer := 51; -- how many elements filter rom have
    constant ROM_ADDR_SIZE :integer := 6; -- if you change this you need to change the rom component itself
    constant ROM_DATA_SIZE : integer := 16; -- number of bits of rom output; -- if you change this you need to change the rom component itself
    constant UART_DATA_SIZE : integer := 8; -- number of bits of uart in

    -- POSSIBLE STATES
    type state_type is (INIT, READING, ENCRIPTING, SENDING, DONE);
    signal state : state_type := INIT;
    
    -- READING SIGNALS
    signal rom_addr : unsigned(ROM_ADDR_SIZE - 1 downto 0);
    signal rom_data_out : signed(ROM_DATA_SIZE - 1 downto 0);
    signal rom_data_index : integer := 0;
    signal rom_index : integer := 0;

    -- ENCRITPING SIGNALS
    signal cypher_in : std_logic;
    signal cypher_out : std_logic;
    signal cypher_en : std_logic := '0';
    signal encripted_data : std_logic_vector(UART_DATA_SIZE - 1 downto 0);
    signal encripted_index: integer :=0;

    -- SENDING SIGNALS
    signal uart_in_data : std_logic_vector(UART_DATA_SIZE - 1 downto 0);
    signal uart_busy : std_logic;
    signal uart_invalid :std_logic;
    signal uart_start : std_logic := '0';
    signal uart_rx : std_logic := '1'; -- set '1' for uart doesn't start serial receiving

    component controller1_rom is 
        GENERIC(
            addr_size : integer := ROM_ADDR_SIZE;
            data_size : integer := ROM_DATA_SIZE 
        );
        Port(
            addr : in unsigned(ROM_ADDR_SIZE - 1 downto 0);
            data_out : out signed(ROM_DATA_SIZE-1 downto 0)
        );
    end component;

    component cypher is
        Port(
            bit_in : in std_logic;
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            bit_out : out std_logic
        );
    end component;

    component uart is 
        GENERIC(
            data_width : integer := UART_DATA_SIZE
        );
        Port(
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            start: in std_logic;
            rx : in std_logic;
            data_in : in std_logic_vector(0 to UART_DATA_SIZE - 1);
            is_busy: out std_logic;
            data_invalid: out std_logic;
            tx : out std_logic;
            data_out : out std_logic_vector(0 to UART_DATA_SIZE - 1)
        );
    end component;
begin

    uui_rom: controller1_rom port map (
        addr => rom_addr,
        data_out => rom_data_out
    );

    uui_cypher: cypher port map (
        bit_in => cypher_in,
        clk => clk,
        rst => rst,
        en => cypher_en,
        bit_out => cypher_out
    );

    uui_uart: uart port map (
        clk => clk,
        rst => rst,
        en => en,
        start => uart_start,
        rx => uart_rx,
        data_in => uart_in_data,
        is_busy => uart_busy,
        data_invalid => uart_invalid,
        tx => tx
    );

    controller_process: process(clk)
    begin
        if rst = '1' then
            state <= READING;
            -- reset all indexs
            rom_index <= 0;
            rom_data_index <= 0;
            encripted_index <= 0;
        elsif falling_edge(clk) then
            case state is
                when READING =>
                    if rom_index = ROM_SIZE then
                        state <= DONE;
                    else
                        rom_addr <= to_unsigned(rom_index, rom_addr'length);
                        state <= ENCRIPTING;
                        -- reset indexs
                        rom_data_index <= 0;
                        encripted_index <= 0;
                    end if;
                when ENCRIPTING =>
                    -- first iteraction still doesn't receive the out bit of cypher
                    -- so will be ignore and only send bit to cypher
                    if rom_data_index = 0  then
                        cypher_en <= '1';
                        cypher_in <= rom_data_out(rom_data_index);
                        rom_data_index <= rom_data_index +1;
                    
                    -- when encripted_index = 7 = UART_DATA_SIZE - 1
                    -- the accumalted data in encripted_data vector should be sent to uart
                    elsif encripted_index = UART_DATA_SIZE - 1 then
                        encripted_data(encripted_index) <= cypher_out;
                        if rom_data_index < ROM_DATA_SIZE - 1 then
                            cypher_in <= rom_data_out(rom_data_index);
                            rom_data_index <= rom_data_index +1;
                        end if;
                        cypher_en <= '0'; -- disable cypher to not continue with lsfr, it's crucial to syncronize with the other cypher
                        encripted_index <= 0; -- reset index
                        state <= SENDING; -- send to uart

                    -- normal proceeded, sent to cypher and save the cypher output
                    else 
                        encripted_data(encripted_index) <= cypher_out;
                        if rom_data_index < ROM_DATA_SIZE then
                            cypher_in <= rom_data_out(rom_data_index);
                            rom_data_index <= rom_data_index +1;
                        end if;
                        encripted_index <= encripted_index +1;
                    end if;
                    
                when SENDING =>
                        uart_in_data <= encripted_data;
                        uart_start <= '1'; -- start uart sending
                        encripted_data <= (others => 'U'); -- clean encripted data, necessary only to easy to visualize in simulation

                        -- if it's the last bit of rom data, read the next rom data
                        -- otherwise repeat encription to the others 8 bits
                        if rom_data_index >  ROM_DATA_SIZE - 1 then
                            state <= READING;
                            rom_index <= rom_index +1;
                        else 
                            state <= ENCRIPTING;
                            cypher_en <= '1';
                        end if;    
                
                when others =>
                    -- This the last state in this case will only disable uart_start to not send any more data
                    uart_start <= '0';
            end case;
        end if;
    end process;

end Behavioral;