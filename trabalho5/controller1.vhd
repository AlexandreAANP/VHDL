library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller1 is
    Port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        -- rx: in std_logic;
        tx: out std_logic
    );
end controller1;

architecture Behavioral of controller1 is
    constant ROM_SIZE :integer := 50; -- how many elements rom have
    constant ROM_DATA_SIZE : integer := 16;
    type state_type is (INIT, READING, SENDING, ENCRIPTING, SPLITING, WAIT_FOR_UART, DONE);
    signal state : state_type := INIT;
    signal rom_addr : unsigned(5 downto 0);
    signal rom_data_out : signed(ROM_DATA_SIZE-1 downto 0);
    signal index : integer := 0;

    signal chiper_in : std_logic;
    signal chiper_out : std_logic;
    signal chiper_en : std_logic := '0';
    signal encripted_data : std_logic_vector(ROM_DATA_SIZE-1 downto 0);
    -- signal chiper_rst : std_logic;
    -- signal start_rom_uart : std_logic := '0';


    signal uart_in_data : std_logic_vector(ROM_DATA_SIZE/2 - 1 downto 0);
    signal uart_busy : std_logic;
    signal uart_invalid :std_logic;
    signal uart_start : std_logic;
    signal uart_rx : std_logic := '1'; -- set '1' for uart doesn't start serial receiving

    component controller1_rom is 
        Port(
            addr : in unsigned(5 downto 0);
            data_out : out signed(ROM_DATA_SIZE-1 downto 0)
        );
    end component;

    component cipher is
        Port(
            bit_in : in std_logic;
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            bit_out : out std_logic
        );
    end component;

    component uart is 
        Port(
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            start: in std_logic;
            rx : in std_logic;
            data_in : in std_logic_vector(0 to ROM_DATA_SIZE/2 - 1);
            is_busy: out std_logic;
            data_invalid: out std_logic;
            tx : out std_logic;
            data_out : out std_logic_vector(0 to ROM_DATA_SIZE/2 - 1)
        );
    end component;
begin

    uui_rom: controller1_rom port map (
        addr => rom_addr,
        data_out => rom_data_out
    );

    uui_chiper: cipher port map (
        bit_in => chiper_in,
        clk => clk,
        rst => rst,
        en => chiper_en,
        bit_out => chiper_out
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

    controller_process: process(clk, uart_busy)
    variable index_bit : integer := 0;
    variable is_first_part : std_logic := '1';
    begin
        if rst = '1' then
            state <= READING;
            index <= 0;
        elsif rising_edge(clk) then
            case state is
                when READING =>
                    rom_addr <= to_unsigned(index, rom_addr'length);
                    state <= SENDING;
                    
                when SENDING =>
                    chiper_en <= '1'; -- enabling chiper
                    chiper_in <= rom_data_out(ROM_DATA_SIZE-1-index_bit);
                    index_bit := index_bit + 1;
                    state <= ENCRIPTING;

                    
                    if index = ROM_SIZE then
                        state <= DONE;
                    end if;
                    
                when ENCRIPTING =>
                    encripted_data(index_bit-1) <= chiper_out;
                    
                    if index_bit = ROM_DATA_SIZE then
                        index_bit := 0;
                        index <= index + 1;

                        state <= SPLITING;
                    else
                        state <= SENDING; 
                    end if;
                    
                when SPLITING =>
                    uart_start <= '1';
                        --split content and sent to uart

                    if is_first_part = '1' then
                        uart_in_data <= encripted_data(ROM_DATA_SIZE/2 - 1 downto 0);
                        state <= WAIT_FOR_UART;
                        is_first_part := '0';
                    else
                        uart_in_data <= encripted_data(ROM_DATA_SIZE - 1 downto ROM_DATA_SIZE/2);
                        uart_start <= '0';
                        is_first_part := '1';
                        state <= READING;
                    end if;
                when WAIT_FOR_UART =>
                    if uart_busy = '0' then
                        state <= SPLITING;
                    end if;
                
                when others =>
                    assert false report "End of simulation" severity failure;
            end case;
        end if;
    end process;

end Behavioral;