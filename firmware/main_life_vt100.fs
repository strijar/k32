\ Game life test for K32

include lib/vt100.fs

5 constant      #w
5 constant      #h

[ 1 #w lshift ] constant w
[ 1 #h lshift ] constant h

[ w 2* ]        constant row
[ row h * ]     constant size

$20 constant    bl

create          world size allot
variable        old'
variable        new'

: col+          1+ ;
: col-          1- dup w and + ;
: row+          row + ;
: row-          row - ;
: wrap          [ size w - 1- ] literal and ;
: w!            wrap old' @ + c! ;
: w@            wrap old' @ + c@ ;

: clear
    world size d# 0 fill
;

: foreachrow ( xt -- )
    h 0do
        i
        #w 1+ lshift ( w * 2 * )
        over execute
    loop
    drop
;

: showrow ( i -- )
    cursor-save

    old' @ +
    w bounds
    do
        i c@ if
            bright green fg [char] #
        else
            normal white fg [char] .
        then
        emit
        bl emit
    loop

    cursor-unsave
    cursor-down
;

: show
    ['] showrow foreachrow
;

: sum-neighbors ( i -- i n )
    dup  col- row- w@
    over      row- w@ +
    over col+ row- w@ +
    over col-      w@ +
    over col+      w@ +
    over col- row+ w@ +
    over      row+ w@ +
    over col+ row+ w@ +
;

: gencell ( i -- )
    sum-neighbors over old' @ + c@
    or d# 3 = d# 1 and swap new' @ + c!
;

: genrow ( i -- )
    w bounds
    do
        i gencell
    loop
;

: age
    old' @ new' @ old' ! new' !
;

: gen
    ['] genrow foreachrow age
;

: pat ( i addr len -- )
    rot dup 2swap bounds
    do
        i c@ [char] | = if
            drop row+ dup
        else
            i c@ bl = 1+ over w!
            col+
        then
    loop
    2drop
;

: glider
    s"  *|  *|***" pat
;

: blink
    s" ***" pat
;

: main
    world old' !
    world w + new' !

    d# 3 glider
    d# 11 row+ row+ row+ blink

    page

    begin
        d# 10 d# 5 cursor-xy
        show cr
        gen
        d# 1000000 0do loop
    again
;fallthru
