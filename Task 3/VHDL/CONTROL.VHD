		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC;
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC;
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 	: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Branch_eq	: OUT 	STD_LOGIC;
	Branch_neq	: OUT 	STD_LOGIC;
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );				  
	Jump		: OUT	STD_LOGIC;				   
	clock, reset: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq, I_format, Bnq 	: STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
	Bnq			<=  '1'  WHEN  Opcode = "000101"  ELSE '0'; --Bnq
	I_format	<=	'1'  WHEN  Opcode = "001100" OR -- ANDI
							   Opcode = "001101" OR -- ORI
							   Opcode = "001000" OR -- ADDI
							   Opcode = "001001" OR -- ADDU (Move)
							   Opcode = "001110"	-- XORI
							   ELSE '0'; 																	   
	Jump		<=  '1'  WHEN  Opcode = "000010"  ELSE '0';											  
  	RegDst    	<=  R_format;					-- I_format will write to the second address (check IDECODE)
 	ALUSrc  	<=  Lw OR Sw OR I_format;		-- will make Binput = immd
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  R_format OR Lw OR I_format;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch_eq   <=  Beq;
	Branch_neq	<=  Bnq;
	ALUOp( 1 ) 	<=  R_format OR I_format;
	ALUOp( 0 ) 	<=  Beq OR Bnq; 
									

   END behavior;


