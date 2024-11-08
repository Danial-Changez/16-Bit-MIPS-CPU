-- This file contains the description of a simple, single-port memory.
-- 
-- * The data_out port updates asynchronously when read_en is high.
-- * The memory is updated synchronously (on a rising clock edge) from
--   data_in when write_en is high.
-- 
-- This memory can be initialized from an input file, and can dump its
-- contents to an output file.  To use this, you must assign the INPUT and
-- OUTPUT generics when instantiating a memory component, e.g.:
--
--     data_mem : entity work.memory
--         generic map (
--             INPUT => "in_data.txt",
--             OUTPUT => "out_data.txt")
--         port map ( ... );
--
-- The input file must have 33 lines, 8 bits per line.  The output file is
-- written in the same format, whenever the mem_dump input goes high.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;


entity Memory is
   generic (
       INPUT : string := "in.txt";
       OUTPUT : string := "out.txt"
   );
    port (
        clk : in std_logic;  
        read_en : in std_logic;
        write_en : in std_logic;
        addr : in std_logic_vector(15 downto 0);
        data_in : in std_logic_vector(15 downto 0);
        data_out : out std_logic_vector(15 downto 0);
        mem_dump : in std_logic := '0'
    );
end entity Memory;


architecture beh of Memory is
    type mem_type is array (0  to  33) of std_logic_vector(7  downto 0);

    impure function init_mem return mem_type is
        file in_file : text; 
        variable in_line : line;
        variable byte : bit_vector(7  downto 0);
        variable mem : mem_type;
    begin
        if INPUT'length = 0 then
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

--    procedure dump_mem is
--        file out_file : text;
--        variable out_line : line;
--        variable byte : bit_vector(7  downto 0);
--
--    begin
--        if OUTPUT'length = 0 then
--            report "The mem_dump port was triggered, but no file name was";
--            report "given.  Specify a file name for the generic OUTPUT in";
--            report "the entity declaration to enable memory dump.";
--            return;
--        end if;
--        
--        file_open(out_file, OUTPUT, WRITE_MODE);
--        for row in mem_type'range loop
--            byte := to_bitvector(mem(row));
--            write(out_line, byte);
--            writeline(out_file, out_line);
--        end loop;
--    end procedure dump_mem;
	 
	 
begin
    read_p : process (read_en, mem, addr) is
    begin
        if read_en = '1' then
            data_out(7  downto 0) <= mem(conv_integer(addr(7 downto 0)));
            data_out(15 downto 8) <= mem(conv_integer(addr(7 downto 0))+1);
        end if;
    end process read_p;

    write_p : process (clk) is
    begin
        if rising_edge(clk) and write_en = '1' then
            mem(conv_integer(addr(7 downto 0))) <= data_in(7  downto 0);
            mem(conv_integer(addr(7 downto 0))+1) <= data_in(15 downto 8);
        end if;
    end process write_p;

--    mem_dump_p : process(mem_dump) is
--    begin
--        if rising_edge(mem_dump) then
--            dump_mem;
--        end if;
--    end process mem_dump_p;
end architecture beh;   

