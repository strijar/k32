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
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;
use work.k32_pkg.all;

entity tb_k32 is
end tb_k32;

architecture rtl of tb_k32 is

    signal clk          : std_logic := '1';
    signal reset        : std_logic := '1';
    signal irq          : irq_type;

    signal en           : std_logic;

    signal ibus_in      : ibus_in_type;
    signal ibus_out     : ibus_out_type;

    signal data_in      : dbus_in_type;
    signal data_out     : dbus_out_type;
    signal data_en      : std_logic;

    signal io_en        : std_logic;
    signal io_in        : dbus_in_type;
    signal io_out       : dbus_out_type;

    signal uart_ce      : std_logic;
    signal from_uart    : dbus_in_type;

    signal uart_rx      : std_logic;
    signal uart_tx      : std_logic;

    signal trace_out    : trace_type;

    signal con_line_buf : string(1 to 80);
    signal con_line_ix  : integer := 1;

    procedure print(text: string) is
    variable msg_line: line;
    begin
        write(msg_line, text);
        writeline(output, msg_line);
    end print;

begin

    -- 100 MHz clock

    process begin
        wait for 5 ns; clk  <= not clk;
    end process;

    -- Reset

    process begin
        wait for 15 ns;
        reset <= '0';
        wait;
    end process;

    -- IRQ

    irq.addr <= IRQ_ADDR;

    process begin
        wait for 40000 ns;
        -- irq.req <= '1';  wait for 10 ns; irq.req  <= '0';
    end process;

    -- CPU --

    en <= '1';

    cpu: entity work.k32
        generic map(
            cpu_id      => 1
        )
        port map(
            clk         => clk,
            rst         => reset,
            en          => en,
            irq         => irq,

            ibus_in     => ibus_in,
            ibus_out    => ibus_out,

            data_in     => data_in,
            data_out    => data_out,

            io_en       => io_en,
            io_in       => io_in,
            io_out      => io_out,

            trace_out   => trace_out
        );

    data_en <= '1' when data_out.re = '1' or data_out.we(0) = '1' else '0';

    ram_i: entity work.ram
        generic map(
            addr_bits   => 13,
            data_bits   => 32
        )
        port map(
            clk         => clk,
            rst         => reset,

            a_addr      => ibus_out.addr(12 downto 0),
            a_dout      => ibus_in.dat,
            a_we        => '0',
            a_din       => (others => '0'),

            b_en        => data_en,
            b_addr      => data_out.addr(12 downto 0),
            b_dout      => data_in.dat,
            b_we        => data_out.we,
            b_din       => data_out.dat
        );

    -- Bus

    uart_ce <= '1' when io_en = '1' and io_out.addr(11 downto 8) = 0 else '0';

    process (io_out.addr, from_uart) begin
        case io_out.addr(11 downto 8) is
            when x"0" => io_in <= from_uart;
            when others => io_in.dat <= (others => '0');
        end case;
    end process;

    -- UART

    uart_i: entity work.uart
        generic map(
            clock_frequency => 4,
            baud => 4
        ) port map(
            clock        => clk,
            reset        => reset,

            bus_ce       => uart_ce,
            bus_in       => io_out,
            bus_out      => from_uart,

            tx           => uart_tx,
            rx           => uart_rx
        );

    uart_rx <= uart_tx;

    -- Debug --

    trace_i: entity work.trace
        generic map(
            log_file => "k32.log"
        )
        port map(
            clk         => clk,
            rst         => reset,
            en          => en,
            irq         => irq,

            trace_in    => trace_out,
            ibus_in     => ibus_in
        );

    process (clk)
        variable uart_data : integer;
    begin
        if rising_edge(clk) then
            if uart_ce = '1' and io_out.we(0) = '1' then
                uart_data := conv_integer(io_out.dat(7 downto 0));

                if uart_data = 10 then
                    print(con_line_buf(1 to con_line_ix));
                    con_line_ix <= 1;
                    con_line_buf(1) <= character'val(0);
                else
                    if con_line_ix < con_line_buf'high then
                        con_line_buf(con_line_ix) <= character'val(uart_data);
                        con_line_buf(con_line_ix + 1) <= character'val(0);
                        con_line_ix <= con_line_ix + 1;
                    else
                        report "Buffer overflow" severity failure;
                    end if;
                end if;
            end if;
        end if;
    end process;

end rtl;
