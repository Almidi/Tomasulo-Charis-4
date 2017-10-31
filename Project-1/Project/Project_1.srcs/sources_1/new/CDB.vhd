library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity CDB is
    Port ( QArithmetic : in STD_LOGIC_VECTOR (4 downto 0);
           VArithmetic : in STD_LOGIC_VECTOR (31 downto 0);
           QLogical : in STD_LOGIC_VECTOR (4 downto 0);
           VLogical : in STD_LOGIC_VECTOR (31 downto 0);
           QBuffer : in STD_LOGIC_VECTOR (4 downto 0);
           VBuffer : in STD_LOGIC_VECTOR (31 downto 0);
           ArithmeticRequest : in STD_LOGIC;
           LogicalRequest : in STD_LOGIC;
           BufferRequest : in STD_LOGIC;
           Clk : in STD_LOGIC;
           Rst : in STD_LOGIC;
           Qout : out STD_LOGIC_VECTOR (4 downto 0);
           Vout : out STD_LOGIC_VECTOR (31 downto 0));
end CDB;
architecture Behavioral of CDB is
	signal priority: std_logic_vector(1 downto 0);
begin
	process(Clk, Rst)
	begin
		if Rst='1' then
			Qout<=std_logic_vector(to_unsigned(0,5));
			Vout<=std_logic_vector(to_unsigned(0,32));
			priority<="00";
		elsif rising_edge(Clk) then
			if priority="00" then
					if ArithmeticRequest='1' then
						Qout<=QArithmetic;
						Vout<=VArithmetic;
					elsif LogicalRequest='1' then
						Qout<=QLogical;
						Vout<=VLogical;
					elsif BufferRequest='1' then
						Qout<=QBuffer;
						Vout<=VBuffer;
					else
						Qout<=std_logic_vector(to_unsigned(0,5));
						Vout<=std_logic_vector(to_unsigned(0,32));
					end if;
					priority<="01";
				elsif priority="01" then
					if LogicalRequest='1' then
						Qout<=QLogical;
						Vout<=VLogical;
					elsif BufferRequest='1' then
						Qout<=QBuffer;
						Vout<=VBuffer;
					elsif ArithmeticRequest='1' then
						Qout<=QArithmetic;
						Vout<=VArithmetic;
					else
						Qout<=std_logic_vector(to_unsigned(0,5));
						Vout<=std_logic_vector(to_unsigned(0,32));
					end if;
					priority<="10";
				else
					if BufferRequest='1' then
						Qout<=QBuffer;
						Vout<=VBuffer;
					elsif ArithmeticRequest='1' then
						Qout<=QArithmetic;
						Vout<=VArithmetic;
					elsif LogicalRequest='1' then
						Qout<=QLogical;
						Vout<=VLogical;
					else
						Qout<=std_logic_vector(to_unsigned(0,5));
						Vout<=std_logic_vector(to_unsigned(0,32));
					end if;
					priority<="00";
				end if;
		end if;
	end process;
end Behavioral;