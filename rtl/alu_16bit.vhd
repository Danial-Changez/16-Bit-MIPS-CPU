library ieee;
  use ieee.std_logic_1164.all;

entity alu_16bit is
  port (
    a    : in    std_logic_vector(15 downto 0);
    b    : in    std_logic_vector(15 downto 0);
    s    : in    std_logic_vector(1 downto 0);
    sout : out   std_logic_vector(15 downto 0);
    cout : out   std_logic
  );
end entity alu_16bit;

architecture behavior of alu_16bit is

  component alu is
    port (
      a    : in    std_logic;
      b    : in    std_logic;
      cin  : in    std_logic;
      s    : in    std_logic_vector(1 downto 0);
      sout : out   std_logic;
      cout : out   std_logic
    );
  end component alu;

  signal carry : std_logic_vector(14 downto 0);

begin

  alu00 : component alu
    port map (
      a    => a(0),
      b    => b(0),
      cin  => s(0),
      s    => s,
      sout => sout(0),
      cout => carry(0)
    );

  alu01 : component alu
    port map (
      a    => a(1),
      b    => b(1),
      cin  => carry(0),
      s    => s,
      sout => sout(1),
      cout => carry(1)
    );

  alu02 : component alu
    port map (
      a    => a(2),
      b    => b(2),
      cin  => carry(1),
      s    => s,
      sout => sout(2),
      cout => carry(2)
    );

  alu03 : component alu
    port map (
      a    => a(3),
      b    => b(3),
      cin  => carry(2),
      s    => s,
      sout => sout(3),
      cout => carry(3)
    );

  alu04 : component alu
    port map (
      a    => a(4),
      b    => b(4),
      cin  => carry(3),
      s    => s,
      sout => sout(4),
      cout => carry(4)
    );

  alu05 : component alu
    port map (
      a    => a(5),
      b    => b(5),
      cin  => carry(4),
      s    => s,
      sout => sout(5),
      cout => carry(5)
    );

  alu06 : component alu
    port map (
      a    => a(6),
      b    => b(6),
      cin  => carry(5),
      s    => s,
      sout => sout(6),
      cout => carry(6)
    );

  alu07 : component alu
    port map (
      a    => a(7),
      b    => b(7),
      cin  => carry(6),
      s    => s,
      sout => sout(7),
      cout => carry(7)
    );

  alu08 : component alu
    port map (
      a    => a(8),
      b    => b(8),
      cin  => carry(7),
      s    => s,
      sout => sout(8),
      cout => carry(8)
    );

  alu09 : component alu
    port map (
      a    => a(9),
      b    => b(9),
      cin  => carry(8),
      s    => s,
      sout => sout(9),
      cout => carry(9)
    );

  alu10 : component alu
    port map (
      a    => a(10),
      b    => b(10),
      cin  => carry(9),
      s    => s,
      sout => sout(10),
      cout => carry(10)
    );

  alu11 : component alu
    port map (
      a    => a(11),
      b    => b(11),
      cin  => carry(10),
      s    => s,
      sout => sout(11),
      cout => carry(11)
    );

  alu12 : component alu
    port map (
      a    => a(12),
      b    => b(12),
      cin  => carry(11),
      s    => s,
      sout => sout(12),
      cout => carry(12)
    );

  alu13 : component alu
    port map (
      a    => a(13),
      b    => b(13),
      cin  => carry(12),
      s    => s,
      sout => sout(13),
      cout => carry(13)
    );

  alu14 : component alu
    port map (
      a    => a(14),
      b    => b(14),
      cin  => carry(13),
      s    => s,
      sout => sout(14),
      cout => carry(14)
    );

  alu15 : component alu
    port map (
      a    => a(15),
      b    => b(15),
      cin  => carry(14),
      s    => s,
      sout => sout(15),
      cout => cout
    );

end architecture behavior;

