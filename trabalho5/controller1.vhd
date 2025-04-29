library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller1 is
    Port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        -- rx: in std_logic;
        tx: out std_logic;
        start_uart : out std_logic
    );
end controller1;

architecture Behavioral of controller1 is
    constant ROM_SIZE :integer := 51; -- how many elements rom have
    constant ROM_DATA_SIZE : integer := 16;
    type state_type is (INIT, READING, ENCRIPTING, SENDING, DONE);
    signal state : state_type := INIT;
    signal rom_addr : unsigned(5 downto 0);
    signal rom_data_out : signed(ROM_DATA_SIZE-1 downto 0);
    signal rom_index : integer := 0;
    signal index : integer := 0;

    signal cypher_in : std_logic;
    signal cypher_out : std_logic;
    signal cypher_en : std_logic := '0';
    signal encripted_data : std_logic_vector(ROM_DATA_SIZE/2-1 downto 0);
    signal encripted_index: integer :=0;
    -- signal cypher_rst : std_logic;
    -- signal start_rom_uart : std_logic := '0';


    signal uart_in_data : std_logic_vector(ROM_DATA_SIZE/2 - 1 downto 0);
    signal uart_busy : std_logic;
    signal uart_invalid :std_logic;
    signal uart_start : std_logic := '0';
    signal uart_rx : std_logic := '1'; -- set '1' for uart doesn't start serial receiving
    signal uart_receiving_in_serial : std_logic := '0'; -- in this case the uart will never receive in serial
    signal test_index : std_logic;

    component controller1_rom is 
        Port(
            addr : in unsigned(5 downto 0);
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
        Port(
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            start: in std_logic;
            receiving_in_serial: in std_logic;
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
        receiving_in_serial => uart_receiving_in_serial,
        rx => uart_rx,
        data_in => uart_in_data,
        is_busy => uart_busy,
        data_invalid => uart_invalid,
        tx => tx
    );

    start_uart <= uart_start;
    controller_process: process(clk, uart_busy)
    
    -- variable encripted_index : integer := 0;
    variable is_first_part : std_logic := '1';
    variable uart_already_start : std_logic := '0';
    variable save_bit_encripted : std_logic :='0';
    begin
        if rst = '1' then
            state <= READING;
            index <= 0;
        elsif falling_edge(clk) then
            case state is
                when READING =>
                    if index = ROM_SIZE then
                        state <= DONE;
                    else
                        rom_addr <= to_unsigned(index, rom_addr'length);
                        state <= ENCRIPTING;
                        
                        rom_index <= 0;
                        encripted_index <= 0;
                        -- cypher_in <= rom_data_out(0);
                    end if;
                    
                when ENCRIPTING =>
                    

                    if rom_index = 0  then
                        cypher_en <= '1';
                        cypher_in <= rom_data_out(rom_index);
                        rom_index <= rom_index +1;
                    elsif rom_index = 1 then
                        encripted_data(encripted_index) <= cypher_out;
                        cypher_in <= rom_data_out(rom_index);
                        rom_index <= rom_index +1;
                        encripted_index <= encripted_index + 1;   

                       
                        
                    elsif encripted_index = 7 then
                        encripted_data(encripted_index) <= cypher_out;
                        test_index <= cypher_out;
                        if rom_index < 15 then
                            cypher_in <= rom_data_out(rom_index);
                            rom_index <= rom_index +1;
                        end if;
                        cypher_en <= '0';
                        encripted_index <= 0;
                        
                        -- send to uart
                        state <= SENDING;
                    else 
                        encripted_data(encripted_index) <= cypher_out;
                        test_index <= cypher_out;
                        if rom_index < 16 then
                            cypher_in <= rom_data_out(rom_index);
                            rom_index <= rom_index +1;
                        end if;
                        encripted_index <= encripted_index +1;
                        
                    end if;
                    
                when SENDING =>
                        uart_in_data <= encripted_data;
                        encripted_data <= (others => 'U');

                        uart_start <= '1';
                        if rom_index > 15 then
                            state <= READING;
                            index <= index +1;
                        else 
                            state <= ENCRIPTING;
                            cypher_en <= '1';
                        end if;    
                
                when others =>
                    -- assert false report "End of simulation" severity failure;
            end case;
        end if;
    end process;

end Behavioral;