library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.k32_pkg.all;

entity node_port is
    port (
        clk             : in std_logic;
        reset           : in std_logic;

        bus_ce		: in std_logic;
        bus_in       	: in dbus_out_type;
        bus_out      	: out dbus_in_type;

        port_rx         : in std_logic_vector(7 downto 0);
        port_rx_req     : in std_logic;
        port_rx_ack     : out std_logic;

        port_tx         : out std_logic_vector(7 downto 0);
        port_tx_req     : out std_logic;
        port_tx_ack     : in std_logic
);
end node_port;

architecture Behavioral of node_port is

    type rx_states is (
        idle,
        ready,
        readed
    );

    signal tx       : std_logic_vector(7 downto 0);
    signal tx_req   : std_logic;
    signal tx_free  : std_logic;

    signal rx       : std_logic_vector(7 downto 0);
    signal rx_state : rx_states;
    signal rx_ack   : std_logic;
    signal rx_ready : std_logic;

begin

    port_tx <= tx;
    port_tx_req <= tx_req;
    port_rx_ack <= rx_ack;

    -- Connect bus --

    process (bus_in.addr, tx_free, rx_ready, rx) begin
	case bus_in.addr(3 downto 2) is
	    when "00" =>
		bus_out.dat(31 downto 8) <= (others => '0');
		bus_out.dat(7 downto 0) <= rx;

	    when "01" =>
		bus_out.dat <= (others => tx_free);

	    when "10" =>
		bus_out.dat <= (others => rx_ready);

	    when others =>
		bus_out.dat <= (others => '0');
	end case;
    end process;

    -- Tx --

    tx_free <= '1' when tx_req = '0' or port_tx_ack = '1' else '0';

    process (clk, reset, port_tx_ack, bus_ce, bus_in) begin
        if rising_edge(clk) then
            if reset = '1' then
                tx <= (others => '0');
                tx_req <= '0';
            else
                if port_tx_ack = '1' then
                    tx_req <= '0';
                end if;

		if bus_ce = '1' and bus_in.we(0) = '1' then
		    if bus_in.addr(3 downto 2) = "00" then
			tx <= bus_in.dat(7 downto 0);
			tx_req <= '1';
		    end if;
		end if;
            end if;
        end if;
    end process;

    -- Rx --

    rx_ready <= '1' when rx_state = ready else '0';
    rx_ack <= '1' when rx_ready = '1' and bus_ce = '1' and bus_in.re = '1' and bus_in.addr(3 downto 2) = "00" else '0';

    process (clk, reset, bus_ce, bus_in, port_rx_req) begin
        if rising_edge(clk) then
            if reset = '1' then
                rx <= (others => '0');
                rx_state <= idle;
            else
                case rx_state is
                    when idle =>
                        if port_rx_req = '1' then
                            rx <= port_rx;
                            rx_state <= ready;
                        end if;

                    when ready =>
                    	if bus_ce = '1' and bus_in.re = '1' and bus_in.addr(3 downto 2) = "00" then
                            -- rx_ack <= '1';
                            rx_state <= readed;
                        end if;

                    when readed =>
                        if port_rx_req = '0' then
                            -- rx_ack <= '0';
                            rx_state <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
