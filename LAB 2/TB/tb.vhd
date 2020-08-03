library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------------
entity tb is
	constant n : integer := 8;
	constant m : integer := 7;
	constant k : integer := 3;
end tb;
--------------------------------------------------------------
architecture rtb of tb is
	SIGNAL rst,ena,clk : std_logic := '0';
	SIGNAL din : std_logic_vector (n-1 DOWNTO 0):=(others=>'0');
	SIGNAL cond	: integer range 0 to 3;
	SIGNAL detector : std_logic := '0';
	COMPONENT top is
		generic (
			n : positive := 8 ;
			m : positive := 7 ;
			k : positive := 3
		); -- where k=log2(m+1)
		port(
			rst,ena,clk : in std_logic;
			din : in std_logic_vector(n-1 downto 0);
			cond : in integer range 0 to 3;
			detector : out std_logic
		);
	END COMPONENT;
begin
	tester : top generic map (n,m,k) port map(rst,ena,clk,din,cond,detector);
	--------- start of stimulus section ------------------	
		
	process
		begin
		ena <= '0';
		wait for 200 ns;
		ena <= '1';
		wait;
	end process;
	
	process
		begin
		rst <= '1';
		wait for 100 ns;
		rst <= '0';
		wait;
	end process;
	
	process
		begin
		clk<='0';
		for i in 0 to 39 loop
			wait for 50 ns;
			clk<='1';
			wait for 50 ns;
			clk <='0';
		end loop;
		wait;
	end process;

	process
		begin
		cond <= 0;
		wait for 1200 ns;
		cond <= 1;
		wait for 1200 ns;
		cond <= 2;
		wait;
	end process;
	
	process
		begin
		din<= (others => '0');
		for i in 0 to 10 loop
			wait for 100 ns;
			din <= din + 1;
		end loop;
		wait for 100 ns;
		din<= (others => '0');
		for i in 0 to 10 loop
			wait for 100 ns;
			din <= din + 2;
		end loop;
		wait for 100 ns;
		din<= (others => '0');
		for i in 0 to 10 loop
			wait for 100 ns;
			din <= din + 3;
		end loop;
		wait for 100 ns;
	end process;

end architecture rtb;
