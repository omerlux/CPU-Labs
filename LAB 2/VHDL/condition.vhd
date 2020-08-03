LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE work.aux_package.all;
-------------------------------------
ENTITY condition IS
  GENERIC (n : INTEGER := 8);
  PORT ( 
		cond : in integer range 0 to 3;
		din_new : in std_logic_vector(n-1 downto 0);
		din_old : in std_logic_vector(n-1 downto 0);
		rise : out std_logic
		 );
END condition;
------------------------------------------------
ARCHITECTURE rtl OF condition IS
	SIGNAL din_old_invert: std_logic_vector (n-1 downto 0);
	SIGNAL res: std_logic_vector (n-1 downto 0);
	SIGNAL cout: std_logic;
BEGIN
	din_old_invert <= not din_old; -- setting the old value to be subtract from = xor with 1
	create_adder:
		Adder generic map(n) -- adder single instantiation
			PORT MAP(
				a => din_new,
				b => din_old_invert, 	-- for subtraction
				cin => '1',		-- for subtrcation
				s =>res,
				cout => cout);
	
	
	PROCESS (cond, res)	-- check cond vs result
		VARIABLE res_int: INTEGER; -- same as the vector res
	BEGIN
		res_int := CONV_INTEGER (UNSIGNED(res));	-- converted to integer	
		IF res_int = cond + 1 THEN 
			rise <= '1';
		ELSE 
			rise <= '0';
		END IF;
	END PROCESS;
END rtl;
