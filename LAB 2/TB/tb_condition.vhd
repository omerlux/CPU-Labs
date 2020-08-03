library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity tb_condition is
	constant n : integer := 3;
end tb_condition;
--------------------------------------------------------------
architecture rtb of tb_condition is
	SIGNAL cond : integer range 0 to 3 := 0;
	SIGNAL rise : std_logic:='0';
	SIGNAL din_new	: std_logic_vector(n-1 downto 0):=(others=>'0');
	SIGNAL din_old : std_logic_vector(n-1 downto 0):=(others=>'0');
	component condition IS
		GENERIC (n: INTEGER := 3);
		PORT (
			cond : in integer range 0 to 3;
			din_new : in std_logic_vector(n-1 downto 0);
			din_old : in std_logic_vector(n-1 downto 0);
			rise : out std_logic);
	END component;
begin
	tester : condition generic map (n) port map(cond, din_new, din_old, rise);
	--------- start of stimulus section ------------------	
	process
		begin
		for j in 0 to 3 loop
			cond <= j;
			din_new <= "000";
			din_old <= "000";
			for i in 0 to 5 loop
				wait for 50 ns;
				din_new <= din_new+1;
			end loop;
		end loop;
	end process;

end architecture rtb;
