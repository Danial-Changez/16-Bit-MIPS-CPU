library ieee;
  use ieee.std_logic_1164.all;

entity pc_reg is
  port (
    clk    : in    std_logic;
    reset  : in    std_logic;
    input  : in    std_logic_vector(15 downto 0);
    output : out   std_logic_vector(15 downto 0)
  );
end entity pc_reg;

architecture behavioral of pc_reg is

begin

  pc : process (reset, clk) is
  begin

    -- Asynchronous, active-low reset.
    if (reset = '0') then
      output <= (others => '0');
    elsif rising_edge(clk) then
      output <= input;
    end if;

  end process pc;

end architecture behavioral;
