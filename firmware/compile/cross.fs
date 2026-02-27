\ Cross-compiler for the K32
\ Based on J1 sources

vocabulary k32assembler         \ assembly storage and instructions
vocabulary metacompiler         \ the cross-compiling words
vocabulary k32target            \ actual target words

: k32asm
    only
    metacompiler
    also k32assembler definitions
    also forth ;
: meta
    only
    k32target also
    k32assembler also
    metacompiler definitions also
    forth ;
: target
    only
    metacompiler also
    k32target definitions ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

k32asm

4 constant tcell

65536 allocate throw constant tflash

variable tdp

: there         tdp @ ;
: tc!           tflash + c! ;
: tc@           tflash + c@ ;

: t!            tflash + ! ;
: t@            tflash + @ ;

: talign        tdp @ 3 + $FFFFFFFC and tdp ! ;

: tc,           there tc! 1 tdp +! ;
: t,            there tflash + ! tcell tdp +! ;
: org           tdp ! ;

variable dict
variable dict'

: dict? dict @ ;
: dict[ 1 dict ! ;
: ]dict 0 dict ! ;
: dict, dict' @ t, ;

tflash 65536 0 fill

65536 cells allocate throw constant references

: referenced
    cells references + 1 swap +!
;

65536 cells allocate throw constant labels
labels 65536 cells 0 fill

: atlabel? ( -- f = are we at a label )
    labels there cells + @ 0<>
;

: preserve  ( c-addr1 u -- c-addr )
    dup 1+ allocate throw dup >r
    2dup c! 1+
    swap cmove r> ;

: dictlabel
    there >r
    dup tc,

    2dup bounds do
        i c@ tc,
    loop

    talign
    dict,
    r> dict' !
;

: setlabel ( c-addr u -- )
    atlabel? if
        2drop
    else
        2dup type ." : 0x"
        preserve
        labels there
        hex dup . decimal cr
        cells + !
    then
;

: setlabel:
    ( dict? if dictlabel then )
    setlabel
;

: alu_a         26 lshift ;
: alu_b         23 lshift or ;
: alu_op        18 lshift or ;

: alu_a:dT      0 alu_a ;
: alu_a:dN      1 alu_a ;
: alu_a:rT      2 alu_a ;
: alu_a:rN      3 alu_a ;
: alu_a:xT      4 alu_a ;
: alu_a:xN      5 alu_a ;
: alu_a:dSP     6 alu_a ;
: alu_a:q       7 alu_a ;

: alu_b:X       0 alu_b ;
: alu_b:dT      1 alu_b ;
: alu_b:dN      2 alu_b ;
: alu_b:rT      3 alu_b ;
: alu_b:rN      4 alu_b ;
: alu_b:xT      5 alu_b ;
: alu_b:xN      6 alu_b ;
: alu_b:q       7 alu_b ;

: alu:+         0 alu_op ;
: alu:-         1 alu_op ;
: alu:&         2 alu_op ;
: alu:|         3 alu_op ;
: alu:^         4 alu_op ;
: alu:~         5 alu_op ;
: alu:=         6 alu_op ;
: alu:<         7 alu_op ;
: alu:u<        8 alu_op ;
: alu:>>        9 alu_op ;
: alu:<<        10 alu_op ;
: alu:[a]       11 alu_op ;
: alu:q*        12 alu_op ;
: alu:q+        13 alu_op ;
: alu:q-        14 alu_op ;
: alu:break     31 alu_op ;

: R->PC         1 17 lshift ;
: T->N          1 16 lshift or ;
: T->R          1 15 lshift or ;
: T->X          1 14 lshift or ;
: N->[T]        1 13 lshift or ;
: bmem          1 12 lshift or ;

: x:push        1 9 lshift or ;
: x:pop         2 9 lshift or ;
: r:push        1 7 lshift or ;
: r:pop         2 7 lshift or ;
: d:push        1 5 lshift or ;
: d:pop         2 5 lshift or ;

: ubranch
    ." ubranch 0x" dup hex . decimal cr
    0 29 lshift or t,
;

: 0branch
    ." branch 0x" dup hex . decimal cr
    1 29 lshift or t,
;

