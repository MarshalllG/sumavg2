library ieee;
use ieee.std_logic_1164.all;

package divider_pkg is
component divider is
	generic (
		OPSIZE		: integer := 32
	);
	port (
		CLK		: in  std_logic;
		rst_n		: in  std_logic;
		abort 		: in  std_logic;
		-- data inputs
		operand1	: in  std_logic_vector(OPSIZE - 1 downto 0);
		operand2	: in  std_logic_vector(OPSIZE - 1 downto 0);
		-- data outputs
		div		: out std_logic_vector(OPSIZE - 1 downto 0);
		remainder	: out std_logic_vector(OPSIZE - 1 downto 0);
		-- control signals
		start		: in  std_logic;
		-- status signals
		ready		: out std_logic
	);
end component;
end divider_pkg;