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

library work;
use work.k32_pkg.all;

entity k32_dstack_ext is
    generic (
        depth           : positive := 16
    );
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        en              : in std_logic;

        din             : in dstack_in_type;
        dout            : out dstack_out_type
    );
end k32_dstack_ext;

architecture rtl of k32_dstack_ext is

    type regs_type is array(natural range 0 to depth) of unsigned(CELL_BITS-1 downto 0);

    signal r            : regs_type;
    signal sp           : unsigned(STACK_BITS-1 downto 0);

begin

    dout.t <= r(0);
    dout.n <= r(1);
    dout.sp <= sp;

    process (clk, rst, en, din) begin
        if rising_edge(clk) then
            if rst = '1' then
                for i in 0 to depth loop
                    r(i) <= (others => '0');
                end loop;

                sp <= (others => '1');
            elsif en = '1' then

                if din.op.push = '1' then
                    if din.t_we = '1' then
                        r(0) <= din.t;
                    else 
                        r(0) <= r(depth);
                    end if;

                    for i in 0 to depth-1 loop
                        r(i+1) <= r(i);
                    end loop;

                    sp <= sp + 1;
                elsif din.op.pop = '1' then
                    if din.t_we = '1' then
                        r(0) <= din.t;
                    else
                        r(0) <= r(1);
                    end if;

                    for i in 1 to depth-1 loop
                        r(i) <= r(i+1);
                    end loop;

                    r(depth) <= r(0);
                    sp <= sp - 1;

                else
                    if din.t_we = '1' then
                        r(0) <= din.t;
                    end if;

                    if din.we = '1' then
                        r(1) <= r(0);
                    end if;
                end if;
            end if;
        end if;
    end process;

end;
