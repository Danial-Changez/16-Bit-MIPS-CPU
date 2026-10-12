library ieee;
  use ieee.std_logic_1164.all;

entity mux3_1 is
  generic (
    WIDTH : positive := 16
  );
  port (
    input1 : in    std_logic_vector(WIDTH - 1   downto 0);
    input2 : in    std_logic_vector(WIDTH - 1   downto 0);
    input3 : in    std_logic_vector(WIDTH - 1   downto 0);
    s      : in    std_logic_vector(1       downto 0);
    sout   : out   std_logic_vector(WIDTH - 1   downto 0)
  );
end entity mux3_1;

architecture behavioral of mux3_1 is

begin

  sout <= input1 when s = "00" else
          input2 when s = "01" else
          input3;

end architecture behavioral;

