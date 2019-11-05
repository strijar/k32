--
--  Copyright 2017 Oleg Belousov <belousov.oleg@gmail.com>,
--
--  All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
-- 
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

library work;
use work.k32_pkg.all;
use work.txt_util.all;

entity trace is
    generic (
	log_file	: string := "UNUSED"
    );
    port (
	clk		: in std_logic;
	rst		: in std_logic;
	en		: in std_logic;
	irq		: in irq_type;

	ibus_in		: in ibus_in_type;
	trace_in	: in trace_type
    );
end trace;

architecture rtl of trace is

begin

-- synthesis_off

    logger:
    if log_file /= "UNUSED" generate
	process
	    file store_file	: text open write_mode is log_file;
	    variable out_line	: line;
	begin
	    print(store_file, "PC       Instr                                                                                          Dt       Dn       SP   Rt       Rn       SP");

    	    wait until rst = '0';
    	    wait until clk = '1';
    	    wait until clk = '0';

    	    while true loop
    		write(out_line, hstr(std_logic_vector(trace_in.fetch.pc)));
    		write(out_line, string'(" "));
    		write(out_line, hstr(std_logic_vector(ibus_in.dat)));

    		if trace_in.decode.call = '1' then
    		    write(out_line, string'(" Call     : "));
    		    write(out_line, hstr(std_logic_vector(trace_in.decode.target(CELL_BITS-4 downto 0))));
    		    write(out_line, string'("                                                                "));
    		elsif trace_in.decode.jump = '1' then 
    		    write(out_line, string'(" Jump     : "));
    		    write(out_line, hstr(std_logic_vector(trace_in.decode.target(CELL_BITS-4 downto 0))));
    		    write(out_line, string'("                                                                "));
    		elsif trace_in.decode.cond_jump = '1' then
    		    write(out_line, string'(" CondJump : "));
    		    write(out_line, hstr(std_logic_vector(trace_in.decode.target(CELL_BITS-4 downto 0))));
    		    write(out_line, string'("                                                                "));
    		elsif trace_in.decode.lit = '1' then
    		    write(out_line, string'(" Lit      : "));
    		    write(out_line, hstr(std_logic_vector(trace_in.decode.target(CELL_BITS-2 downto 0))));
    		    write(out_line, string'("                                                                "));
    		elsif trace_in.decode.alu = '1' then
    		    write(out_line, string'(" ALU      : "));

    		    write(out_line, string'("A:"));
    		    case trace_in.decode.alu_a is
    		        when "000" => write(out_line, string'("Dt"));
    			when "001" => write(out_line, string'("Dn"));
    			when "010" => write(out_line, string'("Rt"));
    			when "011" => write(out_line, string'("Rn"));
    			when "100" => write(out_line, string'("cp"));
    			when "101" => write(out_line, string'("X "));
    			when "110" => write(out_line, string'("Ds"));
    			when others => write(out_line, string'("0 "));
    		    end case;
    		    write(out_line, string'(" "));

    		    write(out_line, string'("B:"));
    		    case trace_in.decode.alu_b is
    			when "00" => write(out_line, string'("X "));
    			when "01" => write(out_line, string'("Dt"));
    			when "10" => write(out_line, string'("Dn"));
    			when others => write(out_line, string'("Rt "));
    		    end case;
    		    write(out_line, string'(" "));

    		    write(out_line, string'("X:"));
    		    write(out_line, hstr(std_logic_vector(trace_in.decode.alu_x)));
    		    write(out_line, string'(" "));

    		    write(out_line, string'("Op:"));
		    case trace_in.decode.alu_op is
			when x"0" => write(out_line, string'("+   "));
			when x"1" => write(out_line, string'("-   "));
			when x"2" => write(out_line, string'("and "));
			when x"3" => write(out_line, string'("or  "));
			when x"4" => write(out_line, string'("xor "));
			when x"5" => write(out_line, string'("not "));
			when x"6" => write(out_line, string'("=   "));
	    		when x"7" => write(out_line, string'("<   "));
	    		when x"8" => write(out_line, string'("u<  "));
	    		when x"9" => write(out_line, string'("srl "));
			when x"A" => write(out_line, string'("sll "));
	    		when x"B" => write(out_line, string'("[Dt]"));
	    		when others => write(out_line, string'("??? "));
	    	    end case;
    		    write(out_line, string'(" "));

		    if trace_in.decode.alu_r_pc = '1' then
    			write(out_line, string'("Rt->PC "));
    		    else
    			write(out_line, string'("       "));
		    end if;

		    if trace_in.decode.alu_t_n = '1' then
    			write(out_line, string'("Dt->Dn "));
    		    else
    			write(out_line, string'("       "));
		    end if;

		    if trace_in.decode.alu_t_r = '1' then
    			write(out_line, string'("Dt->Rn "));
    		    else
    			write(out_line, string'("       "));
		    end if;

		    if trace_in.decode.alu_store = '1' then
    			write(out_line, string'("store  "));
    		    else
    			write(out_line, string'("       "));
		    end if;

		    if trace_in.decode.alu_byte = '1' then
    			write(out_line, string'("byte   "));
    		    else
    			write(out_line, string'("       "));
		    end if;


		    if trace_in.decode.alu_d_op.push = '1' then
			write(out_line, string'("D:push "));
		    elsif trace_in.decode.alu_d_op.pop = '1' then
			write(out_line, string'("D:pop  "));
		    else
			write(out_line, string'("       "));
		    end if;

		    if trace_in.decode.alu_r_op.push = '1' then
			write(out_line, string'("R:push "));
		    elsif trace_in.decode.alu_r_op.pop = '1' then
			write(out_line, string'("R:pop  "));
		    else
			write(out_line, string'("       "));
		    end if;
    		end if;

		write(out_line, string'(" | "));

    		write(out_line, hstr(std_logic_vector(trace_in.ds.t)));
		write(out_line, string'(" "));
    		write(out_line, hstr(std_logic_vector(trace_in.ds.n)));
		write(out_line, string'(" "));
    		write(out_line, hstr(std_logic_vector(trace_in.ds.sp)));

		write(out_line, string'(" | "));

    		write(out_line, hstr(std_logic_vector(trace_in.rs.t)));
		write(out_line, string'(" "));
    		write(out_line, hstr(std_logic_vector(trace_in.rs.n)));
		write(out_line, string'(" "));
    		write(out_line, hstr(std_logic_vector(trace_in.rs.sp)));

		if trace_in.decode.alu_r_pc = '1' or trace_in.decode.call = '1' then
		    write(out_line, LF);
		end if;

		writeLine(store_file, out_line);

        	wait until clk = '0';
    	    end loop;
	end process;
    end generate;

-- synthesis_on

end;
