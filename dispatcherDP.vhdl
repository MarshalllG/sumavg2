------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package dispatcher_dp_pkg is
component dispatcher_dp is
    generic (
        N_BITS                              : integer := 40;
        W_BITS                              : integer := 32;
        A_BITS                              : integer := 12;
        K_BITS                              : integer := 8
    );
    port (
            CLK, rst_n                      : in std_logic;
            -- data inputs
            input                           : in std_logic_vector(N_BITS-1 DOWNTO 0);
            -- data outputs
            output                          : out std_logic_vector(N_BITS-1 DOWNTO 0);
            ma_din_addr                     : out std_logic_vector(W_BITS-1 DOWNTO 0);
            dev_ptr1                        : out std_logic_vector(A_BITS-1 DOWNTO 0);
            dev_ptr2                        : out std_logic_vector(A_BITS-1 DOWNTO 0);
            dev_len                         : out std_logic_vector(K_BITS-1 DOWNTO 0);
            -- control signals
            load_R_dataout                  : in std_logic;
            sel_R_dataout                   : in std_logic;
            set_ma_din_addr                 : in std_logic;
            set_dev_ptr1                    : in std_logic;
            set_dev_ptr2                    : in std_logic;
            set_dev_len                     : in std_logic;
            set_output                      : in std_logic;
            -- status signals
            input_hi                        : out std_logic_vector(K_BITS-1 DOWNTO 0);	   
            ma_dout                         : in std_logic_vector(W_BITS-1 DOWNTO 0);
            dev_result                      : in std_logic_vector(W_BITS-1 DOWNTO 0)
        );
	end component;
end dispatcher_dp_pkg;
------------------------------------------------


------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dispatcher_dp is
    generic (
                N_BITS                      : integer := 40;
                W_BITS                      : integer := 32;
                A_BITS                      : integer := 12;
                K_BITS			              : integer := 8
	 );
    port (
            CLK, rst_n                      : in std_logic;
            -- data inputs
            input                           : in std_logic_vector(N_BITS-1 DOWNTO 0);
            -- data outputs
            output                          : out std_logic_vector(N_BITS-1 DOWNTO 0);
            ma_din_addr                     : out std_logic_vector(W_BITS-1 DOWNTO 0);
            dev_ptr1                        : out std_logic_vector(A_BITS-1 DOWNTO 0);
            dev_ptr2                        : out std_logic_vector(A_BITS-1 DOWNTO 0);
            dev_len                         : out std_logic_vector(K_BITS-1 DOWNTO 0);
            -- control signals
            load_R_dataout                  : in std_logic;
            sel_R_dataout                   : in std_logic;
            set_ma_din_addr                 : in std_logic;
            set_dev_ptr1                    : in std_logic;
            set_dev_ptr2                    : in std_logic;
            set_dev_len                     : in std_logic;
            set_output                      : in std_logic;
            -- status signals
            input_hi                        : out std_logic_vector(K_BITS-1 DOWNTO 0);
            ma_dout                         : in std_logic_vector(W_BITS-1 DOWNTO 0);
            dev_result                      : in std_logic_vector(W_BITS-1 DOWNTO 0)
        );
end dispatcher_dp;


architecture s of dispatcher_dp is
    signal R_dataout, R_dataout_in          : std_logic_vector(N_BITS-1 DOWNTO 0);
    signal input_lo                         : std_logic_vector(W_BITS-1 DOWNTO 0);

begin
   
    regs: process(rst_n, CLK)
    begin
	if rst_n = '0' then
	    R_dataout <= (others => '0');
	elsif rising_edge(CLK) then
	    if load_R_dataout = '1' then
		R_dataout <= R_dataout_in;
	    end if;
	end if;
    end process regs;

    -- MUX for R_dataout
    R_dataout_in <= "00000000" & ma_dout when sel_R_dataout = '0' else "00000000" & dev_result;

    -- status signals
    input_hi <= input(N_BITS-1 DOWNTO W_BITS);
    input_lo <= input(W_BITS-1 DOWNTO 0);

    -- data outputs                         
    ma_din_addr         <= input_lo                     when set_ma_din_addr = '1' else (others => '-');
    dev_ptr1            <= input(11 DOWNTO 0)           when set_dev_ptr1 = '1' else (others => '-');          
    dev_ptr2            <= input(23 DOWNTO 12)          when set_dev_ptr2 = '1' else (others => '-');
    dev_len             <= input(31 DOWNTO 24)          when set_dev_len = '1' else (others => '-');
    output              <= R_dataout;
end s;