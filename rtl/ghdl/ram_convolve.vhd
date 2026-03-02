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

entity ram is
    generic (
	addr_bits	: integer := 5;
	data_bits	: integer := 16
    );
    port (
	clk	: in std_logic;
	rst	: in std_logic;

	a_addr	: in std_logic_vector(addr_bits-1 downto 0);
	a_din	: in std_logic_vector(data_bits-1 downto 0);
	a_dout	: out std_logic_vector(data_bits-1 downto 0);
        a_we	: in std_logic;

	b_en	: in std_logic;
	b_addr	: in std_logic_vector(addr_bits-1 downto 0);
	b_din	: in std_logic_vector(data_bits-1 downto 0);
	b_dout	: out std_logic_vector(data_bits-1 downto 0);
        b_we	: in std_logic_vector(3 downto 0)
    );
end ram;

architecture rtl of ram is

type ram_type is array(natural range 0 to (2**(addr_bits))-1) of std_logic_vector(data_bits-1 downto 0);

signal a_addr_word	: std_logic_vector(addr_bits-1 downto 2) := (others => '0');
signal b_addr_word	: std_logic_vector(addr_bits-1 downto 2) := (others => '0');

signal ram : ram_type :=
(
0000 => x"00000090",	--0000
0001 => x"000009E8",	--0004

0008 => x"0CCCCCCD",	--0020
0009 => x"1999999A",	--0024
0010 => x"26666666",	--0028
0011 => x"33333333",	--002C
0012 => x"40000000",	--0030
0013 => x"4CCCCCCD",	--0034
0014 => x"5999999A",	--0038
0015 => x"66666666",	--003C
0016 => x"60040004",	--0040
0017 => x"640080C0",	--0044
0018 => x"80000000",	--0048
0019 => x"64004240",	--004C
0020 => x"64050004",	--0050
0021 => x"64050004",	--0054
0022 => x"64010004",	--0058
0023 => x"603C0200",	--005C
0024 => x"64010004",	--0060
0025 => x"603C0200",	--0064
0026 => x"76B00420",	--0068
0027 => x"7C000400",	--006C
0028 => x"7C000000",	--0070
0029 => x"7EB40000",	--0074
0030 => x"64004040",	--0078
0031 => x"68980020",	--007C
0032 => x"20000058",	--0080
0033 => x"64000040",	--0084
0034 => x"70000540",	--0088
0035 => x"60020100",	--008C
0036 => x"80000020",	--0090
0037 => x"80000030",	--0094
0038 => x"80000040",	--0098
0039 => x"40000040",	--009C
0040 => x"60000000",	--00A0
0041 => x"607C0000",	--00A4

others => x"00000000"
);

begin

    a_addr_word <= a_addr(addr_bits-1 downto 2);
    b_addr_word <= b_addr(addr_bits-1 downto 2);

    process (clk, rst, a_addr_word, a_we, b_addr_word, b_we) begin
	if rising_edge(clk) then
	    if rst = '1' then
		a_dout <= (others => '0');
		b_dout <= (others => '0');
	    else
		-- Port A

		if (a_we = '1') then
		    ram(to_integer(unsigned(a_addr_word))) <= a_din;
		end if;

		a_dout <= ram(to_integer(unsigned(a_addr_word)));

		-- Port B

		if b_we(0) = '1' then
		    ram(to_integer(unsigned(b_addr_word)))(7 downto 0) <= b_din(7 downto 0);
		end if;

		if b_we(1) = '1' then
		    ram(to_integer(unsigned(b_addr_word)))(15 downto 8) <= b_din(15 downto 8);
		end if;

		if b_we(2) = '1' then
		    ram(to_integer(unsigned(b_addr_word)))(23 downto 16) <= b_din(23 downto 16);
		end if;

		if b_we(3) = '1' then
		    ram(to_integer(unsigned(b_addr_word)))(31 downto 24) <= b_din(31 downto 24);
		end if;

		b_dout <= ram(to_integer(unsigned(b_addr_word)));

	    end if;
	end if;
    end process;

end;
