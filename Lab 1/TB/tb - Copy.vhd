library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------------
entity tb is
	constant m : integer := 3;
end tb;
--------------------------------------------------------------
architecture rtb of tb is
	SIGNAL cin : STD_LOGIC :='0';
	SIGNAL sel : STD_LOGIC_VECTOR (1 DOWNTO 0):="00";
	SIGNAL X,Y : STD_LOGIC_VECTOR (m-1 DOWNTO 0):=(others=>'0');
	SIGNAL s   : STD_LOGIC_VECTOR (m DOWNTO 0):=(others=>'0');
begin
	tester : top generic map (m) port map(cin,sel,X,Y,s);
	--------- start of stimulus section ------------------	
		
		tb : process
        begin
		  cin <= '0';
		  sel <= "00";
		  X <= "00000000";
		  Y <= "11111111";
		  wait for 50 ns;
		  cin <= '1';
		  sel <= "00";
		  X <= "11111110";
		  Y <= "00000001";
		  wait for 50 ns;
		  cin <= '0';
		  sel <= "00";
		  X <= "11111100";
		  Y <= "00000011";
		  wait for 50 ns;
		  cin <= '1';
		  sel <= "00";
		  X <= "11111010";
		  Y <= "00000101";
		  wait for 50 ns;
		  cin <= '0';
		  sel <= "00";
		  X <= "11111000";
		  Y <= "00000111";
		  wait for 50 ns;
		  cin <= '1';
		  sel <= "00";
		  X <= "11110110";
		  Y <= "00001001";
		  wait for 50 ns;
        end process tb;
  
end architecture rtb;
