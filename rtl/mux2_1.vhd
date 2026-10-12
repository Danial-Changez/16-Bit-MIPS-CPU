library ieee;
  use ieee.std_logic_1164.all;

entity mux2_1 is
  generic (
    WIDTH : positive := 16
  );
  port (
    input1 : in    std_logic_vector(WIDTH - 1   downto 0);
    input2 : in    std_logic_vector(WIDTH - 1   downto 0);
    s      : in    std_logic;
    sout   : out   std_logic_vector(WIDTH - 1   downto 0)
  );
end entity mux2_1;

architecture behavioral of mux2_1 is

begin

  sout <= input1 when s = '0' else
          input2;

end architecture behavioral;

