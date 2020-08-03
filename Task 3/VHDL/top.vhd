LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
-------------------------------------------------------------
entity top is
	port(
		reset,clk_50Mhz				: IN 	STD_LOGIC;
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );		-- 10 BITS
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC ;

		Switches	   		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		LEDG_out	   		: BUFFER STD_LOGIC_VECTOR (7 DOWNTO 0);
		LEDR_out	   		: BUFFER STD_LOGIC_VECTOR (7 DOWNTO 0);
		HEX0_out	   		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg
		HEX1_out	  		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg
		HEX2_out	  		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg
		HEX3_out	  		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg	
		Zero4LEDR			: OUT	 STD_LOGIC_VECTOR (1 DOWNTO 0)		-- just for ledr8,9 = 0

	);
end top;
------------- complete the top Architecture code --------------
architecture arc_sys of top is

	COMPONENT MIPS
		PORT(	reset,clk_50Mhz				: IN 	STD_LOGIC;
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );		-- 10 BITS
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC ;

		Switches	   		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		LEDG_out	   		: BUFFER STD_LOGIC_VECTOR (7 DOWNTO 0);
		LEDR_out	   		: BUFFER STD_LOGIC_VECTOR (7 DOWNTO 0);
		HEX0_out	   		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg
		HEX1_out	  		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg
		HEX2_out	  		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg
		HEX3_out	  		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg	
		Zero4LEDR			: OUT	 STD_LOGIC_VECTOR (1 DOWNTO 0));		-- just for ledr8,9 = 0				
	END COMPONENT;
	
	SIGNAL reset_MIPS, clk_50Mhz_MIPS	: STD_LOGIC;
	SIGNAL PC_MIPS			: STD_LOGIC_VECTOR( 9 DOWNTO 0 );		-- 10 BITS
	SIGNAL	ALU_result_out_MIPS, read_data_1_out_MIPS, read_data_2_out_MIPS, write_data_out_MIPS,	
     	Instruction_out_MIPS		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL	Branch_out_MIPS, Zero_out_MIPS, Memwrite_out_MIPS, 
		Regwrite_out_MIPS			: STD_LOGIC ;
	SIGNAL	Switches_MIPS	   		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL	LEDG_out_MIPS	   		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL	LEDR_out_MIPS	   		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL	HEX0_out_MIPS	   		: STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg
	SIGNAL	HEX1_out_MIPS  			: STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg
	SIGNAL	HEX2_out_MIPS	  		: STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg
	SIGNAL	HEX3_out_MIPS	  		: STD_LOGIC_VECTOR (6 DOWNTO 0);		-- converting to 7-seg	
	SIGNAL	Zero4LEDR_MIPS			: STD_LOGIC_VECTOR (1 DOWNTO 0);
begin

	PROCESS (clk_50Mhz)
	BEGIN
		IF(rising_edge(clk_50Mhz)) THEN
			reset_MIPS 		<= reset;
			Switches_MIPS	<= Switches;
		END IF;
	END PROCESS;

	-- MIPS:
	MIPS_create : MIPS
	port map(
		reset				=> reset_MIPS,
		clk_50Mhz			=> clk_50Mhz,	
		PC					=> PC_MIPS,
		ALU_result_out		=> ALU_result_out_MIPS,
		read_data_1_out		=> read_data_1_out_MIPS,
		read_data_2_out		=> read_data_2_out_MIPS,
		write_data_out		=> write_data_out_MIPS,
     	Instruction_out		=> Instruction_out_MIPS,
		Branch_out			=> Branch_out_MIPS,
		Zero_out			=> Zero_out_MIPS,
		Memwrite_out 		=> Memwrite_out_MIPS,
		Regwrite_out		=> Regwrite_out_MIPS,
		Switches			=> Switches_MIPS,
		LEDG_out			=> LEDG_out_MIPS,
		LEDR_out			=> LEDR_out_MIPS,
		HEX0_out			=> HEX0_out_MIPS,
		HEX1_out			=> HEX1_out_MIPS,
		HEX2_out			=> HEX2_out_MIPS,
		HEX3_out			=> HEX3_out_MIPS,
		Zero4LEDR			=> Zero4LEDR_MIPS
		);
	
	PROCESS (clk_50Mhz)
	BEGIN
		IF(rising_edge(clk_50Mhz)) THEN
			PC					<= PC_MIPS;
			ALU_result_out		<= ALU_result_out_MIPS;
			read_data_1_out		<= read_data_1_out_MIPS;
			read_data_2_out		<= read_data_2_out_MIPS;
			write_data_out		<= write_data_out_MIPS;
			Instruction_out		<= Instruction_out_MIPS;
			Branch_out			<= Branch_out_MIPS;
			Zero_out			<= Zero_out_MIPS;
			Memwrite_out 		<= Memwrite_out_MIPS;
			Regwrite_out		<= Regwrite_out_MIPS;
			LEDG_out			<= LEDG_out_MIPS;
			LEDR_out			<= LEDR_out_MIPS;
			HEX0_out			<= HEX0_out_MIPS;
			HEX1_out			<= HEX1_out_MIPS;
			HEX2_out			<= HEX2_out_MIPS;
			HEX3_out			<= HEX3_out_MIPS;
			Zero4LEDR			<= Zero4LEDR_MIPS;
		END IF;
	END PROCESS;
			
end arc_sys;







