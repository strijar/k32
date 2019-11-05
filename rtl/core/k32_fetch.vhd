--
--  Copyright 2015 Oleg Belousov <belousov.oleg@gmail.com>,
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

library work;
use work.k32_pkg.all;

entity k32_fetch is
    port (
	clk		: in std_logic;
	rst		: in std_logic;
	en		: in std_logic;

	decode 		: in decode_type;

	ex		: in ex_type;
	fetch		: out fetch_type;

	ibus_out	: out ibus_out_type
    );
end k32_fetch;

architecture rtl of k32_fetch is

    signal pc, pc_next	: unsigned(CELL_BITS-1 downto 0) := (others => '0');
    signal target	: unsigned(CELL_BITS-1 downto 0) := (others => '0');

begin
    target <= unsigned("000" & decode.target(CELL_BITS-4 downto 0));
    ibus_out.addr <= std_logic_vector(pc_next);

    process (rst, en, decode, pc, ex, target) begin
	pc_next <= pc + 4;

	if rst = '1' or en = '0' then
	    pc_next <= pc;
	elsif decode.jump = '1' or decode.call = '1' then
	    pc_next <= target;
	elsif decode.cond_jump = '1' and ex.d_t = x"0" then
	    pc_next <= target;
	elsif decode.alu = '1' and decode.alu_r_pc = '1' then
	    pc_next <= ex.r_t;
	end if;
    end process;

    fetch.pc <= pc;

    process (clk, rst) begin
	if rising_edge(clk) then
	    if rst = '1' then
		pc <= unsigned(START_ADDR);
	    else
		pc <= pc_next;
	    end if;
	end if;
    end process;

end;
