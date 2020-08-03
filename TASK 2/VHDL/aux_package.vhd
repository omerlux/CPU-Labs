LIBRARY ieee;
USE ieee.std_logic_1164.all;


package aux_package is
-----------------------------------------------------------------
  component top is
	generic (
		n : positive := 8 ; -- A,B length
		m : positive := 5 ; -- OPC length
		k : positive := 2   -- STATUS length
	);
	port(
		ena_A : in std_logic;
		ena_OP : in std_logic;
		ena_B : in std_logic;
		clk : in std_logic;
		input : in std_logic_vector(n-1 downto 0);
		----------------------------------------
		RES_HI : out std_logic_vector(n-1 downto 0); -- RES(HI)
		RES_LO : out std_logic_vector(n-1 downto 0); -- RES(LO)
		STATUS : out std_logic_vector(k-1 downto 0);
		HEX0 : out std_logic_vector(3 downto 0);
		HEX1 : out std_logic_vector(3 downto 0);
		HEX2 : out std_logic_vector(3 downto 0);
		HEX3 : out std_logic_vector(3 downto 0)
	);
  end component;
-----------------------------------------------------------------

	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;
	
-----------------------------------------------------------------

	component Adder_Subtractor is
	GENERIC (n : INTEGER:= 16);
	PORT (  cin: IN STD_LOGIC;
		    sel: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            s: OUT STD_LOGIC_VECTOR(n downto 0));
	end component;
	
-----------------------------------------------------------------
 
	component MUX2 is
		port (a,b,s: IN STD_LOGIC; 
			  y: OUT STD_LOGIC);
	end component;
	
-----------------------------------------------------------------

	component Yblock is 
		generic ( n:INTEGER :=8);
		port (	sy: IN STD_LOGIC;
				x0,x1: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
				yout: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
	end component;
	
-----------------------------------------------------------------
	
	component RLA IS
		GENERIC (n : INTEGER := 8);
		PORT (    --cin: IN STD_LOGIC;
			x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            res: OUT STD_LOGIC_VECTOR(n-1 downto 0));
	END component;

-----------------------------------------------------------------

	component RRA IS
		GENERIC (n : INTEGER := 8);
		PORT (    --cin: IN STD_LOGIC;
			x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            res: OUT STD_LOGIC_VECTOR(n-1 downto 0));
	END component;

-----------------------------------------------------------------

	component Shift_Unit IS
		GENERIC (		
			n : positive := 8 ; -- A,B length
			m : positive := 5 ; -- OPC length
			k : positive := 2   -- STATUS length
		);
		PORT (    
			cin : in std_logic;
			A,B : in std_logic_vector(n-1 downto 0);
			OPC : in std_logic_vector(m-1 downto 0);
			----------------------------------------
			RES : out std_logic_vector(2*n-1 downto 0); -- RES(HI,LO)
			CARRY : out std_logic);
	END component;
  
-----------------------------------------------------------------

	component Arithmetic_Logic_Unit IS
		GENERIC (		
			n : positive := 8 ; -- A,B length
			m : positive := 5 ; -- OPC length
			k : positive := 2   -- STATUS length
			);
		PORT (    
			clk,cin : in std_logic;
			A,B : in std_logic_vector(n-1 downto 0);
			OPC : in std_logic_vector(m-1 downto 0);
			----------------------------------------
			RES : buffer std_logic_vector(2*n-1 downto 0)); -- RES(HI,LO)
	END component;
	
-----------------------------------------------------------------

	component ALU IS
		GENERIC (		
			n : positive := 8 ; -- A,B length
			m : positive := 5 ; -- OPC length
			k : positive := 2   -- STATUS length
			);
		PORT (    
			clk,cin : in std_logic;
			A,B : in std_logic_vector(n-1 downto 0);
			OPC : in std_logic_vector(m-1 downto 0);
			----------------------------------------
			HI : buffer std_logic_vector(n-1 downto 0); -- RES(HI)
			LO : buffer std_logic_vector(n-1 downto 0); -- RES(LO)
			STATUS : out std_logic_vector(k-1 downto 0));
	END component;
  
-----------------------------------------------------------------

    component top_shifter is
	generic (
		n : positive := 8 ; -- A,B length
		m : positive := 5 ; -- OPC length
		k : positive := 2   -- STATUS length
	);
	port(
		ena_A : in std_logic;
		ena_OP : in std_logic;
		ena_B : in std_logic;
		clk : in std_logic;
		input : in std_logic_vector(n-1 downto 0);
		----------------------------------------
		RES_HI : out std_logic_vector(n-1 downto 0); -- RES(HI)
		RES_LO : out std_logic_vector(n-1 downto 0); -- RES(LO)
		STATUS : out std_logic_vector(k-1 downto 0)
	);
  end component;

-----------------------------------------------------------------

    component top_arith is
	generic (
		n : positive := 8 ; -- A,B length
		m : positive := 5 ; -- OPC length
		k : positive := 2   -- STATUS length
	);
	port(
		ena_A : in std_logic;
		ena_OP : in std_logic;
		ena_B : in std_logic;
		clk : in std_logic;
		input : in std_logic_vector(n-1 downto 0);
		----------------------------------------
		RES_HI : out std_logic_vector(n-1 downto 0); -- RES(HI)
		RES_LO : out std_logic_vector(n-1 downto 0); -- RES(LO)
		STATUS : out std_logic_vector(k-1 downto 0)
	);
  end component;
  
-----------------------------------------------------------------

component LCD is
    Port ( bits : in  STD_LOGIC_VECTOR (3 downto 0);
          hex : out  STD_LOGIC_VECTOR (6 downto 0)
             );
end component;
  
end aux_package;

