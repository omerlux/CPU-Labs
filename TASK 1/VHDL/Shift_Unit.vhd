LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE work.aux_package.all; -- this is the package
-------------------------------------
ENTITY Shift_Unit IS
	GENERIC (		
		n : positive := 8 ; -- A,B length
		m : positive := 5 ; -- OPC length
		k : positive := 2   -- STATUS length
		);
	PORT (    
		cin : in std_logic;
		A,B : in std_logic_vector(n-1 downto 0);
		OPC : in std_logic_vector(m-1 downto 0);
		----------------------------------------
		RES : out std_logic_vector(2*n-1 downto 0); -- RES(HI,LO)
		CARRY : out std_logic);
END Shift_Unit;
--------------------------------------------------------------
ARCHITECTURE dfl OF Shift_Unit IS
	SIGNAL B_int: integer range 0 to 7;
	SIGNAL res_rla: std_logic_vector(n-1 downto 0);
	SIGNAL res_rlc: std_logic_vector(n-1 downto 0);
	SIGNAL res_rra: std_logic_vector(n-1 downto 0);
	SIGNAL res_rrc: std_logic_vector(n-1 downto 0);
	SIGNAL RLA_y  : std_logic_vector(n-1 downto 0);
	SIGNAL RRA_y  : std_logic_vector(n-1 downto 0);
BEGIN
	-- int signal for RRC RLC cut
	B_int <= CONV_INTEGER(UNSIGNED(B (2 downto 0)));

	-- RLA shifter
	RLA_y <= (n-1 downto 3 => '0') & B(2 downto 0);		-- 3 LSB of B
	RLA_shift : RLA generic map(n) 
	port map(
			x => A,										-- A will be shifted
			y => RLA_y,
            res => res_rla);
	
	-- RLC shifter - using RLA result and concating A
	res_rlc <= A WHEN B(2 downto 0)="000" ELSE
			res_rla(n-1 downto 1)& cin  WHEN B(2 downto 0)="001" ELSE
			res_rla(n-1 downto 2)& cin & A(n-1 downto n-1) WHEN B(2 downto 0)="010" ELSE
			res_rla(n-1 downto 3)& cin & A(n-1 downto n-2) WHEN B(2 downto 0)="011" ELSE
			res_rla(n-1 downto 4)& cin & A(n-1 downto n-3) WHEN B(2 downto 0)="100" ELSE
			res_rla(n-1 downto 5)& cin & A(n-1 downto n-4) WHEN B(2 downto 0)="101" ELSE
			res_rla(n-1 downto 6)& cin & A(n-1 downto n-5) WHEN B(2 downto 0)="110" ELSE
			res_rla(n-1 downto 7)& cin & A(n-1 downto n-6);
						
			-- res_rla(n-1 downto 1)& A(n-1 downto n-1) WHEN B(2 downto 0)="001" ELSE
			-- res_rla(n-1 downto 2)& A(n-1 downto n-2) WHEN B(2 downto 0)="010" ELSE
			-- res_rla(n-1 downto 3)& A(n-1 downto n-3) WHEN B(2 downto 0)="011" ELSE
			-- res_rla(n-1 downto 4)& A(n-1 downto n-4) WHEN B(2 downto 0)="100" ELSE
			-- res_rla(n-1 downto 5)& A(n-1 downto n-5) WHEN B(2 downto 0)="101" ELSE
			-- res_rla(n-1 downto 6)& A(n-1 downto n-6) WHEN B(2 downto 0)="110" ELSE
			-- res_rla(n-1 downto 7)& A(n-1 downto n-7);
				--(res_rla(n-1 downto (B_int)))&(A(n-1 downto n-(B_int))); -- concat
				
	-- RRA shifter			
	RRA_y <= (n-1 downto 3 => '0') & B(2 downto 0);		-- 3 LSB of B
	RRA_shift : RRA generic map(n) 
	port map(
			x => A,										-- A will be shifted
			y => RRA_y,
            res => res_rra);
			
	-- RLC shifter - using RLA result and concating A
	res_rrc <= A WHEN B(2 downto 0)="000" ELSE
			cin & res_rra(n-1-1 downto 0) WHEN B(2 downto 0)="001" ELSE
			A(1-1 downto 0)& cin & res_rra(n-1-2 downto 0) WHEN B(2 downto 0)="010" ELSE
			A(2-1 downto 0)& cin & res_rra(n-1-3 downto 0) WHEN B(2 downto 0)="011" ELSE
			A(3-1 downto 0)& cin & res_rra(n-1-4 downto 0) WHEN B(2 downto 0)="100" ELSE
			A(4-1 downto 0)& cin & res_rra(n-1-5 downto 0) WHEN B(2 downto 0)="101" ELSE
			A(5-1 downto 0)& cin & res_rra(n-1-6 downto 0) WHEN B(2 downto 0)="110" ELSE
			A(6-1 downto 0)& cin & res_rra(n-1-7 downto 0);
			
			-- A(1-1 downto 0) & res_rra(n-1-1 downto 0) WHEN B(2 downto 0)="001" ELSE
			-- A(2-1 downto 0) & res_rra(n-1-2 downto 0) WHEN B(2 downto 0)="010" ELSE
			-- A(3-1 downto 0) & res_rra(n-1-3 downto 0) WHEN B(2 downto 0)="011" ELSE
			-- A(4-1 downto 0) & res_rra(n-1-4 downto 0) WHEN B(2 downto 0)="100" ELSE
			-- A(5-1 downto 0) & res_rra(n-1-5 downto 0) WHEN B(2 downto 0)="101" ELSE
			-- A(6-1 downto 0) & res_rra(n-1-6 downto 0) WHEN B(2 downto 0)="110" ELSE
			-- A(7-1 downto 0) & res_rra(n-1-7 downto 0);			
				--A((B_int)-1 downto 0)  & res_rra(n-1-(B_int) downto 0); -- concat
				
	-- Setting C status
	CARRY <= '0' 	 WHEN B_int=0 	  ELSE -- no shift
		'0' 		 WHEN OPC="00000" ELSE -- for testing
		A(n-B_int)   WHEN OPC="01100" ELSE -- RLA carry
		A(n-B_int)	 WHEN OPC="01101" ELSE -- RLC carry
		A(B_int-1)	 WHEN OPC="01110" ELSE -- RRA carry
		A(B_int-1);
		
	-- Setting res for shift_unit
	RES <= (2*n-1 downto n => '0') & A     WHEN B_int=0 	ELSE -- no shift
		(others=>'0') 					   WHEN OPC="00000" ELSE -- for testing
		(2*n-1 downto n => '0') & res_rla  WHEN OPC="01100" ELSE -- RLA carry
		(2*n-1 downto n => '0') & res_rlc  WHEN OPC="01101" ELSE -- RLC carry
		(2*n-1 downto n => '0') & res_rra  WHEN OPC="01110" ELSE -- RRA carry
		(2*n-1 downto n => '0') & res_rrc;
	
END dfl;
