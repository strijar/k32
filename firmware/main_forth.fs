variable        cp
variable        <ok>
variable        >in
4 constant      cell
$40 constant    word-length

variable        #tib
create          tib 80 allot

: +! tuck @ + ;fallthru
: swap! swap ! ;

: zero d# 0 swap! ;
: over+ over + ;

: -throw negate ;fallthru
: throw
;

: ?exit if rdrop exit then ;

: in@ >in @ ;
: here cp @ ;
: down 4/ 4* ;
: aligned 4/ 4* 4+ ;

: 1depth d# 1 ;fallthru
: ?depth depth < ?exit d# 4 -throw ;

: -trailing
;

: parser
;

: parse
    >r
    tib in@ +
    #tib @ in@ -
    r@ parser >in +!
    r>
    =bl = if
        -trailing
    then
    d# 0 max
;

: ?length
    dup word-length < ?exit h# 13 -throw
;

: pack$
    aligned dup>r over
    dup down
    - over+ zero 2dup c! 1+ swap cmove r>
;

: word
    1depth parse ?length here pack$
;

: token
    =bl word
;

: interpret
;

: @execute
    @ ?dup if execute exit then
;

: eval
    begin
        token dup c@
    while
        interpret d# 0 ?depth
    repeat drop <ok> @execute
;

: main
    s" test" eval
;fallthru
