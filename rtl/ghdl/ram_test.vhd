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
0000 => x"00000020",	--0000
0001 => x"000009E8",	--0004

0008 => x"8CCCCCCD",	--0020
0009 => x"C0000000",	--0024
0010 => x"CCCCCCCD",	--0028
0011 => x"65600040",	--002C
0012 => x"7C000000",	--0030
0013 => x"7C000000",	--0034
0014 => x"7E680040",	--0038
0015 => x"60000000",	--003C
0016 => x"60000000",	--0040
0017 => x"60F80000",	--0044

0512 => x"80010000",	--0800
0513 => x"60008040",	--0804
0514 => x"64000040",	--0808
0515 => x"80010004",	--080C
0516 => x"605A0020",	--0810
0517 => x"20000810",	--0814
0518 => x"64040240",	--0818
0519 => x"8000000A",	--081C
0520 => x"00000800",	--0820
0521 => x"80000020",	--0824
0522 => x"00000800",	--0828
0523 => x"65000000",	--082C
0524 => x"64020000",	--0830
0525 => x"64020000",	--0834
0526 => x"64010140",	--0838
0527 => x"64010140",	--083C
0528 => x"68020020",	--0840
0529 => x"60584000",	--0844
0530 => x"40000800",	--0848
0531 => x"68000021",	--084C
0532 => x"6D310000",	--0850
0533 => x"20000840",	--0854
0534 => x"60000200",	--0858
0535 => x"60000200",	--085C
0536 => x"60040200",	--0860
0537 => x"60020020",	--0864
0538 => x"60000001",	--0868
0539 => x"64020000",	--086C
0540 => x"605C4200",	--0870
0541 => x"64010140",	--0874
0542 => x"64020000",	--0878
0543 => x"68020220",	--087C
0544 => x"64020000",	--0880
0545 => x"64010140",	--0884
0546 => x"64010140",	--0888
0547 => x"64020000",	--088C
0548 => x"68020220",	--0890
0549 => x"64020000",	--0894
0550 => x"68020220",	--0898
0551 => x"60040200",	--089C
0552 => x"64000040",	--08A0
0553 => x"64040240",	--08A4
0554 => x"60020020",	--08A8
0555 => x"200008B4",	--08AC
0556 => x"60020020",	--08B0
0557 => x"60040200",	--08B4
0558 => x"60280000",	--08B8
0559 => x"60040201",	--08BC
0560 => x"64020020",	--08C0
0561 => x"64020020",	--08C4
0562 => x"65380040",	--08C8
0563 => x"200008D8",	--08CC
0564 => x"64000040",	--08D0
0565 => x"000008DC",	--08D4
0566 => x"60000040",	--08D8
0567 => x"60040200",	--08DC
0568 => x"64020020",	--08E0
0569 => x"64020020",	--08E4
0570 => x"62380040",	--08E8
0571 => x"000008CC",	--08EC
0572 => x"68000020",	--08F0
0573 => x"60584000",	--08F4
0574 => x"69020020",	--08F8
0575 => x"60480002",	--08FC
0576 => x"60500002",	--0900
0577 => x"60000004",	--0904
0578 => x"68010001",	--0908
0579 => x"64060200",	--090C
0580 => x"64010140",	--0910
0581 => x"60040200",	--0914
0582 => x"64010140",	--0918
0583 => x"65000000",	--091C
0584 => x"64020000",	--0920
0585 => x"65220020",	--0924
0586 => x"20000944",	--0928
0587 => x"68020020",	--092C
0588 => x"64020020",	--0930
0589 => x"6000C040",	--0934
0590 => x"64000040",	--0938
0591 => x"60000001",	--093C
0592 => x"00000924",	--0940
0593 => x"68020220",	--0944
0594 => x"64000040",	--0948
0595 => x"000008A0",	--094C
0596 => x"80000000",	--0950
0597 => x"64020000",	--0954
0598 => x"64010140",	--0958
0599 => x"64010140",	--095C
0600 => x"64020020",	--0960
0601 => x"60580000",	--0964
0602 => x"64020020",	--0968
0603 => x"60008040",	--096C
0604 => x"64000040",	--0970
0605 => x"60000002",	--0974
0606 => x"64020000",	--0978
0607 => x"60000002",	--097C
0608 => x"64020000",	--0980
0609 => x"68000021",	--0984
0610 => x"6D310000",	--0988
0611 => x"20000960",	--098C
0612 => x"60000200",	--0990
0613 => x"60000200",	--0994
0614 => x"000008A0",	--0998
0615 => x"80000000",	--099C
0616 => x"64020000",	--09A0
0617 => x"64010140",	--09A4
0618 => x"64010140",	--09A8
0619 => x"64020020",	--09AC
0620 => x"60584000",	--09B0
0621 => x"64020020",	--09B4
0622 => x"6000C040",	--09B8
0623 => x"64000040",	--09BC
0624 => x"60000001",	--09C0
0625 => x"64020000",	--09C4
0626 => x"60000001",	--09C8
0627 => x"64020000",	--09CC
0628 => x"68000021",	--09D0
0629 => x"6D310000",	--09D4
0630 => x"200009AC",	--09D8
0631 => x"60000200",	--09DC
0632 => x"60000200",	--09E0
0633 => x"000008A0",	--09E4
0634 => x"60040200",	--09E8
0635 => x"60500001",	--09EC
0636 => x"64020020",	--09F0
0637 => x"60380000",	--09F4
0638 => x"20000A00",	--09F8
0639 => x"60000001",	--09FC
0640 => x"64520001",	--0A00
0641 => x"64020000",	--0A04
0642 => x"64010140",	--0A08
0643 => x"64020000",	--0A0C
0644 => x"68020220",	--0A10
0645 => x"64020000",	--0A14
0646 => x"64020020",	--0A18
0647 => x"64020020",	--0A1C
0648 => x"65380040",	--0A20
0649 => x"60280000",	--0A24
0650 => x"20000A5C",	--0A28
0651 => x"650A0000",	--0A2C
0652 => x"64020000",	--0A30
0653 => x"64010140",	--0A34
0654 => x"64020000",	--0A38
0655 => x"68020220",	--0A3C
0656 => x"64020000",	--0A40
0657 => x"60000001",	--0A44
0658 => x"64010140",	--0A48
0659 => x"64020000",	--0A4C
0660 => x"68020220",	--0A50
0661 => x"64020000",	--0A54
0662 => x"00000A6C",	--0A58
0663 => x"64020000",	--0A5C
0664 => x"64010140",	--0A60
0665 => x"64020000",	--0A64
0666 => x"68020220",	--0A68
0667 => x"60040200",	--0A6C
0668 => x"64020000",	--0A70
0669 => x"64010140",	--0A74
0670 => x"64020000",	--0A78
0671 => x"68020220",	--0A7C
0672 => x"80000020",	--0A80
0673 => x"64010140",	--0A84
0674 => x"80000000",	--0A88
0675 => x"64010140",	--0A8C
0676 => x"400009EC",	--0A90
0677 => x"68000021",	--0A94
0678 => x"6D310000",	--0A98
0679 => x"20000A90",	--0A9C
0680 => x"60000200",	--0AA0
0681 => x"60000200",	--0AA4
0682 => x"64010140",	--0AA8
0683 => x"64020000",	--0AAC
0684 => x"68020220",	--0AB0
0685 => x"64020000",	--0AB4
0686 => x"64000040",	--0AB8
0687 => x"64060200",	--0ABC
0688 => x"64020000",	--0AC0
0689 => x"64010140",	--0AC4
0690 => x"64020000",	--0AC8
0691 => x"68020220",	--0ACC
0692 => x"80000020",	--0AD0
0693 => x"64010140",	--0AD4
0694 => x"80000000",	--0AD8
0695 => x"64010140",	--0ADC
0696 => x"400009EC",	--0AE0
0697 => x"68000021",	--0AE4
0698 => x"6D310000",	--0AE8
0699 => x"20000AE0",	--0AEC
0700 => x"60000200",	--0AF0
0701 => x"60000200",	--0AF4
0702 => x"64010140",	--0AF8
0703 => x"64020000",	--0AFC
0704 => x"68020220",	--0B00
0705 => x"64020000",	--0B04
0706 => x"64000040",	--0B08
0707 => x"64040240",	--0B0C
0708 => x"0000000A",	--0B10
0709 => x"00000000",	--0B14
0710 => x"00000000",	--0B18
0711 => x"00000000",	--0B1C
0712 => x"00000000",	--0B20
0713 => x"00000000",	--0B24
0714 => x"00000000",	--0B28
0715 => x"00000000",	--0B2C
0716 => x"00000000",	--0B30
0717 => x"00000000",	--0B34
0718 => x"00000000",	--0B38
0719 => x"00000000",	--0B3C
0720 => x"00000000",	--0B40
0721 => x"00000000",	--0B44
0722 => x"00000000",	--0B48
0723 => x"00000000",	--0B4C
0724 => x"00000000",	--0B50
0725 => x"00000000",	--0B54
0726 => x"00000000",	--0B58
0727 => x"00000000",	--0B5C
0728 => x"00000000",	--0B60
0729 => x"00000000",	--0B64
0730 => x"00000000",	--0B68
0731 => x"80000B14",	--0B6C
0732 => x"60580000",	--0B70
0733 => x"60080001",	--0B74
0734 => x"60020020",	--0B78
0735 => x"80000B14",	--0B7C
0736 => x"60008040",	--0B80
0737 => x"64000040",	--0B84
0738 => x"6000C040",	--0B88
0739 => x"64040240",	--0B8C
0740 => x"80000009",	--0B90
0741 => x"64020020",	--0B94
0742 => x"65380040",	--0B98
0743 => x"20000BA8",	--0B9C
0744 => x"80000007",	--0BA0
0745 => x"65000040",	--0BA4
0746 => x"80000030",	--0BA8
0747 => x"65040240",	--0BAC
0748 => x"80000B6C",	--0BB0
0749 => x"80000B14",	--0BB4
0750 => x"60008040",	--0BB8
0751 => x"64040240",	--0BBC
0752 => x"80000B10",	--0BC0
0753 => x"60580000",	--0BC4
0754 => x"40000A70",	--0BC8
0755 => x"64020000",	--0BCC
0756 => x"40000B90",	--0BD0
0757 => x"40000B6C",	--0BD4
0758 => x"80000000",	--0BD8
0759 => x"60040200",	--0BDC
0760 => x"40000BC0",	--0BE0
0761 => x"64020020",	--0BE4
0762 => x"64020020",	--0BE8
0763 => x"65180040",	--0BEC
0764 => x"60300000",	--0BF0
0765 => x"20000BE0",	--0BF4
0766 => x"60040200",	--0BF8
0767 => x"400008A0",	--0BFC
0768 => x"80000B14",	--0C00
0769 => x"60580000",	--0C04
0770 => x"80000B6C",	--0C08
0771 => x"64020020",	--0C0C
0772 => x"650C0240",	--0C10
0773 => x"8000000A",	--0C14
0774 => x"80000B10",	--0C18
0775 => x"60008040",	--0C1C
0776 => x"64040240",	--0C20
0777 => x"80000010",	--0C24
0778 => x"80000B10",	--0C28
0779 => x"60008040",	--0C2C
0780 => x"64040240",	--0C30

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
