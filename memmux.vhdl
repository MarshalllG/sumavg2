------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package memmux_pkg is
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
end memmux_pkg;
------------------------------------------------


------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.memmux_ctrl_pkg.all;
use work.memmux_dp_pkg.all;

entity memmux is
	generic (
           W_BITS				: integer := 32;
           A_BITS				: integer := 12
	);
	port (
           CLK                                  : in std_logic;
           rst_n				: in std_logic;

           ma_mem_en                            : in std_logic;
           ma_mem_we                            : in std_logic;
           ma_mem_addr                          : in std_logic_vector(A_BITS-1 DOWNTO 0);
           ma_mem_datain                        : in std_logic_vector(W_BITS-1 DOWNTO 0);
           ma_mem_dataout                       : out std_logic_vector(W_BITS-1 DOWNTO 0);
           ma_mem_ready                         : out std_logic;
           dev_mem_en                           : in std_logic;
           dev_mem_we                           : in std_logic;
           dev_mem_addr                         : in std_logic_vector(A_BITS-1 DOWNTO 0);
           dev_mem_datain                       : in std_logic_vector(W_BITS-1 DOWNTO 0);
           dev_mem_dataout                      : out std_logic_vector(W_BITS-1 DOWNTO 0);
           dev_mem_ready                        : out std_logic;

           mem_en                               : out std_logic;
           mem_we                               : out std_logic;
           mem_addr                             : out std_logic_vector(A_BITS-1 DOWNTO 0);
           mem_datain                           : out std_logic_vector(W_BITS-1 DOWNTO 0);
           mem_dataout                          : in std_logic_vector(W_BITS-1 DOWNTO 0);
           mem_ready                            : in std_logic
	);
	end memmux;

architecture s of memmux is

begin
	CTRL: memmux_ctrl
           port map (
              CLK			        => CLK,
              rst_n				=> rst_n,
              dev_mem_en                        => dev_mem_en,
              ma_mem_en                         => ma_mem_en,
              mem_ready                         => mem_ready
           );

	DP: memmux_dp
           generic map (
              W_BITS				=> W_BITS,
              A_BITS				=> A_BITS
           )
           port map (
              CLK                               => CLK,
              rst_n				=> rst_n,
              dev_mem_datain                    => dev_mem_datain,
              dev_mem_addr                      => dev_mem_addr,
              dev_mem_dataout                   => dev_mem_dataout,
              ma_mem_datain                     => ma_mem_datain,
	      ma_mem_addr                       => ma_mem_addr,
              mem_dataout                       => mem_dataout,
              dev_mem_we                        => dev_mem_we,
              dev_mem_en                        => dev_mem_en,
              dev_mem_ready                     => dev_mem_ready,
              ma_mem_en                         => ma_mem_en,
              ma_mem_we                         => ma_mem_we,
              mem_en                            => mem_en,
              mem_we                            => mem_we,
              mem_ready                         => mem_ready,
              ma_mem_ready                      => ma_mem_ready,
	      ma_mem_dataout                    => ma_mem_dataout,
              mem_addr                          => mem_addr,
              mem_datain                        => mem_datain
          );
end s;
------------------------------------------------
