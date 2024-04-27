-- testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use STD.textio.all;

use work.system_pkg.all;
use work.tester_pkg.all;

   --interface
entity systemTB is
   generic (
      CLK_SEMIPERIOD0                                 : time := 5 ns;
      CLK_SEMIPERIOD1                                 : time := 5 ns;
      RESET_TIME                                      : time := 50 ns;
      VERBOSE                                         : boolean := false;
      NTESTS                                          : integer := -1;
      N_BITS                                          : integer := 40;
      W_BITS                                          : integer := 32;
      A_BITS                                          : integer := 12;
      K_BITS                                          : integer := 8
   );
end systemTB;

architecture behav of systemTB is

   signal CLK                                         : std_logic;
   signal rst_n                                       : std_logic;

   signal start	                                      : std_logic;
   signal abort                                       : std_logic;
   signal done                                        : std_logic;
   signal input                                       : std_logic_vector(N_BITS-1 downto 0);
   signal output                                      : std_logic_vector(N_BITS-1 downto 0);

   signal end_simul                                   : boolean := false;

   signal test_finished                               : std_logic := '0';

   signal CLK_PERIOD                                  : time := CLK_SEMIPERIOD0 + CLK_SEMIPERIOD1;

begin

SYS : system
   generic map (
      N_BITS => N_BITS,
      W_BITS => W_BITS,
      A_BITS => A_BITS,
      K_BITS => K_BITS
   )
   port map (
      CLK => CLK,
      rst_n => rst_n,
      sys_abort => abort,
      sys_start => start,
      sys_input => input,
      sys_done => done,
      sys_output => output
   );

TG : tester
   generic map (
      N_BITS => N_BITS,
      W_BITS => W_BITS,
      A_BITS => A_BITS,
      K_BITS => K_BITS
   )
   port map (
      CLK,
      rst_n,
      start => start,
      abort => abort,
      input_data => input,
      done => done,
      output_data => output,
      finished => test_finished
   );
      
	
-- START PROCESS
   start_process : process
   begin
      rst_n <= '0';
      wait for RESET_TIME;
      rst_n <= '1';
      wait;
   end process start_process;

-- CLK PROCESS
   clk_process : process
   begin
      CLK <= '1', '0' after CLK_SEMIPERIOD1;
      wait for CLK_PERIOD;
			
      if end_simul then
         wait;
      end if;
   end process clk_process;

  
   finish_process: process(test_finished)
   begin 
      if test_finished = '1' then
         end_simul <= true after 10 * CLK_PERIOD;
      end if;
   end process finish_process;

end behav;

