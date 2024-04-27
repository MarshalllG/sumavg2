------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package dispatcher_pkg is
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
end dispatcher_pkg;
------------------------------------------------


------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.dispatcher_ctrl_pkg.all;
use work.dispatcher_dp_pkg.all;

entity dispatcher is
	generic (
			N_BITS				: integer := 40;
			W_BITS				: integer := 32;
			A_BITS				: integer := 12;
			K_BITS				: integer := 8
	);
	port (
			CLK		                : in std_logic;
			rst_n				: in std_logic;
			
			abort				: in std_logic;
			start				: in std_logic;
			input				: in std_logic_vector(N_BITS-1 DOWNTO 0);
                        output                          : out std_logic_vector(N_BITS-1 DOWNTO 0);
			done				: out std_logic;
			ma_set_addr			: out std_logic;
			ma_read				: out std_logic;
			ma_write			: out std_logic;
			ma_din_addr			: out std_logic_vector(W_BITS-1 DOWNTO 0);
			ma_done				: in std_logic;
			ma_dout				: in std_logic_vector(W_BITS-1 DOWNTO 0);
			dev_abort			: out std_logic;
			dev_start			: out std_logic;
			dev_ptr1			: out std_logic_vector(A_BITS-1 DOWNTO 0);
			dev_ptr2			: out std_logic_vector(A_BITS-1 DOWNTO 0);
			dev_len				: out std_logic_vector(K_BITS-1 DOWNTO 0);
			dev_done			: in std_logic;
			dev_result			: in std_logic_vector(W_BITS-1 DOWNTO 0)
	);
	end dispatcher;

architecture s of dispatcher is
	signal load_R_dataout			        : std_logic;
	signal sel_R_dataout			        : std_logic;
	signal set_ma_din_addr 			        : std_logic;
	signal set_dev_ptr1			        : std_logic;
	signal set_dev_ptr2			        : std_logic;
	signal set_dev_len			        : std_logic;
	signal input_hi				        : std_logic_vector(K_BITS-1 DOWNTO 0);
        signal set_output                               : std_logic;

begin
	CTRL: dispatcher_ctrl
		generic map (
			K_BITS				=> K_BITS
		)
		port map (
			CLK				=> CLK,
			rst_n				=> rst_n,
			abort 				=> abort,
			start				=> start,
			done 				=> done,
			ma_set_addr			=> ma_set_addr,
			ma_read				=> ma_read,
			ma_write			=> ma_write,
			ma_done				=> ma_done,
			dev_abort			=> dev_abort,
			dev_start			=> dev_start,
			dev_done			=> dev_done,
			input_hi			=> input_hi,
			load_R_dataout		        => load_R_dataout,
			sel_R_dataout		        => sel_R_dataout,
			set_ma_din_addr		        => set_ma_din_addr,
			set_dev_ptr1		        => set_dev_ptr1,
			set_dev_ptr2		        => set_dev_ptr2,
			set_dev_len		        => set_dev_len
		);

	DP: dispatcher_dp
		generic map (
			N_BITS				=> N_BITS,
			W_BITS				=> W_BITS,
			A_BITS				=> A_BITS,
			K_BITS				=> K_BITS
		)
		port map (
			CLK				=> CLK,
			rst_n				=> rst_n,
			input				=> input,
                        output                          => output,
			ma_din_addr			=> ma_din_addr,
			ma_dout				=> ma_dout,
			dev_ptr1			=> dev_ptr1,
			dev_ptr2			=> dev_ptr2,
			dev_len				=> dev_len,
			dev_result			=> dev_result,
			input_hi			=> input_hi,
			load_R_dataout		        => load_R_dataout,
			sel_R_dataout		        => sel_R_dataout,
			set_ma_din_addr		        => set_ma_din_addr,
			set_dev_ptr1		        => set_dev_ptr1,
			set_dev_ptr2		        => set_dev_ptr2,
			set_dev_len			=> set_dev_len,
                        set_output                      => set_output
		);
end s;
------------------------------------------------