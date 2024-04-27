------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package system_pkg is
   component system is
    generic (
      N_BITS                        : integer := 40;
      W_BITS                        : integer := 32;
      A_BITS                        : integer := 12;
      K_BITS                        : integer := 8
   );
   port (
      CLK                           : in std_logic;
      rst_n                         : in std_logic;
      ---
      sys_abort                     : in std_logic;
      sys_start                     : in std_logic;
      sys_input                     : in std_logic_vector(N_BITS-1 DOWNTO 0);
      sys_done                      : out std_logic;
      sys_output                    : out std_logic_vector(N_BITS-1 DOWNTO 0)
   );
   end component;
end system_pkg;
------------------------------------------------


------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity system is
   generic (
      N_BITS                        : integer := 40;
      W_BITS                        : integer := 32;
      A_BITS                        : integer := 12;
      K_BITS                        : integer := 8
   );
   port (
      CLK                           : in std_logic;
      rst_n                         : in std_logic;
      ---
      sys_abort                     : in std_logic;
      sys_start                     : in std_logic;
      sys_input                     : in std_logic_vector(N_BITS-1 DOWNTO 0);
      sys_done                      : out std_logic;
      sys_output                    : out std_logic_vector(N_BITS-1 DOWNTO 0)
   );
end system;

architecture rtl of system is
   
   -- use work.dispatcher_pkg.all;
   -- use work.memaccess_pkg.all;
   -- use work.memmux_pkg.all;

   component dispatcher is
   generic (
      N_BITS                        : integer := 40;
      W_BITS                        : integer := 32;
      A_BITS                        : integer := 12;
      K_BITS                        : integer := 8
   );
   port (
      CLK                           : in std_logic;
      rst_n                         : in std_logic;
      ---
      abort                         : in std_logic;
      start                         : in std_logic;
      input                         : in std_logic_vector(N_BITS-1 DOWNTO 0);
      output                        : out std_logic_vector(N_BITS-1 DOWNTO 0);
      done                          : out std_logic;
      ma_set_addr                   : out std_logic;
      ma_read                       : out std_logic;
      ma_write                      : out std_logic;
      ma_din_addr                   : out std_logic_vector(W_BITS-1 DOWNTO 0);
      ma_done                       : in std_logic;
      ma_dout                       : in std_logic_vector(W_BITS-1 DOWNTO 0);
      dev_abort                     : out std_logic;
      dev_start	                    : out std_logic;
      dev_ptr1                      : out std_logic_vector(A_BITS-1 DOWNTO 0);
      dev_ptr2                      : out std_logic_vector(A_BITS-1 DOWNTO 0);
      dev_len                       : out std_logic_vector(K_BITS-1 DOWNTO 0);
      dev_done                      : in std_logic;
      dev_result                    : in std_logic_vector(W_BITS-1 DOWNTO 0)
   );
   end component;

   component memaccess is
      generic (
         W_BITS                     : integer := 32;
         A_BITS                     : integer := 12
      );
      port (
         CLK                        : in std_logic;
         rst_n                      : in std_logic;   
         ---
         set_addr                   : in std_logic;
         read                       : in std_logic;
         write                      : in std_logic;
         din_addr                   : in std_logic_vector(W_BITS-1 DOWNTO 0);
         done                       : out std_logic;
         dout                       : out std_logic_vector(W_BITS-1 DOWNTO 0);
         mem_en                     : out std_logic;
         mem_we	                    : out std_logic;
         mem_addr                   : out std_logic_vector(A_BITS-1 DOWNTO 0);
         mem_datain                 : out std_logic_vector(W_BITS-1 DOWNTO 0);
         mem_dataout                : in std_logic_vector(W_BITS-1 DOWNTO 0);
         mem_ready                  : in std_logic
      );
   end component;

   component sumavg is
      generic (
         W_BITS                     : integer := 32;
         A_BITS                     : integer := 12;
         K_BITS                     : integer := 8
      );
      port (
         CLK                        : in std_logic;
         rst_n                      : in std_logic;
            -- inputs
         start                      : in std_logic;
         abort                      : in std_logic;
         ptr1                       : in std_logic_vector(A_BITS-1 downto 0);
         ptr2                       : in std_logic_vector(A_BITS-1 downto 0);
         len                        : in std_logic_vector(K_BITS-1 downto 0);
         mem_dataout                : in std_logic_vector(W_BITS-1 downto 0);
         mem_ready                  : in std_logic;
            -- outputs
         done                       : out std_logic;
         result                     : out std_logic_vector(W_BITS-1 downto 0);
         mem_en                     : out std_logic;
         mem_we                     : out std_logic;
         mem_addr                   : out std_logic_vector(A_BITS-1 downto 0);
         mem_datain                 : out std_logic_vector(W_BITS-1 downto 0)
      );
   end component;

   component memmux is
   generic (
      W_BITS                        : integer := 32;
      A_BITS                        : integer := 12
   );
   port (
      CLK                           : in std_logic;
      rst_n                         : in std_logic;
      ---
      ma_mem_en                     : in std_logic;
      ma_mem_we                     : in std_logic;
      ma_mem_addr                   : in std_logic_vector(A_BITS-1 DOWNTO 0);
      ma_mem_datain                 : in std_logic_vector(W_BITS-1 DOWNTO 0);
      ma_mem_dataout                : out std_logic_vector(W_BITS-1 DOWNTO 0);
      ma_mem_ready                  : out std_logic;
      dev_mem_en                    : in std_logic;
      dev_mem_we                    : in std_logic;
      dev_mem_addr                  : in std_logic_vector(A_BITS-1 DOWNTO 0);
      dev_mem_datain                : in std_logic_vector(W_BITS-1 DOWNTO 0);
      dev_mem_dataout               : out std_logic_vector(W_BITS-1 DOWNTO 0);
      dev_mem_ready                 : out std_logic;
      mem_en                        : out std_logic;
      mem_we                        : out std_logic;
      mem_addr                      : out std_logic_vector(A_BITS-1 DOWNTO 0);
      mem_datain                    : out std_logic_vector(W_BITS-1 DOWNTO 0);
      mem_dataout                   : in std_logic_vector(W_BITS-1 DOWNTO 0);
      mem_ready                     : in std_logic
   );
   end component;

   component memory is
   port(
      CLK                 : in std_logic;
      address             : in std_logic_vector(11 downto 0);
      enable              : in std_logic; 
      we                  : in std_logic; 
      ready               : out std_logic;
      datain              : in std_logic_vector(31 downto 0);
      dataout             : out std_logic_vector(31 downto 0)
   ); 
   end component;

