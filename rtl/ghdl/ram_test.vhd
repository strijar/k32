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
0001 => x"00000918",	--0004

0008 => x"400008B8",	--0020
0009 => x"00003101",	--0024
0010 => x"4000082C",	--0028
0011 => x"4000081C",	--002C
0012 => x"400008B8",	--0030
0013 => x"00323102",	--0034
0014 => x"4000082C",	--0038
0015 => x"4000081C",	--003C
0016 => x"400008B8",	--0040
0017 => x"33323103",	--0044
0018 => x"4000082C",	--0048
0019 => x"4000081C",	--004C
0020 => x"400008B8",	--0050
0021 => x"33323104",	--0054
0022 => x"00000034",	--0058
0023 => x"4000082C",	--005C
0024 => x"4000081C",	--0060
0025 => x"400008B8",	--0064
0026 => x"33323105",	--0068
0027 => x"00003534",	--006C
0028 => x"4000082C",	--0070
0029 => x"4000081C",	--0074
0030 => x"400008B8",	--0078
0031 => x"33323106",	--007C
0032 => x"00363534",	--0080
0033 => x"4000082C",	--0084
0034 => x"4000081C",	--0088
0035 => x"400008B8",	--008C
0036 => x"33323107",	--0090
0037 => x"37363534",	--0094
0038 => x"4000082C",	--0098
0039 => x"4000081C",	--009C
0040 => x"400008B8",	--00A0
0041 => x"33323108",	--00A4
0042 => x"37363534",	--00A8
0043 => x"00000038",	--00AC
0044 => x"4000082C",	--00B0
0045 => x"4000081C",	--00B4
0046 => x"D5AA55AA",	--00B8
0047 => x"60F00000",	--00BC

