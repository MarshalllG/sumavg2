------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package dispatcher_ctrl_pkg is
component dispatcher_ctrl is
    generic (
       K_BITS                               : integer := 8
	);
    port (
        CLK, rst_n                          : in std_logic;
            -- inputs
        abort                               : in std_logic;
        start                               : in std_logic;
        ma_done                             : in std_logic;
        dev_done                            : in std_logic;
            -- status signal from dp
        input_hi 	                    : in std_logic_vector(K_BITS-1 DOWNTO 0);
            -- control outputs
        done                                : out std_logic;
        load_R_dataout                      : out std_logic;
        sel_R_dataout	                    : out std_logic;
        set_ma_din_addr                     : out std_logic;
        set_dev_ptr1                        : out std_logic;
        set_dev_ptr2                        : out std_logic;
        set_dev_len                         : out std_logic;
        ma_set_addr                         : out std_logic;
        ma_read                             : out std_logic;
        ma_write                            : out std_logic;
        dev_abort                           : out std_logic;
        dev_start                           : out std_logic
    );
	end component;
end dispatcher_ctrl_pkg;
------------------------------------------------


------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dispatcher_ctrl is
    generic (
       K_BITS                               : integer := 8
	);
    port (
        CLK, rst_n                          : in std_logic;
            -- inputs
        abort                               : in std_logic;
        start                               : in std_logic;
        ma_done                             : in std_logic;
        dev_done                            : in std_logic;
            -- status signal from dp
        input_hi                            : in std_logic_vector(K_BITS-1 DOWNTO 0);
            -- control outputs
        done                                : out std_logic;
        load_R_dataout                      : out std_logic;
        sel_R_dataout	                    : out std_logic;
        set_ma_din_addr                     : out std_logic;
        set_dev_ptr1                        : out std_logic;
        set_dev_ptr2                        : out std_logic;
        set_dev_len                         : out std_logic;
        ma_set_addr                         : out std_logic;
        ma_read                             : out std_logic;
        ma_write                            : out std_logic;
        dev_abort                           : out std_logic;
        dev_start                           : out std_logic
    );
end dispatcher_ctrl;


architecture behav of dispatcher_ctrl is
    type statetype is (INIT, WAIT_MA, WAIT_DEV);
    signal state, nextstate : statetype;


begin    
    -- ctrl unit: next state
    process (input_hi, state, start, ma_done, dev_done)
    begin
        case state is
            
           when INIT =>
               if start = '1' then
                  if input_hi = "00000000" or input_hi = "00000001" or input_hi = "00000010" then
                     nextstate <= WAIT_MA;
                  else 
                     nextstate <= WAIT_DEV;
                  end if;
               else
                  nextstate <= INIT;
               end if;

            when WAIT_MA =>
                if ma_done = '1' then
                    nextstate <= INIT;
                else
                    nextstate <= WAIT_MA;
                end if;

            when WAIT_DEV =>
                if dev_done = '1' then
                    nextstate  <= INIT;
                else
                    nextstate <= WAIT_DEV;
                end if;
        
            when others =>
                nextstate <= INIT;

        end case;
    end process;

state <= INIT when rst_n = '0' else nextstate when rising_edge(CLK);

-- control outputs	    
done                        <= '1'          when state = INIT else '0';
ma_set_addr                 <= '1'          when state = INIT and start = '1' and input_hi = "00000000" else '0';
ma_read                     <= '1'          when state = INIT and start = '1' and input_hi = "00000001" else '0';
ma_write                    <= '1'          when state = INIT and start = '1' and input_hi = "00000010" else '0';
dev_start                   <= '1'          when state = INIT and start = '1' and input_hi /= "00000000" 
                                                                            and input_hi /= "00000001" 
                                                                            and input_hi /= "00000010" else '0';
load_R_dataout              <= '1'          when (state = WAIT_MA and ma_done = '1') or
                                                (state = WAIT_DEV and dev_done = '1') else '0';
sel_R_dataout		    <= '1'          when (state = WAIT_DEV and dev_done = '1') else '0';	
set_ma_din_addr             <= '1'          when (state = INIT and start = '1' and input_hi = "00000000") or 
                                            (state = INIT and start = '1' and input_hi = "00000010") else '0';
set_dev_ptr1                <= '1'          when state = INIT and start = '1' and input_hi /= "00000000" 
                                                                            and input_hi /= "00000001" 
                                                                            and input_hi /= "00000010" else '0';
set_dev_ptr2                <= '1'          when state = INIT and start = '1' and input_hi /= "00000000" 
                                                                            and input_hi /= "00000001" 
                                                                            and input_hi /= "00000010" else '0';                                                                    
set_dev_len                 <= '1'          when state = INIT and start = '1' and input_hi /= "00000000" 
                                                                            and input_hi /= "00000001" 
                                                                            and input_hi /= "00000010" else '0';

end behav;