meta

: dup@          alu_a:dT        T->N            alu:[a] d:push  alu ;
: dupc@         alu_a:dT        T->N     bmem   alu:[a] d:push  alu ;

: 1-            alu_a:dT        alu_b:X         alu:-   1 or    alu ;
: 2-            alu_a:dT        alu_b:X         alu:-   2 or    alu ;
: 4-            alu_a:dT        alu_b:X         alu:-   4 or    alu ;

: 1+            alu_a:dT        alu_b:X         alu:+   1 or    alu ;
: 2+            alu_a:dT        alu_b:X         alu:+   2 or    alu ;
: 3+            alu_a:dT        alu_b:X         alu:+   3 or    alu ;
: 4+            alu_a:dT        alu_b:X         alu:+   4 or    alu ;

: 2/            alu_a:dT        alu_b:X         alu:>>  1 or    alu ;
: 4/            alu_a:dT        alu_b:X         alu:>>  2 or    alu ;

: 2*            alu_a:dT        alu_b:X         alu:<<  1 or    alu ;
: 4*            alu_a:dT        alu_b:X         alu:<<  2 or    alu ;
: 8*            alu_a:dT        alu_b:X         alu:<<  3 or    alu ;
: 16*           alu_a:dT        alu_b:X         alu:<<  4 or    alu ;

: break         alu_a:dT                        alu:break       alu ;

: tuck-         alu_a:dN        alu_b:dT        alu:-  T->N     alu ;

