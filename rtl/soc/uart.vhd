library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.k32_pkg.all;

entity uart is
    generic (
        baud                : positive;
        clock_frequency     : positive
    );
    port (
        clock        :   in  std_logic;
        reset        :   in  std_logic;

        bus_ce       :   in  std_logic;
        bus_in       :   in dbus_out_type;
        bus_out      :   out dbus_in_type;

        tx           :   out std_logic;
        rx           :   in  std_logic
    );
end uart;

architecture rtl of uart is
    constant BITLENGTH		: integer := clock_frequency / baud;

    signal tx_data_reg		: std_logic_vector(7 downto 0) := "00000000";
    signal tx_data_bit		: std_logic_vector(9 downto 0) := "1111111111";
    signal tx_count		: integer range 0 to BITLENGTH;
    signal tx_bits		: integer range 0 to 10;
    signal tx_busy		: std_logic := '0';
    signal tx_start		: std_logic := '0';

    type rx_states is (
        rx_get_start_bit,
        rx_align,
        rx_get_data,
        rx_get_stop_bit
    );

    signal rxd_reg		: std_logic_vector(2 downto 0);
    signal rx_state 		: rx_states := rx_get_start_bit;
    signal rx_bit 		: std_logic := '1';
    signal rx_data_reg 		: std_logic_vector(7 downto 0) := (others => '0');
    signal rx_count		: integer range 0 to BITLENGTH := 0;
    signal rx_bits		: integer range 0 to 7 := 0;
    signal rx_data_out_stb	: std_logic := '0';
    signal rx_ready		: std_logic := '0';
    signal rx_ready_reg		: std_logic := '0';

begin
    -- Connect bus --

    process (bus_in.addr) begin
	case bus_in.addr(3 downto 2) is
	    when "00" =>
		bus_out.dat(31 downto 8) <= (others => '0');
		bus_out.dat(7 downto 0) <= rx_data_reg;

	    when "01" =>
		bus_out.dat <= (others => not tx_busy);

	    when "10" =>
		bus_out.dat <= (others => rx_ready_reg);

	    when others =>
		bus_out.dat <= (others => '0');
	end case;
    end process;

    process (clock, bus_ce, bus_in) begin
	if rising_edge(clock) then
	    if reset = '1' then
		rx_ready_reg <= '0';
	    else
		tx_start <= '0';

		if bus_ce = '1' and bus_in.we(0) = '1' then
		    if bus_in.addr(3 downto 2) = "00" then
			tx_start <= '1';
			tx_data_reg <= bus_in.dat(7 downto 0);
		    end if;
		end if;

		if rx_ready = '1' then
		    rx_ready_reg <= '1';
		end if;

		if bus_ce = '1' and bus_in.re = '1' then
		    if bus_in.addr(3 downto 2) = "00" then
			rx_ready_reg <= '0';
		    end if;
		end if;
	    end if;
	end if;
    end process;

    -- Rx --

    process(clock, reset) begin
	if rising_edge(clock) then
	    if reset = '1' then
		rxd_reg <= (others => '1');
	    else
		rxd_reg(0) <= rx;
		rxd_reg(1) <= rxd_reg(0);
		rxd_reg(2) <= rxd_reg(1);
	    end if;
	end if;
    end process;

    rx_bit <= rxd_reg(2);
    rx_ready <= '1' when rx_state = rx_get_stop_bit and rx_count = BITLENGTH and rx_bit = '1' else '0';

    process(clock) begin
        if rising_edge(clock) then
            if reset = '1' then
                rx_state <= rx_get_start_bit;
            	rx_data_reg <= (others => '0');
            else
                case rx_state is
                    when rx_get_start_bit =>
                        if rx_bit = '0' then
                    	    rx_count <= 0;
                    	    rx_state <= rx_align;
                    	end if;

		    when rx_align =>
			if rx_count = (BITLENGTH / 2) then
			    rx_count <= 0;
			    rx_state <= rx_get_data;
                    	    rx_bits <= 0;
			else
			    rx_count <= rx_count + 1;
			end if;

                    when rx_get_data =>
                        if rx_count = BITLENGTH then
                            rx_data_reg(7) <= rx_bit;
                            rx_data_reg(6 downto 0) <= rx_data_reg(7 downto 1);
                            rx_count <= 0;

                            if rx_bits = 7 then
                                rx_state <= rx_get_stop_bit;
                            else
                                rx_bits <= rx_bits + 1;
                            end if;
                        else
                    	    rx_count <= rx_count + 1;
                        end if;

                    when rx_get_stop_bit =>
                        if rx_count = BITLENGTH then
                            rx_state <= rx_get_start_bit;
                        else
                    	    rx_count <= rx_count + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Tx --

    tx <= tx_data_bit(0);

    process(clock, reset) begin
        if rising_edge(clock) then
            if reset = '1' then
                tx_busy <= '0';
            else
            	if tx_start = '1' then
		    tx_bits <= 0;
		    tx_count <= 0;
            	    tx_busy <= '1';
		    tx_data_bit <= '1' & tx_data_reg & "0";
		elsif tx_count = BITLENGTH then
		    tx_data_bit <=  '1' & tx_data_bit(9 downto 1);
		    tx_count <= 0;

                    if tx_bits = 10 then
            		tx_busy <= '0';
                    else
                        tx_bits <= tx_bits + 1;
                    end if;
                else
            	    tx_count <= tx_count + 1;
                end if;
            end if;
        end if;
    end process;

end rtl;