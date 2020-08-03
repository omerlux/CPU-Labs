library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity tb_counter is
	constant m : integer := 7;
	constant k : integer := 3;
end tb_counter;
--------------------------------------------------------------
architecture rtb of tb_counter is
	SIGNAL rst,ena,clk : std_logic := '0';
	SIGNAL rise : std_logic;
	SIGNAL count	: std_logic_vector(k-1 downto 0):=(others=>'0');
	component counter IS
		GENERIC (m: INTEGER := 7 ;
		         k: INTEGER := 3);
		PORT (
			rst,ena,clk : in std_logic;
			rise : in std_logic;
			count : buffer std_logic_vector(k-1 downto 0));
	END component;
begin
	tester : counter generic map (m,k) port map(rst,ena,clk,rise,count);
	--------- start of stimulus section ------------------	
	process
		begin
		wait for 200 ns;
		ena <= '1';
	end process;
	
	process
		begin
		clk <= '1';
		for i in 0 to 39 loop
			wait for 50 ns;
			clk <= not clk;
		 end loop;
	end process;
	
	process
		begin
		rise<='1';
		wait for 900 ns;
		rise<='0';
		wait for 150 ns;
		rise<='1';
	end process;

end architecture rtb;
