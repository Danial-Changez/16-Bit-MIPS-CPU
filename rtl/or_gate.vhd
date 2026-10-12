library ieee;
  use ieee.std_logic_1164.all;

entity or_gate is
  port (
    in1  : in    std_logic;
    in2  : in    std_logic;
    sout : out   std_logic
  );
end entity or_gate;

architecture behavior of or_gate is

begin

  sout <= in1 or in2;

end architecture behavior;

