0 constant black
1 constant red
2 constant green
3 constant yellow
4 constant blue
5 constant magenta
6 constant cyan
7 constant white

: ESC[  d# 27 emit [char] [ emit ;

: home          ESC[ [char] H emit ;
: page          ESC[ [char] 2 emit [char] J emit ;

: fg            ESC[ [char] 3 emit [char] 0 + emit [char] m emit ;
: bg            ESC[ [char] 4 emit [char] 0 + emit [char] m emit ;

: normal        ESC[ [char] 0 emit [char] m emit ;
: bright        ESC[ [char] 1 emit [char] m emit ;

: cursor-xy     ESC[ s>d <# #s #> type [char] ; emit s>d <# #s #> type [char] f emit ;
: cursor-save   ESC[ [char] s emit ;
: cursor-unsave ESC[ [char] u emit ;
: cursor-up     ESC[ [char] A emit ;
: cursor-down   ESC[ [char] B emit ;
: cursor-right  ESC[ [char] C emit ;
: cursor-left   ESC[ [char] D emit ;
