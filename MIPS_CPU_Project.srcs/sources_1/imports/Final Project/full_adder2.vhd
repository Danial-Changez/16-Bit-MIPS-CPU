Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.std_logic_unsigned.all;

Entity full_adder is
port(	
		A	:	in	std_logic;
		B	:	in	std_logic;
		Cin	:	in	std_logic;
		Sout	:	out std_logic;
		Cout:	out	std_logic
);
End;

Architecture behavior of full_adder is

Begin
-- Cin A  B  S  C
--  0  0  0  0  0
--  0  0  1  1  0
--  0  1  0  1  0
--  0  1  1  0  1
--  1  0  0  1  0
--  1  0  1  0  1
--  1  1  0  0  1
--  1  1  1  1  1

-- Full adder Logic find the expression in previous ppt

	Sout <= A xor B xor Cin;
	Cout <= (A and B) or ((A Xor B) and Cin);

	
End;

