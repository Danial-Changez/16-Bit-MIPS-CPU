Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.std_logic_unsigned.all;

entity MUX31 is
port(	Input1		:	in	std_logic;
		Input2		:	in	std_logic;
		Input3		:	in	std_logic;
		S			:	in	std_logic_vector(1 downto 0);
		Sout		:	out	std_logic);
end MUX31;

architecture Behavioral of MUX31 is

Begin
--MUX31 Logic (using When - ElSE structure)
	Sout <=	Input1 when S="00" else
				Input1 when S="01" else
				Input2 when S="10" else
				Input3 when S="11";


end Behavioral;

