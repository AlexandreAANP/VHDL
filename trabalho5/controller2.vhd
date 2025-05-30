library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity controller2 is
    GENERIC (
        gen_filter_size : integer := 51;
        gen_rom_addr_size : integer := 6;
        gen_rom_data_size : integer := 16;
        gen_uart_data_size : integer := 8;
        gen_noisy_signal_size : integer := 1000
    );
    PORT(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        rx: in std_logic
    );
end entity;

architecture Behavioral of controller2 is
    -- CONSTANTS
     -- You can change this constantes by changinc the generic values to have the disered behavior for data bigger or smaller
    constant FILTER_SIZE :integer := gen_filter_size; 
    constant ROM_ADDR_SIZE : integer := gen_rom_addr_size;
    constant ROM_DATA_SIZE : integer := gen_rom_data_size;
    constant UART_DATA_SIZE : integer := gen_uart_data_size;
    constant NOISY_SIGNAL_SIZE : integer := gen_noisy_signal_size;
    

    -- POSSIBLE STATES
    type state_type is (INIT, READ_UART, DECRIPTING, DECRIPT_NEXT_SIGNAL, FILTER);
    signal state : state_type := INIT; -- Start in INIT state

    -- RECEIVING SIGNALS
    signal uart_data_in: std_logic_vector(0 to UART_DATA_SIZE - 1) := (others=>'0');
    signal uart_output : std_logic_vector(UART_DATA_SIZE - 1 downto 0);
    signal uart_busy: std_logic;
    signal uart_invalid: std_logic;
    signal uart_tx: std_logic;
    signal uart_start : std_logic := '0';

    -- DECRIPTING SIGNALS
    signal cypher_en :std_logic := '0';
    signal cypher_in: std_logic;
    signal cypher_out : std_logic;
    signal data_encripted : std_logic_vector(UART_DATA_SIZE-1 downto 0);
    signal data_decripted: std_logic_vector(ROM_DATA_SIZE-1 downto 0);

    -- FILTERING SIGNALS
    type sample_array is array (0 to FILTER_SIZE - 1) of signed(ROM_DATA_SIZE - 1 downto 0);
    signal filter_data : sample_array;
    signal signal_data : sample_array;
    signal calc_convultion : signed((ROM_DATA_SIZE * 2) - 1 downto 0) := (others => '0'); -- this should have the double size of ROM_DATA_SIZE to preserver the calc data

    -- ROM NOISY SIGNAL, SIGNALS
    signal addr_signal : unsigned(ROM_ADDR_SIZE - 1 downto 0);
    signal data_out_signal : signed(ROM_DATA_SIZE - 1 downto 0);

    -- SAVE RESULT SIGNALS
    signal write_file_enable: std_logic := '0';

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

    component cypher is
        Port(
            bit_in : in std_logic;
            clk: in std_logic;
            rst: in std_logic;
            en: in std_logic;
            bit_out : out std_logic
        );
    end component;

    component controller2_rom is
        Port(
            addr : in unsigned(ROM_ADDR_SIZE - 1 downto 0);
            data_out : out signed(ROM_DATA_SIZE - 1 downto 0)
        );
    end component;

    component write_file is
        generic (
            DATA_LENGTH : integer := ROM_DATA_SIZE * 2
        );
        Port (
            clk: in std_logic;
            enable: in std_logic;
            data: in signed((ROM_DATA_SIZE * 2) - 1 downto 0)
        );
    end component;
