--
--  Copyright 2015-2026 Oleg Belousov <belousov.oleg@gmail.com>,
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

entity k32_q is
    generic (
        mul_stages      : integer := 4
    );
    port (
        clk             : in std_logic;
        rst             : in std_logic;

        a               : in unsigned(CELL_BITS-1 downto 0);
        b               : in unsigned(CELL_BITS-1 downto 0);

        mul_en          : in std_logic;
        mul_res         : out unsigned(CELL_BITS-1 downto 0);
        add_res         : out unsigned(CELL_BITS-1 downto 0);
        sub_res         : out unsigned(CELL_BITS-1 downto 0)
    );
end k32_q;

architecture rtl of k32_q is
    constant MAX_VAL : signed(33 downto 0) := to_signed(2147483647, CELL_BITS + 2);
    constant MIN_VAL : signed(33 downto 0) := to_signed(-2147483648, CELL_BITS + 2);

    type pipe_array is array (0 to mul_stages - 1) of signed(CELL_BITS * 2 - 1 downto 0);

    signal mul_pipe : pipe_array := (others => (others => '0'));
    signal mul_last : unsigned(CELL_BITS * 2 - 1 downto 0);

    signal add_pre : signed(CELL_BITS + 1 downto 0);
    signal sub_pre : signed(CELL_BITS + 1 downto 0);

    attribute use_dsp : string;
    attribute use_dsp of mul_pipe : signal is "yes";

begin

    mul_last <= unsigned(mul_pipe(mul_stages - 1));
    mul_res <= mul_last(CELL_BITS * 2 - 2 downto CELL_BITS - 1);

    add_pre <= resize(signed(a), add_pre'length) + resize(signed(b), add_pre'length);
    sub_pre <= resize(signed(a), sub_pre'length) - resize(signed(b), sub_pre'length);

    -- Saturation

    process (add_pre) begin
        if add_pre > MAX_VAL then
            add_res <= x"7FFFFFFF";
        elsif add_pre < MIN_VAL then
            add_res <= x"80000000";
        else
            add_res <= unsigned(add_pre(CELL_BITS - 1 downto 0));
        end if;
    end process;

    process (sub_pre) begin
        if sub_pre > MAX_VAL then
            sub_res <= x"7FFFFFFF";
        elsif sub_pre < MIN_VAL then
            sub_res <= x"80000000";
        else
            sub_res <= unsigned(sub_pre(CELL_BITS - 1 downto 0));
        end if;
    end process;

    -- Mult pipe

    process (clk, rst) begin
        if rising_edge(clk) then
            if rst = '1' then
                mul_pipe <= (others => (others => '0'));
            else
                if mul_en = '1' then
                    if a = x"80000000" and b = x"80000000" then
                        mul_pipe(0)(CELL_BITS * 2 - 2 downto CELL_BITS - 1) <= x"7FFFFFFF";
                    else
                        mul_pipe(0) <= signed(a) * signed(b);
                    end if;
                else
                    for i in 1 to mul_stages - 1 loop
                        mul_pipe(i) <= mul_pipe(i - 1);
                    end loop;
                end if;
            end if;
        end if;
    end process;

end;
