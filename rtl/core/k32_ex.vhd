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
use work.txt_util.all;

entity k32_ex is
    generic (
        cpu_id          : integer := 0
    );
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        en              : in std_logic;
        irq             : in irq_type;

        decode          : in decode_type;

        fetch           : in fetch_type;

        ds_out          : out dstack_in_type;
        ds_in           : in dstack_out_type;

        rs_out          : out dstack_in_type;
        rs_in           : in dstack_out_type;

        dbus_out        : out dbus_out_type;
        dbus_in         : in dbus_in_type;

        exception       : out exception_type
    );
end k32_ex;

architecture rtl of k32_ex is

    signal ds_top       : unsigned(CELL_BITS-1 downto 0) := (others => '0');
    signal alu_a, alu_b : unsigned(CELL_BITS-1 downto 0);

    signal dbus_re      : std_logic;
    signal dbus_we      : std_logic;
    signal dbus_addr    : unsigned(CELL_BITS-1 downto 0);

begin

    exception.rstack_under <= '0';      -- TODO

    -- BUS --

    dbus_out.re <= dbus_re;
    dbus_out.addr <= std_logic_vector(dbus_addr);

    dbus_addr <= ds_top;
    dbus_we <= decode.alu and decode.alu_store;

    process (dbus_we, decode.alu_x, ds_in.n) begin
        dbus_out.dat <= std_logic_vector(ds_in.n);
        dbus_out.we <= "0000";

        if dbus_we = '1' then
            dbus_out.we <= "1111";

            if decode.alu_byte = '1' then
                dbus_out.dat <=
                    std_logic_vector(ds_in.n(7 downto 0)) &
                    std_logic_vector(ds_in.n(7 downto 0)) &
                    std_logic_vector(ds_in.n(7 downto 0)) &
                    std_logic_vector(ds_in.n(7 downto 0));

                case (ds_in.t(1 downto 0)) is
                    when "00" =>
                        dbus_out.we <= "0001";
                    when "01" =>
                        dbus_out.we <= "0010";
                    when "10" =>
                        dbus_out.we <= "0100";
                    when "11" =>
                        dbus_out.we <= "1000";
                    when others =>
                end case;
            end if;
        end if;
    end process;

    -- ALU

    WITH decode.alu_a SELECT alu_a <=
        ds_in.t                         WHEN "000",
        ds_in.n                         WHEN "001",
        rs_in.t                         WHEN "010",
        rs_in.n                         WHEN "011",
        to_unsigned(cpu_id, CELL_BITS)  WHEN "100",
        resize(decode.alu_x, CELL_BITS) WHEN "101",
        resize(ds_in.sp, CELL_BITS)     WHEN "110",
        (others => '0')                 WHEN others;

    WITH decode.alu_b SELECT alu_b <=
        resize(decode.alu_x, CELL_BITS) WHEN "00",
        ds_in.t                         WHEN "01",
        ds_in.n                         WHEN "10",
        rs_in.t                         WHEN others;

    process (decode, ds_in, rs_in, dbus_in, alu_a, alu_b) begin
        ds_top <= ds_in.t;
        dbus_re <= '0';

        if decode.lit = '1' then
            ds_top <= unsigned('0' & decode.target(CELL_BITS-2 downto 0));
        elsif decode.cond_jump = '1' then
            ds_top <= ds_in.n;
        elsif decode.alu = '1' then
            case decode.alu_op is
                when OP_ADD =>
                    ds_top <= alu_a + alu_b;

                when OP_SUB =>
                    ds_top <= alu_a - alu_b;

                when OP_AND =>
                    ds_top <= alu_a and alu_b;

                when OP_OR =>
                    ds_top <= alu_a or alu_b;

                when OP_XOR =>
                    ds_top <= alu_a xor alu_b;

                when OP_NOT =>
                    ds_top <= not alu_a;

                when OP_EQ =>
                    if alu_a = alu_b then
                        ds_top <= (others => '1');
                    else
                        ds_top <= (others => '0');
                    end if;

                when OP_LT =>
                    if signed(alu_a) < signed(alu_b) then
                        ds_top <= (others => '1');
                    else
                        ds_top <= (others => '0');
                    end if;

                when OP_LT_U =>
                    if alu_a < alu_b then
                        ds_top <= (others => '1');
                    else
                        ds_top <= (others => '0');
                    end if;

                when OP_SRL =>
                    ds_top <= alu_a srl to_integer(unsigned(alu_b(4 downto 0)));

                when OP_SLL =>
                    ds_top <= alu_a sll to_integer(unsigned(alu_b(4 downto 0)));

                when OP_READ =>
                    dbus_re <= '1';

                when others =>
                    report "Break by opcode" severity failure;
            end case;
        end if;
    end process;

    -- Data stack

    process (ds_top, decode.alu_x, ds_in.t, dbus_re, dbus_addr) begin
        if dbus_re = '1' then
            if decode.alu_byte = '1' then
                ds_out.t(CELL_BITS-1 downto 8) <= (others => '0');

                case (dbus_addr(1 downto 0)) is
                    when "00" =>
                        ds_out.t(7 downto 0) <= unsigned(dbus_in.dat(7 downto 0));
                    when "01" =>
                        ds_out.t(7 downto 0) <= unsigned(dbus_in.dat(15 downto 8));
                    when "10" =>
                        ds_out.t(7 downto 0) <= unsigned(dbus_in.dat(23 downto 16));
                    when "11" =>
                        ds_out.t(7 downto 0) <= unsigned(dbus_in.dat(31 downto 24));
                    when others =>
                        ds_out.t(7 downto 0) <= (others => '0');
                end case;
            else
                ds_out.t <= unsigned(dbus_in.dat);
            end if;
        else
            ds_out.t <= ds_top;
        end if;
    end process;

    process (decode) begin
        ds_out.op.push <= '0';
        ds_out.op.pop <= '0';
        ds_out.op.load <= '0';

        ds_out.we <= '0';
        ds_out.t_we <= '1';

        if decode.lit = '1' then
            ds_out.op.push <= '1';
        elsif decode.cond_jump = '1' then
            ds_out.op.pop <= '1';
        elsif decode.alu = '1' then
            ds_out.we <= decode.alu_t_n;
            ds_out.op <= decode.alu_d_op;
        end if;
    end process;

    -- Return stack

    process (decode, fetch) begin
        rs_out.op.push <= '0';
        rs_out.op.pop <= '0';
        rs_out.op.load <= '0';

        rs_out.we <= '0';
        rs_out.t_we <= '0';
        rs_out.t <= ds_in.t;

        if decode.alu = '1' then
            rs_out.t_we <= decode.alu_t_r;
            rs_out.op <= decode.alu_r_op;
        elsif decode.call = '1' then
            rs_out.t_we <= '1';
            rs_out.op.push <= '1';

            if irq.req = '1' then
                rs_out.t <= fetch.pc;
            else
                rs_out.t <= fetch.pc + 4;
            end if;
        end if;
    end process;

end;
