library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------------
entity tb_adder_sub is
	constant m : integer := 3;
end tb_adder_sub;
--------------------------------------------------------------
architecture rtb of tb_adder_sub is
	SIGNAL cin : STD_LOGIC :='0';
	SIGNAL sel : STD_LOGIC_VECTOR (1 DOWNTO 0):="00";
	SIGNAL X,Y : STD_LOGIC_VECTOR (m-1 DOWNTO 0):=(others=>'0');
	SIGNAL s   : STD_LOGIC_VECTOR (m DOWNTO 0):=(others=>'0');
begin
	tester : Adder_Subtractor generic map (m) port map(cin,sel,X,Y,s);
	--------- start of stimulus section ------------------	
		
		tb_adder_sub : process
        begin
		  sel <= "00"; -- X+Y
		  cin <= '0';
		  X <= (others => '0');
		  Y <= ("011");
		  for i in 0 to 6 loop
			wait for 50 ns;
			X <= X+1;
		  end loop;
		  wait for 50 ns;
		  cin <= '1';
		  X <= (others => '0');
		  Y <= ("011");
		  for i in 0 to 6 loop
			wait for 50 ns;
			X <= X+1;
		  end loop;
		  wait for 50 ns;
		
		  sel <= "01"; -- X+Y+Cin
		  cin <= '0';
		  X <= (others => '0');
		  Y <= ("011");
		  for i in 0 to 6 loop
			wait for 50 ns;
			X <= X+1;
		  end loop;
		  wait for 50 ns;
		  cin <= '1';
		  X <= (others => '0');
		  Y <= ("011");
		  for i in 0 to 6 loop
			wait for 50 ns;
			X <= X+1;
		  end loop;
		  wait for 50 ns;
		
		  sel <= "10"; -- X-Y
		  cin <= '0';
		  X <= (others => '0');
		  Y <= ("011");
		  for i in 0 to 6 loop
			wait for 50 ns;
			X <= X+1;
		  end loop;
		  wait for 50 ns;
		  cin <= '1';
		  X <= (others => '0');
		  Y <= ("011");
		  for i in 0 to 6 loop
			wait for 50 ns;
			X <= X+1;
		  end loop;
		  wait for 50 ns;
		  
		  -- shifter check
		  sel <= "11"; -- shift
		  cin <= '0';
		  X <= "111";
		  Y <= "000";
		  for i in 0 to 6 loop
			wait for 50 ns;
			Y <= Y+1;
		  end loop;
		  wait for 50 ns;
		  X <= "001";
		  Y <= "000";
		  for i in 0 to 6 loop
			wait for 50 ns;
			Y <= Y+1;
		  end loop;
		  wait;
		
        end process tb_adder_sub;
  
end architecture rtb;
