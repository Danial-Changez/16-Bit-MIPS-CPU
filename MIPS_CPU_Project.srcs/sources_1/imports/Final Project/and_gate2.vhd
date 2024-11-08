Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.std_logic_unsigned.all;

Entity and_gate is
port(	
		In1		:	in	std_logic;
		In2		:	in	std_logic;
		Sout	:	out	std_logic
);
End;

Architecture behavior of and_gate is

Begin
-- In1  In2  Sout
--  0    0    0
--  0    1    0
--  1    0    0
--  1    1    1
	
-- and gate logic
	Sout <= In1 and In2;

End;

