library IEEE;
use IEEE.STD_LOGIC_1164.all;

ENTITY Lab5part2 IS
	PORT ( p, q, r, s		:IN STD_LOGIC ;
			a,b,c,d,e,f,g			:OUT STD_LOGIC );
	
END Lab5part2;

ARCHITECTURE labfivelogic OF Lab5part2 IS 
	BEGIN
	
			a <= NOT( 	(p AND(NOT(s))) OR (NOT(s)AND(NOT(q))) OR (NOT(p)AND(r)) OR (q AND r) OR (p AND(NOT(q))AND(NOT(r))) OR ((NOT(p)AND(q)AND(s)))	 ) ;
			b <= NOT( 	((NOT(p))AND(NOT(q))) OR (NOT(s)AND(NOT(q))) OR ((NOT(p))AND(r)AND(s)) OR ((NOT(p))AND(NOT(r))AND(NOT(s))) OR ((p)AND(NOT(r))AND(s) )) ;
			c <= NOT( 	(NOT(p)AND(NOT(r))) OR (NOT(p)AND(s)) OR (NOT(r)AND(s)) OR (NOT(p)AND(q)) OR ((p)AND(NOT(q))) );
			d <= NOT( 	(P AND NOT R) OR (NOT Q AND NOT R AND NOT S) OR (Q AND NOT R AND S) OR (P AND NOT Q AND S) OR (NOT P AND NOT Q AND R) OR (Q AND R AND NOT S)	) ;
			e <= NOT( 	(NOT(s)AND((NOT(q)) OR (r)))	 OR 	(p AND ((q) OR (r)))	) ;
			f <= NOT( 	((NOT(r))AND(NOT(s))) OR ((p)AND(NOT(q))) OR ((p)AND(r)) OR ((q)AND(NOT(s))) OR ((NOT(p))AND(q)AND(NOT(r)))  );
			g <= NOT( 	((NOT(q))AND(r)) OR ((NOT(s))AND(r)) OR ((p)AND(s)) OR ((NOT(q))AND(p)) OR ((NOT(p))AND(q)AND((NOT(r))))	) ;
			
			
	END labfivelogic;
