library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filter is
    Port ( 
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        filter_bytes_out: out signed(15 downto 0);
        signal_bytes_out: out signed(15 downto 0);
        filter_addr_out: out unsigned(5 downto 0);
        signal_addr_out: out unsigned(9 downto 0);
        filter_out : out signed(31 downto 0) -- Fixed width
    );
end filter;

architecture Behavioral of filter is
    type filter_state is (INIT, FILTER, DONE);
    signal state : filter_state := INIT;
    signal filter_addr : unsigned(5 downto 0) := (others => '0');
    signal filter_bytes : signed(15 downto 0):= (others => '0');
    signal signal_addr : unsigned(9 downto 0) := (others => '0');
    signal signal_output : signed(15 downto 0):= (others => '0');
    signal convultion : signed(31 downto 0) := (others => '0'); -- Changed to signed
    signal i: integer range 0 to 50 := 0;

    component rom is
        Port (
            addr : in unsigned(5 downto 0);
            data_out : out signed(15 downto 0)
        );
    end component;

    component signal_rom_cp is
        Port (
            addr : in unsigned(9 downto 0);
            data_out : out signed(15 downto 0)
        );
    end component;

begin

    -- Instantiate ROM components
    filter_rom : rom port map (
        addr => filter_addr,
        data_out => filter_bytes_out
    );

    signal_rom : signal_rom_cp port map (
        addr => signal_addr,
        data_out => signal_bytes_out
    );

    stim_proc: process
    begin        
        -- Apply test values to addr
        for i in 0 to 50 loop
            filter_addr <= to_unsigned(i, 6);
            signal_addr <= to_unsigned(i, 10);
            wait for 10 ns; -- Wait for some time to observe the output
        end loop;
        
        -- Stop simulation
        wait;
    end process;

    -- Main Process
    -- process(clk, rst)

    -- begin
    --     if rst = '1' then
    --         state <= INIT;
    --         convultion <= (others => '0');
    --         filter_out <= (others => '0');
    --         signal_addr <= (others => '0');
    --     end if;
    --     if en = '1' then
    --         case state is
    --             when INIT =>
    --                 filter_addr <= to_unsigned(i, 6);
    --                 signal_addr <= signal_addr + 1;
    --                 convultion <= signed(convultion + to_signed(i, 32));
    --                 -- convultion <= convultion + (filter_bytes * signal_output);
    --                 i <= i + 1;
    --                 if i = 50 then
    --                     state <= FILTER;
    --                 end if;
    --                 -- -- convultion <= (others => '0'); -- Clear accumulation
    --                 -- for i in 0 to 50 loop
    --                 --     filter_addr <= to_unsigned(i, 6);
    --                 --     temp_signal_addr := signal_addr + 1;
    --                 --     signal_addr <= temp_signal_addr;
    --                 --     -- Corrected multiplication
    --                 --     -- filter_bytes <= std_logic_vector(to_unsigned(i, 16));
    --                 --     -- convultion <= convultion + (signed(filter_bytes) * signed(signal_output));
    --                 --     convultion <= convultion + to_signed(i, 32);
    --                 -- end loop;
    --                 -- -- assert false report "End of simulation" severity failure;
    --                 -- state <= FILTER;

    --             when FILTER =>
    --                 assert false report "End of simulation" severity failure;
    --             --     signal_addr <= std_logic_vector(unsigned(signal_addr) + 1);
    --             --     filter_out <= convultion; -- Convert back to std_logic_vector
    --             --     if signal_addr = "1111101000" then -- 1000 in binary
    --             --         assert false report "End of simulation" severity failure;
    --             --     end if;

    --             when others =>
    --                 assert false report "End of simulation" severity failure;
    --         end case;
            
    --     end if;
    -- end process;

    -- filter_out <= convultion;
    -- -- filter_bytes_out <= filter_bytes;
    -- filter_addr_out <= filter_addr;

    -- -- signal_bytes_out <= signal_output;
    -- signal_addr_out <= signal_addr;
end Behavioral;
