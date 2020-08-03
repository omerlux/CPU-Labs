LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE work.aux_package.all; -- this is the package
-------------------------------------
ENTITY Adder_Subtractor IS
  GENERIC (n : INTEGER := 8);
  PORT (    cin: IN STD_LOGIC;
 		    sel: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            s: OUT STD_LOGIC_VECTOR(n downto 0));
END Adder_Subtractor;
--------------------------------------------------------------
ARCHITECTURE dfl OF Adder_Subtractor IS
	SIGNAL reg : std_logic_vector(n-1 DOWNTO 0);
	SIGNAL y_plus_minus : std_logic_vector(n-1 DOWNTO 0);
	SIGNAL control : std_logic;
	SIGNAL c0_in: std_logic;
	SIGNAL s_n_1: std_logic;
	SIGNAL pm: std_logic;
BEGIN
	-- first we want to change cin and sel as we wish
	control <= '0' WHEN sel="00" ELSE -- X+Y
		   '0' WHEN sel="01" ELSE -- X+Y+Cin
		   '1' WHEN sel="10" ELSE -- X-Y
		   '0'; -- irrelevant - shifter
	
	c0_in <= '0' WHEN sel="00" ELSE -- X+Y
		   cin WHEN sel="01" ELSE -- X+Y+Cin
		   '1' WHEN sel="10" ELSE -- X-Y  , Cin must be 1 for 2's comp
		   '0'; -- irrelevant - shifter
	
	-- now like regular adder and controlstructor
	-- y_plus_minus is changing depends on control and Y
	y_plus_minus(0) <= y(0) XOR control; -- control=1 -> X-Y
	first : FA port map(
			xi => x(0),
			yi => y_plus_minus(0),
			cin => c0_in,
			s => s(0),
			cout => reg(0)
	);
	
	rest : for i in 1 to n-1 generate
		y_plus_minus(i) <= y(i) XOR control; -- control=1 -> X-Y
		chain : FA port map(
			xi => x(i),
			yi => y_plus_minus(i), 
			cin => reg(i-1), --reg is the out signal - connect to next cin
			s => s(i),
			cout => reg(i)
		);
	end generate;
	
	s_n_1 <= x(n-1) XOR y_plus_minus(n-1) XOR reg(n-1); -- output of the last FA
	
	s(n) <= --X+Y
			'0'    WHEN sel="00" and (x(n-1) NOR y(n-1))='1' ELSE -- the nums are positive
			'1'    WHEN sel="00" and (x(n-1) AND y(n-1))='1' ELSE -- the nums are negative
			s_n_1 WHEN sel="00" and (x(n-1) XOR y(n-1))='1' ELSE -- 1 pos 1 neg
			--X+Y+Cin
			'0'    WHEN sel="01" and (x(n-1) NOR y(n-1))='1' ELSE -- the nums are positive
			'1'    WHEN sel="01" and (x(n-1) AND y(n-1))='1' ELSE -- the nums are negative
			s_n_1 WHEN sel="01" and (x(n-1) XOR y(n-1))='1' ELSE -- 1 pos 1 neg
			--X-Y
			s_n_1 WHEN sel="10" and (x(n-1) XNOR y(n-1))='1' ELSE -- X-Y is pos+neg or neg+pos
			'0'    WHEN sel="10" and ((not x(n-1)) AND y(n-1))='1' ELSE -- X-Y is pos+pos
			'1'	   WHEN sel="10" and (x(n-1) AND (not y(n-1)))='1' ELSE -- X-Y is neg+neg
			'0'; --irrelevant

END dfl;












