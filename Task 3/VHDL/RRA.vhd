LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
-------------------------------------
ENTITY RRA IS -- will shift the vector X for (0 -> 7) bits LEFT according to Y0 Y1 Y2
  GENERIC (n : INTEGER := 8); 
  PORT (    x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            res: OUT STD_LOGIC_VECTOR(n-1 downto 0));
END RRA;
--------------------------------------------------------------
ARCHITECTURE dfl OF RRA IS

	component Yblock is 
		generic ( n:INTEGER :=8);
		port (	sy: IN STD_LOGIC;
				x0,x1: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
				yout: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
	end component;
	
	SIGNAL xl1 : std_logic_vector(n-1 DOWNTO 0); -- the configures move by 1 bit x
	SIGNAL xl2 : std_logic_vector(n-1 DOWNTO 0); -- the configures move by 2 bit x
	SIGNAL xl4 : std_logic_vector(n-1 DOWNTO 0); -- the configures move by 4 bit x
	SIGNAL reg0to1 : std_logic_vector(n-1 DOWNTO 0); -- the signals between YBlock 1 to the second
	SIGNAL reg1to2 : std_logic_vector(n-1 DOWNTO 0); -- the signals between YBlock 2 to the third
BEGIN

	xl1 <= x(n-1) & x(n-1 downto 1) WHEN n>1 ELSE -- cut the 1 LSB, double MSB
		   (others => '0');
create0:	
	Yblock generic map( -- first Y block - moves 0 or 1 times
		n)
	   port map(
		sy => y(0),
		x0 => x,
		x1 => xl1,
		yout => reg0to1);
		
	xl2 <= (n-1 downto n-2 => reg0to1(n-1)) & reg0to1(n-1 downto 2) WHEN n>2 ELSE -- cut the 2 LSB, DOUBLE the MSB
		   (others => '0');
create1:	
	Yblock generic map( -- second Y block - moves 0 or 2 times
		n)
	   port map(
		sy => y(1),
		x0 => reg0to1,
		x1 => xl2,
		yout => reg1to2);
	
	xl4 <= (n-1 downto n-4 => reg0to1(n-1)) & reg1to2(n-1 downto 4) WHEN n>4 ELSE -- cut the 4 LSB, DOUBLE the MSB
		   (others => '0');	
create2:	
	Yblock generic map( -- third Y block - moves 0 or 4 times
		n)	
	   port map(
		sy => y(2),
		x0 => reg1to2,
		x1 => xl4,
		yout => res);

END dfl;










