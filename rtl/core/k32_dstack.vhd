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

entity k32_dstack is
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        en              : in std_logic;

        din             : in dstack_in_type;
        dout            : out dstack_out_type
    );
end k32_dstack;

architecture rtl of k32_dstack is

    signal stack        : stack_type := (others => (others => '0'));

    signal sp           : unsigned(STACK_BITS-1 downto 0);
    signal sp_next      : unsigned(STACK_BITS-1 downto 0) := (others => '0');
    signal t            : unsigned(CELL_BITS-1 downto 0);
    signal n            : unsigned(CELL_BITS-1 downto 0);

begin

    n <= stack(to_integer(unsigned(sp)));

    dout.n <= n;
    dout.t <= t;
    dout.sp <= sp;

    process (din, sp) begin
        sp_next <= sp;

        if din.op.push = '1' then
            sp_next <= sp + 1;
        elsif din.op.pop = '1' then
            sp_next <= sp - 1;
        end if;
    end process;

    process (clk, rst, en, din, sp_next, t) begin
        if rising_edge(clk) then
            if rst = '1' then
                t <= (others => '0');
                sp <= (others =>'0');
            elsif en = '1' then
                sp <= sp_next;

                if din.t_we = '1' then
                    t <= din.t;
                elsif din.op.pop = '1' then
                    t <= n;
                end if;

                if din.we = '1' or din.op.push = '1' then
                    stack(to_integer(unsigned(sp_next))) <= t;
                end if;
            end if;
        end if;
    end process;

end;