---------- signals ----------
signal sig_ma_set_addr              : std_logic;
signal sig_ma_read                  : std_logic;
signal sig_ma_write                 : std_logic;
signal sig_ma_din_addr              : std_logic_vector(W_BITS-1 DOWNTO 0);
signal sig_ma_done                  : std_logic;
signal sig_ma_dout                  : std_logic_vector(W_BITS-1 DOWNTO 0);
signal sig_dev_abort                : std_logic;
signal sig_dev_start                : std_logic;
signal sig_dev_ptr1                 : std_logic_vector(A_BITS-1 DOWNTO 0);
signal sig_dev_ptr2                 : std_logic_vector(A_BITS-1 DOWNTO 0);
signal sig_dev_len                  : std_logic_vector(K_BITS-1 DOWNTO 0);
signal sig_dev_done                 : std_logic;
signal sig_dev_result               : std_logic_vector(W_BITS-1 DOWNTO 0);
signal sig_ma_mem_en                : std_logic;
signal sig_ma_mem_we                : std_logic;
signal sig_ma_mem_addr              : std_logic_vector(A_BITS-1 DOWNTO 0);
signal sig_ma_mem_datain            : std_logic_vector(W_BITS-1 DOWNTO 0);
signal sig_ma_mem_dataout           : std_logic_vector(W_BITS-1 DOWNTO 0);
signal sig_ma_mem_ready             : std_logic;
signal sig_dev_mem_en               : std_logic; 
signal sig_dev_mem_we               : std_logic;
signal sig_dev_mem_addr             : std_logic_vector(A_BITS-1 DOWNTO 0);
signal sig_dev_mem_datain           : std_logic_vector(W_BITS-1 DOWNTO 0);
signal sig_dev_mem_dataout          : std_logic_vector(W_BITS-1 DOWNTO 0);
signal sig_dev_mem_ready            : std_logic;
signal sig_mem_en                   : std_logic;
signal sig_mem_we                   : std_logic;
signal sig_mem_addr                 : std_logic_vector(A_BITS-1 DOWNTO 0);
signal sig_mem_datain               : std_logic_vector(W_BITS-1 DOWNTO 0);
signal sig_mem_dataout              : std_logic_vector(W_BITS-1 DOWNTO 0);
signal sig_mem_ready                : std_logic;
  
