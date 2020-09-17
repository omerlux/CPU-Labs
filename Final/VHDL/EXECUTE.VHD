--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			Opcode			: IN	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );								
			Jump			: IN	STD_LOGIC;	
			isJR			: IN    STD_LOGIC;
			ALUSrc 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 8 DOWNTO 0 );		-- 9 BITS
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 10 DOWNTO 0 );	-- 11 BITS
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS

	component RLA IS
		GENERIC (n : INTEGER := 32);
		PORT (    --cin: IN STD_LOGIC;
			x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            res: OUT STD_LOGIC_VECTOR(n-1 downto 0));
	END component;
	
	component RRA IS
		GENERIC (n : INTEGER := 32);
		PORT (    --cin: IN STD_LOGIC;
			x,y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
            res: OUT STD_LOGIC_VECTOR(n-1 downto 0));
	END component;
	
SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 8 DOWNTO 0 );			-- 9 BITS - this will be address
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 2 DOWNTO 0 );
SIGNAL Shamt				: STD_LOGIC_VECTOR( 31 DOWNTO 0);
SIGNAL RLA_out			    : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL RRA_out			    : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
BEGIN
	Shamt <= X"000000" & B"000" & Sign_extend(10 DOWNTO 6);
	
	Shift_L: RLA
	PORT MAP ( 	x => Binput,
				y => Shamt,
				res => RLA_out );
				
	Shift_R: RRA
	PORT MAP ( 	x => Binput,
				y => Shamt,
				res => RRA_out );
	
	Ainput <= Read_data_1;	-- RS
						-- ALU input mux
	Binput <= Read_data_2 	-- RT
		WHEN ( ALUSrc = '0' ) 	-- if lw/sw/i_format: than B is the immediate
  		ELSE  X"0000" & Sign_extend( 15 DOWNTO 0) 
		WHEN (Opcode="001100" OR Opcode="001101" OR Opcode="001110")														
		ELSE  Sign_extend( 31 DOWNTO 0 );
						-- Generate ALU control bits
	-- ALU_ctl( 0 ) <= ( Function_opcode( 0 ) OR Function_opcode( 3 ) ) AND ALUOp(1 );
	-- ALU_ctl( 1 ) <= ( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) );
	-- ALU_ctl( 2 ) <= ( Function_opcode( 1 ) AND ALUOp( 1 )) OR ALUOp( 0 );
	
	ALU_ctl <=  "110" WHEN ALUOp(0)='1' OR (Opcode="000000" AND Function_opcode="100010")	-- BEQ - branch if equal / BNQ - branch if not equal / SUB
		ELSE	"000" WHEN (Opcode="000000" AND Function_opcode="100100") OR Opcode="001100" -- AND,  ANDI
		ELSE	"001" WHEN (Opcode="000000" AND Function_opcode="100101") OR Opcode="001101" -- OR,   ORI
		ELSE	"010" WHEN (Opcode="000000" AND Function_opcode="100000") OR Opcode="001000" OR -- ADD,  ADDI
						   (ALUOp = "00")	-- LW / SW
		ELSE	"011" WHEN (Opcode="000000" AND Function_opcode="100001") OR Opcode="001001" -- ADDU, ADDIU
		ELSE	"100" WHEN (Opcode="000000" AND Function_opcode="100110") OR Opcode="001110" -- XOR,  XORI
		ELSE 	"111" WHEN (Opcode="000000" AND Function_opcode="101010") -- SLT - set less than
		ELSE 	"101"; -- zero out...
						-- Generate Zero Flag
	Zero <= '1' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )
		ELSE '0';    
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) WHEN  ALU_ctl = "111"  	-- SLT - set less than
		ELSE	RLA_out WHEN Opcode="000000" AND Function_opcode = "000000" 			-- sll
		ELSE	RRA_out WHEN Opcode="000000" AND Function_opcode = "000010"				-- srl
		ELSE	B"0" & X"00000" & PC_plus_4 WHEN Opcode="000011" 						-- jal !!! not taking care of modelsim/quartus problem!
		ELSE  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 10 DOWNTO 2 ) +  Sign_extend( 8 DOWNTO 0 ) ;			
	
	Add_result 	<= 	-- Add_result is the address in words! not bytes!!!	
				Sign_extend(8 DOWNTO 0) WHEN Jump='1'
				ELSE	Ainput(10 DOWNTO 2) 		WHEN isJR = '1'
				ELSE   	Branch_Add( 8 DOWNTO 0 );	

PROCESS ( ALU_ctl, Ainput, Binput )
	BEGIN
					-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "010" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- ALU performs MOVE which is ADDU with '0'
 	 	WHEN "011" 	=>	ALU_output_mux  <= UNSIGNED(Ainput) + UNSIGNED(Binput);		-- added by function_op = 21h
						-- ALU performs ALUresult = A XOR B
 	 	WHEN "100" 	=>	ALU_output_mux 	<= Ainput XOR Binput;	-- added by function_op = 26h
						-- ALU performs ?
 	 	WHEN "101" 	=>	ALU_output_mux 	<= X"00000000";
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "111" 	=>	ALU_output_mux 	<= Ainput - Binput ;
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
END behavior;