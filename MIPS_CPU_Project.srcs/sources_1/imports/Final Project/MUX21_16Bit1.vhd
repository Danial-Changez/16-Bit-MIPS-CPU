Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.std_logic_unsigned.all;

entity MUX21_16Bit is
port(	Input1		:	in	std_logic_vector(15 downto 0);
		Input2		:	in	std_logic_vector(15 downto 0);
		S			:	in	std_logic;
		Sout		:	out	std_logic_vector(15 downto 0));
end MUX21_16Bit;

architecture Behavioral of MUX21_16Bit is

Begin

	Sout <=	Input1 when S='0' else
			Input2 when S='1';

end Behavioral;

