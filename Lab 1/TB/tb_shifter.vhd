library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------------
entity tb_shifter is
	constant m : integer := 8;
end tb_shifter;
--------------------------------------------------------------
architecture rtb of tb_shifter is
	SIGNAL cin : STD_LOGIC :='0';
	SIGNAL sel : STD_LOGIC_VECTOR (1 DOWNTO 0):="00";
	SIGNAL X,Y : STD_LOGIC_VECTOR (m-1 DOWNTO 0):=(others=>'0');
	SIGNAL s   : STD_LOGIC_VECTOR (m-1 DOWNTO 0):=(others=>'0');
begin
	tester : shifter generic map (m) port map(X,Y,s);
	--------- start of stimulus section ------------------	
		
		tb_shifter : process
        begin
		  -- shifter check
		  sel <= "11"; -- shift
		  cin <= '0';
		  X <= (others => '1');
		  Y <= (others => '0');
		  for i in 0 to 6 loop
			wait for 50 ns;
			Y <= Y+1;
		  end loop;
		  wait for 50 ns;
		  X <= "00000001";
		  Y <= (others => '0');
		  for i in 0 to 6 loop
			wait for 50 ns;
			Y <= Y+1;
		  end loop;
		  wait;
		
        end process tb_shifter;
  
end architecture rtb;
