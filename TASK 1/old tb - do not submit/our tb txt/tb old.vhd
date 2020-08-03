library IEEE;
use ieee.std_logic_1164.all;
use std.textio.all;
USE work.aux_package.all;
-----------------------------------------------------------
entity tb is
	generic( ton: time := 50 ns);
	constant n : positive := 8 ; -- A,B length
	constant m : positive := 5 ; -- OPC length
	constant k : positive := 2;   -- STATUS length
end tb;
-----------------------------------------------------------
architecture rtl of tb is 
	signal rst,ena,clk,cin : std_logic;
	signal A,B : std_logic_vector(n-1 downto 0);
	signal OPC : std_logic_vector(m-1 downto 0);
	----------------------------------------
	signal RES : std_logic_vector(2*n-1 downto 0);
	signal STATUS : std_logic_vector(k-1 downto 0);
	----------------------------------------
	signal gen : boolean :=true;
	signal done : boolean :=false;
	----------------------------------------
	constant read_file_location : string(1 to 63) :=
	"D:\Documents\BGU Programing\CPU\TASK1\TASK1 - task\TB\input.txt";
	constant write_file_location : string(1 to 64) :=
	"D:\Documents\BGU Programing\CPU\TASK1\TASK1 - task\TB\output.txt";
begin
	-- DUT - Design under test
	L0 : top generic map (n,m,k) port map(rst,ena,clk,cin,A,B,OPC,RES,STATUS);
	-----------------------------------------------------------
	gen <= not gen after ton;
	-----------------------------------------------------------
	process
		file infile : text open read_mode is read_file_location;
		file outfile : text open write_mode is write_file_location;
		variable L : line;
		variable in_rst,in_ena,in_clk,in_cin : bit;
		variable in_A : bit_vector (n-1 downto 0);
		variable in_B : bit_vector (n-1 downto 0);
		variable in_OPC : bit_vector (m-1 downto 0);
		variable good : boolean;
		constant write_fileheader : string(1 to 40):=
		"time      result              status    ";
	begin
		----------set file header------------------
		write(L, write_fileheader);
		writeline(outfile, L);
		----------start test and write------------------
		while not endfile(infile) loop
			readline(infile, L);			-- read a line to L
			-----------------------------------------------------
			read(L,in_rst,good);			-- read entry type from L
			next when not good; 		-- skip on a comment line
			read(L,in_ena,good);			-- read entry type from L
			next when not good; 		-- skip on a comment line
			read(L,in_clk,good);			-- read entry type from L
			next when not good; 		-- skip on a comment line
			read(L,in_cin,good);			-- read entry type from L
			next when not good; 		-- skip on a comment line
			read(L,in_A,good);			-- read entry type from L
			next when not good; 		-- skip on a comment line
			read(L,in_B,good);			-- read entry type from L
			next when not good; 		-- skip on a comment line
			read(L,in_OPC,good);			-- read entry type from L
			next when not good; 		-- skip on a comment line
			-----------------------------------------------------
			wait until (gen'event and gen=false);
			rst <= to_stdulogic(in_rst);
			ena <= to_stdulogic(in_ena);
			clk <= to_stdulogic(in_clk);
			cin <= to_stdulogic(in_cin);
			A <= to_stdlogicvector(in_A);
			B <= to_stdlogicvector(in_B);
			OPC <= to_stdlogicvector(in_OPC);
			------------------------------------------------------
			wait until (gen'event and gen=true);
				write(L, now, left, 10);
				write(L, to_bitvector(RES), left, 2*10);
				write(L, to_bitvector(STATUS), left, 10);
				writeline(outfile, L);
		end loop;
		-------------------------------------------------------
		done <= true;
		file_close(infile);
		file_close(outfile);
		report "End of test using of input and outputs file" severity note;
		-------------------------------------------------------
		wait;
	end process;
end rtl;
			
			
			
			
			
			
			
			
			
			