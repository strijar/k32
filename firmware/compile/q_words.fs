\ K32 Q words implemented in assembler

meta

: q*            alu_a:dN        alu_b:dT        alu:q*  d:pop   alu
                alu_a:q                                         alu
                alu_a:q                                         alu
                alu_a:q                                         alu ;

: q+            alu_a:dN        alu_b:dT        alu:q+  d:pop   alu ;
: q-            alu_a:dN        alu_b:dT        alu:q-  d:pop   alu ;

: qmac          alu_a:dN        alu_b:dT        alu:q*  d:pop   alu
                alu_a:q                                         alu
                alu_a:q                                         alu
                alu_a:q         alu_b:dN        alu:q+  d:pop   alu ;

: x>qmac>x
                alu_a:xN        alu_b:xT        alu:q*  d:push x:pop    alu
                alu_a:q                                        x:pop    alu
                alu_a:q                                                 alu
                alu_a:q         alu_b:xT        alu:q+                  alu
                alu_a:dN        T->X                    d:pop           alu ;
