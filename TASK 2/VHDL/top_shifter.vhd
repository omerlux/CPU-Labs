LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE work.aux_package.all;
-------------------------------------------------------------
entity top_shifter is
	generic (
		n : positive := 8 ; -- A,B length
		m : positive := 5 ; -- OPC length
		k : positive := 2   -- STATUS length
	);
	port(
		rst,ena,clk,cin : in std_logic;
		A,B : in std_logic_vector(n-1 downto 0);
		OPC : in std_logic_vector(m-1 downto 0);
		----------------------------------------
		RES : out std_logic_vector(2*n-1 downto 0); -- RES(HI,LO)
		STATUS : out std_logic_vector(k-1 downto 0)
	);
end top_shifter;
------------- complete the top Architecture code --------------
architecture arc_sys of top_shifter is
	SIGNAL reg2ALU_cin: std_logic;
	SIGNAL reg2ALU_A: std_logic_vector(n-1 downto 0);
	SIGNAL reg2ALU_B: std_logic_vector(n-1 downto 0);
	SIGNAL reg2ALU_OPC: std_logic_vector(m-1 downto 0);
	--------------------------------------------------
	SIGNAL ALU2reg_RES: std_logic_vector(2*n-1 downto 0);
	SIGNAL ALU2reg_CARRY: std_logic;
	--------------------------------------------------
	SIGNAL reg2_RES: std_logic_vector(2*n-1 downto 0);
	SIGNAL reg2_CARRY: std_logic;
begin
	
	-- Register 1:
	PROCESS (clk, rst, ena)
	BEGIN
		IF (rst='1') THEN	-- Asynchronous part
			reg2ALU_cin <= '0';
			reg2ALU_A <= (others => '0');
			reg2ALU_B <= (others => '0');
			reg2ALU_OPC <= (others => '0');
		ELSIF (clk'EVENT and clk='1') THEN -- Synchronous part
			IF (ena='1') THEN	-- Enable is 1
				reg2ALU_cin <= 	cin;
				reg2ALU_A <= 	A;
				reg2ALU_B <= 	B;
				reg2ALU_OPC <= 	OPC;
			END IF;
		END IF;
	END PROCESS;			
	
	-- SHIFTER:
	Shifter_create : Shift_Unit generic map(n,m,k) 
	port map(
		cin => reg2ALU_cin,
		A 	=> reg2ALU_A,
		B 	=> reg2ALU_B,
		OPC	=> reg2ALU_OPC,
		-------------------
		RES	=> ALU2reg_RES,
		CARRY => ALU2reg_CARRY
		);
	
	-- Register 2:
	PROCESS (clk, rst, ena)
	BEGIN
		IF (rst='1') THEN	-- Asynchronous part
			reg2_RES <= (others => '0');
			reg2_CARRY <= '0';
		ELSIF (clk'EVENT and clk='1') THEN 	-- Synchronous part
			IF (ena='1') THEN				-- Enable is 1
				reg2_RES <= ALU2reg_RES;
				reg2_CARRY <= ALU2reg_CARRY;
			END IF;
			RES <= reg2_RES;
			STATUS <= '0' & reg2_CARRY;
		END IF;
	END PROCESS;			
end arc_sys;







