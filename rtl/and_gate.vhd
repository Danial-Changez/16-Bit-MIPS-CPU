library ieee;
  use ieee.std_logic_1164.all;

entity and_gate is
  port (
    in1  : in    std_logic;
    in2  : in    std_logic;
    sout : out   std_logic
  );
end entity and_gate;

architecture behavior of and_gate is

begin

  sout <= in1 and in2;

end architecture behavior;

