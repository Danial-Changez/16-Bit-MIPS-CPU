-- Self-checking testbench for cpu_3380.
--
-- Releases reset and lets the CPU run one of five programs. Just before each
-- rising clock edge it compares what the CPU is about to do with a table:
-- the PC, the fetched instruction word, whether a register write or a
-- memory write is requested, its destination and value, and the next PC.
-- A BNE or JMP row (pc_write) expects no write and gives the next PC; every
-- other row expects PC + 2. Any mismatch is a failure, which stops the
-- simulation with a non-zero exit status.
--
-- A register or memory write is observed as the request on the write port,
-- not by reading the storage; later instructions in each program read the
-- stored values back, so a lost or misdirected write shows up there.
--
-- The CPU loads Instr.txt and in.txt from the current directory, so the
-- simulation must be started in tb/<PROGRAM>/.
--
--   part_a    the program supplied with the course project (15 instructions)
--   directed  17 instructions covering every Part A opcode with
--             operands that tell the operations apart, negative immediates
--             and a negative store offset, the initial data memory contents,
--             and writes to the constant registers r0 and r1
--   part_b    the report's Part B program: a loop closed by JMP and left by
--             BNE, with a halt (JMP to itself) added at PC 32
--   branch    BNE taken and not taken, offsets 0 and 14, r0 against r1,
--             forward and backward jumps, back-to-back transfers and stores
--             that a taken branch skips
--   values    BNE on equal negatives and on the same register twice (not
--             taken), and on differences of x8000, xFF00, 1, 2 and xFFFF
--             (taken)
--
-- Loads use small non-negative addresses only. memory.vhd indexes its 34
-- bytes without a range check, and its read is asynchronous, so a load
-- aborts the simulation if its address passes through a value above 32
-- while the ripple-carry ALU settles. A negative offset does that, and so
-- can a load right after an instruction in subtract mode (SUB, SUBI, SLT,
-- BNE) or one whose ALU result is above 32. That includes a JMP, whose ALU
-- adds the registers named by target[7:4] and target[3:0]. No load in these
-- programs directly follows either kind.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity cpu_3380_tb is
  generic (
    PROGRAM : string := "part_a"
  );
end entity cpu_3380_tb;

