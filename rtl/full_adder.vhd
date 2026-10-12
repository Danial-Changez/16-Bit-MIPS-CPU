library ieee;
  use ieee.std_logic_1164.all;

entity full_adder is
  port (
    a    : in    std_logic;
    b    : in    std_logic;
    cin  : in    std_logic;
    sout : out   std_logic;
    cout : out   std_logic
  );
end entity full_adder;

architecture behavior of full_adder is

begin

  sout <= a xor b xor cin;
  cout <= (a and b) or ((a xor b) and cin);

end architecture behavior;

