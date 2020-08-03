LIBRARY ieee;
USE ieee.std_logic_1164.all;
-------------------------------------
ENTITY sync_delay IS
  GENERIC (n : INTEGER := 8);
  PORT ( 
		rst,ena,clk : in std_logic;
		din : in std_logic_vector(n-1 downto 0);
		dout_new	: out std_logic_vector(n-1 downto 0);
		dout_old : out std_logic_vector(n-1 downto 0)
		 );

END sync_delay;
------------------------------------------------
ARCHITECTURE rtl OF sync_delay IS
	SIGNAL internal: std_logic_vector (n-1 downto 0);
BEGIN
	PROCESS (clk, rst, ena)
	BEGIN
		IF (rst='1') THEN	-- Asynchronous part
			dout_old <= (others => '0');
		ELSIF (clk'EVENT and clk='1') THEN -- Synchronous part
			IF (ena='1') THEN	-- Enable is 1
				dout_new <= din;			-- this output won't be stored
				internal <= din;			-- this is the delayed din
				dout_old <= internal;
			END IF;
		END IF;
		
	END PROCESS;
END rtl;
