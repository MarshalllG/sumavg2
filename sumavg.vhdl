-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package sumavg_pkg is

component sumavg is
   generic (
      W_BITS                                    : integer := 32;
      A_BITS                                    : integer := 12;
      K_BITS                                    : integer := 8
   );
    port (
      CLK                                       : in std_logic;
      rst_n                                     : in std_logic;
      abort                                     : in std_logic;
      start                                     : in std_logic;
      ptr1                                      : in std_logic_vector(A_BITS-1 DOWNTO 0);
      ptr2                                      : in std_logic_vector(A_BITS-1 DOWNTO 0);
      len                                       : in std_logic_vector(K_BITS-1 DOWNTO 0);
      result                                    : out std_logic_vector(W_BITS-1 DOWNTO 0);
      done                                      : out std_logic;
      mem_en                                    : out std_logic;
      mem_we                                    : out std_logic;
      mem_addr                                  : out std_logic_vector(A_BITS-1 DOWNTO 0);
      mem_datain                                : out std_logic_vector(W_BITS-1 DOWNTO 0);
      mem_dataout                               : in std_logic_vector(W_BITS-1 DOWNTO 0);
      mem_ready                                 : in std_logic
   );
end component;

end sumavg_pkg;
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sumavg_ctrl_pkg.all;
use work.sumavg_dp_pkg.all;

entity sumavg is
   generic (
      W_BITS                                    : integer := 32;
      A_BITS                                    : integer := 12;
      K_BITS                                    : integer := 8
   );
  port (
      CLK                                       : in std_logic;
      rst_n                                     : in std_logic;
      abort                                     : in std_logic;
      start                                     : in std_logic;
      ptr1                                      : in std_logic_vector(A_BITS-1 DOWNTO 0);
      ptr2                                      : in std_logic_vector(A_BITS-1 DOWNTO 0);
      len                                       : in std_logic_vector(K_BITS-1 DOWNTO 0);
      result                                    : out std_logic_vector(W_BITS-1 DOWNTO 0);
      done                                      : out std_logic;
      mem_en                                    : out std_logic;
      mem_we                                    : out std_logic;
      mem_addr                                  : out std_logic_vector(A_BITS-1 DOWNTO 0);
      mem_datain                                : out std_logic_vector(W_BITS-1 DOWNTO 0);
      mem_dataout                               : in std_logic_vector(W_BITS-1 DOWNTO 0);
      mem_ready                                 : in std_logic
   );
end sumavg;

architecture struct of sumavg is
   signal last_iteration                        : std_logic;
   signal load_R_X                              : std_logic;
   signal load_R_Y                              : std_logic;
   signal load_R_D1                             : std_logic;
   signal load_R_D2                             : std_logic;
   signal load_R_acc                            : std_logic;
   signal load_CNT                              : std_logic;
   signal load_L                                : std_logic;
   signal load_result                           : std_logic;
   signal sel_R_X                               : std_logic;
   signal sel_R_Y                               : std_logic;
   signal sel_R_acc                             : std_logic;
   signal sel_CNT                               : std_logic;
   signal set_mem_addr                          : std_logic;   
   signal sel_mem_addr                          : std_logic;
   signal div_abort                             : std_logic;
   signal div_start                             : std_logic;
   signal div_ready                             : std_logic;
   signal len_zero                              : std_logic;
   signal overflow                              : std_logic;
   signal set_zero                              : std_logic;


begin
   CTRL : sumavg_ctrl
   generic map (
      W_BITS, A_BITS, K_BITS
   )
   port map (
      CLK => CLK,
      rst_n => rst_n,
      abort => abort,
      start => start,
      last_iteration => last_iteration,
      load_R_X => load_R_X,
      load_R_Y => load_R_Y,
      load_R_D1 => load_R_D1,
      load_R_D2 => load_R_D2,                              
      load_R_acc => load_R_acc,
      load_CNT => load_CNT,
      load_L => load_L,
      load_result => load_result,
      sel_R_X => sel_R_X,
      sel_R_Y => sel_R_Y,
      sel_R_acc => sel_R_acc,
      sel_CNT => sel_CNT,
      set_mem_addr => set_mem_addr, 
      sel_mem_addr => sel_mem_addr, 
      mem_ready => mem_ready, 
      overflow => overflow,
      len_zero => len_zero,
      set_zero => set_zero,
      div_abort => div_abort,
      div_start => div_start,
      div_ready => div_ready,
      done => done,
      mem_en => mem_en,
      mem_we => mem_we
   );

   DP : sumavg_dp
   generic map (
      W_BITS, A_BITS, K_BITS
   )
   port map (
      CLK, rst_n,
      ptr1 => ptr1,
      ptr2 => ptr2,
      len => len,
      mem_dataout => mem_dataout,
      result => result,
      mem_addr => mem_addr,
      mem_datain => mem_datain,
      last_iteration => last_iteration,
      load_R_X => load_R_X,
      load_R_Y => load_R_Y,
      load_R_D1 => load_R_D1,
      load_R_D2 => load_R_D2,                              
      load_R_acc => load_R_acc,
      load_CNT => load_CNT,
      load_L => load_L,
      load_result => load_result,
      sel_R_X => sel_R_X,
      sel_R_Y => sel_R_Y,
      sel_R_acc => sel_R_acc,
      sel_CNT => sel_CNT,
      set_mem_addr => set_mem_addr, 
      sel_mem_addr => sel_mem_addr, 
      overflow => overflow,
      len_zero => len_zero,
      set_zero => set_zero,
      div_start => div_start,
      div_ready => div_ready,
      div_abort => div_abort
   );
end struct;