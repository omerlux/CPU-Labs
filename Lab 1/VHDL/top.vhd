LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;
-------------------------------------
ENTITY top IS
  GENERIC (n : INTEGER := 8);
  PORT (    cin : IN STD_LOGIC;
			sel : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			 X,Y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  result: OUT STD_LOGIC_VECTOR(n downto 0));
END top;
------------- complete the top Architecture code --------------
ARCHITECTURE struct OF top IS
	signal as_out : STD_LOGIC_VECTOR (n DOWNTO 0);
	signal shifter_out : STD_LOGIC_VECTOR (n DOWNTO 0);
	signal shifter_x : STD_LOGIC_VECTOR (n DOWNTO 0);
	signal shifter_y : STD_LOGIC_VECTOR (n DOWNTO 0);
BEGIN
	create_as:	
	Adder_Subtractor generic map(n)
	    port map(
			cin => cin,
			sel => sel,
			x => X,
			y => Y,
			s => as_out );
	
	shifter_x <= '0' & X;
	shifter_y <= '0' & Y;
	create_shifter:
	shifter generic map(n+1)
		port map(
			x => shifter_x,
			y => shifter_y,
			res => shifter_out );

	create_selector:
	Selector generic map(n)
		port map(
			sel => sel,
			as_in => as_out,
			shifter_in => shifter_out,
			result => result );




END struct;

