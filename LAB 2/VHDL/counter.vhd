LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
-------------------------------------
ENTITY counter IS
  GENERIC (m: INTEGER := 7 ;
		   k: INTEGER := 3);
  PORT ( 
		rst,ena,clk : in std_logic;
		rise : in std_logic;
		count : buffer std_logic_vector(k-1 downto 0):=(others=>'0')
		);
END counter;
------------------------------------------------
ARCHITECTURE rtl OF counter IS
BEGIN
	PROCESS (clk, rst, ena)
	BEGIN
		IF (rst='1') THEN	-- Asynchronous part
			count <= (others => '0');
		ELSIF (clk'EVENT and clk='1') THEN -- Synchronous part
			IF (ena='1') THEN	-- Enable is 1:
				IF rise='1' THEN	-- rise is 1:
					IF count = m THEN	-- count is m=7
						count <= CONV_STD_LOGIC_VECTOR(m,k);	-- stay at m=7
					ELSE
						count <= count + '1';	-- feedback adder till m=7 ###won't create Adder
					END IF;
				ELSE	-- rise is 0:
					count <= (others => '0');	-- reset count
				END IF; -- end rise
			END IF; -- end enable
		END IF; -- and clk='1'
	END PROCESS;
END rtl;
