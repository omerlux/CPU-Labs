library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all; -- this is the package
--------------------------------------------------------------
entity TB_TEST is
	constant n : integer := 8;
	constant m : integer := 5;
	constant k : integer := 2;
end TB_TEST;
--------------------------------------------------------------
architecture rtb of TB_TEST is
	signal rst,ena,clk,cin : std_logic;
	signal A,B : std_logic_vector(n-1 downto 0);
	signal OPC : std_logic_vector(m-1 downto 0);
	----------------------------------------
	signal RES : std_logic_vector(2*n-1 downto 0); -- RES(HI,LO)
	signal STATUS : std_logic_vector(k-1 downto 0);
	
	component top IS
		GENERIC (		
			n : positive := 8 ; -- A,B length
			m : positive := 5 ; -- OPC length
			k : positive := 2   -- STATUS length
		);
		PORT (
		rst,ena,clk,cin : in std_logic;
		A,B : in std_logic_vector(n-1 downto 0);
		OPC : in std_logic_vector(m-1 downto 0);
		----------------------------------------
		RES : out std_logic_vector(2*n-1 downto 0); -- RES(HI,LO)
		STATUS : out std_logic_vector(k-1 downto 0)
		);
	END component;
		
begin
	tester : top generic map (n,m,k) 
	port map(rst,ena,clk,cin,A,B,OPC,RES,STATUS);
	--------- start of stimulus section ------------------	
	ena <= '1' after 50 ns;
	cin <= '0';
	rst <= '0';
	process
		begin
			clk <= '0';
			wait for 50 ns;
			clk <= '1';
			wait for 50 ns;
	end process;
	
	process
		begin
			a <= "00100000";
			b <= "00110000";
			opc <= "00000";
			wait for 100 ns;
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
			wait for 200 ns;
			
			opc <= "00110";  -- 2x RESET MAC
			wait for 200 ns;
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
			wait for 100 ns;
			
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