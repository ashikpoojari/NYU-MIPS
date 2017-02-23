library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; --use conv_integer

entity mips is
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
end mips;

architecture arch of mips is

component control
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
end component;

component alu
 port  (
  ALUop: in std_logic_vector(2 downto 0); --ALU operation bits from the control
  a: in std_logic_vector(31 downto 0);--32-bit input
  b: in std_logic_vector(31 downto 0); --32-bit input
  alu_output: out std_logic_vector(31 downto 0) --32-bit alu output
  );
end component;

	type reg is array(31 downto 0) of std_logic_vector(31 downto 0);
	signal R: reg;
	signal a,b,b_ctrl: std_logic_vector(31 downto 0);
  	signal RegDst: std_logic;
  	signal Branch: std_logic;
  	signal MemtoReg: std_logic;
  	signal ALUSrc: std_logic;
  	signal RegWrite: std_logic;
  	signal ALUop: std_logic_vector(2 downto 0);
  	signal alu_output: std_logic_vector(31 downto 0);
  	signal O_BUS: std_logic_vector(31 downto 0);
  	signal jumpaddr: std_logic_vector(31 downto 0);
  	signal pcaddr: std_logic_vector(31 downto 0);
  	signal pctmp: std_logic_vector(31 downto 0);
  	signal mem_delay: std_logic_vector(1 downto 0);
  	signal fetch_delay: std_logic_vector(1 downto 0);

  	type states is (Fetch,
				ID,
				Exe,
				Mem,
				MemRd,
				WrB
				);
  	signal state, nextstate: states;

begin

	control1: control port map (a,b_ctrl,Instruction(31 downto 26),Instruction(5 downto 0),RegDst,Branch,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUop);
	alu1	: alu 	  port map (ALUop,a,b,alu_output);


	Process(clk)
	begin
		if(clk'event and clk='1')then
			if(clr = '1') then
				state<= Fetch;
			else
			     state<= nextstate;
			end if;
		end if;
	end process;


	Process(state, mem_delay, fetch_delay)
	begin
				case( nextstate ) is
				
					when Fetch 	=> 	if(fetch_delay = "01") then
										nextstate <= ID;
									end if;
					when ID    	=> nextstate <= Exe;
					when Exe 	=> nextstate <= Mem;
					when Mem 	=>   if(Instruction(31 downto 26) = "001000" or MemtoReg = '1') then
								  		nextstate <= MemRd;
								  	else
								  		nextstate<= WrB;
								  	end if;
					when MemRd 	=> if(mem_delay = "10") then
										nextstate <= WrB;
								   end if;
					when WrB 	=> nextstate <= Fetch;
				
					when others => nextstate <= Fetch;
				
				end case ;
	end Process;

	Process(clk)
	begin
		if(clk'event and clk = '1') then
			if(state = Mem) then
				mem_delay <= "00";
			end if;

			if(state = MemRd) then
				mem_delay<=mem_delay+1;
			end if;
		end if;
	end Process;

	Process(clk)
	begin
		if(clk'event and clk = '1') then
			if(clr ='1') then
				fetch_delay <= "00";
			else
			if(state = WrB) then
				fetch_delay <= "00";
			end if;

			if(state = fetch) then
				fetch_delay<=fetch_delay+1;
			end if;
			end if;
		end if;
	end Process;				  		

	Process(clk)
	begin
		if(clk'event and clk='1') then
			if(state = ID) then
				a<= R(conv_integer(Instruction(25 downto 21)));
				b_ctrl<= R(conv_integer(Instruction(20 downto 16)));
			end if;
		end if;
	end process;


	Process(clk) 
	begin
		if(clk'event and clk='1') then
			if(state = ID) then
				if(ALUSrc = '1') then
					if(Instruction(15) = '1')then
						b<= x"ffff" & Instruction(15 downto 0);
					else
						b<= x"0000" & Instruction(15 downto 0);
					end if;
				else
					b<= R(conv_integer(Instruction(20 downto 16)));
				end if;
			end if;
		end if;
	end Process;

	Process(clk)
	begin
		if(clk'event and clk='1') then
			if(clr='1') then
				R    	 <= (others=>(others=>'0'));
			else
				if(state = WrB) then
					if(RegWrite='1') then
						if(RegDst = '1') then
							R(conv_integer(Instruction(15 downto 11))) <= O_BUS;
						else
							R(conv_integer(Instruction(20 downto 16))) <= O_BUS;
						end if;
					end if;
				end if;
			end if;
		end if;
	end Process;

	Process(clk)
	begin
	if(clk'event and clk='1') then
		if (MemtoReg = '1' and state=MemRd) then
			O_BUS <= DataRead;
		else
			if(state = Mem) then
				O_BUS <= alu_output;
			end if;
		end if ;
	end if;
	end Process;

	Process(Instruction,pctmp,jumpaddr)
	begin
	if(Instruction(15) = '1')then
		jumpaddr <= pctmp + (x"ffff" & Instruction(15 downto 0)) + 1; 
	else
		jumpaddr <= pctmp + (x"0000" & Instruction(15 downto 0)) + 1; 
	end if;

	

	case(Instruction(28 downto 26)) is
	
		when "001" => pcaddr <= jumpaddr;
		when "010" => pcaddr <= jumpaddr; 
		when "011" => pcaddr <= jumpaddr;
		when "100" => pcaddr <= (pctmp(31 downto 26) & Instruction(25 downto 0));
		when "111" => pcaddr <= pctmp;
		when others => pcaddr<=(others=>'0'); 
	
	end case ;
	end Process;

	Process (clk)
	begin
	if(clk'event and clk='1')then
		if(clr='1')then
			pctmp <= (others => '0');
		else
			if(state = Mem) then
				if (Branch = '1') then
					pctmp<=pcaddr;
				else
					pctmp<=pctmp +1;
					--if(pctmp < x"0000000D") then
					--	pctmp <= pctmp +1;
					--else
					--	pctmp <= pctmp;
					--end if;
				end if ;
			end if;
		end if;
	end if;
	end process;

	Process(clk) begin
	if(clk'event and clk='1') then
		if(state = Exe) then
			Dataadd <= alu_output(9 downto 0);
			Datawrite <= R(conv_integer(Instruction(20 downto 16)));
		end if;
	end if;
	end process;

	Process(clk) begin
	if(clk'event and clk='1') then
		if(clr ='1') then
			PC <= (others=>'0');
		else
			if(state =WrB) then
				PC<=pctmp;
			end if;
		end if;
	end if;
	end process;

end architecture ; -- arch