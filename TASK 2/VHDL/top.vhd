LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE work.aux_package.all;
-------------------------------------------------------------
entity top is
	generic (
		n : positive := 8 ; -- A,B length
		m : positive := 5 ; -- OPC length
		k : positive := 2   -- STATUS length
	);
	port(
		ena_A, ena_OP, ena_B, clk_mac : in std_logic;
		clk, clk_ena : in std_logic;
		input : in std_logic_vector(n-1 downto 0);
		----------------------------------------
		RES_HI : buffer std_logic_vector(n-1 downto 0); -- RES(HI)
		RES_LO : buffer std_logic_vector(n-1 downto 0); -- RES(LO)
		STATUS : out std_logic_vector(k-1 downto 0);
		HEX0 : out std_logic_vector(6 downto 0);
		HEX1 : out std_logic_vector(6 downto 0);
		HEX2 : out std_logic_vector(6 downto 0);
		HEX3 : out std_logic_vector(6 downto 0)
	);
end top;
------------- complete the top Architecture code --------------
architecture arc_sys of top is
	SIGNAL reg2ALU_A: std_logic_vector(n-1 downto 0);
	SIGNAL reg2ALU_B: std_logic_vector(n-1 downto 0);
	SIGNAL reg2ALU_OPC: std_logic_vector(m-1 downto 0);
begin
	
	-- Register A
	PROCESS (ena_A)
	BEGIN
		IF(rising_edge(ena_A)) THEN	-- Key pressed
			reg2ALU_A <= input;
		END IF;
	END PROCESS;
	
	-- Register B
	PROCESS (ena_B)
	BEGIN
		IF(rising_edge(ena_B)) THEN	-- Key pressed
			reg2ALU_B <= input;
		END IF;
	END PROCESS;
	
	-- Register OPC
	PROCESS (ena_OP)
	BEGIN
		IF(rising_edge(ena_OP)) THEN	-- Key pressed
			reg2ALU_OPC <= input(m-1 downto 0);
		END IF;
	END PROCESS;
	
	-- ALU:
	ALU_create : ALU generic map(n,m,k) 
	port map(
		clk => clk_mac,
		cin => '0',
		A 	=> reg2ALU_A,
		B 	=> reg2ALU_B,
		OPC	=> reg2ALU_OPC,
		-------------------
		HI	=> RES_HI,
		LO	=> RES_LO,
		STATUS => STATUS
		);
		
	bits2hex1:  LCD  port map (
					bits => RES_LO (3 downto 0),
					hex=>HEX0
	);	
	bits2hex2: LCD  port map (
					bits => RES_LO (7 downto 4),
					hex=>HEX1
	);	
	bits2hex3: LCD  port map (
					bits => RES_HI (3 downto 0),
					hex=>HEX2
	);	
	bits2hex4: LCD  port map (
					bits => RES_HI (7 downto 4),
					hex=>HEX3
	);
			
end arc_sys;







