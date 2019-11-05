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
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;

library std;
use std.textio.all;
use work.k32_pkg.all;

entity node is
    generic(
	cpu_id		: integer := 0;
	log_file	: string := "UNUSED"
    );
    port(
	clk		: in std_logic;
	reset 		: in std_logic;

        east_rx         : in std_logic_vector(7 downto 0);
        east_rx_req     : in std_logic;
        east_rx_ack     : out std_logic;
        east_tx         : out std_logic_vector(7 downto 0);
        east_tx_req     : out std_logic;
        east_tx_ack     : in std_logic;

        west_rx         : in std_logic_vector(7 downto 0);
        west_rx_req     : in std_logic;
        west_rx_ack     : out std_logic;
        west_tx         : out std_logic_vector(7 downto 0);
        west_tx_req     : out std_logic;
        west_tx_ack     : in std_logic
    );
end node;

architecture rtl of node is

    signal irq		: irq_type;

    signal en		: std_logic := '1';

    signal ibus_in	: ibus_in_type;
    signal ibus_out	: ibus_out_type;

    signal data_in	: dbus_in_type;
    signal data_out	: dbus_out_type;
    signal data_en	: std_logic;

    signal io_en	: std_logic;
    signal io_in	: dbus_in_type;
    signal io_out	: dbus_out_type;

    signal east_ce	: std_logic;
    signal from_east	: dbus_in_type;

    signal west_ce	: std_logic;
    signal from_west	: dbus_in_type;

    signal trace_out	: trace_type;

begin

    -- IRQ

    irq.addr <= IRQ_ADDR;
    irq.req <= '0';

    -- CPU --

    cpu: entity work.k32
	generic map(
	    cpu_id	=> cpu_id
	)
	port map(
	    clk		=> clk,
	    rst		=> reset,
	    en		=> en,
	    irq		=> irq,

	    ibus_in	=> ibus_in,
	    ibus_out	=> ibus_out,

	    data_in	=> data_in,
	    data_out	=> data_out,

	    io_en	=> io_en,
	    io_in	=> io_in,
	    io_out	=> io_out,

	    trace_out	=> trace_out
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

    -- Bus

    east_ce <= '1' when io_en = '1' and io_out.addr(11 downto 8) = x"1" else '0';
    west_ce <= '1' when io_en = '1' and io_out.addr(11 downto 8) = x"2" else '0';

    process (io_out.addr, from_east, from_west) begin
	case io_out.addr(11 downto 8) is
	    when x"1" => io_in <= from_east;
	    when x"2" => io_in <= from_west;
	    when others => io_in.dat <= (others => '0');
	end case;
    end process;

    -- East

    east_i: entity work.node_port
	port map(
    	    clk		=> clk,
    	    reset       => reset,

	    bus_ce       => east_ce,
	    bus_in       => io_out,
	    bus_out      => from_east,

    	    port_rx	=> east_rx,
    	    port_rx_req	=> east_rx_req,
    	    port_rx_ack	=> east_rx_ack,

    	    port_tx	=> east_tx,
    	    port_tx_req => east_tx_req,
    	    port_tx_ack => east_tx_ack
	);

    en <= from_east.ready and from_west.ready;

    -- West

    west_i: entity work.node_port
	port map(
    	    clk		=> clk,
    	    reset       => reset,

	    bus_ce       => west_ce,
	    bus_in       => io_out,
	    bus_out      => from_west,

    	    port_rx	=> west_rx,
    	    port_rx_req	=> west_rx_req,
    	    port_rx_ack	=> west_rx_ack,

    	    port_tx	=> west_tx,
    	    port_tx_req => west_tx_req,
    	    port_tx_ack => west_tx_ack
	);

    -- Debug --

    trace_i: entity work.trace
	generic map(
	    log_file => log_file
	)
	port map(
	    clk 	=> clk,
	    rst 	=> reset,
	    en		=> en,
	    irq		=> irq,

	    trace_in	=> trace_out,
	    ibus_in	=> ibus_in
	);

end rtl;
