library ieee;
use ieee.std_logic_1164.all;


entity CPU_3380_Test is
end entity CPU_3380_Test;


architecture mixed of CPU_3380_Test is
    constant tick : time := 100 ns;
	 constant RUN_TIME : integer := 18;
    signal reset, clock : std_logic;
	 signal mem_dump : std_logic := '0';
    --signal instruction : std_logic_vector(0 to 15);
begin
    uut : entity work.CPU_3380
        port map(
            clk		=> clock,
            clear	=> reset,
				mem_dump    => mem_dump
        );

    driver : process is
    begin
        -- reset the system
        reset <= '0'; 
		  wait for 50 ns;
        -- reset <= '1';

			for i in  1 to RUN_TIME loop
				wait for tick;
			end loop;
			
--			addi r3, r0, 5
--			addi r4, r0, 2
--			slt r11, r3, r4
--			sw r3, 0(r0)
--			sw r4, 4(r0)
--			addi r6, r0, 4
--			lw r7, 0(r6)
--			lw r8, 0(r0)
--			add r9, r7, r8
--			slt r10, r0, r1
--			slt r10, r1, r0
--			or r5, r10, r9
--			subi r10, r5, 7
--			sub r11, r10, r7
--			sw r11, 5(r8)
        wait;
    end process driver;

    clock_p : process is
    begin
        for i in 0 to 50 loop
            clock <= '1'; wait for tick/2;
            clock <= '0'; wait for tick/2;
        end loop;
        wait;
    end process clock_p;
end architecture mixed;
