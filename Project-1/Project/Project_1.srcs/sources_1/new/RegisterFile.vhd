library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Bus32pkg.ALL;
use IEEE.NUMERIC_STD.ALL;
entity RegisterFile is
    Port ( ReadAddr1 : in STD_LOGIC_VECTOR (4 downto 0);
           ReadAddr2 : in STD_LOGIC_VECTOR (4 downto 0);
           CDBQ : in STD_LOGIC_VECTOR (4 downto 0);
           CDBV : in STD_LOGIC_VECTOR (31 downto 0);
           Tag : in STD_LOGIC_VECTOR (4 downto 0);
           WrEn : in STD_LOGIC;
           AddrW : in STD_LOGIC_VECTOR (4 downto 0);
           Clk : in STD_LOGIC;
           Rst : in STD_LOGIC;
           DataOut1 : out STD_LOGIC_VECTOR (31 downto 0);
           Tag1Out: out STD_LOGIC_VECTOR (4 downto 0);
           DataOut2 : out STD_LOGIC_VECTOR (31 downto 0);
           Tag2Out: out STD_LOGIC_VECTOR (4 downto 0));
end RegisterFile;
architecture Structural of RegisterFile is
	component Register32 is
		Port ( DataIn : in STD_LOGIC_VECTOR (31 downto 0);
			   WrEn : in STD_LOGIC;
			   Clk : in STD_LOGIC;
			   DataOut : out STD_LOGIC_VECTOR (31 downto 0);
			   Rst : in STD_LOGIC);
	end component;
	component Register5 is
		Port ( DataIn : in STD_LOGIC_VECTOR (4 downto 0);
			   WrEn : in STD_LOGIC;
			   Rst : in STD_LOGIC;
			   Clk : in STD_LOGIC;
			   DataOut : out STD_LOGIC_VECTOR (4 downto 0));
	end component;
	component TagWrEnHandler is
		Port ( AddrW : in STD_LOGIC_VECTOR (4 downto 0);
			   WrEn : in STD_LOGIC;
			   Output : out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component BusMultiplexer32 is
	    Port (	Input : in Bus32;
				Sel : in  STD_LOGIC_VECTOR (4 downto 0);
				Output : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component CompareModule is
	    Port ( In0 : in  STD_LOGIC_VECTOR (4 downto 0);
	           In1 : in  STD_LOGIC_VECTOR (4 downto 0);
	           DOUT : out  STD_LOGIC);
	end component;
	
	type Bus5x32 is array (31 downto 0) of std_logic_vector(4 downto 0);
	signal register32Out : Bus32;
	signal register5Out: Bus5x32;
	signal TagWrEnHandlerOut, ComparatorsOut, Register32WrEnSignal: std_logic_vector(31 downto 0);
	signal isZero: std_logic;
begin
	Register32Generator:
	for i in 0 to 31 generate
		register32_i: Register32 port map(DataIn=>CDBV, WrEn=>Register32WrEnSignal(i), Clk=>Clk, DataOut=>register32Out(i), Rst=>Rst);
	end generate;
	Register5Generator:
	for i in 0 to 31 generate
		register5_i: Register5 port map(DataIn=>Tag, WrEn=>TagWrEnHandlerOut(i), Clk=>Clk, DataOut=>register5Out(i), Rst=>Rst);
	end generate;
	BusMux32_1: BusMultiplexer32 port map(Input=>register32Out, Sel=>ReadAddr1, Output=>DataOut1);
	BusMux32_2: BusMultiplexer32 port map(Input=>register32Out, Sel=>ReadAddr2, Output=>DataOut2);
	TagWrEnHandler_0: TagWrEnHandler port map(AddrW=>AddrW,WrEn=>WrEn,Output=>TagWrEnHandlerOut);
	ComparatorsGenerators:
	for i in 0 to 31 generate
		comparator_i: CompareModule port map(In0=>CDBQ,In1=>register5Out(i),DOUT=>ComparatorsOut(i));
	end generate;
	CompareToZero: CompareModule port map(In0=>CDBQ,In1=>std_logic_vector(to_unsigned(0,5)),DOUT=>isZero);
	Register32WrEnGenerator:
	for i in 0 to 31 generate
		Register32WrEnSignal(i)<=ComparatorsOut(i) and not isZero;
	end generate;
end Structural;