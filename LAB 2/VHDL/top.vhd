LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE work.aux_package.all;
-------------------------------------------------------------
entity top is
	generic (
		n : positive := 8 ;
		m : positive := 7 ;
		k : positive := 3
	); -- where k=log2(m+1)
	port(
		rst,ena,clk : in std_logic;
		din : in std_logic_vector(n-1 downto 0);
		cond : in integer range 0 to 3;
		detector : out std_logic
	);
end top;
------------- complete the top Architecture code --------------
architecture arc_sys of top is
	-- sync delay
	SIGNAL internal: std_logic_vector (n-1 downto 0);
	SIGNAL dout_new: std_logic_vector (n-1 downto 0);
	SIGNAL dout_old: std_logic_vector (n-1 downto 0);
	-- condition
	SIGNAL din_old_invert: std_logic_vector (n-1 downto 0);
	SIGNAL res: std_logic_vector (n-1 downto 0);
	SIGNAL cout: std_logic;
	SIGNAL rise: std_logic;
	-- counter
	SIGNAL count: std_logic_vector (k-1 downto 0);
	-- detect
	SIGNAL m_logic: std_logic_vector (k-1 downto 0);
begin
------------------ sync delay ------------------
	PROCESS (clk, rst, ena)
	BEGIN
		IF (rst='1') THEN	-- Asynchronous part
			dout_old <= (others => '0');
		ELSIF (clk'EVENT and clk='1') THEN -- Synchronous part
			IF (ena='1') THEN	-- Enable is 1
				dout_new <= din;			-- this output won't be stored
				internal <= din;			-- this is the delayed din
				dout_old <= internal;
			END IF;
		END IF;
	END PROCESS;
------------------ condition ------------------
	din_old_invert <= not dout_old; -- setting the old value to be subtract from = xor with 1	
	L0 : Adder generic map(n) port map(
				a => dout_new,
				b => din_old_invert, 	-- for subtraction
				cin => '1',		-- for subtrcation
				s =>res,
				cout => cout); -- Adder single instantiation
				
	PROCESS (cond, res)	-- check cond vs result
		VARIABLE res_int: INTEGER; -- same as the vector res
	BEGIN
		res_int := CONV_INTEGER (UNSIGNED(res));	-- converted to integer	
		IF res_int = cond + 1 THEN  -- ### this won't create another Adder
			rise <= '1';
		ELSE 
			rise <= '0';
		END IF;
	END PROCESS;
------------------ counter ------------------
	PROCESS (clk, rst, ena)
	BEGIN
		IF (rst='1') THEN	-- Asynchronous part
			count <= (others => '0');
		ELSIF (clk'EVENT and clk='1') THEN -- Synchronous part
			IF (ena='1') THEN	-- Enable is 1:
				IF rise='1' THEN	-- rise is 1:
					IF count = m THEN	-- count is m=7
						count <= CONV_STD_LOGIC_VECTOR(m,k);	-- stay at m=7
					ELSE
						count <= count + '1';	-- feedback adder till m=7 ###won't create Adder
					END IF;
				ELSE	-- rise is 0:
					count <= (others => '0');	-- reset count
				END IF; -- end rise
			END IF; -- end enable
		END IF; -- and clk='1'
	END PROCESS;
------------------ detect ------------------
	m_logic <= CONV_STD_LOGIC_VECTOR(m, k); -- converted m to a std_logic_vector signal length k
	detector <= '1' WHEN count = m_logic ELSE	-- if count is m, the detector is 1
				'0';
end arc_sys;







