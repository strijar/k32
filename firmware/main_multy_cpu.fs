create world 4 allot

$10100		constant #east_data
$10104		constant #east_tx_busy
$10108		constant #east_rx_ready

$10200		constant #west_data
$10204		constant #west_tx_busy
$10208		constant #west_rx_ready

: master
    begin
	h# 12 #east_data !
    again
;fallthru

: slave
    h# 123 drop
    h# 456 drop

    begin
	#west_data c@ drop
    again
;fallthru

: main
    d# 0 cpu = if
	master
    else
	slave
    then
;fallthru
