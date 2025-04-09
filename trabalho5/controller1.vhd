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
    type state_type is (INIT, READING, SENDING, DONE);
    signal state : state_type := INIT;
    signal rom_addr : unsigned(5 downto 0);
    signal rom_data_out : signed(ROM_DATA_SIZE-1 downto 0);
    signal index : integer := 0;

    signal chyper_in : std_logic;
    -- signal start_rom_uart : std_logic := '0';


    component controller1_rom is 
        Port(
            addr : in unsigned(5 downto 0);
            data_out : out signed(ROM_DATA_SIZE-1 downto 0)
        );
    end component;

    -- component uart is 
    --     Port(
    --         clk : in std_logic;
    --         rst : in std_logic;
    --         en : in std_logic;
    --         start: in std_logic := '0';
    --         rx : in std_logic;
    --         data_in : in std_logic_vector(0 to 15) := (others => '0');
    --         is_busy: out std_logic := '0';
    --         data_invalid: out std_logic := '0';
    --         tx : out std_logic := '0';
    --         data_out : out std_logic_vector(0 to 15) := (others => '0')
    --     );
    -- end component;
begin

    rom: controller1_rom port map (
        addr => rom_addr,
        data_out => rom_data_out
    );

    -- rom_uart: uart port map (
    --     clk => clk,
    --     rst => rst,
    --     en => en,
    --     start => start_rom_uart,
    --     rx => _rom_uart_rx,
    --     data_in => rom_uart_data_in,
    --     is_busy => rom_uart_busy,
    --     data_invalid => rom_uart_invalid,
    --     tx => chiper_in,
    -- );

    controller_process: process(clk)
    variable index_bit : integer := 0;
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
                    
                    chyper_in <= rom_data_out(ROM_DATA_SIZE-1-index_bit);
                    index_bit := index_bit + 1;
                    
                    if index_bit = ROM_DATA_SIZE-1 then
                        index_bit := 0;
                        index <= index + 1;
                        if index = ROM_SIZE then
                            state <= DONE;
                        else
                            state <= READING;
                        end if;
                    end if;
                when others =>
                    assert false report "End of simulation" severity failure;
            end case;
        end if;
    end process;

end Behavioral;