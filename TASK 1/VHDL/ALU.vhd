LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE work.aux_package.all; -- this is the package
-------------------------------------
ENTITY ALU IS
	GENERIC (		
		n : positive := 8 ; -- A,B length
		m : positive := 5 ; -- OPC length
		k : positive := 2   -- STATUS length
		);
	PORT (    
		clk,cin : in std_logic;
		A,B : in std_logic_vector(n-1 downto 0);
		OPC : in std_logic_vector(m-1 downto 0);
		----------------------------------------
		HI : buffer std_logic_vector(n-1 downto 0); -- RES(HI)
		LO : buffer std_logic_vector(n-1 downto 0); -- RES(LO)
		STATUS : buffer std_logic_vector(k-1 downto 0));
END ALU;
--------------------------------------------------------------
ARCHITECTURE dfl OF ALU IS
	SIGNAL ArithLogic_res : std_logic_vector(2*n-1 downto 0); -- RES(HI,LO)
	SIGNAL Shift_res : std_logic_vector(2*n-1 downto 0); 	  -- RES(HI,LO)
	SIGNAL Shift_carry : std_logic;
	SIGNAL HI_signal : std_logic_vector(n-1 downto 0); -- RES(HI)
	SIGNAL LO_signal : std_logic_vector(n-1 downto 0); -- RES(LO)
	SIGNAL STATUS_signal: std_logic_vector(k-1 downto 0);
BEGIN
	-- creating arithmetic logic unit
	ArithLogic : Arithmetic_Logic_Unit generic map(n,m,k) 
	port map(
		cin => cin,
		clk => clk,			-- KEY3 for MAC
		A => A,
		B => B,
		OPC => OPC,
		RES => ArithLogic_res
		);
	
	-- creating shift unit
	ShiftUnit : Shift_Unit generic map(n,m,k) 
	port map(
		cin => cin,
		A => A,
		B => B,
		OPC => OPC,
		RES => Shift_res,
		CARRY => Shift_carry
		);
	
	
	-- SELECTOR:
	-- setting HI - n vector
	HI_signal <= ArithLogic_res(2*n-1 downto n) WHEN OPC>="00001" 
						and OPC<="01011" ELSE -- for arithmetic only
		  (others => '0');										-- for shifter
		   
	-- setting LO - n vector
	LO_signal <= ArithLogic_res(n-1 downto 0) WHEN OPC>="00001" 
					  and OPC<="01011" ELSE -- for arithmetic only
		  Shift_res(n-1 downto 0);										  	-- for shifter	  
		   
	-- setting Z
	STATUS_signal(1) <= '1'  WHEN CONV_INTEGER(unsigned(LO_signal)) = 0 ELSE		--   low is 0
				 '0';
				 
	-- setting C
	STATUS_signal(0) <= '1'  WHEN OPC>="00001" and OPC<="01011" and 
						   ArithLogic_res(2*n-1 downto n)/=0 ELSE -- for arithmetic only
		  Shift_carry WHEN OPC>="01100" and OPC<="01111" ELSE  -- for shifter
		  '0';												   -- arith - no carry on HI
	
	-- saving the temp result
	PROCESS(clk,cin,A,B,OPC)
	BEGIN
		IF (OPC ="00110") THEN
			-- MAC RST - temp values will be out (from last opcode)
			HI <= HI;
			LO <= LO;
			STATUS <= STATUS;
		ELSE
			-- NOT MAC RST - just the usual output
			HI <= HI_signal;
			LO <= LO_signal;
			STATUS <= STATUS_signal;
		END IF;
	END PROCESS;
	
END dfl;

















