library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; --use conv_integer

entity processor is
 port  (
 	clk: 			in 		std_logic;
 	--clkmem:			in 		std_logic;
 	clr: 			in 		std_logic
 	--sw:				in std_logic_vector
  );
end processor;

architecture behav of processor is

	signal Instruction:	std_logic_vector(31 downto 0);
 	signal Dataadd:		std_logic_vector(9 downto 0);
 	signal DataRead:	std_logic_vector(31 downto 0);
 	signal Datawrite:	std_logic_vector(31 downto 0);
 	signal MemWrite: 	std_logic_vector(0 downto 0);
 	signal PC:			std_logic_vector(31 downto 0);
 	signal Instwrite: 	std_logic_vector(0 downto 0);
 	signal Inst_din: 	std_logic_vector(31 downto 0);
	signal Insten: 		std_logic;
	signal Dataen:		std_logic;

	component mips
	port  (
	 	clk: 			in 		std_logic;
	 	clr: 			in 		std_logic;
	 	Instruction:	in 		std_logic_vector(31 downto 0);
	 	Dataadd:		out 	std_logic_vector(9 downto 0);
	 	Datawrite:		out 	std_logic_vector(31 downto 0);
	 	DataRead:		in 		std_logic_vector(31 downto 0);
	 	MemWrite: 		out		std_logic_vector(0 downto 0);
	 	PC:				out 	std_logic_vector(31 downto 0)
  		);
	end component;

	component InstMem
     PORT (
	      clka : 		IN STD_LOGIC;
	      ena : 		IN STD_LOGIC;
	      wea : 		IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	      addra : 		IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	      dina : 		IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	      douta : 		OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
	end component;

	component DataMem
    PORT (
	      clka : IN STD_LOGIC;
	      ena : IN STD_LOGIC;
	      wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	      addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	      dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	      douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
	end component;
begin
	m1: mips port map (clk => clk,
					   clr=> clr,
					   Instruction=>Instruction,
					   Dataadd=> Dataadd,
					   Datawrite=> Datawrite,
					   DataRead=> DataRead,
					   MemWrite=> MemWrite,
					   PC=> PC);
	mem1: InstMem port map(clka=> clk,
						   ena=> Insten,
						   wea=> Instwrite,addra=> PC(9 downto 0),dina=> Inst_din,douta=> Instruction);
	mem2: DataMem port map(clka=> clk,ena=> Dataen,wea=> MemWrite,addra=> Dataadd,dina=> Datawrite,douta=> DataRead);

	Dataen <= '1';
	Insten <= '1';
	Instwrite<="0";
	Inst_din<=x"00000000";


end architecture ; -- behav