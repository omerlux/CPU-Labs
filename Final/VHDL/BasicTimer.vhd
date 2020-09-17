-- Basic Timer module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY BasicTimer IS
	PORT(	SIGNAL MCLK, reset	: IN 	 	STD_LOGIC;						-- Input
			SIGNAL BTCTL_W		: IN 		STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Write
			SIGNAL BTCTL_R		: OUT 		STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Read
			SIGNAL BTCNT_W		: IN 		STD_LOGIC_VECTOR(31 DOWNTO 0); 	-- Write
			SIGNAL BTCNT_R		: OUT 		STD_LOGIC_VECTOR(31 DOWNTO 0); 	-- Read
			SIGNAL BTIFG		: OUT	 	STD_LOGIC						-- Read
		);
END BasicTimer;

ARCHITECTURE behavior OF BasicTimer IS
	SIGNAL	BTHOLD		: STD_LOGIC;
	SIGNAL  BTHOLD_old	: STD_LOGIC;
	SIGNAL	BTSSEL		: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL	BTIPx		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL  CLK			: STD_LOGIC;
	
	SIGNAL	MCLK2		: STD_LOGIC:='0';
	SIGNAL	MCLK4		: STD_LOGIC:='0';
	SIGNAL	MCLK8		: STD_LOGIC:='0';
	SIGNAL  clk_div_cnt : STD_LOGIC_VECTOR(2 DOWNTO 0):="000";
	SIGNAL  clk_div_fixed : STD_LOGIC_VECTOR(2 DOWNTO 0):="000";
	SIGNAL	Counter 	: STD_LOGIC_VECTOR(31 DOWNTO 0):=X"00000000";
	SIGNAL  Counter_old	: STD_LOGIC_VECTOR(31 DOWNTO 0):=X"00000000";
	SIGNAL  BTIFG_curr	: STD_LOGIC;

BEGIN
	-- Register BTCTL
	process (MCLK, reset, BTCTL_W)
		begin
			if reset = '1' then
				BTHOLD <= '1';
				BTSSEL <= "00";
				BTIPx  <= "000";
			elsif rising_edge(MCLK) then		-- writing is in falling_edge
				BTHOLD <= BTCTL_W(5);
				BTSSEL <= BTCTL_W(4 DOWNTO 3);
				BTIPx  <= BTCTL_W(2 DOWNTO 0);
			end if;
	end process;		
	BTCTL_R <= "00" & BTHOLD & BTSSEL & BTIPx;
	
	process (CLK, reset)
		begin
			if reset = '1' then
				BTHOLD_old <='1';
			elsif rising_edge(CLK) then
				BTHOLD_old <= BTHOLD;	-- last value of BTHOLD
			end if;
	end process;
	
	-- Master Clock division counter
	process (MCLK, BTHOLD)
		begin
			if BTHOLD = '1' then	-- reset for clk_div_cnt			-- falling_edge(BTHOLD) (old value for start counting from 000 and not 001)
				clk_div_cnt <= "000";
			elsif rising_edge(MCLK) then
				clk_div_cnt <= clk_div_cnt + 1;				-- initialize the clk_div_cnt	
			end if;
	end process;	
	
	-- MCLKx and CLK are both for testing (not in use...)
	MCLK2 <= NOT clk_div_cnt(0);			-- rising edge is in "xx1"
	MCLK4 <= NOT clk_div_cnt(1);			-- rising edge is in "x10"
	MCLK8 <= NOT clk_div_cnt(2);			-- rising edge is in "100"
	
	-- BTSSEL Mux
	CLK	<= 	MCLK  WHEN BTSSEL = "00" ELSE
			MCLK2 WHEN BTSSEL = "01" ELSE
			MCLK4 WHEN BTSSEL = "10" ELSE
			MCLK8;
		
	process (MCLK, reset, CLK, BTCNT_W)
		begin
			if reset = '1' then
				Counter <= (others => '0');
			elsif rising_edge(MCLK) then
				if BTHOLD ='0' then							-- Enable
					if BTSSEL = "00" then		-- MCLK
						-- MCLK rising edge
						Counter <= Counter +1;
					elsif BTSSEL = "01" then	-- MCLK2
						-- MCLK2 rising_edge
						if clk_div_cnt(0) = '1' then 
							Counter <= Counter +1;
						else
							Counter <= Counter;
						end if;
					elsif BTSSEL = "10" then	-- MCLK4
						-- MCLK4 rising_edge
						if clk_div_cnt(1 DOWNTO 0) = "11" then 
							Counter <= Counter +1;
						else
							Counter <= Counter;	
						end if;							
					elsif BTSSEL = "11" then	-- MCLK8
						-- MCLK8 rising_edge
						if clk_div_cnt = "111" then 
							Counter <= Counter +1;
						else
							Counter <= Counter;
						end if;							
					else
						Counter <= Counter;				
					end if;
				else
					Counter <= BTCNT_W;						-- Counter input is BTCNT
				end if;			
			end if;	
	end process;	
	
	-- BTCNT Read
	BTCNT_R <= Counter;
	
	-- BTIPx Mux
	process (MCLK, Counter, reset, BTIPx)
		begin
			if reset = '1' then
				BTIFG_curr <= '0';
			elsif rising_edge(MCLK) then
				if BTIFG_curr = '1' OR BTHOLD_old = '1' then   			-- BTHOLD_old = '1' to prevent initialization irq
					BTIFG_curr <= '0';
				elsif BTIPx = "000" AND Counter(0) = '0' then
					BTIFG_curr <= '1';
				elsif BTIPx = "001" AND Counter(3 DOWNTO 0) = "0000" then
					BTIFG_curr <= '1';	
				elsif BTIPx = "010" AND Counter(7 DOWNTO 0) = "00000000" then
					BTIFG_curr <= '1';	
				elsif BTIPx = "011" AND Counter(11 DOWNTO 0) = "000000000000" then
					BTIFG_curr <= '1';	
				elsif BTIPx = "100" AND Counter(15 DOWNTO 0) = "0000000000000000" then
					BTIFG_curr <= '1';	
				elsif BTIPx = "101" AND Counter(19 DOWNTO 0) = "00000000000000000000" then
					BTIFG_curr <= '1';	
				elsif BTIPx = "110" AND Counter(23 DOWNTO 0) = "000000000000000000000000" then
					BTIFG_curr <= '1';	
				elsif BTIPx = "111" AND Counter(25 DOWNTO 0) = "00000000000000000000000000" then
					BTIFG_curr <= '1';	
				else 
					BTIFG_curr <= BTIFG_curr;
				end if;
			end if;
	end process;
	BTIFG <= BTIFG_curr;
				
				
	-- BTIFG 	<= Counter(0)  WHEN BTIPx = "000" ELSE
			   -- Counter(3)  WHEN BTIPx = "001" ELSE
			   -- Counter(7)  WHEN BTIPx = "010" ELSE
			   -- Counter(11) WHEN BTIPx = "011" ELSE
			   -- Counter(15) WHEN BTIPx = "100" ELSE
			   -- Counter(19) WHEN BTIPx = "101" ELSE
			   -- Counter(23) WHEN BTIPx = "110" ELSE
			   -- Counter(25);
	
END behavior;


-- Check:
-- 1. Reading while counting (BTHOLD=0) is allowed?
-- 2. Try different Clock and different divisor (BTSSEL, BTIPx)