begin
    
    uui_uart: uart port map (
        clk => clk,
        rst => rst,
        en => en,
        start => uart_start,
        data_in => uart_data_in,
        rx => rx,
        tx => uart_tx,
        is_busy => uart_busy,
        data_invalid => uart_invalid,
        data_out => uart_output
    );

    uui_cypher: cypher port map (
        bit_in => cypher_in,
        clk => clk,
        rst => rst,
        en => cypher_en,
        bit_out => cypher_out
    );

    uui_rom_signal : controller2_rom port map(
        addr => addr_signal,
        data_out => data_out_signal
    );

    uui_write_file: write_file port map (
        clk => clk,
        enable => write_file_enable,
        data => calc_convultion
    );

    controller2_process: process(clk, state)
    variable uart_index : integer := 0;
    variable decript_index : integer := 0;
    variable filter_index : integer := 0;
    variable signal_index : integer := -1;
    variable should_shift_signal : std_logic := '0';
    variable uart_already_start : std_logic := '0';
    variable acc : signed((ROM_DATA_SIZE * 2) - 1 downto 0) := (others => '0');
    begin
        if rst='1' then
            state <= INIT;
            uart_index := 0;
            uart_already_start := '0';
            filter_index := 0;
            signal_index := -1;
            decript_index := 0;

        elsif falling_edge(clk) then
            if en='1' then
                case state is
                  when INIT =>
                        -- change the state to decripting as soon uart start and is not busy anymore
                        if uart_already_start = '1' and uart_busy = '0' then
                            state <= DECRIPTING;
                            if signal_index < FILTER_SIZE then
                                addr_signal <= to_unsigned(signal_index, addr_signal'length); -- change the addr of noisy signal rom
                            end if;
                        elsif uart_busy = '1' then
                            uart_already_start := '1';    
                        end if;

                    when DECRIPTING =>
                    write_file_enable <= '0'; -- disable write file    
                        if uart_index = 0 then
                            cypher_en <= '1'; --enable cypher
                            data_encripted <= uart_output; -- save the output, could change in the next iteractions
                            cypher_in <= uart_output(0); --send the first bit already
                            uart_index := uart_index + 1;

                            if decript_index = 0 then -- only do this one time per two bytes of data          
                                if should_shift_signal = '1' then
                                    signal_data <= signal_data(1 to FILTER_SIZE - 1) &  signed(data_decripted); --shift signal data

                                elsif signal_index > -1 and signal_index < FILTER_SIZE then -- ignore the first time data_decripted stil doesn't have data
                                    signal_data(signal_index) <= signed(data_decripted); -- save the signal data
                                    filter_data(signal_index) <= data_out_signal; -- read filter signal from rom
                                end if;

                                if signal_index < FILTER_SIZE then 
                                    signal_index := signal_index + 1; -- increment filter index
                                end if;
                                data_decripted <= (others => 'U'); -- reset data_decripted, only necessary for debuging
                            end if;
                            
                        else
                            -- save the cypher output
                            data_decripted(decript_index) <= cypher_out;
                            decript_index := decript_index + 1;
                            
                            -- continue if index doesn't pass the limit
                            if decript_index < ROM_DATA_SIZE and uart_index < UART_DATA_SIZE then
                                cypher_in <= data_encripted(uart_index);
                                uart_index := uart_index +1;
                            -- other wise reset the necessary index
                            else
                                --reset the uart index
                                if uart_index = UART_DATA_SIZE then 
                                    uart_index := 0;
                                    cypher_en <= '0';    
                                    state <= INIT;
                                end if;
                                    
                                -- reset the decripted index
                                if decript_index = ROM_DATA_SIZE then
                                        decript_index := 0;
                                        if signal_index = FILTER_SIZE then
                                            state <= FILTER;
                                        end if;
                                end if;
                            end if;
                            
                        end if;
                    
                    when FILTER =>
                        should_shift_signal := '1'; -- next signal data should be shifted

                        -- filter result has the size of noisy signal minus the filter sizes; in this case we want index so subtract by one 
                        if filter_index = NOISY_SIGNAL_SIZE - FILTER_SIZE - 1 then
                            write_file_enable <= '0';
                            assert false report "End of simulation" severity failure;
                        end if;

                        acc := (others => '0');
                        for i in 0 to FILTER_SIZE - 1 loop
                            acc := acc + (filter_data(i) * signal_data(i));
                        end loop;
                        
                        calc_convultion <= acc;
                        write_file_enable <= '1';
                        
                        -- shift the signal sample
                        -- should get the next encripted data
                        state <= DECRIPTING;
                        filter_index := filter_index + 1;
                        
                   when others =>
                        assert false report "End of simulation" severity failure;
                end case;
            end if;
        end if;
    end process;


end Behavioral;