library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity tb_detect is
	constant m : integer := 7;
	constant k : integer := 3;
end tb_detect;
--------------------------------------------------------------
architecture rtb of tb_detect is
	SIGNAL count : std_logic_vector(k-1 downto 0);
	SIGNAL detector: std_logic;
	component detect IS
		GENERIC (m: INTEGER := 7;
				 k: INTEGER := 3);
		PORT ( 
			count : in std_logic_vector(k-1 downto 0);
			detector : out std_logic
		);
	END component;
begin
	tester : detect generic map (m,k) port map(count, detector);
	--------- start of stimulus section ------------------	
	process
		begin
		count <= "000";
		for i in 0 to 6 loop
			wait for 50 ns;
			count <= count+1;
		end loop;
		wait for 50 ns;
		count <= "110";
		wait for 50 ns;
		count <= count+1;
		wait for 50 ns;
		count <= "000";
		for i in 0 to 6 loop
			wait for 50 ns;
			count <= count+1;
		end loop;
		wait for 200 ns;
		count <= "000";
		wait for 200 ns;
	end process;

end architecture rtb;
