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

entity k32_decode is
    port (
        irq     : in irq_type;
        instr   : in std_logic_vector(CELL_BITS-1 downto 0);
        decode  : out decode_type
    );
end k32_decode;

architecture rtl of k32_decode is

begin
    decode.lit <= instr(31);

    process (irq, instr) begin
        decode.jump <= '0';
        decode.cond_jump <= '0';
        decode.call <= '0';
        decode.alu <= '0';

        if irq.req = '1' then
            decode.call <= '1';
            decode.target <= irq.addr;
        else
            decode.target <= instr;

            case instr(31 downto 29) is
                when "000" =>
                    decode.jump <= '1';

                when "001" =>
                    decode.cond_jump <= '1';

                when "010" =>
                    decode.call <= '1';

                when "011" =>
                    decode.alu <= '1';

                when others => null;
            end case;
        end if;
    end process;

    decode.alu_a <= instr(28 downto 26);
    decode.alu_b <= instr(25 downto 23);
    decode.alu_op <= instr(22 downto 18);

    decode.alu_r_pc <= instr(17);
    decode.alu_t_n <= instr(16);
    decode.alu_t_r <= instr(15);
    decode.alu_t_x <= instr(14);
    decode.alu_store <= instr(13);
    decode.alu_byte <= instr(12);

    -- (11 downto 11)

    process (instr) begin
        decode.alu_x_op.push <= '0';
        decode.alu_x_op.pop <= '0';

        case instr(10 downto 9) is
            when "01" => decode.alu_x_op.push <= '1';
            when "10" => decode.alu_x_op.pop <= '1';
            when others => null;
        end case;
    end process;

    process (instr) begin
        decode.alu_r_op.push <= '0';
        decode.alu_r_op.pop <= '0';

        case instr(8 downto 7) is
            when "01" => decode.alu_r_op.push <= '1';
            when "10" => decode.alu_r_op.pop <= '1';
            when others => null;
        end case;
    end process;

    process (instr) begin
        decode.alu_d_op.push <= '0';
        decode.alu_d_op.pop <= '0';

        case instr(6 downto 5) is
            when "01" => decode.alu_d_op.push <= '1';
            when "10" => decode.alu_d_op.pop <= '1';
            when others => null;
        end case;
    end process;

    decode.alu_x <= unsigned(instr(4 downto 0));

end;
