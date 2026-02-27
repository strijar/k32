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

package k32_pkg is

    constant CELL_BITS          : integer := 32;
    constant STACK_BITS         : integer := 5;

    subtype cell_type is std_logic_vector(CELL_BITS-1 downto 0);
    subtype op_type is std_logic_vector(4 downto 0);

    constant OP_ADD     : op_type := b"00000";
    constant OP_SUB     : op_type := b"00001";
    constant OP_AND     : op_type := b"00010";
    constant OP_OR      : op_type := b"00011";
    constant OP_XOR     : op_type := b"00100";
    constant OP_NOT     : op_type := b"00101";
    constant OP_EQ      : op_type := b"00110";
    constant OP_LT      : op_type := b"00111";
    constant OP_LT_U    : op_type := b"01000";
    constant OP_SRL     : op_type := b"01001";
    constant OP_SLL     : op_type := b"01010";
    constant OP_READ    : op_type := b"01011";
    constant OP_QMUL    : op_type := b"01100";
    constant OP_QADD    : op_type := b"01101";
    constant OP_QSUB    : op_type := b"01110";

    type stack_op_type is record
        push            : std_logic;
        pop             : std_logic;
    end record;

    type decode_type is record
        lit             : std_logic;

        alu             : std_logic;
        alu_a           : std_logic_vector(2 downto 0);
        alu_b           : std_logic_vector(1 downto 0);
        alu_op          : op_type;

        alu_t_n         : std_logic;
        alu_t_r         : std_logic;
        alu_t_x         : std_logic;
        alu_r_pc        : std_logic;
        alu_store       : std_logic;
        alu_byte        : std_logic;

        alu_d_op        : stack_op_type;
        alu_r_op        : stack_op_type;
        alu_x_op        : stack_op_type;
        alu_x           : unsigned(4 downto 0);

        jump            : std_logic;
        cond_jump       : std_logic;
        call            : std_logic;
        target          : cell_type;
    end record;

    type stack_type is array(natural range 0 to (2**(STACK_BITS))-1) of unsigned(CELL_BITS-1 downto 0);

    type fetch_type is record
        pc              : unsigned(CELL_BITS-1 downto 0);
    end record;

    type exception_type is record
        rstack_under    : std_logic;
    end record;

    type ex_type is record
        d_t             : unsigned(CELL_BITS-1 downto 0);
        r_t             : unsigned(CELL_BITS-1 downto 0);
        x_t             : unsigned(CELL_BITS-1 downto 0);
    end record;

    -- Data stack

    type dstack_in_type is record
        we              : std_logic;
        op              : stack_op_type;
        t               : unsigned(CELL_BITS-1 downto 0);
        t_we            : std_logic;
    end record;

    type dstack_out_type is record
        sp              : unsigned(STACK_BITS-1 downto 0);
        t               : unsigned(CELL_BITS-1 downto 0);
        n               : unsigned(CELL_BITS-1 downto 0);
    end record;

    -- Instruction bus

    type ibus_out_type is record
        addr    : cell_type;
    end record;

    type ibus_in_type is record
        dat     : cell_type;
    end record;

    -- Data/IO bus

    type dbus_out_type is record
        addr    : cell_type;
        dat     : cell_type;
        we      : std_logic_vector(3 downto 0);
        re      : std_logic;
    end record;

    type dbus_in_type is record
        dat     : cell_type;
        ready   : std_logic;
    end record;

    type irq_type is record
        req     : std_logic;
        addr    : cell_type;
    end record;

    -- Trace

    type trace_type is record
        fetch   : fetch_type;
        decode  : decode_type;
        ds      : dstack_out_type;
        rs      : dstack_out_type;
        xs      : dstack_out_type;
    end record;

    -- Vectors

    constant START_ADDR         : cell_type := x"0000_0000";
    constant IRQ_ADDR           : cell_type := x"0000_0004";

end package;