: scall
    ." call 0x" dup hex . decimal cr
    2 29 lshift or t,
;

: alu           3 29 lshift or t, ;

: return        R->PC r:pop alu ;

\ tcompile is like "STATE": it is true when compiling

variable tcompile

: tcompile? tcompile @ ;
: +tcompile tcompile? abort" Already in compilation mode" 1 tcompile !  ;
: -tcompile 0 tcompile ! ;

: (literal)
    dup $80000000 and if
        $FFFFFFFF xor recurse
        alu_a:dT alu:~ alu
    else
        $80000000 or t,
    then
;

: (t-constant)
    tcompile? if
        (literal)
    then
;

meta

\ Find name - without consuming it - and return a counted string
: wordstr ( "name" -- c-addr u )
    >in @ >r bl word count r> >in !
;

: literal
    (literal)
; immediate

: 2literal swap (literal) (literal) ; immediate
: call,
    dup referenced
    scall
;

: t:
    talign
    wordstr setlabel:

    create
        there ,
        +tcompile
        947947
    does>
        @
        tcompile? if
            call,
        then
;

: lookback
    there tcell - t@
;

: prevcall?
    lookback $E0000000 and $40000000 =
;

: prevsafe?
    lookback $E0000000 and $60000000 =          \ is an ALU
    lookback 0 T->R r:pop and 0= and            \ does not touch RStack
;

: call>goto
   ." call -> branch " cr
    dup t@ $1FFFFFFF and swap t!
;

: alu>return
   ." alu -> return " cr
    dup t@ R->PC or r:pop swap t!
;

: t;
    947947 <> if abort" 1) Unstructured" then
    true if
        atlabel? invert prevcall? and if
            there tcell - call>goto
        else
            atlabel? invert prevsafe? and if
                there tcell - alu>return
            else
                cr
                return
            then
        then
    else
        cr
        return
    then
    cr
    -tcompile
;

: t;fallthru
    947947 <> if abort" 2) Unstructured" then
    -tcompile
;

variable shadow-tcompile
wordlist constant escape]-wordlist
escape]-wordlist set-current

: ]
    shadow-tcompile @ tcompile !
    previous previous
;

: >number
;

meta


: [
    tcompile @ shadow-tcompile !
    -tcompile get-order forth-wordlist escape]-wordlist rot 2 + set-order
;

: : t: ;
: ; t; ;
: ;fallthru t;fallthru ;
: , t, ;
: c, tc, ;

: constant ( n "name" -- ) create , immediate does> @ (t-constant) ;

: ]asm
    -tcompile also
    forth also
    k32target also
    k32assembler
;

: asm[
    +tcompile previous previous previous
;

: code t: ]asm ;

k32asm

: end-code
    947947 <> if abort" Unstructured" then
    previous previous previous
;

meta

\ Some Forth words are safe to use in target mode, so import them

