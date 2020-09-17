				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.all; 


ENTITY MIPS IS
	GENERIC (n : INTEGER := 1);
	-- Model-sim is n=0, and quartus is n=/=0
	PORT( reset,clk_24Mhz				: IN 	STD_LOGIC;
		-- Key0 = reset
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( 10 DOWNTO 0 );		-- 11 BITS
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC ;

		-- EDIT
		ENABLE				: IN STD_LOGIC;			-- Trigger for signal tap
		KEY1				: IN STD_LOGIC;			
		KEY2				: IN STD_LOGIC;	
		KEY3				: IN STD_LOGIC;	
		Switches	   		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		LEDG_out	   		: BUFFER STD_LOGIC_VECTOR (7 DOWNTO 0):=(others => '0');
		LEDR_out	   		: BUFFER STD_LOGIC_VECTOR (7 DOWNTO 0):=(others => '0');
		HEX0_out	   		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0):=(others => '0');		-- converting to 7-seg
		HEX1_out	  		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0):=(others => '0');		-- converting to 7-seg
		HEX2_out	  		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0):=(others => '0');		-- converting to 7-seg
		HEX3_out	  		: BUFFER STD_LOGIC_VECTOR (6 DOWNTO 0):=(others => '0');		-- converting to 7-seg	
		Zero4LEDR			: OUT	 STD_LOGIC_VECTOR (1 DOWNTO 0)		-- just for ledr8,9 = 0
	);
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch
		 GENERIC (n : INTEGER := 0);
   	     PORT(	Instruction			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 10 DOWNTO 0 );		-- 11 BITS
        		Add_result 			: IN 	STD_LOGIC_VECTOR( 8 DOWNTO 0 );		-- 9 BITS
        		Branch_eq 			: IN 	STD_LOGIC;
				Branch_neq 			: IN 	STD_LOGIC;
        		Zero 				: IN 	STD_LOGIC;
				Jump				: IN	STD_LOGIC;
				isJR				: IN	STD_LOGIC;
        		PC_out 				: OUT 	STD_LOGIC_VECTOR( 10 DOWNTO 0 );		-- 11 BITS
				INTR				: IN	STD_LOGIC;
				INTA				: OUT 	STD_LOGIC;
				ISR_adrs			: IN	STD_LOGIC_VECTOR( 8 DOWNTO 0);
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
				IntrptGIE			: OUT	STD_LOGIC;
				Return_PC			: IN	STD_LOGIC_VECTOR( 10 DOWNTO 0); -- 11Bits
        		clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT control
	     PORT( 	Opcode 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				Fun_op				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
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
				isJR				: OUT   STD_LOGIC;
             	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
   	     PORT(	Read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
                Read_data_2 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Sign_Extend 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Function_opcode		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				Opcode				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );				
               	ALUOp 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				Jump				: IN	STD_LOGIC;		   
				isJR				: IN	STD_LOGIC;		
               	ALUSrc 				: IN 	STD_LOGIC;
               	Zero 				: OUT	STD_LOGIC;
               	ALU_Result 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Add_Result 			: OUT	STD_LOGIC_VECTOR( 8 DOWNTO 0 );		-- 9 BITS
               	PC_plus_4 			: IN 	STD_LOGIC_VECTOR( 10 DOWNTO 0 );	-- 11 BITS
               	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;


	COMPONENT dmemory
	     PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		address 			: IN 	STD_LOGIC_VECTOR( 10 DOWNTO 0 );	-- 11 BITS
        		write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		MemRead, Memwrite 	: IN 	STD_LOGIC;
        		Clock,reset			: IN 	STD_LOGIC
				);
	END COMPONENT;
	
	COMPONENT BasicTimer
		PORT(	MCLK, reset			: IN 	STD_LOGIC;						-- Input
				BTCTL_W				: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Write
				BTCTL_R				: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Read
				BTCNT_W				: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Write
				BTCNT_R				: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Read
				BTIFG				: OUT	STD_LOGIC						-- Read
				);
	END COMPONENT;
	
	COMPONENT InterruptController
		PORT(	clock, reset		: IN	STD_LOGIC;
				INTA				: IN	STD_LOGIC;	-- 0 is ACK
				irq0				: IN	STD_LOGIC;
				irq1				: IN	STD_LOGIC;
				irq2				: IN	STD_LOGIC;
				irq3				: IN	STD_LOGIC;
				IE_W				: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Write
				IFG_W				: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Write
				IE_R				: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Read
				IFG_R				: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Read
				IFG_writebit		: IN	STD_LOGIC;
				ISR_MemAdrs			: OUT	STD_LOGIC_VECTOR(10 DOWNTO 0);	-- Read -> see for ref the 	Address_ALU_res	-- 11 BITS
				INTR				: OUT	STD_LOGIC						-- Read
				);
	END COMPONENT;

					-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( 10 DOWNTO 0 );					-- 11 BITS
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( 8 DOWNTO 0 );					-- 9 BITS
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
	SIGNAL isJR				: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  1 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL Address_ALU_res  : STD_LOGIC_VECTOR(10 DOWNTO 0);					-- 11 BITS
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
	SIGNAL IO_out	   : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL read_data_tmp  : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL MemWrite_mem	: STD_LOGIC;
	SIGNAL MemRead_mem	: STD_LOGIC;
	SIGNAL ioWrite		: STD_LOGIC;
	SIGNAL ioRead		: STD_LOGIC;
	
	SIGNAL BTCTL_W		: STD_LOGIC_VECTOR (7 DOWNTO 0):="00100000";
	SIGNAL BTCTL_R		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL BTCNT_W		: STD_LOGIC_VECTOR (31 DOWNTO 0):=(others => '0');
	SIGNAL BTCNT_R		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL BTIFG		: STD_LOGIC;
		
	SIGNAL GIE			: STD_LOGIC;						-- global interrupt enable - inserted from the IDECODE
	SIGNAL INTA			: STD_LOGIC;
	SIGNAL INTR_synced	: STD_LOGIC:='0';
	SIGNAL INTR			: STD_LOGIC;
	SIGNAL IE_W			: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL IE_R			: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL IFG_W		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL IFG_R		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL IFG_writebit : STD_LOGIC;
	SIGNAL ISR_MemAdrs	: STD_LOGIC_VECTOR (10 DOWNTO 0);	-- 11 Bits
	SIGNAL PC_tmp		: STD_LOGIC_VECTOR (10 DOWNTO 0);	-- 11 Bits
	
	SIGNAL KEY1_inv		: STD_LOGIC;
	SIGNAL KEY2_inv		: STD_LOGIC;
	SIGNAL KEY3_inv		: STD_LOGIC;
	
	SIGNAL clock 			: std_logic:='0';
	SIGNAL reset_inv		: std_logic;
	
