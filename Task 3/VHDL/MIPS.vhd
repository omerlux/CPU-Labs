				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.all; 


ENTITY MIPS IS

	PORT( reset,clk_50Mhz				: IN 	STD_LOGIC;
		-- Key0 = reset
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
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch
   	     PORT(	Instruction			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );		-- 10 BITS
        		Add_result 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );		-- 8 BITS
        		Branch_eq 			: IN 	STD_LOGIC;
				Branch_neq 			: IN 	STD_LOGIC;
        		Zero 				: IN 	STD_LOGIC;
				Jump				: IN	STD_LOGIC;
        		PC_out 				: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );		-- 10 BITS
        		clock,reset 		: IN 	STD_LOGIC );
	END COMPONENT; 

	COMPONENT Idecode
 	     PORT(	read_data_1 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data_2 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		Instruction 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		ALU_result 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		RegWrite, MemtoReg 	: IN 	STD_LOGIC;
        		RegDst 				: IN 	STD_LOGIC;
        		Sign_extend 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT control
	     PORT( 	Opcode 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
             	RegDst 				: OUT 	STD_LOGIC;
             	ALUSrc 				: OUT 	STD_LOGIC;
             	MemtoReg 			: OUT 	STD_LOGIC;
             	RegWrite 			: OUT 	STD_LOGIC;
             	MemRead 			: OUT 	STD_LOGIC;
             	MemWrite 			: OUT 	STD_LOGIC;
             	Branch_eq			: OUT 	STD_LOGIC;
				Branch_neq			: OUT 	STD_LOGIC;
             	ALUop 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );		   					   
				Jump				: OUT	STD_LOGIC;			
             	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
   	     PORT(	Read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
                Read_data_2 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Sign_Extend 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Function_opcode		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				I_opcode			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );				
               	ALUOp 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				Jump				: IN	STD_LOGIC;		   
               	ALUSrc 				: IN 	STD_LOGIC;
               	Zero 				: OUT	STD_LOGIC;
               	ALU_Result 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Add_Result 			: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );		-- 8 BITS
               	PC_plus_4 			: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );	-- 10 BITS
               	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;


	COMPONENT dmemory
	     PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		address 			: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );		-- 10 BITS
        		write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		MemRead, Memwrite 	: IN 	STD_LOGIC;
        		Clock,reset			: IN 	STD_LOGIC
				);
	END COMPONENT;

					-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );					-- 10 BITS
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );					-- 8 BITS
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL Branch_eq 		: STD_LOGIC;
	SIGNAL Branch_neq 		: STD_LOGIC;							 
	SIGNAL RegDst 			: STD_LOGIC;
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC;
	SIGNAL MemRead 			: STD_LOGIC;						   
	SIGNAL Jump				: STD_LOGIC;						
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  1 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL Address_ALU_res  : STD_LOGIC_VECTOR(9 DOWNTO 0);
	-- FOR IO
	COMPONENT LCD IS
		Port ( bits : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
			hex : OUT  STD_LOGIC_VECTOR (6 DOWNTO 0)
             );
	END COMPONENT;
	SIGNAL HEX0_tmp	   : STD_LOGIC_VECTOR (6 DOWNTO 0);
	SIGNAL HEX1_tmp    : STD_LOGIC_VECTOR (6 DOWNTO 0);
	SIGNAL HEX2_tmp	   : STD_LOGIC_VECTOR (6 DOWNTO 0);
	SIGNAL HEX3_tmp	   : STD_LOGIC_VECTOR (6 DOWNTO 0);
	SIGNAL Switches_out	  : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL read_data_tmp  : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL MemWrite_mem	: STD_LOGIC;
	SIGNAL MemRead_mem	: STD_LOGIC;
	SIGNAL ioWrite		: STD_LOGIC;
	SIGNAL ioRead		: STD_LOGIC;
	
	-- FOR CLOCK DEVISION
	SIGNAL counter_int 		: std_logic_vector (2 downto 0):="000";		-- to divide the 50mhz  
	SIGNAL clock 			: std_logic:='0';
	SIGNAL reset_inv		: std_logic;
