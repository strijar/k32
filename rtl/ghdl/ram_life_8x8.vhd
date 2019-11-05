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
0000 => x"00000388",	--0000
0001 => x"00000900",	--0004

0008 => x"00000000",	--0020
0009 => x"00000000",	--0024
0010 => x"00000000",	--0028
0011 => x"00000000",	--002C
0012 => x"00000000",	--0030
0013 => x"00000000",	--0034
0014 => x"00000000",	--0038
0015 => x"00000000",	--003C
0016 => x"00000000",	--0040
0017 => x"00000000",	--0044
0018 => x"00000000",	--0048
0019 => x"00000000",	--004C
0020 => x"00000000",	--0050
0021 => x"00000000",	--0054
0022 => x"00000000",	--0058
0023 => x"00000000",	--005C
0024 => x"00000000",	--0060
0025 => x"00000000",	--0064
0026 => x"00000000",	--0068
0027 => x"00000000",	--006C
0028 => x"00000000",	--0070
0029 => x"00000000",	--0074
0030 => x"00000000",	--0078
0031 => x"00000000",	--007C
0032 => x"00000000",	--0080
0033 => x"00000000",	--0084
0034 => x"00000000",	--0088
0035 => x"00000000",	--008C
0036 => x"00000000",	--0090
0037 => x"00000000",	--0094
0038 => x"00000000",	--0098
0039 => x"00000000",	--009C
0040 => x"00000000",	--00A0
0041 => x"00000000",	--00A4
0042 => x"60080201",	--00A8
0043 => x"60100001",	--00AC
0044 => x"60040020",	--00B0
0045 => x"80000008",	--00B4
0046 => x"65200040",	--00B8
0047 => x"65080240",	--00BC
0048 => x"80000010",	--00C0
0049 => x"65080240",	--00C4
0050 => x"80000010",	--00C8
0051 => x"65180240",	--00CC
0052 => x"80000077",	--00D0
0053 => x"65280240",	--00D4
0054 => x"400000D0",	--00D8
0055 => x"800000A0",	--00DC
0056 => x"60A00000",	--00E0
0057 => x"65000040",	--00E4
0058 => x"60018040",	--00E8
0059 => x"64080240",	--00EC
0060 => x"400000D0",	--00F0
0061 => x"800000A0",	--00F4
0062 => x"60A00000",	--00F8
0063 => x"65000040",	--00FC
0064 => x"60A88200",	--0100
0065 => x"80000020",	--0104
0066 => x"80000080",	--0108
0067 => x"80000000",	--010C
0068 => x"000008C8",	--0110
0069 => x"80000008",	--0114
0070 => x"64020140",	--0118
0071 => x"80000000",	--011C
0072 => x"64020140",	--0120
0073 => x"68040020",	--0124
0074 => x"80000003",	--0128
0075 => x"60000001",	--012C
0076 => x"65900040",	--0130
0077 => x"64040020",	--0134
0078 => x"400008C0",	--0138
0079 => x"68000021",	--013C
0080 => x"6D620000",	--0140
0081 => x"20000124",	--0144
0082 => x"60000200",	--0148
0083 => x"60000200",	--014C
0084 => x"64080240",	--0150
0085 => x"800000A0",	--0154
0086 => x"60A00000",	--0158
0087 => x"65000040",	--015C
0088 => x"80000008",	--0160
0089 => x"65000000",	--0164
0090 => x"64040000",	--0168
0091 => x"64040000",	--016C
0092 => x"64020140",	--0170
0093 => x"64020140",	--0174
0094 => x"68040020",	--0178
0095 => x"60A08000",	--017C
0096 => x"2000018C",	--0180
0097 => x"80000023",	--0184
0098 => x"00000190",	--0188
0099 => x"8000002E",	--018C
0100 => x"40000800",	--0190
0101 => x"80000020",	--0194
0102 => x"40000800",	--0198
0103 => x"68000021",	--019C
0104 => x"6D620000",	--01A0
0105 => x"20000178",	--01A4
0106 => x"60000200",	--01A8
0107 => x"60000200",	--01AC
0108 => x"0000081C",	--01B0
0109 => x"80000154",	--01B4
0110 => x"00000114",	--01B8
0111 => x"60040020",	--01BC
0112 => x"400000AC",	--01C0
0113 => x"400000C8",	--01C4
0114 => x"400000F0",	--01C8
0115 => x"64040020",	--01CC
0116 => x"400000C8",	--01D0
0117 => x"400000F0",	--01D4
0118 => x"65000040",	--01D8
0119 => x"64040020",	--01DC
0120 => x"400000A8",	--01E0
0121 => x"400000C8",	--01E4
0122 => x"400000F0",	--01E8
0123 => x"65000040",	--01EC
0124 => x"64040020",	--01F0
0125 => x"400000AC",	--01F4
0126 => x"400000F0",	--01F8
0127 => x"65000040",	--01FC
0128 => x"64040020",	--0200
0129 => x"400000A8",	--0204
0130 => x"400000F0",	--0208
0131 => x"65000040",	--020C
0132 => x"64040020",	--0210
0133 => x"400000AC",	--0214
0134 => x"400000C0",	--0218
0135 => x"400000F0",	--021C
0136 => x"65000040",	--0220
0137 => x"64040020",	--0224
0138 => x"400000C0",	--0228
0139 => x"400000F0",	--022C
0140 => x"65000040",	--0230
0141 => x"64040020",	--0234
0142 => x"400000A8",	--0238
0143 => x"400000C0",	--023C
0144 => x"400000F0",	--0240
0145 => x"65080240",	--0244
0146 => x"400001BC",	--0248
0147 => x"64040020",	--024C
0148 => x"800000A0",	--0250
0149 => x"60A00000",	--0254
0150 => x"65000040",	--0258
0151 => x"60A08000",	--025C
0152 => x"65300040",	--0260
0153 => x"80000003",	--0264
0154 => x"65600040",	--0268
0155 => x"80000001",	--026C
0156 => x"65200040",	--0270
0157 => x"64040000",	--0274
0158 => x"800000A4",	--0278
0159 => x"60A00000",	--027C
0160 => x"65000040",	--0280
0161 => x"60018040",	--0284
0162 => x"64080240",	--0288
0163 => x"80000008",	--028C
0164 => x"65000000",	--0290
0165 => x"64040000",	--0294
0166 => x"64040000",	--0298
0167 => x"64020140",	--029C
0168 => x"64020140",	--02A0
0169 => x"68040020",	--02A4
0170 => x"40000248",	--02A8
0171 => x"68000021",	--02AC
0172 => x"6D620000",	--02B0
0173 => x"200002A4",	--02B4
0174 => x"60000200",	--02B8
0175 => x"60000200",	--02BC
0176 => x"60080200",	--02C0
0177 => x"800000A0",	--02C4
0178 => x"60A00000",	--02C8
0179 => x"800000A4",	--02CC
0180 => x"60A00000",	--02D0
0181 => x"800000A0",	--02D4
0182 => x"60010040",	--02D8
0183 => x"64000040",	--02DC
0184 => x"800000A4",	--02E0
0185 => x"60010040",	--02E4
0186 => x"64080240",	--02E8
0187 => x"8000028C",	--02EC
0188 => x"40000114",	--02F0
0189 => x"000002C4",	--02F4
0190 => x"4000087C",	--02F8
0191 => x"60040020",	--02FC
0192 => x"4000088C",	--0300
0193 => x"65000000",	--0304
0194 => x"64040000",	--0308
0195 => x"64040000",	--030C
0196 => x"64020140",	--0310
0197 => x"64020140",	--0314
0198 => x"68040020",	--0318
0199 => x"60A08000",	--031C
0200 => x"8000007C",	--0320
0201 => x"65600040",	--0324
0202 => x"2000033C",	--0328
0203 => x"64000040",	--032C
0204 => x"400000C0",	--0330
0205 => x"60040020",	--0334
0206 => x"0000035C",	--0338
0207 => x"68040020",	--033C
0208 => x"60A08000",	--0340
0209 => x"80000020",	--0344
0210 => x"65600040",	--0348
0211 => x"60000001",	--034C
0212 => x"64040020",	--0350
0213 => x"400000D8",	--0354
0214 => x"400000A8",	--0358
0215 => x"68000021",	--035C
0216 => x"6D620000",	--0360
0217 => x"20000318",	--0364
0218 => x"60000200",	--0368
0219 => x"60000200",	--036C
0220 => x"00000864",	--0370
0221 => x"400008A0",	--0374
0222 => x"7C2A200A",	--0378
0223 => x"7C2A2020",	--037C
0224 => x"002A2A2A",	--0380
0225 => x"000002F8",	--0384
0226 => x"80000020",	--0388
0227 => x"800000A0",	--038C
0228 => x"60010040",	--0390
0229 => x"64000040",	--0394
0230 => x"80000020",	--0398
0231 => x"80000008",	--039C
0232 => x"65000040",	--03A0
0233 => x"800000A4",	--03A4
0234 => x"60010040",	--03A8
0235 => x"64000040",	--03AC
0236 => x"80000000",	--03B0
0237 => x"40000374",	--03B4
0238 => x"80000002",	--03B8
0239 => x"64020140",	--03BC
0240 => x"80000000",	--03C0
0241 => x"64020140",	--03C4
0242 => x"400001B4",	--03C8
0243 => x"4000081C",	--03CC
0244 => x"400002EC",	--03D0
0245 => x"68000021",	--03D4
0246 => x"6D620000",	--03D8
0247 => x"200003C8",	--03DC
0248 => x"60000200",	--03E0
0249 => x"60000200",	--03E4
0250 => x"60F00000",	--03E8

