\ Nucleus: ANS Forth core and ext words
\ Based on J1 sources

$0		constant false
10              constant =cr
32              constant =bl

$10000		constant #uart_data
$10004		constant #uart_busy

: emit
    #uart_data !

    #uart_busy
    begin dup@ until
    drop
;

: cr
    =cr emit
;

: space
    =bl emit
;

: type
    bounds do
        i c@ emit
    loop
;

: count		dup 1+ swap c@ ;
: 2swap		rot >r rot r> ;
: 2drop		drop drop ;
: ?dup          dup if dup then ;
: negate        invert 1+ ;

: min       2dup < ;fallthru
: ?:        ( xt xf f -- xt | xf) if drop else nip then ;
: max       2dup > ?: ;

: sliteral
    ]asm
        alu_a:rT                                 d:push     alu
        alu_a:dT            alu:[a]  bmem                   alu
        alu_a:rT  alu_b:dT  alu:+    T->N        d:push     alu
    asm[

    4/ 4* 4+

    ]asm
        alu_a:rT  alu_b:X   alu:+    T->R  1 or             alu
    asm[

    swap
;

: execute >r ;

: fill ( c-addr u char -- )
    >r  bounds
    begin
	2dupxor
    while
	r@ over C! 1+
    repeat
    r> drop 2drop
;

: move ( addr1 addr2 u -- )
    d# 0 do
        over @ over !
        2+ swap 2+ swap
    loop
    2drop
;

: cmove ( c-addr1 c-addr2 u -- )
    d# 0 do
        over c@ over c!
        1+ swap 1+ swap
    loop
    2drop
;

]dict

: .irq.
;

dict[
