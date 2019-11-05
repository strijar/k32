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
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;
use work.k32_pkg.all;

entity tb_k32 is
end tb_k32;

architecture rtl of tb_k32 is

    signal clk 		: std_logic := '1';
    signal reset 	: std_logic := '1';

    signal port0       	: std_logic_vector(7 downto 0);
    signal port0_req	: std_logic;
    signal port0_ack	: std_logic;

    signal port1       	: std_logic_vector(7 downto 0);
    signal port1_req	: std_logic;
    signal port1_ack	: std_logic;

    signal uart_rx	: std_logic;
    signal uart_tx	: std_logic;

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

    node_0: entity work.node
	generic map(
	    cpu_id	=> 0,
	    log_file	=> "cpu0.log"
	)
	port map(
	    clk		=> clk,
	    reset	=> reset,

	    east_rx	=> (others => '0'),
	    east_rx_req	=> '0',
	    east_rx_ack	=> open,
	    east_tx	=> port0,
	    east_tx_req	=> port0_req,
	    east_tx_ack	=> port0_ack,

	    west_rx	=> (others => '0'),
	    west_rx_req	=> '0',
	    west_rx_ack	=> open,
	    west_tx	=> open,
	    west_tx_req	=> open,
	    west_tx_ack	=> '0'
	);

    node_1: entity work.node
	generic map(
	    cpu_id	=> 1,
	    log_file	=> "cpu1.log"
	)
	port map(
	    clk		=> clk,
	    reset	=> reset,

	    east_rx	=> (others => '0'),
	    east_rx_req	=> '0',
	    east_rx_ack	=> open,
	    east_tx	=> open,
	    east_tx_req	=> open,
	    east_tx_ack	=> '0',

	    west_rx	=> port0,
	    west_rx_req	=> port0_req,
	    west_rx_ack	=> port0_ack,
	    west_tx	=> open,
	    west_tx_req	=> open,
	    west_tx_ack	=> '0'
	);

end rtl;
