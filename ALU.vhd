library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; --use conv_integer

entity alu is
 port  (
  ALUop: in std_logic_vector(2 downto 0); --ALU operation bits from the control
  a: in std_logic_vector(31 downto 0);--32-bit input
  b: in std_logic_vector(31 downto 0); --32-bit input
  alu_output: out std_logic_vector(31 downto 0) --32-bit alu output
  );
end alu;

architecture alu_behave of alu is

	signal a_rightshift,a_leftshift: std_logic_vector(31 downto 0);

begin
	process(a,b,ALUop,a_leftshift, a_rightshift) begin
		case(ALUop) is
		
			when "000" => alu_output <= (a + b);					---add
			when "001" => alu_output <= a + not(b)+ x"00000001";	---subtract
			when "010" => alu_output <= a and b;					---and
			when "011" => alu_output <= a or b;						---or
			when "100" => alu_output <= not(a or b);				---nor
			when "101" => alu_output <= a_leftshift;				---left shift
			when "110" => alu_output <= a_rightshift;				---right shift
			when others => alu_output<= (others => '0');
		
		end case ;
	end process;


-----------------------------left shift --------------------------------------
with b(4 downto 0) select
		a_leftshift <=  a(30 DOWNTO 0) & '0' WHEN"00001",
						a(29 DOWNTO 0) & "00" WHEN"00010",
						a(28 DOWNTO 0) & "000" WHEN"00011",
						a(27 DOWNTO 0) & "0000" WHEN"00100",
						a(26 DOWNTO 0) & "00000" WHEN"00101",
						a(25 DOWNTO 0) & "000000" WHEN"00110",
						a(24 DOWNTO 0) & "0000000" WHEN"00111",
						a(23 DOWNTO 0) & "00000000" WHEN"01000",
						a(22 DOWNTO 0) & "000000000" WHEN"01001",
						a(21 DOWNTO 0) & "0000000000" WHEN"01010",
						a(20 DOWNTO 0) & "00000000000" WHEN"01011",
						a(19 DOWNTO 0) & "000000000000" WHEN"01100",
						a(18 DOWNTO 0) & "0000000000000" WHEN"01101",
						a(17 DOWNTO 0) & "00000000000000" WHEN"01110",
						a(16 DOWNTO 0) & "000000000000000" WHEN"01111",
						a(15 DOWNTO 0) & "0000000000000000" WHEN"10000",
						a(14 DOWNTO 0) & "00000000000000000" WHEN"10001",
						a(13 DOWNTO 0) & "000000000000000000" WHEN"10010",
						a(12 DOWNTO 0) & "0000000000000000000" WHEN"10011",
						a(11 DOWNTO 0) & "00000000000000000000" WHEN"10100",
						a(10 DOWNTO 0) & "000000000000000000000" WHEN"10101",
						a(09 DOWNTO 0) & "0000000000000000000000" WHEN"10110",
						a(08 DOWNTO 0) & "00000000000000000000000" WHEN"10111", 
						a(07 DOWNTO 0) & "000000000000000000000000" WHEN"11000",
						a(06 DOWNTO 0) & "0000000000000000000000000" WHEN"11001",
						a(05 DOWNTO 0) & "00000000000000000000000000" WHEN"11010",
						a(04 DOWNTO 0) & "000000000000000000000000000" WHEN"11011",
						a(03 DOWNTO 0) & "0000000000000000000000000000" WHEN"11100",
						a(02 DOWNTO 0) & "00000000000000000000000000000" WHEN"11101",
						a(01 DOWNTO 0) & "000000000000000000000000000000" WHEN"11110",
						a(0)		   & "0000000000000000000000000000000" WHEN"11111",
		        		a WHEN OTHERS;

-----------------------------right shift --------------------------------------
with b(4 downto 0) select
		a_rightshift <= '0' & a(31 DOWNTO 01)  WHEN"00001",
						"00" & a(31 DOWNTO 02)  WHEN"00010",
						"000" & a(31 DOWNTO 03)  WHEN"00011",
						"0000" & a(31 DOWNTO 04)  WHEN"00100",
						"00000" & a(31 DOWNTO 05)  WHEN"00101",
						"000000" & a(31 DOWNTO 06)  WHEN"00110",
						"0000000" & a(31 DOWNTO 07)  WHEN"00111",
						"00000000" & a(31 DOWNTO 08)  WHEN"01000",
						"000000000" & a(31 DOWNTO 09)  WHEN"01001",
						"0000000000" & a(31 DOWNTO 10)  WHEN"01010",
						"00000000000" & a(31 DOWNTO 11)  WHEN"01011",
						"000000000000" & a(31 DOWNTO 12)  WHEN"01100",
						"0000000000000" & a(31 DOWNTO 13)  WHEN"01101",
						"00000000000000" & a(31 DOWNTO 14)  WHEN"01110",
						"000000000000000" & a(31 DOWNTO 15)  WHEN"01111",
						"0000000000000000" & a(31 DOWNTO 16)  WHEN"10000",
						"00000000000000000" & a(31 DOWNTO 17)  WHEN"10001",
						"000000000000000000" & a(31 DOWNTO 18)  WHEN"10010",
						"0000000000000000000" & a(31 DOWNTO 19)  WHEN"10011",
						"00000000000000000000" & a(31 DOWNTO 20)  WHEN"10100",
						"000000000000000000000" & a(31 DOWNTO 21)  WHEN"10101",
						"0000000000000000000000" & a(31 DOWNTO 22)  WHEN"10110",
						"00000000000000000000000" & a(31 DOWNTO 23)  WHEN"10111", 
						"000000000000000000000000" & a(31 DOWNTO 24)  WHEN"11000",
						"0000000000000000000000000" & a(31 DOWNTO 25)  WHEN"11001",
						"00000000000000000000000000" & a(31 DOWNTO 26)  WHEN"11010",
						"000000000000000000000000000" & a(31 DOWNTO 27)  WHEN"11011",
						"0000000000000000000000000000" & a(31 DOWNTO 28)  WHEN"11100",
						"00000000000000000000000000000" & a(31 DOWNTO 29)  WHEN"11101",
						"000000000000000000000000000000" & a(31 DOWNTO 30)  WHEN"11110",
						"0000000000000000000000000000000" & a(31)		      WHEN"11111",
		        		a WHEN OTHERS;
end alu_behave;
