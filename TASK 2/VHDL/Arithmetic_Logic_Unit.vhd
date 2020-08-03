LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE work.aux_package.all; -- this is the package
-------------------------------------
ENTITY Arithmetic_Logic_Unit IS
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
		RES : buffer std_logic_vector(2*n-1 downto 0)); -- RES(HI,LO)
END Arithmetic_Logic_Unit;
--------------------------------------------------------------
ARCHITECTURE dfl OF Arithmetic_Logic_Unit IS
	SIGNAL XOR_res : std_logic_vector(2*n-1 DOWNTO 0);
	SIGNAL OR_res : std_logic_vector(2*n-1 DOWNTO 0);
	SIGNAL AND_res : std_logic_vector(2*n-1 DOWNTO 0);
	SIGNAL MIN : std_logic_vector(2*n-1 DOWNTO 0);
	SIGNAL MAX : std_logic_vector(2*n-1 DOWNTO 0);
	SIGNAL MULT : std_logic_vector(2*n-1 DOWNTO 0);
	SIGNAL ACC : std_logic_vector(2*n-1 DOWNTO 0);
	
	SIGNAL AS_cin: STD_LOGIC;
	SIGNAL AS_sel: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL AS_x,AS_y: STD_LOGIC_VECTOR (2*n-1 DOWNTO 0);
    SIGNAL AS_s: STD_LOGIC_VECTOR(2*n downto 0);
	
BEGIN
	-- creating adder subtractor module
	Add_Sub : Adder_Subtractor generic map(n*2) 
	port map(
		cin => AS_cin,
		sel => AS_sel,
		x => AS_x,
		y => AS_y,
		s => AS_s
		);

	-- XOR = A xor B
	XOR_res <= (2*n-1 downto n => '0') & (A xor B); 
	
	-- OR = A or B
	OR_res <= (2*n-1 downto n => '0') & (A or B); 
	
	-- AND = A and B
	AND_res <= (2*n-1 downto n => '0') & (A and B);
	
	-- MAX / MIN= max(A,B) / min(A,B)
	MAX_MIN : process (A, B)
	begin	
		if B>A then 
			MAX <= (2*n-1 downto n => '0') & B; 
			MIN <= (2*n-1 downto n => '0') & A; 
		else 
			MAX <= (2*n-1 downto n => '0') & A; 
			MIN <= (2*n-1 downto n => '0') & B; 
		end if;
	end process;

	-- MULT = A * B
	MULT <= A * B;
	
	-- MAC
	PROCESS (clk)
	BEGIN
		IF (OPC = "00110") THEN				-- Asynchronous part - MAC_RST opcode
			ACC <= (others => '0');
		ELSIF (clk'EVENT and clk='1') THEN 	-- Synchronous part
			IF (OPC = "00101") THEN 		-- MAC: ACC = ACC+MULT       - MAC opcode
				ACC <= AS_s(2*n-1 downto 0);-- output of the Add_Sub
			END IF;							-- ACC (t) = ACC (t-1)
		END IF;
	END PROCESS;

	-- first selector - deciding what to pass to Add_Sub
	AS_sel <= "00" 	WHEN OPC="00001" ELSE --X+Y
			  "10" 	WHEN OPC="00010" ELSE --X-Y
			  "01" 	WHEN OPC="00011" ELSE --X+Y+Cin
			  "00";  -- else, and also MAC
			  
	AS_cin <= '0' 	WHEN OPC="00001" ELSE --X+Y
			  '1' 	WHEN OPC="00010" ELSE --X-Y
			  cin 	WHEN OPC="00011" ELSE --X+Y+Cin
			  '0';  -- else, and also MAC
			  
	AS_x <=	  (2*n-1 downto n => '0') & A WHEN OPC="00001" ELSE --X+Y
			  (2*n-1 downto n => '0') & A WHEN OPC="00010" ELSE --X-Y
			  (2*n-1 downto n => '0') & A WHEN OPC="00011" ELSE --X+Y+Cin
			  MULT WHEN OPC="00101" ELSE -- MAC
			  (others => '0');	-- else
	
	AS_y <=	  (2*n-1 downto n => '0') & B WHEN OPC="00001" ELSE --X+Y
			  (2*n-1 downto n => '0') & B WHEN OPC="00010" ELSE --X-Y
			  (2*n-1 downto n => '0') & B WHEN OPC="00011" ELSE --X+Y+Cin
			  ACC WHEN OPC="00101" ELSE -- MAC
			  (others => '0');	-- else
	
	-- second selector
	RES <= MULT 	WHEN OPC="00100" ELSE  	-- MULT
		   MAX 		WHEN OPC="00111" ELSE  	-- MAX
		   MIN 		WHEN OPC="01000" ELSE  	-- MIN
		   AND_res 	WHEN OPC="01001" ELSE  	-- AND
		   OR_res 	WHEN OPC="01010" ELSE  	-- OR
		   XOR_res 	WHEN OPC="01011" ELSE  	-- XOR
		   ACC		WHEN OPC="00101" ELSE	-- ACC+A*B
		   RES		WHEN OPC="00110" ELSE 	-- MAC RESET
		   AS_s(2*n-1 downto 0);			-- A+B / A-B / A+B+cin
	
END dfl;

