library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux2_1 is
   generic (WIDTH : positive:=16);
	port(
		Input1		:	in		std_logic_vector(WIDTH-1 	downto 0);
		Input2		:	in		std_logic_vector(WIDTH-1 	downto 0);
		S				:	in		std_logic;
		Sout			:	out	std_logic_vector(WIDTH-1 	downto 0));
end mux2_1;

architecture Behavioral of mux2_1 is

begin
	Sout <=	Input1 when S='0' else
				Input2 when S='1';
end Behavioral;

