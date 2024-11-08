library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

Entity Control is
	port(
		op		:	in	std_logic_vector( 3 downto 0);
		alu_op		:	out	std_logic_vector( 1 downto 0);
		alu_src		:	out	std_logic;
		reg_dest		:	out	std_logic;
		reg_load		:	out	std_logic;
		reg_src		:	out	std_logic_vector(1 downto 0);
		mem_read		:	out	std_logic;
		mem_write	:	out	std_logic
		);
End Control;

architecture syn of Control is

begin
	process (op) is
	begin
		case op is

			-- op=0, ADD
			when x"0" =>
				alu_op		<=	"00";
				alu_src		<=	'0';
				reg_dest		<=	'0';
				reg_load		<=	'1';
				reg_src		<=	"01";
				mem_read		<=	'0';
				mem_write	<=	'0';

			-- op=1, SUB
			when x"1" =>
				alu_op		<=	"01";
				alu_src		<=	'0';
				reg_dest		<=	'0';
				reg_load		<=	'1';
				reg_src		<=	"01";
				mem_read		<=	'0';
				mem_write	<=	'0';

			-- op=2, AND
			when x"2" =>
				alu_op		<=	"10";
				alu_src		<=	'0';
				reg_dest		<=	'0';
				reg_load		<=	'1';
				reg_src		<=	"01";
				mem_read		<=	'0';
				mem_write	<=	'0';

			-- op=3, OR
			when x"3" =>
				alu_op		<=	"11";
				alu_src		<=	'0';
				reg_dest		<=	'0';
				reg_load		<=	'1';
				reg_src		<=	"01";
				mem_read		<=	'0';
				mem_write	<=	'0';

			-- op=4, ADDi
			when x"4" =>
				alu_op		<=	"00";
				alu_src		<=	'1';
				reg_dest		<=	'0';
				reg_load		<=	'1';
				reg_src		<=	"01";
				mem_read		<=	'0';
				mem_write	<=	'0';

			-- op=5, SUBi
			when x"5" =>
				alu_op		<=	"01";
				alu_src		<=	'1';
				reg_dest		<=	'0';
				reg_load		<=	'1';
				reg_src		<=	"01";
				mem_read		<=	'0';
				mem_write	<=	'0';

			-- op=8, LW
			when x"8" =>
				alu_op		<=	"00";
				alu_src		<=	'1';
				reg_dest		<=	'0';
				reg_load		<=	'1';
				reg_src		<=	"00";
				mem_read		<=	'1';
				mem_write	<=	'0';

			-- op=C, SW
			when x"C" =>
				alu_op		<=	"00";
				alu_src		<=	'1';
				reg_dest		<=	'1';
				reg_load		<=	'0';
				reg_src		<=	"01";
				mem_read		<=	'0';
				mem_write	<=	'1';
	
			-- op=7, SLT
			when x"7" =>
				alu_op		<=	"01";
				alu_src		<=	'0';
				reg_dest		<=	'0';
				reg_load		<=	'1';
				reg_src		<=	"10";
				mem_read		<=	'0';
				mem_write	<=	'0';

			when others =>
				alu_op		<=	"00";
				alu_src		<=	'0';				
				reg_dest		<=	'0';
				reg_load		<=	'0';
				reg_src		<=	"01";
				mem_read		<=	'0';
				mem_write	<=	'0';

		end case;
	end process;
end syn;
