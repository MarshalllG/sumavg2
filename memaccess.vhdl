------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package memaccess_pkg is
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
end memaccess_pkg;
------------------------------------------------


------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.memaccess_ctrl_pkg.all;
use work.memaccess_dp_pkg.all;

entity memaccess is
	generic (
			W_BITS				: integer := 32;
			A_BITS				: integer := 12
	);
	port (
			CLK					: in std_logic;
			rst_n				: in std_logic;

			set_addr			: in std_logic;
			read 				: in std_logic;
			write				: in std_logic;
			din_addr			: in std_logic_vector(W_BITS-1 DOWNTO 0);
			done				: out std_logic;
			dout				: out std_logic_vector(W_BITS-1 DOWNTO 0);

			mem_en				: out std_logic;
			mem_we				: out std_logic;
			mem_addr			: out std_logic_vector(A_BITS-1 DOWNTO 0);
			mem_datain			: out std_logic_vector(W_BITS-1 DOWNTO 0);
			mem_dataout			: in std_logic_vector(W_BITS-1 DOWNTO 0);
			mem_ready			: in std_logic
	);
	end memaccess;

architecture s of memaccess is
	signal load_R_address		: std_logic;
	signal sel_R_address		: std_logic;
	signal set_mem_datain		: std_logic;
	signal set_mem_dataout		: std_logic;

begin
	CTRL: memaccess_ctrl
		port map (
			CLK					=> CLK,
			rst_n				=> rst_n,
			set_addr			=> set_addr,
			read				=> read,
			write 				=> write,
			mem_ready			=> mem_ready,
			load_R_address		=> load_R_address,
			sel_R_address		=> sel_R_address,
			set_mem_datain		=> set_mem_datain,
			set_mem_dataout		=> set_mem_dataout,
			done 				=> done,
			mem_en				=> mem_en,
			mem_we				=> mem_we
		);

	DP: memaccess_dp
		generic map (
			W_BITS				=> W_BITS,
			A_BITS				=> A_BITS
		)
		port map (
                        CLK					=> CLK,
			rst_n				=> rst_n,
			mem_dataout			=> mem_dataout,
			din_addr			=> din_addr,
			mem_addr			=> mem_addr,
			mem_datain			=> mem_datain,
			dout				=> dout,
			load_R_address		=> load_R_address,
			sel_R_address		=> sel_R_address,
			set_mem_datain		=> set_mem_datain,
			set_mem_dataout		=> set_mem_dataout
		);
end s;
------------------------------------------------
