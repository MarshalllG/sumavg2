-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package sumavg_ctrl_pkg is
component sumavg_ctrl is
   generic (
      W_BITS                                    : integer := 32;
      A_BITS                                    : integer := 12;
      K_BITS                                    : integer := 8							
   );
   port (
      CLK                                       : in std_logic;
      rst_n                                     : in std_logic;
         -- inputs
      abort                                     : in std_logic;
      start                                     : in std_logic;
      last_iteration                            : in std_logic; -- status signal from dp
         -- ctrl signals
      load_R_X                                  : out std_logic;
      load_R_Y                                  : out std_logic;
      load_R_D1                                 : out std_logic;
      load_R_D2                                 : out std_logic;
      load_R_acc                                : out std_logic;
      load_CNT                                  : out std_logic;
      load_L                                    : out std_logic;
      sel_R_X                                   : out std_logic;
      sel_R_Y                                   : out std_logic;
      sel_R_acc                                 : out std_logic;
      sel_CNT                                   : out std_logic;
      set_mem_addr                              : out std_logic;  
      sel_mem_addr                              : out std_logic; 
      load_result                               : out std_logic;
      set_zero                                  : out std_logic;
         -- div
      div_abort                                 : out std_logic;
      div_start                                 : out std_logic;
      div_ready                                 : in std_logic;
      done                                      : out std_logic;
         -- mem
      mem_en                                    : out std_logic;
      mem_we                                    : out std_logic;
      mem_ready                                 : in std_logic;
         -- status
      len_zero                                  : in std_logic;
      overflow                                  : in std_logic
   );
end component;
end sumavg_ctrl_pkg;
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sumavg_ctrl is
   generic (
      W_BITS                                    : integer := 32;
      A_BITS                                    : integer := 12;
      K_BITS                                    : integer := 8							
   );
   port (
      CLK                                       : in std_logic;
      rst_n                                     : in std_logic;
         -- inputs
      abort                                     : in std_logic;
      start                                     : in std_logic;
      last_iteration                            : in std_logic; -- status signal from dp
         -- ctrl signals
      load_R_X                                  : out std_logic;
      load_R_Y                                  : out std_logic;
      load_R_D1                                 : out std_logic;
      load_R_D2                                 : out std_logic;
      load_R_acc                                : out std_logic;
      load_CNT                                  : out std_logic;
      load_L                                    : out std_logic;
      sel_R_X                                   : out std_logic;
      sel_R_Y                                   : out std_logic;
      sel_R_acc                                 : out std_logic;
      sel_CNT                                   : out std_logic;
      set_mem_addr                              : out std_logic;  
      sel_mem_addr                              : out std_logic; 
      load_result                               : out std_logic;
      set_zero                                  : out std_logic; 
         -- div
      div_abort                                 : out std_logic;
      div_start                                 : out std_logic;
      div_ready                                 : in std_logic;
      done                                      : out std_logic;
         -- mem
      mem_en                                    : out std_logic;
      mem_we                                    : out std_logic;
      mem_ready                                 : in std_logic;
         -- status
      len_zero                                  : in std_logic;
      overflow                                  : in std_logic
   );
end sumavg_ctrl;

architecture behav of sumavg_ctrl is
	type statetype is (S_INIT, S_READ_1, S_FETCH_1, S_READ_2, S_FETCH_2, S_ACC_1, S_CHECK_OVERFLOW_1, S_ACC_2, S_CHECK_OVERFLOW_2, S_OVERFLOW, S_DIV_START, S_ERR_ZERO, S_DIV_WAIT, S_DIV_END);
	signal state, nextstate : statetype;
  
begin

   -- ctrl unit: next state
   process (state, abort, start, mem_ready, last_iteration, overflow, len_zero, div_ready)
   begin
      case state is
         when S_INIT =>
            if start = '1' then
               if len_zero = '1' then
                  nextstate <= S_ERR_ZERO;
               else 
                  nextstate <= S_READ_1;
               end if;
            else
               nextstate <= S_INIT;
            end if;

         when S_ERR_ZERO =>
            nextstate <= S_INIT;

         when S_READ_1 =>
                nextstate <= S_FETCH_1;

         when S_FETCH_1 =>
            if mem_ready = '1' then
               nextstate  <= S_READ_2;
            else
               nextstate <= S_FETCH_1;
            end if;

         when S_READ_2 =>
            nextstate <= S_FETCH_2;

         when S_FETCH_2 =>
            if mem_ready = '1' then
               nextstate  <= S_ACC_1;
            else
               nextstate <= S_FETCH_2;
            end if;

         when S_ACC_1 =>
            nextstate <= S_CHECK_OVERFLOW_1;
            
         when S_CHECK_OVERFLOW_1 =>
            if overflow = '1' then
               nextstate <= S_OVERFLOW;
            else
               nextstate <= S_ACC_2;
            end if;

         when S_OVERFLOW =>
            nextstate <= S_INIT;
    
         when S_ACC_2 =>
            nextstate <= S_CHECK_OVERFLOW_2;

         when S_CHECK_OVERFLOW_2 =>
            if overflow = '1' then
               nextstate <= S_OVERFLOW;
            elsif last_iteration = '1' then
               nextstate <= S_DIV_START;
            else
               nextstate <= S_READ_1;
            end if;

         when S_DIV_START =>
            nextstate <= S_DIV_WAIT;

         when S_DIV_WAIT => 
            if div_ready = '1' then
               nextstate <= S_DIV_END;
            else
               nextstate <= S_DIV_WAIT;
            end if;

         when S_DIV_END =>
            nextstate <= S_INIT;

         if abort = '1' then
            nextstate <= S_INIT;
         end if;

      end case;
   end process;

state <= S_INIT when rst_n = '0' else nextstate when rising_edge(CLK);

-- control signals
mem_we                    <= '0';
mem_en                    <= '1'            when state = S_READ_1 or state = S_READ_2 else '0';		    
done                      <= '1'            when state = S_INIT else '0';
load_R_X                  <= '1'            when (state = S_INIT and start = '1') or
                                                 (state = S_FETCH_1 and mem_ready = '1') else '0';
load_R_Y                  <= '1'            when (state = S_INIT and start = '1') or
                                                 (state = S_FETCH_2 and mem_ready = '1') else '0';
load_R_D1                 <= '1'            when (state = S_FETCH_1 and mem_ready = '1') else '0'; 
load_R_D2                 <= '1'            when (state = S_FETCH_2 and mem_ready = '1') else '0';
load_R_acc                <= '1'            when (state = S_ACC_1) or (state = S_ACC_2) else '0';           
load_CNT                  <= '1'            when (state = S_INIT and start = '1') or
                                                 (state = S_CHECK_OVERFLOW_2) else '0';
load_L                    <= '1'            when (state = S_INIT and start = '1') else '0';
sel_R_X                   <= '1'            when (state = S_FETCH_1) else '0';
sel_R_Y                   <= '1'            when (state = S_FETCH_2) else '0';
sel_CNT                   <= '0'            when (state = S_INIT) else '1';
sel_R_acc                 <= '0'            when (state = S_ACC_1) else '1';
load_result               <= '1'            when (state = S_DIV_END) or (state = S_OVERFLOW) or (state = S_ERR_ZERO) else '0';
set_mem_addr              <= '1'            when (state = S_READ_1) or (state = S_READ_2) else '0';
sel_mem_addr              <= '0'            when (state = S_READ_1) else '1';
div_start                 <= '1'            when (state = S_DIV_START) else '0';
set_zero                  <= '1'            when (state = S_ERR_ZERO) else '0';
div_abort                 <= '0';

end behav;