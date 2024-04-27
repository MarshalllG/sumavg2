------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package memaccess_ctrl_pkg is
component memaccess_ctrl is
    port (
        CLK, rst_n                      : in std_logic;
            -- inputs
        set_addr                        : in std_logic;
        read                            : in std_logic;
        write                           : in std_logic;
        mem_ready                       : in std_logic;
            -- control outputs
        load_R_address                  : out std_logic;
        sel_R_address	                : out std_logic;
        set_mem_datain                  : out std_logic;
        set_mem_dataout                 : out std_logic;
        done                            : out std_logic;
        mem_en                          : out std_logic;
        mem_we                          : out std_logic
    );
    end component;
end memaccess_ctrl_pkg;
------------------------------------------------


------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memaccess_ctrl is
    port (
        CLK, rst_n                      : in std_logic;
            -- inputs
        set_addr                        : in std_logic;
        read                            : in std_logic;
        write                           : in std_logic;
        mem_ready                       : in std_logic;
            -- control outputs
        load_R_address                  : out std_logic;
        sel_R_address	                : out std_logic;
        set_mem_datain                  : out std_logic;
        set_mem_dataout                 : out std_logic;
        done                            : out std_logic;
        mem_en                          : out std_logic;
        mem_we                          : out std_logic
    );
end memaccess_ctrl;


architecture behav of memaccess_ctrl is
    type statetype is (INIT, WAITMEM);
    signal state, nextstate : statetype;
 
begin
    -- ctrl unit: next state
    process (state, set_addr, read, write, mem_ready)
    begin
        case state is
            
            when INIT =>
                if set_addr = '1' then
                    nextstate <= INIT;
                else 
                    if read = '1' then
                        nextstate <= WAITMEM;
                    else 
                        if write = '1' then
                            nextstate <= WAITMEM;
                        else
                            nextstate <= INIT;
                        end if;
                    end if;
                end if;

            when WAITMEM =>
                if mem_ready = '1' then
                    nextstate <= INIT;
                else
                    nextstate <= WAITMEM;
                end if;
        
            when others =>
                nextstate <= INIT;

        end case;
    end process;

state <= INIT when rst_n = '0' else nextstate when rising_edge(CLK);

-- OUTPUTS
load_R_address              <= '1'          when (state = INIT and set_addr = '1') or
                                            (state = WAITMEM and mem_ready = '1') else '0';
sel_R_address               <= '1'          when (state = WAITMEM and mem_ready = '1') else '0';	
set_mem_datain              <= '1'          when state = INIT and set_addr = '0' and read = '0' and write = '1' else '0';
set_mem_dataout             <= '1'          when state = INIT else '0';	    
mem_en                      <= '1'          when state = INIT and (read = '1' or write = '1') else '0';
mem_we                      <= '1'          when state = INIT and write = '1' else '0';
done                        <= '1'          when state = INIT else '0'; 
end behav;