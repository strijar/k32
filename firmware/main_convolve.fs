create table1
    q: 0.1  ,
    q: 0.2  ,
    q: 0.3  ,
    q: 0.4  ,

create table2
    q: 0.5  ,
    q: 0.6  ,
    q: 0.7  ,
    q: 0.8  , create table2_end

: convolve      ( add-d addr-c addr-c-end -- sum )
    4-      >r
    q# 0.0  >x

    swap4-
    swap4-

    begin
        swap4+ @>x
        swap4+ @>x
        x>qmac>x
    r= until
]asm
    alu_a:dN    d:pop                   alu ( drop )
    alu_a:xT    d:pop   x:pop   r:pop   alu ( drop rdrop x> )
asm[
;

: main
    table1 table2 table2_end
    convolve

    nop
    break
;fallthru
