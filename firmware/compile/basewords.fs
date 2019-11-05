\ K32 base words implemented in assembler
\ Based on J1 sources

meta

: +		alu_a:dN	alu_b:dT	alu:+	d:pop	alu ;
: -		alu_a:dN	alu_b:dT	alu:-	d:pop	alu ;
: xor		alu_a:dN	alu_b:dT	alu:^	d:pop	alu ;
: and		alu_a:dN	alu_b:dT	alu:&	d:pop	alu ;
: or		alu_a:dN	alu_b:dT	alu:|	d:pop	alu ;
: lshift	alu_a:dN	alu_b:dT	alu:<<	d:pop	alu ;
: rshift	alu_a:dN	alu_b:dT	alu:>>	d:pop	alu ;

: invert	alu_a:dT			alu:~		alu ;

: =		alu_a:dN	alu_b:dT	alu:=	d:pop	alu ;
: <		alu_a:dN	alu_b:dT	alu:<	d:pop	alu ;
: >		alu_a:dT	alu_b:dN	alu:<	d:pop	alu ;
: u<		alu_a:dN	alu_b:dT	alu:u<	d:pop	alu ;

: 0=		alu_a:dT	alu_b:X		alu:=		alu ;
: 0<            alu_a:dT	alu_b:X		alu:<		alu ;

: >=            alu_a:dN	alu_b:dT	alu:<	d:pop	alu
                alu_a:dT			alu:~		alu ;

: swap		alu_a:dN	T->N				alu ;
: dup		alu_a:dT	T->N			d:push	alu ;
: drop		alu_a:dN				d:pop	alu ;
: over		alu_a:dN	T->N			d:push	alu ;
: nip		alu_a:dT				d:pop	alu ;

: >r		alu_a:dN	T->R		r:push	d:pop	alu ;
: r>		alu_a:rT	T->N		r:pop	d:push	alu ;
: r@		alu_a:rT	T->N			d:push	alu ;
: rdrop		alu_a:dN				r:pop	alu ;

: @		alu_a:dT			alu:[a]		alu ;
: !		alu_a:dT	N->[T]			d:pop	alu
		alu_a:dN				d:pop	alu ;

: c@		alu_a:dT                bmem	alu:[a]		alu ;
: c!		alu_a:dT	N->[T]	bmem		d:pop	alu
		alu_a:dN				d:pop	alu ;

: 2>r		alu_a:dN	T->N				alu
    		alu_a:dN	T->R		r:push	d:pop	alu
		alu_a:dN	T->R		r:push	d:pop	alu ;

: s>d           alu_a:dT        alu_b:X alu:<   T->N    d:push  alu ;

: depth 	alu_a:dSP	T->N		        d:push  alu ;

: dup>r         alu_a:dT        T->R                    r:push  alu ;

(
: 2r>       rT    T->N      r-1 d+1 alu
            rT    T->N      r-1 d+1 alu
            N     T->N              alu ;
: 2r@       rT    T->N      r-1 d+1 alu
            rT    T->N      r-1 d+1 alu
            N     T->N          d+1 alu
            N     T->N          d+1 alu
            N     T->R      r+1 d-1 alu
            N     T->R      r+1 d-1 alu
            N     T->N              alu ;
)

: looptest	alu_a:rT	alu_b:X		alu:+	1 or d:push	alu
        	alu_a:rN	alu_b:dT	alu:=	T->R	        alu ;

: +looptest	alu_a:rT	alu_b:dT	alu:+		        alu
        	alu_a:rN	alu_b:dT	alu:=	T->R	        alu ;

: unloop	alu_a:dT				r:pop	        alu 
		alu_a:dT				r:pop	        alu ;

: i		alu_a:rT	T->N			d:push	        alu ;


: 2dupxor   	alu_a:dN	alu_b:dT	alu:^	T->N	d:push	alu ;

: bounds	alu_a:dN	alu_b:dT	alu:+		        alu
		alu_a:dN	T->N				        alu ;

: rot ( a b c -- b c a )
                alu_a:dN	T->R		r:push	d:pop	        alu     ( >r )
                alu_a:dN	T->N				        alu     ( swap )
                alu_a:rT	T->N		r:pop	d:push	        alu     ( r> )
                alu_a:dN	T->N				        alu ;   ( swap )

: -rot ( a b c -- c a b )
                alu_a:dN	T->N				        alu     ( swap )
                alu_a:dN	T->R		r:push	d:pop	        alu     ( >r )
                alu_a:dN	T->N				        alu     ( swap )
                alu_a:rT	T->N		r:pop	d:push	        alu ;   ( r> )

: 2dup ( a b -- a b a b )
                alu_a:dN	T->N			d:push	        alu     ( over )
                alu_a:dN	T->N			d:push	        alu ;   ( over )

: tuck ( a b -- b a b )
                alu_a:dN	T->N				        alu     ( swap )
                alu_a:dN	T->N			d:push	        alu ;   ( over )

: exit      return ;


(
: 2dup=     N==T  T->N          d+1 alu ;
: !nip      T     N->[T]        d-1 alu ;
: 2dup!     T     N->[T]            alu ;
)
