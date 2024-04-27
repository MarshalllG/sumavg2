------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package memmux_dp_pkg is
component memmux_dp is
    generic (
        N_BITS                                          : integer := 40;
        W_BITS			                                : integer := 32;
        A_BITS 			                                : integer := 12;
        K_BITS			                                : integer := 8
    );
    port (
        CLK                                         : in std_logic;
        rst_n                                       : in std_logic;
        dev_mem_datain                              : in std_logic_vector(W_BITS-1 DOWNTO 0);
        dev_mem_addr                                : in std_logic_vector(A_BITS-1 DOWNTO 0);
        dev_mem_dataout                             : out std_logic_vector(W_BITS-1 DOWNTO 0);
        ma_mem_datain                               : in std_logic_vector(W_BITS-1 DOWNTO 0);
	ma_mem_addr                                 : in std_logic_vector(A_BITS-1 DOWNTO 0);
        mem_dataout                                 : in std_logic_vector(W_BITS-1 DOWNTO 0);
        dev_mem_we                                  : in std_logic;
        dev_mem_en                                  : in std_logic;
        dev_mem_ready                               : out std_logic;
        ma_mem_en                                   : in std_logic;
        ma_mem_we                                   : in std_logic;
        mem_en                                      : out std_logic;
        mem_we                                      : out std_logic;
        mem_ready                                   : in std_logic;
        ma_mem_ready                                : out std_logic;
	ma_mem_dataout                              : out std_logic_vector(W_BITS-1 DOWNTO 0);
        mem_addr                                    : out std_logic_vector(A_BITS-1 DOWNTO 0);
        mem_datain                                  : out std_logic_vector(W_BITS-1 DOWNTO 0)
    );
    end component;
end memmux_dp_pkg;
------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- interface
entity memmux_dp is
    generic (
        N_BITS                                      : integer := 40;
        W_BITS			                    : integer := 32;
        A_BITS 			                    : integer := 12;
        K_BITS			                    : integer := 8
    );
    port (
        CLK                                         : in std_logic;
        rst_n                                       : in std_logic;
        dev_mem_datain                              : in std_logic_vector(W_BITS-1 DOWNTO 0);
        dev_mem_addr                                : in std_logic_vector(A_BITS-1 DOWNTO 0);
        dev_mem_dataout                             : out std_logic_vector(W_BITS-1 DOWNTO 0);    
        ma_mem_datain                               : in std_logic_vector(W_BITS-1 DOWNTO 0);
        ma_mem_addr                                 : in std_logic_vector(A_BITS-1 DOWNTO 0);
        mem_dataout                                 : in std_logic_vector(W_BITS-1 DOWNTO 0);
        dev_mem_we                                  : in std_logic;
        dev_mem_en                                  : in std_logic;
        dev_mem_ready                               : out std_logic;
        ma_mem_en                                   : in std_logic;
        ma_mem_we                                   : in std_logic;
        mem_en                                      : out std_logic;
        mem_we                                      : out std_logic;
        mem_ready                                   : in std_logic;
	ma_mem_ready                                : out std_logic;
     	ma_mem_dataout                              : out std_logic_vector(W_BITS-1 DOWNTO 0);
        mem_addr                                    : out std_logic_vector(A_BITS-1 DOWNTO 0);
        mem_datain                                  : out std_logic_vector(W_BITS-1 DOWNTO 0)
    );
end memmux_dp;


architecture s of memmux_dp is

begin
    -- MUX
    with ma_mem_en select
        mem_we      <= dev_mem_we when '0',
                        ma_mem_we when others;

    with ma_mem_en select
        mem_addr    <= dev_mem_addr when '0',
                        ma_mem_addr when others;

    with ma_mem_en select
        mem_datain  <= dev_mem_datain when '0',
                        ma_mem_datain when others;

    mem_en          <= '1'          when ma_mem_en = '1' or dev_mem_en = '1' else '0';  
    
    ma_mem_dataout  <= mem_dataout;
    ma_mem_ready    <= mem_ready;
    dev_mem_dataout <= mem_dataout;
    dev_mem_ready   <= mem_ready;
end s;