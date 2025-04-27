library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity controller2 is
    PORT(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        start_uart: in std_logic;
        rx: in std_logic
       -- tx: out std_logic;
    );
end entity;

architecture Behavioral of controller2 is
    
    constant ROM_SIZE :integer := 50; -- how many elements rom have
    constant ROM_DATA_SIZE : integer := 16;
    constant RECEIVING_IN_SERIAL : std_logic := '1';
    
    type state_type is (INIT, READ_UART,DECRIPTING, FILTER);
    signal state : state_type := INIT;

    signal cypher_en :std_logic := '0';
    signal cypher_in: std_logic;
    signal cypher_out : std_logic;

    signal uart_data_in: std_logic_vector(0 to ROM_DATA_SIZE/2 - 1) := (others=>'0');
    signal uart_output : std_logic_vector(ROM_DATA_SIZE/2 - 1 downto 0);
    signal uart_busy: std_logic;
    signal uart_invalid: std_logic;
    signal uart_tx: std_logic;
    
    type sample_array is array (0 to 50) of signed(15 downto 0);
    signal filter_data : sample_array; -- := (others => to_signed(0, 15));
    signal signal_data : sample_array;
    signal filter_index : integer := 0;

    signal data_encripted : std_logic_vector(ROM_DATA_SIZE/2-1 downto 0);
    signal data_decripted: std_logic_vector(ROM_DATA_SIZE-1 downto 0);
    signal data_decripted_fix: std_logic_vector(ROM_DATA_SIZE-1 downto 0);
    signal calc_convultion : signed((16 * 2) - 1 downto 0) := (others => '0');

    signal addr_signal : unsigned(9 downto 0);
    signal data_out_signal : signed(15 downto 0);

    signal write_file_enable: std_logic := '0';

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
            addr : in unsigned(9 downto 0);
            data_out : out signed(15 downto 0)
        );
    end component;

    component write_file is
        generic (
            DATA_LENGTH : integer
        );
        Port (
            clk: in std_logic;
            enable: in std_logic;
            data: in signed(DATA_LENGTH - 1 downto 0)
        );
    end component;
begin
    
    uui_uart: uart port map (
        clk => clk,
        rst => rst,
        en => en,
        start => start_uart,
        receiving_in_serial => RECEIVING_IN_SERIAL,
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

    uui_write_file: write_file 
    generic map (
        DATA_LENGTH => 16 * 2
    )
    port map (
        clk => clk,
        enable => write_file_enable,
        data => calc_convultion
    );

    controller2_process: process(clk, state)
    variable index : integer := 0;
    variable its_first_8_bits : std_logic := '1';
    variable uart_already_start : std_logic := '0';
    variable index_filter : integer := -1;
    variable acc : signed((16 * 2) - 1 downto 0) := (others => '0');
    begin
        if rst='1' then
            state <= INIT;
        elsif falling_edge(clk) then
            if en='1' then
                case state is
                  when INIT =>
                        if uart_already_start = '1' and uart_busy = '0' then
                            state <= DECRIPTING;
                            addr_signal <= to_unsigned(index_filter, addr_signal'length);
                        elsif uart_busy = '1' then
                            uart_already_start := '1';    
                        end if;
                    
                    when DECRIPTING =>
                        if index = 0 then
                            cypher_en <= '1';
                            data_encripted <= uart_output;
                            if its_first_8_bits = '1' then
                                if index_filter = 51  then
                                    state <= FILTER;
                                elsif index_filter > -1 then
                                    filter_data(index_filter) <= signed(data_decripted);
                                    signal_data(index_filter) <= data_out_signal;
                                end if;
                                
                                index_filter := index_filter + 1;
                                data_decripted <= (others => 'U');
                            end if;
                            cypher_in <= uart_output(index);
                            index := index + 1;
                        elsif index = 1  then
                            cypher_in <= data_encripted(index);
                            if its_first_8_bits = '1' then
                                data_decripted(0) <= cypher_out;
                            else
                                data_decripted(8) <= cypher_out;
                            end if;
                            index := index + 1;
                        
                            elsif index = 8 then
                                index := 0;
                                if its_first_8_bits = '1' then
                                    data_decripted(7) <= cypher_out;
                                    its_first_8_bits := '0';
                                else
                                    its_first_8_bits := '1';
                                    data_decripted(15) <= cypher_out;
                                end if;
                                cypher_en <= '0';
                                state <= INIT;
                                
                            else
                                cypher_in <= data_encripted(index);
                                if its_first_8_bits = '1' then
                                    data_decripted(index - 1) <= cypher_out;
                                else
                                    data_decripted(8+index - 1) <= cypher_out;
                                end if;
                                index := index +1;
                            end if;
                    
                    when FILTER =>
                        if filter_index = 950 then
                            write_file_enable <= '0';
                            assert false report "End of simulation" severity failure;
                        end if;

                        acc := (others => '0');
                        for i in 0 to 50 loop
                            acc := acc + (filter_data(i) * signal_data(i));
                        end loop;
                        
                        calc_convultion <= acc;
                        write_file_enable <= '1';
                        filter_index <= filter_index + 1;
                        
                        -- shift the signal sample
                        addr_signal <= to_unsigned((50 + filter_index), 10);
                        signal_data <= signal_data(1 to 50) & data_out_signal;
                   when others =>
                        assert false report "End of simulation" severity failure;
                end case;
            end if;
        end if;
    end process;


end Behavioral;