-- Simple single-port memory, one byte per location. A 16-bit word occupies
-- two locations, low byte first.
--
-- * data_out updates asynchronously while read_en is high.
-- * The memory is written on the rising clock edge when write_en is high.
-- * The contents are loaded at elaboration from the text file named by the
--   INPUT generic: one line per location (34 lines are read), eight binary
--   digits per line.
--
-- The OUTPUT generic and the mem_dump port are not used.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use std.textio.all;

entity memory is
  generic (
    INPUT  : string := "in.txt";
    OUTPUT : string := "out.txt"
  );
  port (
    clk      : in    std_logic;
    read_en  : in    std_logic;
    write_en : in    std_logic;
    addr     : in    std_logic_vector(15 downto 0);
    data_in  : in    std_logic_vector(15 downto 0);
    data_out : out   std_logic_vector(15 downto 0);
    mem_dump : in    std_logic
  );
end entity memory;

architecture beh of memory is

  type mem_type is array (0  to  33) of std_logic_vector(7  downto 0);

  impure function init_mem return mem_type is

    file     in_file : text;
    variable in_line : line;
    variable byte    : bit_vector(7  downto 0);
    variable mem     : mem_type;

  begin

    if (INPUT'length = 0) then
      return mem;
    end if;

    file_open(in_file, INPUT, READ_MODE);

    for row in mem_type'range loop

      readline(in_file, in_line);
      read(in_line, byte);
      mem(row) := to_stdlogicvector(byte);

    end loop;

    return mem;

  end function init_mem;

  signal mem : mem_type := init_mem;

begin

  read_p : process (read_en, mem, addr) is
  begin

    if (read_en = '1') then
      data_out(7  downto 0) <= mem(to_integer(unsigned(addr(7 downto 0))));
      data_out(15 downto 8) <= mem(to_integer(unsigned(addr(7 downto 0))) + 1);
    else
      data_out <= (others => '0');
    end if;

  end process read_p;

  write_p : process (clk) is
  begin

    if (rising_edge(clk) and write_en = '1') then
      mem(to_integer(unsigned(addr(7 downto 0))))     <= data_in(7  downto 0);
      mem(to_integer(unsigned(addr(7 downto 0))) + 1) <= data_in(15 downto 8);
    end if;

  end process write_p;

end architecture beh;

