: d# ;

: digit
    d# 9 over <
    if
        d# 7 +
    then
    d# 48 +
;

: #?
    base @ um/mod
    swap digit hold 0
;

:noname
    decimal

    12345678 s>d
    <#
        16 0 do # loop
    #> type cr

    .s cr
; execute
bye
