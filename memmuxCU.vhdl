------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package memmux_ctrl_pkg is
component memmux_ctrl is
    port (
        CLK, rst_n                  : in std_logic;
        dev_mem_en	   	    : in std_logic;
        ma_mem_en                   : in std_logic;
        mem_ready                   : in std_logic
    );
	end component;
end memmux_ctrl_pkg;
------------------------------------------------


------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

--interface
entity memmux_ctrl is
    port (
        CLK, rst_n                  : in std_logic;
        dev_mem_en                  : in std_logic;
        ma_mem_en                   : in std_logic;
        mem_ready                   : in std_logic
    );
end memmux_ctrl;


architecture behav of memmux_ctrl is
    type statetype is (INIT, WAIT_MEM);
    signal state, nextstate : statetype;

 
begin
    -- ctrl unit: next state
    process (state, ma_mem_en, dev_mem_en, mem_ready) -- sensitivity list
    begin
        case state is
            
            when INIT =>
                if ma_mem_en = '1' or dev_mem_en = '1' then
                    nextstate <= WAIT_MEM;
                else 
                    nextstate <= INIT;
                end if;

            when WAIT_MEM =>
                if mem_ready = '1' then
                    if ma_mem_en = '1' or dev_mem_en = '1' then
                        nextstate <= INIT;
                    end if;
                else
                    nextstate <= WAIT_MEM;
                end if;
        
            when others =>
                nextstate <= INIT;

        end case;
    end process;

state <= INIT when rst_n = '0' else nextstate when rising_edge(CLK);

end behav;