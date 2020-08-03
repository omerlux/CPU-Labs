LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE work.aux_package.all; -- this is the package
-------------------------------------
ENTITY Selector IS
	GENERIC (n : INTEGER := 8);
	PORT(	 sel: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			 as_in: IN STD_LOGIC_VECTOR (n DOWNTO 0);
			 shifter_in: IN STD_LOGIC_VECTOR(n DOWNTO 0);
			 result: OUT STD_LOGIC_VECTOR(n DOWNTO 0) );
END Selector;
--------------------------------------------------------------
ARCHITECTURE dfl OF Selector IS
BEGIN
	result <= shifter_in WHEN sel="11" ELSE --shifter selector
			  as_in;	-- otherwise > adder subtractor selector
	
END dfl;