begin
   DIS : dispatcher 
      generic map (
         N_BITS, W_BITS, A_BITS, K_BITS
      ) 
      port map (
         CLK, rst_n,
         abort => sys_abort,
         start => sys_start,
         input => sys_input,
         done => sys_done,
         output => sys_output,
         ma_set_addr => sig_ma_set_addr,
         ma_read => sig_ma_read,
         ma_write => sig_ma_write,
         ma_din_addr => sig_ma_din_addr,
         ma_done => sig_ma_done,
         ma_dout => sig_ma_dout,
         dev_abort => sig_dev_abort,
         dev_start => sig_dev_start,
         dev_ptr1 => sig_dev_ptr1,
         dev_ptr2 => sig_dev_ptr2,
         dev_len => sig_dev_len,
         dev_done => sig_dev_done,
         dev_result => sig_dev_result
      );
   
   MA : memaccess
      generic map (
         W_BITS, A_BITS
      )
      port map (
         CLK, rst_n,
         set_addr => sig_ma_set_addr,
         read => sig_ma_read,
         write => sig_ma_write,
         din_addr => sig_ma_din_addr,
         done => sig_ma_done,
         dout => sig_ma_dout,
         mem_en => sig_ma_mem_en,
         mem_we => sig_ma_mem_we,
         mem_addr => sig_ma_mem_addr,
         mem_datain => sig_ma_mem_datain,
         mem_dataout => sig_ma_mem_dataout,
         mem_ready => sig_ma_mem_ready
      );

   DEV : sumavg
      generic map (
         W_BITS, A_BITS, K_BITS 
      )
      port map (
         CLK, rst_n,
         start => sig_dev_start,
         abort => sig_dev_abort,
         ptr1 => sig_dev_ptr1,
         ptr2 => sig_dev_ptr2,
         len => sig_dev_len,
         mem_dataout => sig_dev_mem_dataout,
         mem_ready => sig_dev_mem_ready,
         done => sig_dev_done,
         result => sig_dev_result,
         mem_en => sig_dev_mem_en,
         mem_we => sig_dev_mem_we,
         mem_addr => sig_dev_mem_addr,
         mem_datain => sig_dev_mem_datain
      );

   MMUX : memmux
      generic map (
         W_BITS, A_BITS
      )
      port map (
         CLK, rst_n,
         ma_mem_en => sig_ma_mem_en,
         ma_mem_we => sig_ma_mem_we,
         ma_mem_addr => sig_ma_mem_addr,
         ma_mem_datain => sig_ma_mem_datain,
         ma_mem_dataout => sig_ma_mem_dataout,
         ma_mem_ready => sig_ma_mem_ready,
         dev_mem_en => sig_dev_mem_en,
         dev_mem_we => sig_dev_mem_we,
         dev_mem_addr => sig_dev_mem_addr,
         dev_mem_datain => sig_dev_mem_datain,
         dev_mem_dataout => sig_dev_mem_dataout,
         dev_mem_ready => sig_dev_mem_ready,
         mem_en => sig_mem_en,
         mem_we => sig_mem_we,
         mem_addr => sig_mem_addr,
         mem_datain => sig_mem_datain,
         mem_dataout => sig_mem_dataout,
         mem_ready => sig_mem_ready
      );

   MEM : memory
      port map (
         CLK,
         address => sig_mem_addr,
         enable => sig_mem_en,
         we => sig_mem_we,
         ready => sig_mem_ready,
         datain => sig_mem_datain,
         dataout => sig_mem_dataout
      );

end rtl;
------------------------------------------------
