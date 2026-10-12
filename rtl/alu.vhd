library ieee;
  use ieee.std_logic_1164.all;

entity alu is
  port (
    a    : in    std_logic;
    b    : in    std_logic;
    cin  : in    std_logic;
    s    : in    std_logic_vector(1 downto 0);
    sout : out   std_logic;
    cout : out   std_logic
  );
end entity alu;

architecture behavior of alu is

  component full_adder is
    port (
      a    : in    std_logic;
      b    : in    std_logic;
      cin  : in    std_logic;
      sout : out   std_logic;
      cout : out   std_logic
    );
  end component full_adder;

  component mux31 is
    port (
      input1 : in    std_logic;
      input2 : in    std_logic;
      input3 : in    std_logic;
      s      : in    std_logic_vector(1 downto 0);
      sout   : out   std_logic
    );
  end component mux31;

  component and_gate is
    port (
      in1  : in    std_logic;
      in2  : in    std_logic;
      sout : out   std_logic
    );
  end component and_gate;

  component or_gate is
    port (
      in1  : in    std_logic;
      in2  : in    std_logic;
      sout : out   std_logic
    );
  end component or_gate;

  signal sout_full_adder : std_logic;
  signal sout_or_gate    : std_logic;
  signal sout_and_gate   : std_logic;
  signal nb              : std_logic;

begin

  nb <= b xor s(0);

  c1 : component full_adder
    port map (
      a    => a,
      b    => nb,
      cin  => cin,
      sout => sout_full_adder,
      cout => cout
    );

  c2 : component and_gate
    port map (
      in1  => a,
      in2  => b,
      sout => sout_and_gate
    );

  c3 : component or_gate
    port map (
      in1  => a,
      in2  => b,
      sout => sout_or_gate
    );

  c4 : component mux31
    port map (
      input1 => sout_full_adder,
      input2 => sout_and_gate,
      input3 => sout_or_gate,
      s      => s,
      sout   => sout
    );

end architecture behavior;

