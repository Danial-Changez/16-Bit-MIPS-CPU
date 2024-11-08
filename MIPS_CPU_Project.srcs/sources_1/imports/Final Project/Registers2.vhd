library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

Entity Registers is
	port(
		clk	:	in	 std_logic;
		clear	:	in  std_logic;
		
		a_addr:	in	 std_logic_vector( 3 downto 0);
		a_data:	in	 std_logic_vector(15 downto 0);
		load	:	in	 std_logic;
		
		b_addr:	in	 std_logic_vector( 3 downto 0);
		c_addr:	in	 std_logic_vector( 3 downto 0);
		
		b_data:	out std_logic_vector(15 downto 0);
		c_data:	out std_logic_vector(15 downto 0)
		);
End Registers;

architecture syn of Registers is
	type ram_type is array (15 downto 0) of std_logic_vector(15 downto 0);
	signal REG	:	ram_type;
begin
	process(clk, load, clear)
	begin
		if (clear = '0') then
			REG(0)	<= x"0000";
			REG(1)	<= x"0000";
			REG(2)	<= x"0000";
			REG(3)	<= x"0000";

			REG(4)	<= x"0000";
			REG(5)	<= x"0000";
			REG(6)	<= x"0000";
			REG(7)	<= x"0000";
		
			REG(8)	<= x"0000";
			REG(9)	<= x"0000";
			REG(10)	<= x"0000";
			REG(11)	<= x"0000";

			REG(12)	<= x"0000";
			REG(13)	<= x"0000";
			REG(14)	<= x"0000";
			REG(15)	<= x"0000";
		elsif (clk'event and clk='1') then
			if (load = '1') then
					REG(conv_integer(a_addr)) <= a_data;
			end if;
		end if;
		REG(0)	<= x"0000";
		REG(1)	<= x"0001";
	end process;
	b_data <= REG(conv_integer(b_addr));
	c_data <= REG(conv_integer(c_addr));
end syn;

--		if (clear = '0') then
--			for i in 15 downto 0 loop
--				REG(i) <= x"0000";
--			end loop;
--		elsif (rising_edge(clk) and load = '1') then
--			REG(conv_integer(a_addr)) <= a_data;
--		end if;		
