LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
-------------------------------------
ENTITY detect IS
  GENERIC (m: INTEGER := 7;
		   k: INTEGER := 3);
  PORT ( 
		count : in std_logic_vector(k-1 downto 0);
		detector : out std_logic
		);
END detect;
------------------------------------------------
ARCHITECTURE rtl OF detect IS
	SIGNAL m_logic: std_logic_vector (k-1 downto 0);
BEGIN
	m_logic <= CONV_STD_LOGIC_VECTOR(m, k); -- converted m to a std_logic_vector signal length k
	detector <= '1' WHEN count = m_logic ELSE	-- if count is m, the detector is 1
				'0';
END rtl;