library ieee;
  use ieee.std_logic_1164.all;

entity mux31 is
  port (
    input1 : in    std_logic;
    input2 : in    std_logic;
    input3 : in    std_logic;
    s      : in    std_logic_vector(1 downto 0);
    sout   : out   std_logic
  );
end entity mux31;

architecture behavioral of mux31 is

begin

  -- Select codes 00 (add) and 01 (subtract) both take input1, the adder.
  sout <= input1 when s = "00" else
          input1 when s = "01" else
          input2 when s = "10" else
          input3;

end architecture behavioral;

