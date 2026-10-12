library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity registers is
  port (
    clk   : in    std_logic;
    clear : in    std_logic;

    a_addr : in    std_logic_vector( 3 downto 0);
    a_data : in    std_logic_vector(15 downto 0);
    load   : in    std_logic;

    b_addr : in    std_logic_vector( 3 downto 0);
    c_addr : in    std_logic_vector( 3 downto 0);

    b_data : out   std_logic_vector(15 downto 0);
    c_data : out   std_logic_vector(15 downto 0)
  );
end entity registers;

architecture syn of registers is

  type ram_type is array (15 downto 0) of std_logic_vector(15 downto 0);

  signal reg : ram_type;

begin

  reg_write : process (clk, clear) is
  begin

    if (clear = '0') then
      reg(0) <= x"0000";
      reg(1) <= x"0000";
      reg(2) <= x"0000";
      reg(3) <= x"0000";

      reg(4) <= x"0000";
      reg(5) <= x"0000";
      reg(6) <= x"0000";
      reg(7) <= x"0000";

      reg(8)  <= x"0000";
      reg(9)  <= x"0000";
      reg(10) <= x"0000";
      reg(11) <= x"0000";

      reg(12) <= x"0000";
      reg(13) <= x"0000";
      reg(14) <= x"0000";
      reg(15) <= x"0000";
    elsif (clk'event and clk = '1') then
      if (load = '1') then
        reg(to_integer(unsigned(a_addr))) <= a_data;
      end if;
    end if;

    -- r0 and r1 are the constants 0 and 1. These assignments come last, so
    -- they override both the clear above and any write to either register.
    reg(0) <= x"0000";
    reg(1) <= x"0001";

  end process reg_write;

  b_data <= reg(to_integer(unsigned(b_addr)));
  c_data <= reg(to_integer(unsigned(c_addr)));

end architecture syn;