BEGIN
	Zero4LEDR <= "00";
	reset_inv <= NOT reset;

	-- IO / MEM
	MemWrite_mem <= MemWrite AND (NOT(ALU_Result(11)));			-- Writing to mem / IO 
	--MemRead_mem	<= MemRead AND (NOT(ALU_Result(11)));			
	ioWrite		<= MemWrite AND ALU_Result(11);					-- Writing to IO - see after components
	ioRead		<= MemRead AND ALU_Result(11);	
	-- Added this line to get the switches value into register - memory >= 800h
	read_data <= X"000000" & Switches_out WHEN ioRead = '1'	-- read_data from IO switches
			ELSE read_data_tmp;								-- normal read_data from DMEMORY
	-- temp signal for ALU_res to address:
	Address_ALU_res <= ALU_Result(9 DOWNTO 2) & "00";
	
					-- copy important signals to output pins for easy 
					-- display in Simulator
   Instruction_out 	<= Instruction;
   ALU_result_out 	<= ALU_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;
   write_data_out  	<= read_data WHEN MemtoReg = '1' ELSE ALU_result;
   Branch_out 		<= Branch_eq OR Branch_neq;
   Zero_out 		<= Zero;
   RegWrite_out 	<= RegWrite;
   MemWrite_out 	<= MemWrite;	
					-- connect the 5 MIPS components   
  IFE : Ifetch
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				Branch_eq		=> Branch_eq,
				Branch_neq		=> Branch_neq,	  
				Zero 			=> Zero,
				Jump			=> Jump,
				PC_out 			=> PC,        		
				clock 			=> clock,  
				reset 			=> reset_inv );

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data 		=> read_data,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				RegDst 			=> RegDst,
				Sign_extend 	=> Sign_extend,
        		clock 			=> clock,  
				reset 			=> reset_inv );


   CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				Branch_eq		=> Branch_eq,
				Branch_neq		=> Branch_neq,
				ALUop 			=> ALUop,		  
				Jump			=> Jump,   
                clock 			=> clock,
				reset 			=> reset_inv );

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
                Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				I_opcode		=> Instruction(31 DOWNTO 26),						   
				ALUOp 			=> ALUop,		  
				Jump			=> Jump,   
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset_inv );

   MEM:  dmemory
	PORT MAP (	read_data 		=> read_data_tmp,
				address 		=> Address_ALU_res,--jump memory address by 4
				write_data 		=> read_data_2,
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite_mem, 
                clock 			=> clock,  
				reset 			=> reset_inv
				);
				
	-- For clock division			
	process (clk_50Mhz)
		begin
			if (rising_edge(clk_50Mhz)) then	   
				counter_int <= counter_int + 1;
			end if;
			if (rising_edge(clk_50Mhz) AND counter_int = "000" ) then -- Clock is = 50Mhz / 2^(|count|+1)
				clock <= NOT clock;
			end if;
	end process;
	--clock <= clk_50Mhz; -- No need for less than 24 Mhz
	
	-- For IO
	-- Setting up the memory to Signals --
	-- LW in 800h+, SW in 800h+ - in address it will divided by 4 -> 200h +
	-- read_data_2 is the register data we need to write to the IO

	Switches_out <= Switches 
			WHEN (ALU_Result (11 DOWNTO 2) = X"206" AND ioRead ='1')		-- means 0x818
			ELSE (OTHERS => '0');											-- usual output no switches
	
	PROCESS (ALU_Result, ioWrite)
		BEGIN
			IF (ALU_Result (11 DOWNTO 2) = X"200" AND (ioWrite = '1')) THEN -- Green led - 800H
				LEDG_out <= read_data_2(7 DOWNTO 0);
			ELSE
				LEDG_out <= LEDG_out;
			END IF;
			IF (ALU_Result (11 DOWNTO 2) = X"201" AND (ioWrite = '1')) THEN -- Red led - 804H ...
				LEDR_out <= read_data_2(15 DOWNTO 8);
			ELSE
				LEDR_out <= LEDR_out;
			END IF;
			
			IF (ALU_Result (11 DOWNTO 2) = X"202" AND (ioWrite = '1')) THEN	-- HEX0
				HEX0_out <= HEX0_tmp;
			ELSE
				HEX0_out <= HEX0_out;
			END IF;	
			IF (ALU_Result (11 DOWNTO 2) = X"203" AND (ioWrite = '1')) THEN -- HEX1
				HEX1_out <= HEX1_tmp;
			ELSE
				HEX1_out <= HEX1_out;
			END IF;			
			IF (ALU_Result (11 DOWNTO 2) = X"204" AND (ioWrite = '1')) THEN -- HEX2
				HEX2_out <= HEX2_tmp;
			ELSE
				HEX2_out <= HEX2_out;
			END IF;				
			IF (ALU_Result (11 DOWNTO 2) = X"205" AND (ioWrite = '1')) THEN -- HEX3
				HEX3_out <= HEX3_tmp;
			ELSE
				HEX3_out <= HEX3_out;
			END IF;					
	END PROCESS;

	-- HEX configuration
	bitsToHex1:  LCD  port map (
					bits => read_data_2(3 DOWNTO 0),
					hex=>HEX0_tmp
	);	
	bitsToHex2: LCD  port map (
					bits => read_data_2(7 DOWNTO 4),
					hex=>HEX1_tmp
	);	
	bitsToHex3: LCD  port map (
					bits => read_data_2(11 DOWNTO 8),
					hex=>HEX2_tmp
	);	
	bitsToHex4: LCD  port map (
					bits => read_data_2(15 DOWNTO 12),
					hex=>HEX3_tmp
	);	
	
END structure;

