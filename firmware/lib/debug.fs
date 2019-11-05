create .spad 32 allot create .spad|

: .s
    .spad| .spad !

    depth dup
    dup s>d <# [char] > hold #s [char] < hold #> type space

    ?dup if
        0do
            swap
            .spad @ 4- dup .spad !
            !
        loop

        0do
            .spad @ dup 4+ .spad !
            @
            dup s>d <# #s #> type space
        loop
    else
        drop
    then
;