0512 => x"80010000",	--0800
0513 => x"60010040",	--0804
0514 => x"64000040",	--0808
0515 => x"80010004",	--080C
0516 => x"60A40020",	--0810
0517 => x"20000810",	--0814
0518 => x"64080240",	--0818
0519 => x"8000000A",	--081C
0520 => x"00000800",	--0820
0521 => x"80000020",	--0824
0522 => x"00000800",	--0828
0523 => x"65000000",	--082C
0524 => x"64040000",	--0830
0525 => x"64040000",	--0834
0526 => x"64020140",	--0838
0527 => x"64020140",	--083C
0528 => x"68040020",	--0840
0529 => x"60A08000",	--0844
0530 => x"40000800",	--0848
0531 => x"68000021",	--084C
0532 => x"6D620000",	--0850
0533 => x"20000840",	--0854
0534 => x"60000200",	--0858
0535 => x"60000200",	--085C
0536 => x"60080200",	--0860
0537 => x"60040020",	--0864
0538 => x"60000001",	--0868
0539 => x"64040000",	--086C
0540 => x"60A88200",	--0870
0541 => x"64020140",	--0874
0542 => x"64040000",	--0878
0543 => x"68040220",	--087C
0544 => x"64040000",	--0880
0545 => x"64020140",	--0884
0546 => x"64020140",	--0888
0547 => x"64040000",	--088C
0548 => x"68040220",	--0890
0549 => x"64040000",	--0894
0550 => x"68040220",	--0898
0551 => x"60080200",	--089C
0552 => x"64000040",	--08A0
0553 => x"64080240",	--08A4
0554 => x"60040020",	--08A8
0555 => x"200008B4",	--08AC
0556 => x"60040020",	--08B0
0557 => x"60080200",	--08B4
0558 => x"68000020",	--08B8
0559 => x"60A08000",	--08BC
0560 => x"69040020",	--08C0
0561 => x"60800002",	--08C4
0562 => x"60900002",	--08C8
0563 => x"60000004",	--08CC
0564 => x"68020001",	--08D0
0565 => x"640C0200",	--08D4
0566 => x"64020140",	--08D8
0567 => x"60080200",	--08DC
0568 => x"64020140",	--08E0
0569 => x"65000000",	--08E4
0570 => x"64040000",	--08E8
0571 => x"65440020",	--08EC
0572 => x"2000090C",	--08F0
0573 => x"68040020",	--08F4
0574 => x"64040020",	--08F8
0575 => x"60018040",	--08FC
0576 => x"64000040",	--0900
0577 => x"60000001",	--0904
0578 => x"000008EC",	--0908
0579 => x"68040220",	--090C
0580 => x"64000040",	--0910
0581 => x"000008A0",	--0914
0582 => x"60080200",	--0918
0583 => x"60900001",	--091C
0584 => x"64040020",	--0920
0585 => x"60700000",	--0924
0586 => x"20000930",	--0928
0587 => x"60000001",	--092C
0588 => x"64940001",	--0930
0589 => x"64040000",	--0934
0590 => x"64020140",	--0938
0591 => x"64040000",	--093C
0592 => x"68040220",	--0940
0593 => x"64040000",	--0944
0594 => x"64040020",	--0948
0595 => x"64040020",	--094C
0596 => x"65700040",	--0950
0597 => x"60500000",	--0954
0598 => x"2000098C",	--0958
0599 => x"65140000",	--095C
0600 => x"64040000",	--0960
0601 => x"64020140",	--0964
0602 => x"64040000",	--0968
0603 => x"68040220",	--096C
0604 => x"64040000",	--0970
0605 => x"60000001",	--0974
0606 => x"64020140",	--0978
0607 => x"64040000",	--097C
0608 => x"68040220",	--0980
0609 => x"64040000",	--0984
0610 => x"0000099C",	--0988
0611 => x"64040000",	--098C
0612 => x"64020140",	--0990
0613 => x"64040000",	--0994
0614 => x"68040220",	--0998
0615 => x"60080200",	--099C
0616 => x"64040000",	--09A0
0617 => x"64020140",	--09A4
0618 => x"64040000",	--09A8
0619 => x"68040220",	--09AC
0620 => x"80000020",	--09B0
0621 => x"64020140",	--09B4
0622 => x"80000000",	--09B8
0623 => x"64020140",	--09BC
0624 => x"4000091C",	--09C0
0625 => x"68000021",	--09C4
0626 => x"6D620000",	--09C8
0627 => x"200009C0",	--09CC
0628 => x"60000200",	--09D0
0629 => x"60000200",	--09D4
0630 => x"64020140",	--09D8
0631 => x"64040000",	--09DC
0632 => x"68040220",	--09E0
0633 => x"64040000",	--09E4
0634 => x"64000040",	--09E8
0635 => x"640C0200",	--09EC
0636 => x"64040000",	--09F0
0637 => x"64020140",	--09F4
0638 => x"64040000",	--09F8
0639 => x"68040220",	--09FC
0640 => x"80000020",	--0A00
0641 => x"64020140",	--0A04
0642 => x"80000000",	--0A08
0643 => x"64020140",	--0A0C
0644 => x"4000091C",	--0A10
0645 => x"68000021",	--0A14
0646 => x"6D620000",	--0A18
0647 => x"20000A10",	--0A1C
0648 => x"60000200",	--0A20
0649 => x"60000200",	--0A24
0650 => x"64020140",	--0A28
0651 => x"64040000",	--0A2C
0652 => x"68040220",	--0A30
0653 => x"64040000",	--0A34
0654 => x"64000040",	--0A38
0655 => x"64080240",	--0A3C
0656 => x"00000000",	--0A40
0657 => x"00000000",	--0A44
0658 => x"00000000",	--0A48
0659 => x"00000000",	--0A4C
0660 => x"00000000",	--0A50
0661 => x"00000000",	--0A54
0662 => x"00000000",	--0A58
0663 => x"00000000",	--0A5C
0664 => x"00000000",	--0A60
0665 => x"00000000",	--0A64
0666 => x"00000000",	--0A68
0667 => x"00000000",	--0A6C
0668 => x"00000000",	--0A70
0669 => x"00000000",	--0A74
0670 => x"00000000",	--0A78
0671 => x"00000000",	--0A7C
0672 => x"00000000",	--0A80
0673 => x"00000000",	--0A84
0674 => x"00000000",	--0A88
0675 => x"00000000",	--0A8C
0676 => x"00000000",	--0A90
0677 => x"00000000",	--0A94
0678 => x"00000000",	--0A98
0679 => x"80000A44",	--0A9C
0680 => x"60A00000",	--0AA0
0681 => x"60100001",	--0AA4
0682 => x"60040020",	--0AA8
0683 => x"80000A44",	--0AAC
0684 => x"60010040",	--0AB0
0685 => x"64000040",	--0AB4
0686 => x"60018040",	--0AB8
0687 => x"64080240",	--0ABC
0688 => x"80000009",	--0AC0
0689 => x"64040020",	--0AC4
0690 => x"65700040",	--0AC8
0691 => x"20000AD8",	--0ACC
0692 => x"80000007",	--0AD0
0693 => x"65000040",	--0AD4
0694 => x"80000030",	--0AD8
0695 => x"65080240",	--0ADC
0696 => x"80000A9C",	--0AE0
0697 => x"80000A44",	--0AE4
0698 => x"60010040",	--0AE8
0699 => x"64080240",	--0AEC
0700 => x"80000A40",	--0AF0
0701 => x"60A00000",	--0AF4
0702 => x"400009A0",	--0AF8
0703 => x"64040000",	--0AFC
0704 => x"40000AC0",	--0B00
0705 => x"40000A9C",	--0B04
0706 => x"80000000",	--0B08
0707 => x"60080200",	--0B0C
0708 => x"40000AF0",	--0B10
0709 => x"64040020",	--0B14
0710 => x"64040020",	--0B18
0711 => x"65300040",	--0B1C
0712 => x"60600000",	--0B20
0713 => x"20000B10",	--0B24
0714 => x"60080200",	--0B28
0715 => x"400008A0",	--0B2C
0716 => x"80000A44",	--0B30
0717 => x"60A00000",	--0B34
0718 => x"80000A9C",	--0B38
0719 => x"64040020",	--0B3C
0720 => x"65180240",	--0B40
0721 => x"8000000A",	--0B44
0722 => x"80000A40",	--0B48
0723 => x"60010040",	--0B4C
0724 => x"64080240",	--0B50
0725 => x"80000010",	--0B54
0726 => x"80000A40",	--0B58
0727 => x"60010040",	--0B5C
0728 => x"64080240",	--0B60
0729 => x"00000000",	--0B64
0730 => x"00000000",	--0B68
0731 => x"00000000",	--0B6C
0732 => x"00000000",	--0B70
0733 => x"00000000",	--0B74
0734 => x"00000000",	--0B78
0735 => x"00000000",	--0B7C
0736 => x"00000000",	--0B80
0737 => x"80000B84",	--0B84
0738 => x"80000B64",	--0B88
0739 => x"60010040",	--0B8C
0740 => x"64000040",	--0B90
0741 => x"78040020",	--0B94
0742 => x"60040020",	--0B98
0743 => x"60040020",	--0B9C
0744 => x"60740020",	--0BA0
0745 => x"40000AE0",	--0BA4
0746 => x"8000003E",	--0BA8
0747 => x"40000A9C",	--0BAC
0748 => x"40000B10",	--0BB0
0749 => x"8000003C",	--0BB4
0750 => x"40000A9C",	--0BB8
0751 => x"40000B2C",	--0BBC
0752 => x"4000082C",	--0BC0
0753 => x"40000824",	--0BC4
0754 => x"400008A8",	--0BC8
0755 => x"20000C78",	--0BCC
0756 => x"64020140",	--0BD0
0757 => x"80000000",	--0BD4
0758 => x"64020140",	--0BD8
0759 => x"64040000",	--0BDC
0760 => x"80000B64",	--0BE0
0761 => x"60A00000",	--0BE4
0762 => x"60100004",	--0BE8
0763 => x"60040020",	--0BEC
0764 => x"80000B64",	--0BF0
0765 => x"60010040",	--0BF4
0766 => x"64000040",	--0BF8
0767 => x"60010040",	--0BFC
0768 => x"64000040",	--0C00
0769 => x"68000021",	--0C04
0770 => x"6D620000",	--0C08
0771 => x"20000BDC",	--0C0C
0772 => x"60000200",	--0C10
0773 => x"60000200",	--0C14
0774 => x"64020140",	--0C18
0775 => x"80000000",	--0C1C
0776 => x"64020140",	--0C20
0777 => x"80000B64",	--0C24
0778 => x"60A00000",	--0C28
0779 => x"60040020",	--0C2C
0780 => x"60000004",	--0C30
0781 => x"80000B64",	--0C34
0782 => x"60010040",	--0C38
0783 => x"64000040",	--0C3C
0784 => x"60A00000",	--0C40
0785 => x"60040020",	--0C44
0786 => x"60740020",	--0C48
0787 => x"40000AE0",	--0C4C
0788 => x"40000B10",	--0C50
0789 => x"40000B2C",	--0C54
0790 => x"4000082C",	--0C58
0791 => x"40000824",	--0C5C
0792 => x"68000021",	--0C60
0793 => x"6D620000",	--0C64
0794 => x"20000C24",	--0C68
0795 => x"60000200",	--0C6C
0796 => x"60000200",	--0C70
0797 => x"00000C7C",	--0C74
0798 => x"64000040",	--0C78
0799 => x"60080200",	--0C7C

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
