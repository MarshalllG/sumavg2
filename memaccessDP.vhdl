------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package memaccess_dp_pkg is
component memaccess_dp is
   generic (
      W_BITS                                : integer := 32;
      A_BITS                                : integer := 12
   );
   port (
      CLK, rst_n                            : in std_logic;
         -- data inputs
      mem_dataout                           : in std_logic_vector(W_BITS-1 DOWNTO 0);
      din_addr                              : in std_logic_vector(W_BITS-1 DOWNTO 0);
         -- data outputs
      mem_addr                              : out std_logic_vector(A_BITS-1 DOWNTO 0);
      mem_datain                            : out std_logic_vector(W_BITS-1 DOWNTO 0);
      dout                                  : out std_logic_vector(W_BITS-1 DOWNTO 0);
         -- control signals from CU
      load_R_address                        : in std_logic;
      sel_R_address                         : in std_logic;
      set_mem_datain                        : in std_logic;
      set_mem_dataout                       : in std_logic
   );
   end component;
end memaccess_dp_pkg;
------------------------------------------------


------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity memaccess_dp is
   generic (
      W_BITS                                : integer := 32;
      A_BITS                                : integer := 12
   );
   port (
      CLK, rst_n                            : in std_logic;
         -- data inputs
      mem_dataout                           : in std_logic_vector(W_BITS-1 DOWNTO 0);
      din_addr                              : in std_logic_vector(W_BITS-1 DOWNTO 0);
         -- data outputs
      mem_addr                              : out std_logic_vector(A_BITS-1 DOWNTO 0);
      mem_datain                            : out std_logic_vector(W_BITS-1 DOWNTO 0);
      dout                                  : out std_logic_vector(W_BITS-1 DOWNTO 0);
         -- control signals from CU
      load_R_address                        : in std_logic;
      sel_R_address                         : in std_logic;
      set_mem_datain                        : in std_logic;
      set_mem_dataout                       : in std_logic
   );
end memaccess_dp;


architecture s of memaccess_dp is
    signal R_address, R_address_in              : std_logic_vector(A_BITS-1 DOWNTO 0);
    signal adder1  			                    : std_logic_vector(R_address'range);

begin
    -- register
    --R_address <= (others => '0') when rst_n='0' else
        --R_address_in when rising_edge(CLK) and load_R_address='1';

    regs: process(rst_n, CLK)
    begin
	if rst_n = '0' then
	    R_address <= (others => '0');
	elsif rising_edge(CLK) then
	    if load_R_address = '1' then
		R_address <= R_address_in;
	    end if;
	end if;
    end process regs;

    -- MUX for R_address
    with sel_R_address select
        R_address_in <= adder1 when '1' ,
	    din_addr(A_BITS-1 DOWNTO 0) when others;

    -- ADDER
    adder1 <= std_logic_vector(unsigned(R_address) + 1);


    -- data outputs
    mem_addr            <= R_address;
    mem_datain          <= din_addr             when set_mem_datain = '1' else (others => '-');
    dout                <= mem_dataout          when set_mem_dataout = '1' else (others => '-');
end s;