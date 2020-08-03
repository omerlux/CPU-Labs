LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all; -- this is the package
--------------------------------------
entity Yblock IS  -- a block of connected n muxes 2->1 for the shifter
	generic (n : INTEGER :=8);
	port (  sy: IN STD_LOGIC; -- this is the y(i) in - which is the selector (selects if we take x0 or x1)
			x0,x1: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            yout: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
end Yblock;
--------------------------------------------------------------
architecture yfl OF Yblock IS
begin
	create: for j in 0 to n-1 generate
		chain : MUX2 port map( -- each mux will let x1(j) or x0(j) out
		a => x0(j),
		b => x1(j),
		y => yout(j), -- this is the out signal
		s =>sy); -- sy is the same in all the muxes
		end generate;
end yfl;