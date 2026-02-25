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

entity k32 is
    generic(
        cpu_id          : integer := 0
    );
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        en              : in std_logic;
        irq             : in irq_type;

        ibus_in         : in ibus_in_type;
        ibus_out        : out ibus_out_type;

        data_in         : in dbus_in_type;
        data_out        : out dbus_out_type;

        io_en           : out std_logic;
        io_in           : in dbus_in_type;
        io_out          : out dbus_out_type;

        exception       : out exception_type;
        trace_out       : out trace_type
    );
end k32;

architecture rtl of k32 is

    signal decode       : decode_type;
    signal fetch        : fetch_type;
    signal ex           : ex_type;

    signal ex_ds        : dstack_in_type;
    signal ds_ex        : dstack_out_type;

    signal ex_rs        : dstack_in_type;
    signal rs_ex        : dstack_out_type;

    signal dbus_in      : dbus_in_type;
    signal dbus_out     : dbus_out_type;

begin

    fetch_i: entity work.k32_fetch
        port map(
            clk         => clk,
            rst         => rst,
            en          => en,
            decode      => decode,
            ex          => ex,
            fetch       => fetch,
            ibus_out    => ibus_out
        );

    decode_i: entity work.k32_decode
        port map(
            irq         => irq,
            instr       => ibus_in.dat,
            decode      => decode
        );

    ex_i: entity work.k32_ex
        generic map(
            cpu_id      => cpu_id
        )
        port map(
            clk         => clk,
            rst         => rst,
            en          => en,
            irq         => irq,
            decode      => decode,
            fetch       => fetch,
            ds_in       => ds_ex,
            ds_out      => ex_ds,
            rs_in       => rs_ex,
            rs_out      => ex_rs,
            dbus_in     => dbus_in,
            dbus_out    => dbus_out,
            exception   => exception
        );

    dstack_i: entity work.k32_dstack
        port map(
            clk         => clk,
            rst         => rst,
            en          => en,
            din         => ex_ds,
            dout        => ds_ex
        );

    rstack_i: entity work.k32_dstack
        port map(
            clk         => clk,
            rst         => rst,
            en          => en,
            din         => ex_rs,
            dout        => rs_ex
        );

    ex.d_t <= ds_ex.t;
    ex.r_t <= rs_ex.t;

    data_out.addr <= dbus_out.addr;
    data_out.dat <= dbus_out.dat;

    io_out.addr <= dbus_out.addr;
    io_out.dat <= dbus_out.dat;

    process (ds_ex.t, data_in, io_in, dbus_out) begin
        if ds_ex.t(31 downto 16) = x"0000" then
            dbus_in <= data_in;

            data_out.re <= dbus_out.re;
            data_out.we <= dbus_out.we;

            io_en <= '0';
            io_out.re <= '0';
            io_out.we <= (others => '0');
        else
            dbus_in <= io_in;

            data_out.re <= '0';
            data_out.we <= (others => '0');

            io_en <= '1';
            io_out.re <= dbus_out.re;
            io_out.we <= dbus_out.we;
        end if;
    end process;

    trace_out.fetch <= fetch;
    trace_out.decode <= decode;
    trace_out.ds <= ds_ex;
    trace_out.rs <= rs_ex;

end;
