: divstep ( divisor dq hi )
    2* over
    0< if 1+ then

    ]asm
        alu_a:dN	alu_b:X alu:<< T->N	1 or	alu     ( swap 2* )
        alu_a:dN	               T->N		alu     ( swap )
    asm[

    rot 2dup

    >= if
        tuck-

        swap              ( dq hi divisor )
        rot 1+            ( hi divisor dq )
        rot               ( divisor dq hi )
    else
        -rot
    then
;

: um/mod ( ud u1 -- u2 u3 )
    -rot
    d# 32 0do divstep loop
    rot drop swap
;

: um/ ( ud u1 -- u2 )
    -rot
    d# 32 0do divstep loop
    rot drop drop
;
