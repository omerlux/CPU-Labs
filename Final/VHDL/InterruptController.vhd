-- Interrupt Controller module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY InterruptController IS
	PORT(	SIGNAL clock, reset	: IN		STD_LOGIC;
			SIGNAL INTA			: IN		STD_LOGIC;	-- 0 is ACK
			SIGNAL irq0			: IN		STD_LOGIC;
			SIGNAL irq1			: IN		STD_LOGIC;
			SIGNAL irq2			: IN		STD_LOGIC;
			SIGNAL irq3			: IN		STD_LOGIC;
			SIGNAL IE_W			: IN		STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Write
			SIGNAL IFG_W		: IN		STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Write			
			SIGNAL IE_R			: OUT		STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Read
			SIGNAL IFG_R		: OUT		STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Read
			SIGNAL IFG_writebit : IN		STD_LOGIC;
			SIGNAL ISR_MemAdrs	: OUT		STD_LOGIC_VECTOR(10 DOWNTO 0);	-- Read -> see for ref the 	Address_ALU_res	-- 11 BITS
			SIGNAL INTR			: OUT		STD_LOGIC:='0'					-- Read
		);
END InterruptController;

ARCHITECTURE behavior OF InterruptController IS
	SIGNAL  tmp_address : STD_LOGIC_VECTOR (7 DOWNTO 0);
	-- IE
	SIGNAL	BTIE		: STD_LOGIC:='0';
	SIGNAL	KEY3IE		: STD_LOGIC:='0';
	SIGNAL	KEY2IE		: STD_LOGIC:='0';
	SIGNAL	KEY1IE		: STD_LOGIC:='0';
	
	-- IFG
	SIGNAL	BTIFG		: STD_LOGIC:='0';
	SIGNAL	KEY3IFG		: STD_LOGIC:='0';
	SIGNAL	KEY2IFG		: STD_LOGIC:='0';
	SIGNAL	KEY1IFG		: STD_LOGIC:='0';
	
	SIGNAL	BT_irq_old	: STD_LOGIC:='0';
	SIGNAL	KEY3_irq_old: STD_LOGIC:='0';
	SIGNAL	KEY2_irq_old: STD_LOGIC:='0';
	SIGNAL	KEY1_irq_old: STD_LOGIC:='0';
	SIGNAL	BT_irq		: STD_LOGIC:='0';
	SIGNAL	KEY3_irq	: STD_LOGIC:='0';
	SIGNAL	KEY2_irq	: STD_LOGIC:='0';
	SIGNAL	KEY1_irq	: STD_LOGIC:='0';
	
	-- TYPE
	SIGNAL	TYPEx		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	-- Status SIGNAL - to check if we masked the interrupt. if yes, we can do another interrupt, if no, we cannot
	SIGNAL intr_BT		: STD_LOGIC:='0';	-- 0 is intrpt enable, 1 is in interrupt
	SIGNAL intr_K3		: STD_LOGIC:='0';
	SIGNAL intr_K2		: STD_LOGIC:='0';
	SIGNAL intr_K1		: STD_LOGIC:='0';
	
	SIGNAL status		: STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
	-- IE Write
	-- changing only when writing to it
	process (clock, reset, IE_W) -- (IE is register)
		begin
			if reset = '1' then
				BTIE	<= '0';
				KEY3IE	<= '0';
				KEY2IE	<= '0';
				KEY1IE	<= '0';
			elsif falling_edge(clock) then
				BTIE	<= IE_W(3);
				KEY3IE	<= IE_W(2);
				KEY2IE	<= IE_W(1);
				KEY1IE	<= IE_W(0);
			end if;
	end process;		
	-- IE Read
	IE_R	<= "0000" & BTIE & KEY3IE & KEY2IE & KEY1IE;
	
	-- IFG Write & irq0-3 interrupt
	-- changing when writing to it (to clear flags)
	-- may change due to irqx interrupt request, ONLY when it's corresponding IE is '1'.
	
	-- those 4 process are recording a rising in the inerrupt request (holding the value every rise)
	
	-- BT_irq
	process ( clock, reset, irq3)
		begin
			if reset = '1' then				-- Asynchronys
				BT_irq <= '0';
			elsif rising_edge(irq3) then
				BT_irq <= NOT BT_irq;
			end if;
	end process;
	
	
	-- KEY3_irq
	process ( clock, reset, irq2)
		begin
			if reset = '1' then				-- Asynchronys
				KEY3_irq <= '0';
			elsif rising_edge(irq2) then
				KEY3_irq <= NOT KEY3_irq;
			end if;
	end process;
	
	
	-- KEY2_irq
	process ( clock, reset, irq1)
		begin
			if reset = '1' then				-- Asynchronys
				KEY2_irq <= '0';
			elsif rising_edge(irq1) then
				KEY2_irq <= NOT KEY2_irq;
			end if;
	end process;
	
	
	-- KEY1_irq
	process ( clock, reset, irq0)
		begin
			if reset = '1' then				-- Asynchronys
				KEY1_irq <= '0';
			elsif rising_edge(irq0) then
				KEY1_irq <= NOT KEY1_irq;
			end if;
	end process;
	
	
	-- IFG_R:
	-- Inputs are IFG_W & Flags from irq
	process ( clock, reset, IFG_W, IFG_writebit)
		begin
			if reset = '1' then				-- Asynchronys
				IFG_R <= (others => '0');
				BT_irq_old <= '0';
				KEY3_irq_old <= '0';
				KEY2_irq_old <= '0';
				KEY1_irq_old <= '0';
			elsif rising_edge(clock) then
				if IFG_writebit = '1' then	-- Enable
					BTIFG	<= IFG_W(3);
					KEY3IFG	<= IFG_W(2);
					KEY2IFG	<= IFG_W(1);
					KEY1IFG	<= IFG_W(0);
				else -- COST: 1 more cycle
					BTIFG	<= (BT_irq XOR BT_irq_old) OR BTIFG;			-- rising the flag is there is a request
					KEY3IFG	<= (KEY3_irq XOR KEY3_irq_old) OR KEY3IFG;
					KEY2IFG	<= (KEY2_irq XOR KEY2_irq_old) OR KEY2IFG;
					KEY1IFG	<= (KEY1_irq XOR KEY1_irq_old) OR KEY1IFG;
				end if;	
				BT_irq_old <= BT_irq;
				KEY3_irq_old <= KEY3_irq;
				KEY2_irq_old <= KEY2_irq;
				KEY1_irq_old <= KEY1_irq;
				IFG_R	<= "0000" & BTIFG & KEY3IFG & KEY2IFG & KEY1IFG;
			end if;
	end process;
	
	-- Type - check for priority...
	TYPEx <= 	X"0C" WHEN	BTIFG = '1' AND BTIE = '1' ELSE 
				X"08" WHEN	KEY3IFG = '1' AND KEY3IE = '1'ELSE
				X"04" WHEN	KEY2IFG = '1' AND KEY2IE = '1'ELSE
				X"00" WHEN  KEY1IFG = '1' AND KEY1IE = '1'ELSE
				X"FF";	-- for testing...
				
	-- ISR memory address result
	tmp_address <= TYPEx + X"04";
	ISR_MemAdrs <= 	"000" & tmp_address;
		
	-- INTR - status will prevent nesting between interrupts - intr_x 0 is no interrupt
	INTR <= '0' 	WHEN status/="0000" ELSE			-- if in interrupt, cannot request
			((BTIFG   AND BTIE)   OR (KEY3IFG AND KEY3IE) OR
			(KEY2IFG AND KEY2IE) OR (KEY1IFG AND KEY1IE));
	
	-- status - 0000 is no interrupt
	status <= intr_BT & intr_K3 & intr_K2 & intr_K1;	
	
	-- Changing Status
	process ( clock, reset, IFG_W, IFG_writebit )
		begin
			if reset = '1' then
				intr_BT <= '0';
				intr_K3 <= '0';
				intr_K2 <= '0';
				intr_K1 <= '0';
			elsif rising_edge(clock) then
				if IFG_writebit = '1' then				-- flag has been cleared probably...
					if status="1000" then
						intr_BT <= IFG_W(3);	-- setting flag
						intr_K3 <= intr_K3;
						intr_K2 <= intr_K2;
						intr_K1 <= intr_K1;
					elsif status="0100" then
						intr_BT <= intr_BT;	
						intr_K3 <= IFG_W(2);	-- setting flag
						intr_K2 <= intr_K2;
						intr_K1 <= intr_K1;
					elsif status="0010" then
						intr_BT <= intr_BT;	
						intr_K3 <= intr_K3;
						intr_K2 <= IFG_W(1);	-- setting flag
						intr_K1 <= intr_K1;					
					elsif status="0001" then
						intr_BT <= intr_BT;						
						intr_K3 <= intr_K3;
						intr_K2 <= intr_K2;					
						intr_K1 <= IFG_W(0); -- setting flag
					else
						intr_BT <= intr_BT;						
						intr_K3 <= intr_K3;
						intr_K2 <= intr_K2;
						intr_K1 <= intr_K1;
					end if; 
				elsif INTA = '0' then		-- acknowledge has inserted ( falling_edge ) - won't happen once we are in interrupt because INTR='0'
					if BTIFG = '1' AND BTIE ='1' then
						intr_BT <= '1';		-- status = 1 - inside interrupt BT
						intr_K3 <= '0';
						intr_K2 <= '0';
						intr_K1 <= '0';
					elsif KEY3IFG = '1' AND KEY3IE = '1' then
						intr_BT <= '0';						
						intr_K3 <= '1';		-- status = 1 - inside interrupt KEY3
						intr_K2 <= '0';
						intr_K1 <= '0';
					elsif KEY2IFG = '1' AND KEY2IE = '1' then
						intr_BT <= '0';						
						intr_K3 <= '0';
						intr_K2 <= '1';		-- status = 1 - inside interrupt KEY2
						intr_K1 <= '0';
					elsif KEY1IFG = '1' AND KEY1IE = '1' then
						intr_BT <= '0';						
						intr_K3 <= '0';
						intr_K2 <= '0';
						intr_K1 <= '1';		-- status = 1 - inside interrupt KEY1
					else
						intr_BT <= intr_BT;						
						intr_K3 <= intr_K3;
						intr_K2 <= intr_K2;
						intr_K1 <= intr_K1;
					end if;
				end if;
			end if;
	end process;
	
END behavior;