architecture sim of cpu_3380_tb is

  constant CLK_PERIOD : time := 100 ns;

  type effect_t is (reg_write, mem_write, pc_write);

  type step_t is record
    word   : std_logic_vector(15 downto 0); -- instruction encoding
    effect : effect_t;
    index  : natural;                       -- register number or memory address
    value  : std_logic_vector(15 downto 0); -- for pc_write, the next PC
  end record step_t;

  type trace_t is array (natural range <>) of step_t;

  constant PART_A : trace_t :=
  (
    (x"4305", reg_write,  3, x"0005"), -- addi r3, r0, 5
    (x"4402", reg_write,  4, x"0002"), -- addi r4, r0, 2
    (x"7B34", reg_write, 11, x"0000"), -- slt  r11, r3, r4
    (x"C300", mem_write,  0, x"0005"), -- sw   r3, 0(r0)
    (x"C404", mem_write,  4, x"0002"), -- sw   r4, 4(r0)
    (x"4604", reg_write,  6, x"0004"), -- addi r6, r0, 4
    (x"8760", reg_write,  7, x"0002"), -- lw   r7, 0(r6)
    (x"8800", reg_write,  8, x"0005"), -- lw   r8, 0(r0)
    (x"0978", reg_write,  9, x"0007"), -- add  r9, r7, r8
    (x"7A01", reg_write, 10, x"0001"), -- slt  r10, r0, r1
    (x"7A10", reg_write, 10, x"0000"), -- slt  r10, r1, r0
    (x"35A9", reg_write,  5, x"0007"), -- or   r5, r10, r9
    (x"5A57", reg_write, 10, x"0000"), -- subi r10, r5, 7
    (x"1BA7", reg_write, 11, x"FFFE"), -- sub  r11, r10, r7
    (x"CB85", mem_write, 10, x"FFFE")  -- sw   r11, 5(r8)
  );

  -- The memory holds 17 instructions, so this fills it. The last one is
  -- checked but never clocked: the next PC would be outside the memory.
  constant DIRECTED : trace_t :=
  (
    (x"4207", reg_write,  2, x"0007"), -- addi r2, r0, 7
    (x"430D", reg_write,  3, x"FFFD"), -- addi r3, r0, -3
    (x"542E", reg_write,  4, x"0009"), -- subi r4, r2, -2
    (x"5544", reg_write,  5, x"0005"), -- subi r5, r4, 4
    (x"0625", reg_write,  6, x"000C"), -- add  r6, r2, r5
    (x"1752", reg_write,  7, x"FFFE"), -- sub  r7, r5, r2
    (x"2825", reg_write,  8, x"0005"), -- and  r8, r2, r5
    (x"3945", reg_write,  9, x"000D"), -- or   r9, r4, r5
    (x"7A32", reg_write, 10, x"0001"), -- slt  r10, r3, r2    (-3 < 7)
    (x"7B23", reg_write, 11, x"0000"), -- slt  r11, r2, r3
    (x"C61F", mem_write,  0, x"000C"), -- sw   r6, -1(r1)
    (x"C702", mem_write,  2, x"FFFE"), -- sw   r7, 2(r0)
    (x"8C02", reg_write, 12, x"FFFE"), -- lw   r12, 2(r0)     reads the word stored above
    (x"8D26", reg_write, 13, x"1234"), -- lw   r13, 6(r2)     reads bytes 13-14 of in.txt
    (x"4107", reg_write,  1, x"0007"), -- addi r1, r0, 7      requested, but r1 stays 1
    (x"4007", reg_write,  0, x"0007"), -- addi r0, r0, 7      requested, but r0 stays 0
    (x"0E01", reg_write, 14, x"0001")  -- add  r14, r0, r1    0 + 1
  );

  -- The first pass through the loop at PC 16-28 is the report's Figure 13;
  -- the loop then runs until r4 reaches 0.
  constant PART_B : trace_t :=
  (
    (x"5204", reg_write,  2, x"FFFC"), --  0: subi r2, r0, 4
    (x"4317", reg_write,  3, x"0008"), --  2: addi r3, r1, 7
    (x"0423", reg_write,  4, x"0004"), --  4: add  r4, r2, r3
    (x"3543", reg_write,  5, x"000C"), --  6: or   r5, r4, r3
    (x"C352", mem_write, 14, x"0008"), --  8: sw   r3, 2(r5)
    (x"B00E", pc_write,   0, x"000E"), -- 10: jmp  14
    (x"8236", reg_write,  2, x"0008"), -- 14: lw   r2, 6(r3)
    (x"0744", reg_write,  7, x"0008"), -- 16: add  r7, r4, r4
    (x"1627", reg_write,  6, x"0000"), -- 18: sub  r6, r2, r7
    (x"C460", mem_write,  0, x"0004"), -- 20: sw   r4, 0(r6)
    (x"1441", reg_write,  4, x"0003"), -- 22: sub  r4, r4, r1
    (x"7841", reg_write,  8, x"0000"), -- 24: slt  r8, r4, r1
    (x"9802", pc_write,   0, x"001C"), -- 26: bne  r8, r0, 2
    (x"B010", pc_write,   0, x"0010"), -- 28: jmp  16
    (x"0744", reg_write,  7, x"0006"), -- 16: add  r7, r4, r4
    (x"1627", reg_write,  6, x"0002"), -- 18: sub  r6, r2, r7
    (x"C460", mem_write,  2, x"0003"), -- 20: sw   r4, 0(r6)
    (x"1441", reg_write,  4, x"0002"), -- 22: sub  r4, r4, r1
    (x"7841", reg_write,  8, x"0000"), -- 24: slt  r8, r4, r1
    (x"9802", pc_write,   0, x"001C"), -- 26: bne  r8, r0, 2
    (x"B010", pc_write,   0, x"0010"), -- 28: jmp  16
    (x"0744", reg_write,  7, x"0004"), -- 16: add  r7, r4, r4
    (x"1627", reg_write,  6, x"0004"), -- 18: sub  r6, r2, r7
    (x"C460", mem_write,  4, x"0002"), -- 20: sw   r4, 0(r6)
    (x"1441", reg_write,  4, x"0001"), -- 22: sub  r4, r4, r1
    (x"7841", reg_write,  8, x"0000"), -- 24: slt  r8, r4, r1
    (x"9802", pc_write,   0, x"001C"), -- 26: bne  r8, r0, 2
    (x"B010", pc_write,   0, x"0010"), -- 28: jmp  16
    (x"0744", reg_write,  7, x"0002"), -- 16: add  r7, r4, r4
    (x"1627", reg_write,  6, x"0006"), -- 18: sub  r6, r2, r7
    (x"C460", mem_write,  6, x"0001"), -- 20: sw   r4, 0(r6)
    (x"1441", reg_write,  4, x"0000"), -- 22: sub  r4, r4, r1
    (x"7841", reg_write,  8, x"0001"), -- 24: slt  r8, r4, r1
    (x"9802", pc_write,   0, x"001E"), -- 26: bne  r8, r0, 2
    (x"2571", reg_write,  5, x"0000"), -- 30: and  r5, r7, r1
    (x"B020", pc_write,   0, x"0020")  -- 32: jmp  32             halt
  );

  constant BRANCH : trace_t :=
  (
    (x"4207", reg_write,  2, x"0007"), --  0: addi r2, r0, 7
    (x"9100", pc_write,   0, x"0004"), --  2: bne  r1, r0, 0      taken, offset 0
    (x"B00C", pc_write,   0, x"000C"), --  4: jmp  12             forward
    (x"C206", mem_write,  6, x"0007"), -- 12: sw   r2, 6(r0)
    (x"9022", pc_write,   0, x"0012"), -- 14: bne  r0, r2, 2      taken, over the store
    (x"4302", reg_write,  3, x"0002"), -- 18: addi r3, r0, 2
    (x"8406", reg_write,  4, x"0007"), -- 20: lw   r4, 6(r0)      7, not the 1 the skipped store holds
    (x"B006", pc_write,   0, x"0006"), -- 22: jmp  6              backward, into the loop
    (x"5331", reg_write,  3, x"0001"), --  6: subi r3, r3, 1      loop
    (x"931E", pc_write,   0, x"000A"), --  8: bne  r3, r1, 14     offset 14, taken when r3 /= 1
    (x"B006", pc_write,   0, x"0006"), -- 10: jmp  6              backward
    (x"5331", reg_write,  3, x"0000"), --  6: subi r3, r3, 1      loop
    (x"931E", pc_write,   0, x"0018"), --  8: bne  r3, r1, 14     offset 14, taken when r3 /= 1
    (x"0522", reg_write,  5, x"000E"), -- 24: add  r5, r2, r2
    (x"4552", reg_write,  5, x"0010"), -- 26: addi r5, r5, 2
    (x"9052", pc_write,   0, x"0020"), -- 28: bne  r0, r5, 2      difference x0010
    (x"BF20", pc_write,   0, x"0F20")  -- 32: jmp  xF20           halt: the memory decodes bits 7:0, so this is 32
  );

  constant VALUES : trace_t :=
  (
    (x"8200", reg_write,  2, x"8000"), --  0: lw   r2, 0(r0)
    (x"8300", reg_write,  3, x"8000"), --  2: lw   r3, 0(r0)
    (x"8402", reg_write,  4, x"FFFF"), --  4: lw   r4, 2(r0)
    (x"8504", reg_write,  5, x"0100"), --  6: lw   r5, 4(r0)
    (x"8606", reg_write,  6, x"7FFF"), --  8: lw   r6, 6(r0)
    (x"923E", pc_write,   0, x"000C"), -- 10: bne  r2, r3, 14     equal negatives, not taken
    (x"9022", pc_write,   0, x"0010"), -- 12: bne  r0, r2, 2      difference x8000
    (x"9502", pc_write,   0, x"0014"), -- 16: bne  r5, r0, 2      difference xFF00
    (x"944E", pc_write,   0, x"0016"), -- 20: bne  r4, r4, 14     same register, not taken
    (x"9620", pc_write,   0, x"0018"), -- 22: bne  r6, r2, 0      difference x0001
    (x"9412", pc_write,   0, x"001C"), -- 24: bne  r4, r1, 2      difference x0002
    (x"9262", pc_write,   0, x"0020"), -- 28: bne  r2, r6, 2      difference xFFFF
    (x"B020", pc_write,   0, x"0020")  -- 32: jmp  32             halt
  );

  function trace_for (
    name : string
  ) return trace_t is
  begin

    if (name = "directed") then
      return DIRECTED;
    end if;

    if (name = "part_b") then
      return PART_B;
    end if;

    if (name = "branch") then
      return BRANCH;
    end if;

    if (name = "values") then
      return VALUES;
    end if;

    assert name = "part_a"
      report "unknown PROGRAM """ & name & """"
      severity failure;
    return PART_A;

  end function trace_for;

  constant EXPECTED : trace_t := trace_for(PROGRAM);

  component cpu_3380 is
    port (
      clk      : in    std_logic;
      clear    : in    std_logic;
      mem_dump : in    std_logic
    );
  end component cpu_3380;

  signal clk   : std_logic := '0';
  signal clear : std_logic := '0';
  signal done  : boolean   := false;

begin

  clk <= not clk after CLK_PERIOD / 2 when not done else
         '0';

  dut : component cpu_3380
    port map (
      clk      => clk,
      clear    => clear,
      mem_dump => '0'
    );

  check : process is

    alias pc          is << signal dut.pc_reg_output : std_logic_vector(15 downto 0) >>;
    alias instruction is << signal dut.instruction : std_logic_vector(15 downto 0) >>;
    alias reg_we      is << signal dut.ctrl_reg_load : std_logic >>;
    alias reg_index   is << signal dut.rd : std_logic_vector(3 downto 0) >>;
    alias reg_data    is << signal dut.reg_src_mux_out : std_logic_vector(15 downto 0) >>;
    alias mem_we      is << signal dut.ctrl_mem_write : std_logic >>;
    alias mem_addr    is << signal dut.alu_result : std_logic_vector(15 downto 0) >>;
    alias mem_data    is << signal dut.rt_data : std_logic_vector(15 downto 0) >>;
    alias next_pc     is << signal dut.pc_src_mux_out : std_logic_vector(15 downto 0) >>;

    variable expected_pc      : natural;
    variable expected_next_pc : natural;

    procedure expect (
      ok   : in boolean;
      step : in natural;
      what : in string
    ) is
    begin

      assert ok
        report PROGRAM & ", instruction " & integer'image(step) & " (PC " & integer'image(expected_pc) & "): " & what
        severity failure;

    end procedure expect;

  begin

    expected_pc := 0;

    -- The reset is active-low. It is released between clock edges.
    wait until falling_edge(clk);
    clear <= '1';

    for i in EXPECTED'range loop

      wait for CLK_PERIOD / 4;

      expect(to_integer(unsigned(pc)) = expected_pc, i, "wrong PC " & integer'image(to_integer(unsigned(pc))));
      expect(instruction = EXPECTED(i).word, i, "fetched word differs from the listing");

      case EXPECTED(i).effect is

        when reg_write =>

          expect(reg_we = '1' and mem_we = '0', i, "expected a register write only");
          expect(to_integer(unsigned(reg_index)) = EXPECTED(i).index, i, "wrong destination register");
          expect(reg_data = EXPECTED(i).value, i,
                 "register data is " & integer'image(to_integer(unsigned(reg_data))) &
                 ", expected " & integer'image(to_integer(unsigned(EXPECTED(i).value))));

        when mem_write =>

          expect(mem_we = '1' and reg_we = '0', i, "expected a memory write only");
          expect(to_integer(unsigned(mem_addr)) = EXPECTED(i).index, i, "wrong memory address");
          expect(mem_data = EXPECTED(i).value, i,
                 "memory data is " & integer'image(to_integer(unsigned(mem_data))) &
                 ", expected " & integer'image(to_integer(unsigned(EXPECTED(i).value))));

        when pc_write =>

          expect(reg_we = '0' and mem_we = '0', i, "expected no register or memory write");

      end case;

      if (EXPECTED(i).effect = pc_write) then
        expected_next_pc := to_integer(unsigned(EXPECTED(i).value));
      else
        expected_next_pc := expected_pc + 2;
      end if;

      expect(to_integer(unsigned(next_pc)) = expected_next_pc, i,
             "next PC is " & integer'image(to_integer(unsigned(next_pc))) &
             ", expected " & integer'image(expected_next_pc));
      expected_pc := expected_next_pc;

      -- The clock stops after the last table entry: part_a and directed
      -- would otherwise run off the end of the memory, and part_b, branch
      -- and values end on a JMP to themselves (branch through xF20, which
      -- sets target bits 11:8), whose next PC is checked above.
      if (i < EXPECTED'high) then
        wait until falling_edge(clk);
      end if;

    end loop;

    report "cpu_3380_tb passed: " & PROGRAM & ", " & integer'image(EXPECTED'length) & " instructions";
    done <= true;
    wait;

  end process check;

end architecture sim;
