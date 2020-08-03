LIBRARY ieee;
USE ieee.std_logic_1164.all;


package aux_package is

	component top is
	GENERIC (n : INTEGER);
	PORT (    cin : IN STD_LOGIC;
			sel : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			 X,Y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  result: OUT STD_LOGIC_VECTOR(n downto 0));
	end component;
	
	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;

	component Adder_Subtractor is
	GENERIC (n : INTEGER);
	PORT (  cin: IN STD_LOGIC;
		    sel: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            s: OUT STD_LOGIC_VECTOR(n downto 0));
	end component;
	
	component Selector is
	GENERIC (n : INTEGER);
	PORT(	 sel: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			 as_in: IN STD_LOGIC_VECTOR (n DOWNTO 0);
			 shifter_in: IN STD_LOGIC_VECTOR(n DOWNTO 0);
			 result: OUT STD_LOGIC_VECTOR(n DOWNTO 0) );
	end component;
  
  	component MUX2 is
		port (a,b,s: IN STD_LOGIC; 
			  y: OUT STD_LOGIC);
	end component;
	
	component Yblock is 
		generic ( n:INTEGER :=8);
		port (	sy: IN STD_LOGIC;
				x0,x1: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
				yout: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
	end component;
	
	component shifter IS
		GENERIC (n : INTEGER := 8);
		PORT (    --cin: IN STD_LOGIC;
			x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            res: OUT STD_LOGIC_VECTOR(n-1 downto 0));
	END component;

end aux_package;

