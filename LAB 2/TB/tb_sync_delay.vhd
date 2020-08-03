library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity tb_sync_delay is
	constant n : integer := 8;
end tb_sync_delay;
--------------------------------------------------------------
architecture rtb of tb_sync_delay is
	SIGNAL rst,ena,clk : std_logic := '0';
	SIGNAL din : std_logic_vector (n-1 DOWNTO 0):=(others=>'0');
	SIGNAL dout_new	: std_logic_vector(n-1 downto 0):=(others=>'0');
	SIGNAL dout_old : std_logic_vector(n-1 downto 0):=(others=>'0');
	component sync_delay IS
		GENERIC (n: INTEGER := 8);
		PORT (
			rst,ena,clk : in std_logic;
			din : in std_logic_vector(n-1 downto 0);
			dout_new	: out std_logic_vector(n-1 downto 0);
			dout_old : out std_logic_vector(n-1 downto 0));
	END component;
begin
	tester : sync_delay generic map (n) port map(rst,ena,clk,din,dout_new,dout_old);
	--------- start of stimulus section ------------------	
	process
		begin
		ena <='1';
		clk <= '0';
		for i in 0 to 19 loop
			wait for 50 ns;
			clk <= not clk;
		 end loop;
	end process;
	
	process
		begin
		din <= (others => '1');
		for i in 0 to 9 loop
			wait for 100 ns;
			din <= din-1;
		end loop;
	end process;

end architecture rtb;
