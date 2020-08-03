library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all; -- this is the package
--------------------------------------------------------------
entity TEMP_TEST is
	constant n : integer := 8;
	constant m : integer := 5;
	constant k : integer := 2;
end TEMP_TEST;
--------------------------------------------------------------
architecture rtb of TEMP_TEST is
	    SIGNAL clk : std_logic := '0';
		SIGNAL cin : std_logic :='0';
		SIGNAL a,b : std_logic_vector(n-1 downto 0):=(others =>'0');
		SIGNAL opc : std_logic_vector(m-1 downto 0):=(others =>'0');
		SIGNAL res : std_logic_vector(2*n-1 downto 0) :=(others =>'0');
		
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
		RES : out std_logic_vector(2*n-1 downto 0) -- RES(HI,LO)
		);
END component;
	
begin
	tester : Arithmetic_Logic_Unit generic map (n,m,k) 
	port map(clk,cin,a,b,opc,res);
	--------- start of stimulus section ------------------	
	process
		begin
			clk <= '1';
			wait for 50 ns;
			clk <= '0';
			wait for 50 ns;
	end process;
	
	process
		begin
			a <= "00000011";
			b <= "00000010";
			opc <= "00000";
			for i in 0 to 3 loop
				wait for 100 ns;
				opc <= opc +1;
			end loop;
			wait for 100 ns;
			opc <= "00111" ;
			for i in 0 to 3 loop
				wait for 100 ns;
				opc <= opc +1;
			end loop;
			wait for 100 ns;
			
			opc <= "00110";  -- RESET MAC
			wait for 100 ns;
			opc <= "00101";  -- MAC function
			for i in 0 to 2 loop
				wait for 100 ns;
			end loop;
			opc <= "00001";  -- check if not losing value in ACC
			wait for 200 ns;
			opc <= "00101";  -- BACK TO MAC
			for i in 0 to 2 loop
				wait for 100 ns;
			end loop;
		
	end process;

end architecture rtb;