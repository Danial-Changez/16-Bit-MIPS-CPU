library ieee;
  use ieee.std_logic_1164.all;

entity signextend is
  port (
    immin  : in    std_logic_vector( 3 downto 0);
    immout : out   std_logic_vector(15 downto 0)
  );
end entity signextend;

architecture syn of signextend is

begin

  immout(15) <= immin(3);
  immout(14) <= immin(3);
  immout(13) <= immin(3);
  immout(12) <= immin(3);
  immout(11) <= immin(3);
  immout(10) <= immin(3);
  immout(9)  <= immin(3);
  immout(8)  <= immin(3);
  immout(7)  <= immin(3);
  immout(6)  <= immin(3);
  immout(5)  <= immin(3);
  immout(4)  <= immin(3);
  immout(3)  <= immin(3);
  immout(2)  <= immin(2);
  immout(1)  <= immin(1);
  immout(0)  <= immin(0);

end architecture syn;
