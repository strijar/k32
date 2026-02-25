: save_mem ( stop-addr start-addr filename-addr -- )
    create-output-file
    do
        decimal

        <#
            bl hold
            [char] > hold
            [char] = hold
            bl hold

            i 4 / s>d # # # #
        #> type

        hex

        <#
            [char] , hold
            [char] " hold

            i t@ s>d # # # # # # # #

            [char] " hold
            [char] x hold
        #> type

        <#
            i s>d # # # #

            [char] - hold
            [char] - hold
            09 hold
        #> type cr
    4 +loop
;

: save_bin ( stop-addr start-addr filename-addr -- )
    create-output-file
    do
        i t@ emit
    loop
;

: module[   ( -- start-addr module-name )
    there bl parse preserve
;

: ]module   ( start-addr module-name -- start-addr stop-addr )
    count type ."  compiled" cr cr
    there
    swap
;