0512 => x"80010000",	--0800
0513 => x"60010040",	--0804
0514 => x"64000040",	--0808
0515 => x"80010004",	--080C
0516 => x"60A40020",	--0810
0517 => x"20000810",	--0814
0518 => x"64080240",	--0818
0519 => x"8000000A",	--081C
0520 => x"00000800",	--0820
0521 => x"65000000",	--0824
0522 => x"64040000",	--0828
0523 => x"64040000",	--082C
0524 => x"64020140",	--0830
0525 => x"64020140",	--0834
0526 => x"68040020",	--0838
0527 => x"60A08000",	--083C
0528 => x"40000800",	--0840
0529 => x"68000021",	--0844
0530 => x"6D620000",	--0848
0531 => x"20000838",	--084C
0532 => x"60000200",	--0850
0533 => x"60000200",	--0854
0534 => x"60080200",	--0858
0535 => x"64040020",	--085C
0536 => x"640C0220",	--0860
0537 => x"64000040",	--0864
0538 => x"64080240",	--0868
0539 => x"60040020",	--086C
0540 => x"60000001",	--0870
0541 => x"64040000",	--0874
0542 => x"60A88200",	--0878
0543 => x"64020140",	--087C
0544 => x"64040000",	--0880
0545 => x"68040220",	--0884
0546 => x"640C0200",	--0888
0547 => x"4000087C",	--088C
0548 => x"64020140",	--0890
0549 => x"4000087C",	--0894
0550 => x"68040220",	--0898
0551 => x"60080200",	--089C
0552 => x"68000020",	--08A0
0553 => x"60A08000",	--08A4
0554 => x"69040020",	--08A8
0555 => x"60800001",	--08AC
0556 => x"60900001",	--08B0
0557 => x"60000004",	--08B4
0558 => x"68020001",	--08B8
0559 => x"640C0200",	--08BC
0560 => x"64020140",	--08C0
0561 => x"60080200",	--08C4
0562 => x"64020140",	--08C8
0563 => x"65000000",	--08CC
0564 => x"64040000",	--08D0
0565 => x"65440020",	--08D4
0566 => x"200008F4",	--08D8
0567 => x"68040020",	--08DC
0568 => x"64040020",	--08E0
0569 => x"60018040",	--08E4
0570 => x"64000040",	--08E8
0571 => x"60000001",	--08EC
0572 => x"000008D4",	--08F0
0573 => x"68040220",	--08F4
0574 => x"64000040",	--08F8
0575 => x"00000864",	--08FC
0576 => x"60080200",	--0900

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