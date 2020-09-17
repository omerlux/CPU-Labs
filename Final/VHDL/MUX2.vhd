LIBRARY ieee;
USE ieee.std_logic_1164.all;
--------------------------------------
ENTITY MUX2 IS
	PORT (a, b, s: IN std_logic; -- s=0 will give a, s=1 will give b
		  y: OUT std_logic);
END MUX2;
--------------------------------------
ARCHITECTURE logic OF MUX2 IS
BEGIN
	y <= (a AND NOT s) OR (b AND s) ; -- original mux 2 -> 1 with 1 selector
END logic;

