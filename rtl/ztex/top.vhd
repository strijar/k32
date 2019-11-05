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
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

use work.k32_pkg.all;

entity top is
    port  (
	clk	: in std_logic;
	reset	: in std_logic;
	uart_rx	: in std_logic;
	uart_tx	: out std_logic
    );
end top;

architecture rtl of top is
    signal irq		: irq_type;
    signal en		: std_logic;

    signal ibus_in	: ibus_in_type;
    signal ibus_out	: ibus_out_type;

    signal data_in	: dbus_in_type;
    signal data_out	: dbus_out_type;
    signal data_en	: std_logic;

    signal io_in	: dbus_in_type;
    signal io_out	: dbus_out_type;

    signal empty_in	: dbus_in_type;
    signal empty_out	: dbus_out_type;

    signal uart_rx_data	: std_logic_vector(7 downto 0);
    signal uart_rx_ready: std_logic;
    signal uart_tx_data	: std_logic_vector(7 downto 0);
    signal uart_tx_en	: std_logic;
    signal uart_tx_busy	: std_logic;

begin

    irq.addr <= IRQ_ADDR;
    en <= '1';

    -- CPU --

    cpu: entity work.k32
	port map(
	    clk		=> clk,
	    rst		=> reset,
	    en		=> en,
	    irq		=> irq,

	    ibus_in	=> ibus_in,
	    ibus_out	=> ibus_out,

	    data_in	=> data_in,
	    data_out	=> data_out,
	    io_in	=> io_in,
	    io_out	=> io_out
	);

    data_en <= '1' when data_out.re = '1' or data_out.we(0) = '1' else '0';

    ram_i: entity work.ram
	generic map(
	    addr_bits	=> 13,
	    data_bits	=> 32
	)
	port map(
	    clk 	=> clk,
	    rst 	=> reset,

	    a_addr	=> ibus_out.addr(12 downto 0),
	    a_dout	=> ibus_in.dat,
	    a_we	=> '0',
	    a_din	=> (others => '0'),

	    b_en	=> data_en,
	    b_addr	=> data_out.addr(12 downto 0),
	    b_dout	=> data_in.dat,
	    b_we	=> data_out.we,
	    b_din	=> data_out.dat
	);

    -- UART

    uart_i: entity work.uart
	generic map(
	    clock_frequency => 48000000,
--	    baud => 115200
	    baud => 921600
	) port map(
	    clock        => clk,
	    reset        => reset,
	    data_in      => uart_tx_data,
	    data_in_stb  => uart_tx_en,
	    data_in_busy => uart_tx_busy,
	    data_out     => uart_rx_data,
	    data_out_stb => uart_rx_ready,
	    tx           => uart_tx,
	    rx           => uart_rx
	);

    uart_tx_data <= io_out.dat(7 downto 0);
    uart_tx_en <= io_out.we(0);

    io_in.dat <= (others => uart_tx_busy);

end rtl;
