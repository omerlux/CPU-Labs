-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	GENERIC (n : INTEGER := 0);
	PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 10 DOWNTO 0 );	-- 11 BITS
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 8 DOWNTO 0 );		-- 9 BITS
        	SIGNAL Branch_eq		: IN 	STD_LOGIC;
			SIGNAL Branch_neq		: IN 	STD_LOGIC;
        	SIGNAL Zero 			: IN 	STD_LOGIC;
			SIGNAL Jump				: IN	STD_LOGIC;
			SIGNAL isJR				: IN	STD_LOGIC;
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 10 DOWNTO 0 );	-- 11 BITS
        	SIGNAL INTR				: IN	STD_LOGIC;
			SIGNAL INTA				: OUT	STD_LOGIC;
			SIGNAL ISR_adrs			: IN	STD_LOGIC_VECTOR( 8 DOWNTO 0);		-- 9 BITS
			SIGNAL clock, reset 	: IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4, Mem_Addr 	: STD_LOGIC_VECTOR( 10 DOWNTO 0 );
	SIGNAL next_PC 					: STD_LOGIC_VECTOR( 8 DOWNTO 0 );
	SIGNAL Instruction_tmp			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL INTR_old					: STD_LOGIC;
	SIGNAL tmp_intr					: STD_LOGIC;
BEGIN
						--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => 11,	-- 11 BITS
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\Omer\Downloads\program.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clock,
		address_a 	=> Mem_Addr, 
		q_a 			=> Instruction_tmp );
		
		-- Instruction select - if intrpt is '1' then opcode=31, else the fetched one
		Instruction <= 	X"FC000000" WHEN INTR = '1' AND INTR_old = '0'
				ELSE	Instruction_tmp;						-- impotent instruction
		
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
		Mem_Addr <=  "00" & Next_PC WHEN n=0		-- n=0 - Modelsim
				ELSE Next_PC & "00";				-- n=/=0 - Quartus						
						-- Adder to increment PC by 4        
      	PC_plus_4( 10 DOWNTO 2 ) <= PC( 10 DOWNTO 2 ) + 1;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
		Next_PC  <= '0' & X"00" WHEN Reset = '1' ELSE
					Add_result  WHEN ( ( Branch_eq = '1' ) AND ( Zero = '1' ) ) OR
									 ( ( Branch_neq = '1' ) AND ( Zero = '0' ) ) OR
										Jump = '1' OR
										isJR = '1' ELSE
					ISR_adrs	WHEN INTR = '1' AND INTR_old = '0' 	 ELSE 		-- Choose the address of the ISR WHEN INTR='1'
					PC_plus_4 (10 DOWNTO 2);
		
	-- Acknowledge to the InterruptController
	process( clock, reset, INTR )
		begin
			if reset = '1' then
				INTR_old <= '0';
			elsif rising_edge(clock) then
				INTR_old <= INTR;
			end if;
	end process;
	INTA <=  '0' WHEN INTR_old = '0' AND INTR = '1'
		ELSE '1';
		
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
			    PC( 10 DOWNTO 2) <= "000000000" ; 
			ELSE 
 			    PC( 10 DOWNTO 2 ) <= Next_PC;
			END IF;
	END PROCESS;	
END behavior;


