10 value base
variable hld
create pad 84 allot create pad|

: hold
    hld @ 1- dup hld ! c!
;

: digit
    d# 9 over <
    if
        d# 7 +
    then
    d# 48 +
;

: <#
    pad| hld !
;

: #
    base @ um/mod
    swap digit hold d# 0
;

: #s
    begin # 2dup or 0= until
;

: #>
    2drop hld @ pad| over -
;

: decimal
    d# 10 base !
;

: hex
    d# 16 base !
;
