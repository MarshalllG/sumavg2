library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
   port (
      CLK                           : in std_logic;
      rst_n                         : in std_logic;
      ---
      RXD                           : in  std_logic;
      TXD                           : out std_logic
   );
end toplevel;

architecture rtl of toplevel is
   
   use work.system_pkg.all;

   component serial_to_device is
	port (
		CLK	: in  std_logic;
		rst_n	: in  std_logic;

		RXD	: in  std_logic;
		TXD	: out std_logic;

		abort	: out std_logic;
		start	: out std_logic;
		input	: out std_logic_vector(39 downto 0);
		done	: in  std_logic;
		output	: in  std_logic_vector(39 downto 0)
	);
   end component;

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
  
---------- signals ----------
signal sig_abort                    : std_logic;
signal sig_start                    : std_logic;
signal sig_input                    : std_logic_vector(39 downto 0);
signal sig_done                     : std_logic;
signal sig_output                   : std_logic_vector(39 DOWNTO 0);

begin

   SER : serial_to_device 
      port map (
         CLK, rst_n,
         RXD => RXD,
         TXD => TXD,
         abort => sig_abort,
         start => sig_start,
         input => sig_input,
         done => sig_done,
         output => sig_output
      );
   
   SYS : system
      generic map (
         N_BITS => 40,
         W_BITS => 32,
         A_BITS => 12,
         K_BITS => 8
      )
      port map (
      CLK => CLK,
      rst_n => rst_n,
      sys_abort => sig_abort,
      sys_start => sig_start,
      sys_input => sig_input,
      sys_done => sig_done,
      sys_output => sig_output
   );

end rtl;
------------------------------------------------