BEGIN
	Zero4LEDR <= "00";
	
	reset_inv <= reset 	WHEN n=0	-- n=0 - Modelsim
			ELSE NOT reset;			-- n=/=0 - Quartus

	-- IO / MEM
	MemWrite_mem <= MemWrite AND (NOT(ALU_Result(11)));			-- Writing to mem / IO 
	--MemRead_mem	<= MemRead AND (NOT(ALU_Result(11)));			
	ioWrite		<= MemWrite AND ALU_Result(11);					-- Writing to IO - see after components
	ioRead		<= MemRead AND ALU_Result(11);
	
	-- Added this line to get the switches value into register - memory >= 800h
	read_data <= IO_out WHEN ioRead = '1'		-- read_data from IO switches
			ELSE read_data_tmp;								-- normal read_data from DMEMORY (when ioRead, still has a value)
	
	-- temp signal for ALU_res to address, OR interrupt address:
	Address_ALU_res <= 	
			"00" & ISR_MemAdrs(10 DOWNTO 2)	WHEN INTR_synced ='1' AND n=0	-- Interrupt address in memory (modelsim/quartus already taken care)
			ELSE ISR_MemAdrs(10 DOWNTO 2) & "00" WHEN INTR_synced ='1' AND n=1
			ELSE	"00" & ALU_Result(10 DOWNTO 2) 	WHEN n=0				-- n=0 - Modelsim
			ELSE 	ALU_Result(10 DOWNTO 2) & "00";							-- n=/=0 - Quartus	
					-- copy important signals to output pins for easy 
					-- display in Simulator
   Instruction_out 	<= Instruction;
   ALU_result_out 	<= ALU_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;
   write_data_out  	<= read_data WHEN MemtoReg = '1' ELSE ALU_result;
   Branch_out 		<= Branch_eq OR Branch_neq OR Jump OR isJR;
   Zero_out 		<= Zero;
   RegWrite_out 	<= RegWrite;
   MemWrite_out 	<= MemWrite OR ioWrite;	
					
					-- connect the 7 MIPS components   
  IFE : Ifetch
	GENERIC MAP (n)
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				Branch_eq		=> Branch_eq,
				Branch_neq		=> Branch_neq,	  
				Zero 			=> Zero,
				Jump			=> Jump,
				isJR			=> isJR,
				PC_out 			=> PC_tmp,  
				INTR			=> INTR_synced,					-- interrupt request (clock synced)
				INTA			=> INTA,						-- INTAck output: if 0 then acknowledge back to the interruptController
				ISR_adrs		=> read_data_tmp(10 DOWNTO 2),	-- the ISR address brought from the dmemory - take is as word
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
				IntrptGIE		=> GIE,
				Return_PC		=> PC_tmp,				-- PC is the current PC, out from IFETCH
        		clock 			=> clock,  
				reset 			=> reset_inv );


   CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				Fun_op			=> Instruction( 5  DOWNTO 0),
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
				isJR			=> isJR,
                clock 			=> clock,
				reset 			=> reset_inv );

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
                Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				Opcode			=> Instruction(31 DOWNTO 26),						   
				ALUOp 			=> ALUop,		  
				Jump			=> Jump,  
				isJR			=> isJR,
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset_inv );

   MEM:  dmemory
	PORT MAP (	read_data 		=> read_data_tmp,
				address 		=> Address_ALU_res,		--jump memory address by 4
				write_data 		=> read_data_2,
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite_mem, 
                clock 			=> clock,  
				reset 			=> reset_inv
				);
				
	BT:	 BasicTimer
	PORT MAP (	MCLK			=> clk_24Mhz, -- MCLK input
				reset			=> reset_inv,
				BTCTL_W			=> BTCTL_W,
				BTCTL_R			=> BTCTL_R,
				BTCNT_W			=> BTCNT_W,
				BTCNT_R 		=> BTCNT_R,
				BTIFG			=> BTIFG		-- Output
				);
				
	INTCTL: InterruptController
	PORT MAP (	clock			=> clock,
				reset			=> reset_inv,
				INTA			=> INTA,			-- ACK input
				irq0			=> KEY1_inv,		-- KEY1
				irq1			=> KEY2_inv,		-- KEY2
				irq2			=> KEY3_inv,		-- KEY3
				irq3			=> BTIFG,			-- irq3 is the clock
				IE_W			=> IE_W,
				IFG_W			=> IFG_W,
				IE_R			=> IE_R,
				IFG_R			=> IFG_R,
				IFG_writebit	=> IFG_writebit,
				ISR_MemAdrs		=> ISR_MemAdrs, 	-- will be input for dmemory
				INTR			=> INTR				-- this signal isn't synced with the clock
				);
	
	KEY1_inv <= NOT KEY1;
	KEY2_inv <= NOT KEY2;
	KEY3_inv <= NOT KEY3;
	process(clock, INTR)
		begin
			if rising_edge(clock) then
				INTR_synced <= INTR AND GIE;		-- GIE = '1' is enabling interrupts
			else
				INTR_synced <= INTR_synced;
			end if;
	end process;
	
	PC <= PC_tmp;
	
	process(clk_24Mhz)
		begin
			if rising_edge(clk_24Mhz) then
				clock <= NOT clock; -- need for less than 24 Mhz
			end if;
	end process;
	
	-- ============ For IO ==================
	-- Setting up the memory to Signals --
	-- LW in 800h+, SW in 800h+
	-- read_data_2 is the register data we need to write to the IO

	-- IO read
	IO_out <= X"000000" & Switches 	WHEN (ALU_Result (11 DOWNTO 0) = X"818" AND ioRead ='1')		-- Switches
		ELSE  X"0000000" & KEY3 & KEY2 & KEY1 & reset WHEN (ALU_Result (11 DOWNTO 0) = X"81C" AND ioRead ='1')		-- Keys
		ELSE  X"000000" & BTCTL_R 	WHEN (ALU_Result (11 DOWNTO 0) = X"820" AND ioRead ='1')		-- BTCTL
		ELSE  BTCNT_R				WHEN (ALU_Result (11 DOWNTO 0) = X"824" AND ioRead ='1')		-- BTCNT
		ELSE  X"000000" & IE_R		WHEN (ALU_Result (11 DOWNTO 0) = X"828" AND ioRead ='1')		-- IE
		ELSE  X"000000" & IFG_R		WHEN (ALU_Result (11 DOWNTO 0) = X"82C" AND ioRead ='1')		-- IFG
		ELSE  (OTHERS => '0');											-- usual output no switches
	
	PROCESS (clock, reset_inv, ALU_Result, ioWrite)
		BEGIN
			IF (reset_inv='1') THEN
				LEDG_out <= (others => '0');
				LEDR_out <= (others => '0');
				HEX0_out <= "1000000";
				HEX1_out <= "1000000";
				HEX2_out <= "1000000";
				HEX3_out <= "1000000";
				IFG_writebit <= '0';
				IFG_W	<= (others => '0');
				IE_W	<= (others => '0');
				BTCNT_W <= (others => '0');
				BTCTL_W	<= X"20";
			ELSIF falling_edge(clock) THEN	-- Writing in the half of a cycle
				-- Green Leds
				IF (ALU_Result (11 DOWNTO 0) = X"800" AND (ioWrite = '1')) THEN -- Green led - 800H
					LEDG_out <= read_data_2(7 DOWNTO 0);
				ELSE
					LEDG_out <= LEDG_out;
				END IF;
				-- Red Leds
				IF (ALU_Result (11 DOWNTO 0) = X"804" AND (ioWrite = '1')) THEN -- Red led - 804H ...
					LEDR_out <= read_data_2(15 DOWNTO 8);
				ELSE
					LEDR_out <= LEDR_out;
				END IF;
				-- HEX0
				IF (ALU_Result (11 DOWNTO 0) = X"808" AND (ioWrite = '1')) THEN	-- HEX0
					HEX0_out <= HEX0_tmp;
				ELSE
					HEX0_out <= HEX0_out;
				END IF;	
				-- HEX1
				IF (ALU_Result (11 DOWNTO 0) = X"80C" AND (ioWrite = '1')) THEN -- HEX1
					HEX1_out <= HEX1_tmp;
				ELSE
					HEX1_out <= HEX1_out;
				END IF;
				-- HEX2
				IF (ALU_Result (11 DOWNTO 0) = X"810" AND (ioWrite = '1')) THEN -- HEX2
					HEX2_out <= HEX2_tmp;
				ELSE
					HEX2_out <= HEX2_out;
				END IF;
				-- HEX3
				IF (ALU_Result (11 DOWNTO 0) = X"814" AND (ioWrite = '1')) THEN -- HEX3
					HEX3_out <= HEX3_tmp;
				ELSE
					HEX3_out <= HEX3_out;
				END IF;

				-- BasicTimer
				IF (ALU_Result (11 DOWNTO 0) = X"820" AND (ioWrite = '1')) THEN -- BTCTL
					BTCTL_W <= read_data_2(7 DOWNTO 0);
				ELSE
					BTCTL_W <= BTCTL_W;	
				END IF;
				IF (ALU_Result (11 DOWNTO 0) = X"824" AND (ioWrite = '1')) THEN -- BTCNT
					BTCNT_W	 <= read_data_2(31 DOWNTO 0);
				ELSE
					BTCNT_W  <= BTCNT_W;					-- using signal to represent it to the user
				END IF;
				
				-- InterruptController
				IF (ALU_Result (11 DOWNTO 0) = X"828" AND (ioWrite = '1')) THEN -- IE
					IE_W <= read_data_2(7 DOWNTO 0);
				ELSE
					IE_W <= IE_W;	
				END IF;
				IF (ALU_Result (11 DOWNTO 0) = X"82C" AND (ioWrite = '1')) THEN -- IFG
					IFG_W <= read_data_2(7 DOWNTO 0);
					IFG_writebit <= '1';
				ELSE
					IFG_W <= IFG_W;	-- a flag changed by the irq, change the write signal...
					IFG_writebit <= '0';
				END IF;
			END IF;
	END PROCESS;

	-- HEX configuration
	bitsToHex0: LCD  port map (
					bits => read_data_2(3 DOWNTO 0),
					hex=>HEX0_tmp
	);	
	bitsToHex1: LCD  port map (
					bits => read_data_2(7 DOWNTO 4),
					hex=>HEX1_tmp
	);	
	bitsToHex2: LCD  port map (
					bits => read_data_2(11 DOWNTO 8),
					hex=>HEX2_tmp
	);	
	bitsToHex3: LCD  port map (
					bits => read_data_2(15 DOWNTO 12),
					hex=>HEX3_tmp
	);	
	
END structure;

