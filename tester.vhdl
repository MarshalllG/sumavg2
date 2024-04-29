----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package tester_pkg is
component tester is
	generic (
		W_BITS		: natural := 32;
		A_BITS		: natural := 12;
		K_BITS		: natural := 8;
		N_BITS		: natural := 40
	);
	port (
		CLK             : in  std_logic;
		rst_n		: in  std_logic;
		abort 		: out std_logic;
		start		: out std_logic;
		input_data	: out std_logic_vector(N_BITS - 1 downto 0);
		done		: in  std_logic;
		output_data	: in  std_logic_vector(N_BITS - 1 downto 0);
		finished	: out std_logic
	);
end component;
end tester_pkg;
----------------------------------------------------------------------

----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tester is
	generic (
		W_BITS		: natural := 32;
		A_BITS		: natural := 12;
		K_BITS		: natural := 8;
		N_BITS		: natural := 40
	);
	port (
		CLK		: in  std_logic;
		rst_n		: in  std_logic;
		abort 		: out std_logic;
		start		: out std_logic;
		input_data	: out std_logic_vector(N_BITS - 1 downto 0);
		done		: in  std_logic;
		output_data	: in  std_logic_vector(N_BITS - 1 downto 0);
		finished	: out std_logic
	);
end entity;

architecture behav of tester is
	type statetype is (S_INIT, S_TEST, S_WAIT, S_FINAL_WAIT, S_FINISHED);
	signal state, nextstate				: statetype;

	signal R_cnt, in_R_cnt	: integer;
	signal load_R_cnt	: std_logic;

	constant CMD_SA		: integer := 0;
	constant CMD_RD		: integer := 1;
	constant CMD_WR		: integer := 2;
	constant CMD_GO		: integer := 100;
	constant NODATA		: integer := -1;

	type array_of_integers is array (natural range <>) of integer;
	constant COMMANDS	: array_of_integers := (CMD_SA, CMD_WR, CMD_WR, CMD_WR, CMD_SA, CMD_WR, CMD_WR, CMD_WR, CMD_GO, CMD_GO, CMD_GO);
        constant DATA		: array_of_integers := (10, 15204352, 63111168, 117178368, 16, 50331648, 82116608, 2147483647, 17, 18, 10);
	constant ADDR1		: array_of_integers := (NODATA, NODATA, NODATA, NODATA, NODATA, NODATA, NODATA, NODATA, 10, 11, 10);
	constant ADDR2		: array_of_integers := (NODATA, NODATA, NODATA, NODATA, NODATA, NODATA, NODATA, NODATA, 16, 16, 16);
	constant LEN		: array_of_integers := (NODATA, NODATA, NODATA, NODATA, NODATA, NODATA, NODATA, NODATA, 3, 2, 0);

begin
	abort <= '0';

	regs_process: process(CLK, rst_n)
	begin
		if rst_n = '0' then
			state <= S_INIT;
			R_cnt <= 0;
		elsif rising_edge(CLK) then
			state <= nextstate;
			if load_R_cnt = '1' then
				R_cnt <= in_R_cnt;
			end if;
		end if;
	end process regs_process;

	ns_process: process (state, done, R_cnt)
		variable request	: std_logic_vector(N_BITS - W_BITS - 1 downto 0);
		variable wdata		: std_logic_vector(W_BITS - 1 downto 0);
		variable ptr1		: std_logic_vector(A_BITS - 1 downto 0);
		variable ptr2		: std_logic_vector(A_BITS - 1 downto 0);
		variable veclen		: std_logic_vector(W_BITS - 2 * A_BITS - 1 downto 0);
		variable cmd		: integer;
	begin
		start <= '0';
		input_data <= (others => '-');
		finished <= '0';

		in_R_cnt <= 0;
		load_R_cnt <= '0';

		case state is
			when S_INIT =>
				in_R_cnt <= 0;
				load_R_cnt <= '1';
				nextstate <= S_TEST;
			when S_TEST =>
				cmd := COMMANDS(R_cnt);
				request := std_logic_vector(to_signed(cmd, request'length));
				if cmd = CMD_GO then
					ptr1 := std_logic_vector(to_signed(ADDR1(R_cnt), A_BITS));
					ptr2 := std_logic_vector(to_signed(ADDR2(R_cnt), A_BITS));
					veclen := std_logic_vector(to_signed(LEN(R_cnt), veclen'length));
					wdata := veclen & ptr2 & ptr1;
				else
					wdata := std_logic_vector(to_signed(DATA(R_cnt), W_BITS));
				end if;
				start <= '1';
				input_data <= request & wdata;
				in_R_cnt <= R_cnt + 1;
				load_R_cnt <= '1';
				nextstate <= S_WAIT;
			when S_WAIT =>
				if done = '1' then
					if R_cnt = COMMANDS'length then
						in_R_cnt <= 0;
						load_R_cnt <= '1';
						nextstate <= S_FINAL_WAIT;
					else
						nextstate <= S_TEST;
					end if;
				else
					nextstate <= S_WAIT;
				end if;
			when S_FINAL_WAIT =>
				in_R_cnt <= R_cnt + 1;
				load_R_cnt <= '1';
				if R_cnt = 10 then
					nextstate <= S_FINISHED;
				else
					nextstate <= S_FINAL_WAIT;
				end if;
			when S_FINISHED =>
				finished <= '1';
				nextstate <= S_FINISHED;
		end case;
	end process ns_process;
end behav;
----------------------------------------------------------------------