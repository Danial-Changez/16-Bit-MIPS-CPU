library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux3_1 is
   generic (WIDTH : positive:=16);
	port(
		Input1		:	in		std_logic_vector(WIDTH-1 	downto 0);
		Input2		:	in		std_logic_vector(WIDTH-1 	downto 0);
		Input3		:	in		std_logic_vector(WIDTH-1 	downto 0);
		S				:	in		std_logic_vector(1 			downto 0);
		Sout			:	out	std_logic_vector(WIDTH-1 	downto 0));
end mux3_1;

architecture Behavioral of mux3_1 is

begin
	Sout <=	Input1 when S="00" else
				Input2 when S="01" else
				Input3 when S="10" else
				Input3 when S="11";
end Behavioral;

