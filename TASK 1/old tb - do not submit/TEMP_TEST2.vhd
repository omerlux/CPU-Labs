library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all; -- this is the package
--------------------------------------------------------------
entity TEMP_TEST2 is
	constant n : integer := 8;
	constant m : integer := 5;
	constant k : integer := 2;
end TEMP_TEST2;
--------------------------------------------------------------
architecture rtb of TEMP_TEST2 is
	    SIGNAL clk : std_logic := '0';
		SIGNAL cin : std_logic :='0';
		SIGNAL a,b : std_logic_vector(n-1 downto 0):=(others =>'0');
		SIGNAL opc : std_logic_vector(m-1 downto 0):=(others =>'0');
		SIGNAL res : std_logic_vector(2*n-1 downto 0) :=(others =>'0');
		SIGNAL carry : std_logic :='0';
		
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
		CARRY : out std_logic );
END component;
	
begin
	tester : Shift_Unit generic map (n,m,k) 
	port map(cin,a,b,opc,res,carry);
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
			a <= "11011010";
			b <= "00000000";
			opc <= "00000";
			wait for 100 ns;
			-- RLA
			opc <= "01100";
			for i in 0 to 3 loop
				wait for 100 ns;
				b <= b+1;
			end loop;
			wait for 100 ns;
			
			-- rst
			b <= "00000000";
			opc <= "00000";
			wait for 100 ns;
			-- RLC
			opc <= "01101";
			for i in 0 to 3 loop
				wait for 100 ns;
				b <= b+1;
			end loop;
			wait for 100 ns;
			
			-- rst
			b <= "00000000";
			opc <= "00000";
			wait for 100 ns;
			-- RRA
			opc <= "01110";
			for i in 0 to 3 loop
				wait for 100 ns;
				b <= b+1;
			end loop;
			wait for 100 ns;
						
			-- rst
			b <= "00000000";
			opc <= "00000";
			wait for 100 ns;
			-- RRC
			opc <= "01111";
			for i in 0 to 3 loop
				wait for 100 ns;
				b <= b+1;
			end loop;
			wait for 100 ns;
			
		
	end process;

end architecture rtb;