
: 0<        0 < ;
: >=        < invert ;
: tuck  swap over ;
: -rot  swap >r swap r> ;


: divstep ( divisor dq hi )
    .s cr

    2*
    over 0< if 1+ then
    swap 2* swap
    rot                     ( dq hi divisor )
    2dup >= if
        tuck                ( dq divisor hi divisor )
        -                       .s cr
        swap                ( dq hi divisor )
        rot 1+              ( hi divisor dq )
        rot                 ( divisor dq hi )
    else
        -rot
    then

    s" ---" type cr
;

: um/mod? ( ud u1 -- u2 u3 )
    -rot
    32 0 do
        divstep
    loop
    rot drop drop
    ( rot drop swap )
;

hex cr cr
$12345678 $0 $777 um/mod?

cr .s bye