: ( postpone ( ;
: \ postpone \ ;

: import ( "name" -- )
    >in @ ' swap >in !
    create , does> @ execute ;

import meta
import org
import include
import [if]
import [else]
import [then]

import dict[
import ]dict
import dict,

: do-number ( n -- |n )
    state @ if
        postpone literal
    else
        tcompile? if
            (literal)
        then
    then
;

decimal

: [char] ( "name" -- ) ( run: -- ascii) char (literal) ;

: ['] ( "name" -- ) ( run: -- xt )
    ' tcompile @ >r -tcompile execute r> tcompile !
    dup referenced
    (literal)
;

: (sliteral--h) ( addr n -- ptr ) ( run: -- eeaddr n )
    s" sliteral" evaluate
    there >r
    dup tc,
    0 do
        count tc,
    loop
    drop
    talign
    r>
;

: (sliteral) (sliteral--h) drop ;
: s" ( "ccc<quote>" -- ) ( run: -- eaddr n ) [char] " parse (sliteral) ;
: s' ( "ccc<quote>" -- ) ( run: -- eaddr n ) [char] ' parse (sliteral) ;

: create
    wordstr setlabel:
    create
        there ,
    does>
        @ do-number
;

: allot     tdp +! ;

: variable
    wordstr setlabel
    create
        there , 0 t,
    does>
        @ do-number
;

: 2variable
    wordstr setlabel 
    create 
        there , 0 t, 0 t,
    does>
        @ do-number 
;

: createdoes
    wordstr setlabel
    create
        there , ' ,
    does>
        dup @ dup referenced (literal) cell+ @ execute
;

: jumptable 
    wordstr setlabel
    create there ,
    does> s" 2*" evaluate @ dup referenced (literal) s" + @" evaluate
;

: | ' execute dup referenced t, ;

: ', ' execute t, ;

( DEFER                                      JCB 11:18 11/12/10)

: defer
    wordstr setlabel
    create there , 0 t,
    does> @ tcompile? if do-number s" @ execute" evaluate then ;

: is ( xt "name" -- )
    tcompile? if
        ' >body @ do-number
        s" ! " evaluate
    else
        ' execute t!
    then ;

: ' ' execute ;

( VALUE                                      JCB 13:06 11/12/10)

: value
    wordstr setlabel
    create
        there , t,
    does>
        @ do-number
;

: to ( u "name" -- )
    ' >body @ do-number s" !" evaluate ;

( ARRAY                                      JCB 13:34 11/12/10)

: array
    wordstr setlabel
    create
        there , 0 do
            0 t,
        loop
    does>
        s" cells" evaluate @ do-number s" +" evaluate
;

: 2array
    wordstr setlabel
    create
        there , 2* 0 do
            0 t,
        loop
    does>
        s" 2* cells" evaluate @ do-number s" +" evaluate
;

( eforth's way of handling constants         JCB 13:12 09/03/10)

: sign>number
    over c@ [char] - = if
        1- swap 1+ swap
        >number
        2swap dnegate 2swap
    else
        >number
    then
;

: base>number ( caddr u base -- )
    base @ >r base !
    sign>number
    r> base !
    dup 0= if
        2drop drop do-number
    else
        1 = swap c@ [char] . = and if
            drop dup do-number 16 rshift do-number
        else
            -1 abort" bad number"
        then
    then ;

: b# 0. bl parse 2 base>number ;
: d# 0. bl parse 10 base>number ;
: h# 0. bl parse 16 base>number ;

2147483648.0e0 fconstant Q31_SCALE

: f>q
    Q31_SCALE f* fround f>s
;

: q:
    bl parse                ( addr u )
    2dup >float 0= if
        -1 abort" bad float"
    then
    2drop                   ( -- f: val )

    f>q
;

: q#
    q: do-number
;

( Conditionals                               JCB 13:12 09/03/10)
: if
    there
    ." unresolved "
    0 0branch
;

: resolve
    dup t@ there or swap t!
;

: then
    resolve
    s" (then)" setlabel
;

: else
    there
    ." unresolved "
    0 ubranch 
    swap resolve
    s" (else)" setlabel
;


: begin s" (begin)" setlabel there ;
: again 
    ubranch
;
: until
    0branch
;
: while
    there
    ." unresolved "
    0 0branch
;
: repeat
    swap ubranch
    resolve
    s" (repeat)" setlabel
;

: 0do    s" >r d# 0 >r"     evaluate there s" (do)" setlabel ;
: do     s" 2>r"         evaluate there s" (do)" setlabel ;

: loop
    ." loop 0x" dup hex . decimal cr
    s" looptest" evaluate
    0branch
    s" unloop" evaluate
;

: +loop
    ." +loop 0x" dup hex . decimal cr
    s" +looptest" evaluate
    0branch
    s" unloop" evaluate
;

77 constant sourceline#
s" none" 2constant sourcefilename

: line# sourceline# (literal) ;
create currfilename 1 cells 80 + allot
variable currfilename#
: savestr ( c-addr u dst -- ) 2dup c! 1+ swap cmove ;
: getfilename sourcefilename currfilename count compare 0<>
    if
        sourcefilename 2dup currfilename savestr (sliteral--h) currfilename# !
    else
        currfilename# @ dup 1+ (literal) tc@ (literal)
    then ;
: snap line# getfilename s" (snap)" evaluate ; immediate
: assert 0= if line# sourcefilename (sliteral) s" (assert)" evaluate then ; immediate
