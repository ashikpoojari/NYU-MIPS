library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; --use conv_integer

entity control is
 port  (  
  a: in std_logic_vector(31 downto 0);--32-bit input
  b: in std_logic_vector(31 downto 0); --32-bit input
  opcode: in std_logic_vector(5 downto 0); --function bits to control operation
  func: in std_logic_vector(5 downto 0);--31-bit input
  RegDst: out std_logic;
  Branch: out std_logic;
  MemtoReg: out std_logic;
  MemWrite: out std_logic_vector(0 downto 0);
  ALUSrc: out std_logic;
  RegWrite: out std_logic;
  ALUop: out std_logic_vector(2 downto 0)
  );
end control;

architecture behav_control of control is
signal Branchs : std_logic;
signal blt: std_logic;
signal beq: std_logic;
signal bne: std_logic;

begin
------------------------------------ALU OP ---------------------------------------------
process(opcode,func)
begin
if(((opcode = "000000") and (func = "010000"))or (opcode = "000001") or (opcode =  "000111") or (opcode = "001000"))then --- add when ADD, ADDI, LW and SW
		ALUop		<= "000";---add
end if;

if(((opcode = "000000") and (func = "010001")) or (opcode = "000010"))then --- SUB, SUBI
		ALUop		<= "001";---sub
end if;

if (((opcode= "000000") and (func ="010010")) or (opcode = "000011")) then --- AND, ANDI
		ALUop		<= "010";
end if ;

if (((opcode= "000000") and (func ="010011")) or (opcode = "000100")) then --- OR, ORI
		ALUop		<= "011";
end if ;

if ((opcode= "000000") and (func ="010100")) then --- NOR
		ALUop		<= "100";
end if ;

if(opcode  = "000101") then --- SHL
		ALUop 		<= "101";
end if;

if(opcode  = "000110") then --- SHR
		ALUop 		<= "110";
end if;


------------------------------------ Reg Destination------------------------------------
if (opcode = "000000") then--- register type
		RegDst <= '1';
else
		RegDst <= '0';	---- immediate type
end if ;

------------------------------------ Branch and Branch type ----------------------------
if ((opcode = "001001") or (opcode = "001010") or (opcode = "001011") or (opcode = "001100") or (opcode = "111111")) then
	Branchs <= '1';
else
	Branchs <= '0';
end if ;


------------------------------------ Memory Write----------------------------------------
if (opcode = "001000") then
	MemWrite <= "1";
else
	MemWrite <= "0";
end if ;

------------------------------------ Memory to Reg----------------------------------------
if (opcode = "000111") then
	MemtoReg <= '1';
else
	MemtoReg <= '0';
end if ;
------------------------------------ ALU Source----------------------------------------
if (opcode = "000000") then
	ALUSrc <= '0';
else
	ALUSrc <= '1';
end if;

end process;

process(a,b,opcode,Branchs) begin
	if(opcode = "001001") then
		if(a<b) then
			blt <= Branchs;
		else
			blt <='0';
		end if;
	else
		blt <= '0';
	end if;
end process;

process(a,b,opcode,Branchs) begin
	if(opcode = "001010" or opcode ="001011") then
		if(a = b) then
			beq <=Branchs;
			bne <='0';
		else
			beq <='0';
			bne <=Branchs;
		end if;
	else
		beq <= '0';
		bne <= '0';
	end if;
end process;

with opcode(2 downto 0) select
		Branch <=       blt when "001",
						beq when "010",
						bne when "011",
						Branchs when "100",
						Branchs when "111",
						Branchs when others;

------------------------------------ Reg write----------------------------------------
--RegWrite <= (not(opcode(3)) or (not(opcode(2)) and not(opcode(1))));
RegWrite <= not(opcode(3));

end behav_control;