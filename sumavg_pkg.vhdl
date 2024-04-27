library ieee;
use ieee.std_logic_1164.all;

package sumavg_pkg is

component sumavg is
	generic (
		W_BITS							: integer := 32;
		A_BITS 							: integer := 12;
		K_BITS							: integer := 8
	);
	port (
			CLK							: in std_logic;
			rst_n              			: in std_logic;
					-- inputs
			start             			: in std_logic;
			abort                   	: in std_logic;
			ptr1						: in std_logic_vector(A_BITS-1 downto 0);
			ptr2						: in std_logic_vector(A_BITS-1 downto 0);
			len                  		: in std_logic_vector(K_BITS-1 downto 0);
			mem_dataout 				: in std_logic_vector(W_BITS-1 downto 0);
			mem_ready					: in std_logic;
					-- outputs
			done             			: out std_logic;
			result 						: out std_logic_vector(W_BITS-1 downto 0);
			mem_en                  	: out std_logic;
			mem_we        				: out std_logic;
			mem_addr					: out std_logic_vector(A_BITS-1 downto 0);
			mem_datain					: out std_logic_vector(W_BITS-1 downto 0)
	);
end component;

end sumavg_pkg;