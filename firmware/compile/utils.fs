decimal

0 value outfile

warnings off

: type ( c-addr u )
    outfile if
        outfile write-file throw
    else
        type
    then
;

: emit ( u )
    outfile if
        pad c! pad 1 outfile write-file throw
    else
        emit
    then
;

: cr ( u )
    outfile if
        s" " outfile write-line throw
    else
        cr
    then
;

warnings on

: create-output-file
    w/o create-file throw to outfile 
;

