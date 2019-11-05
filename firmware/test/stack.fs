create save 32 allot create save|

: .s?
    save| save !

    depth dup
    dup s>d <# [char] > hold #s [char] < hold #> type space

    ?dup if
        0 do
            swap
            save @ 4 - dup save !
            !
        loop

        0 do
            save @ dup 4 + save !
            @
            dup s>d <# #s #> type space
        loop
    else
        drop
    then
;

:noname
    123 234 345

    .s?

    cr .s

; execute

bye