library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity cpu_3380 is
  port (
    clk      : in    std_logic;
    clear    : in    std_logic;
    mem_dump : in    std_logic
  );
end entity cpu_3380;

architecture behavioral of cpu_3380 is

  component alu_16bit is
    port (
      a    : in    std_logic_vector(15 downto 0);
      b    : in    std_logic_vector(15 downto 0);
      s    : in    std_logic_vector(1 downto 0);
      sout : out   std_logic_vector(15 downto 0);
      cout : out   std_logic
    );
  end component alu_16bit;

  component registers is
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
  end component registers;

  component control is
    port (
      op        : in    std_logic_vector( 3 downto 0);
      alu_op    : out   std_logic_vector( 1 downto 0);
      alu_src   : out   std_logic;
      reg_dest  : out   std_logic;
      reg_load  : out   std_logic;
      reg_src   : out   std_logic_vector( 1 downto 0);
      mem_read  : out   std_logic;
      mem_write : out   std_logic;
      pc_src    : out   std_logic_vector( 1 downto 0)
    );
  end component control;

  component signextend is
    port (
      immin  : in    std_logic_vector( 3 downto 0);
      immout : out   std_logic_vector(15 downto 0)
    );
  end component signextend;

  component mux3_1 is
    generic (
      WIDTH : positive := 16
    );
    port (
      input1 : in    std_logic_vector(WIDTH - 1   downto 0);
      input2 : in    std_logic_vector(WIDTH - 1   downto 0);
      input3 : in    std_logic_vector(WIDTH - 1   downto 0);
      s      : in    std_logic_vector(1       downto 0);
      sout   : out   std_logic_vector(WIDTH - 1   downto 0)
    );
  end component mux3_1;

  component mux2_1 is
    generic (
      WIDTH : positive := 16
    );
    port (
      input1 : in    std_logic_vector(WIDTH - 1   downto 0);
      input2 : in    std_logic_vector(WIDTH - 1   downto 0);
      s      : in    std_logic;
      sout   : out   std_logic_vector(WIDTH - 1   downto 0)
    );
  end component mux2_1;

  component memory is
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
  end component memory;

  component pc_reg is
    port (
      clk    : in    std_logic;
      reset  : in    std_logic;
      input  : in    std_logic_vector(15 downto 0);
      output : out   std_logic_vector(15 downto 0)
    );
  end component pc_reg;

  signal instruction : std_logic_vector(15 downto 0);
  signal op          : std_logic_vector( 3 downto 0);
  signal rd          : std_logic_vector( 3 downto 0);
  signal rs          : std_logic_vector( 3 downto 0);
  signal rt          : std_logic_vector( 3 downto 0);

  signal alu_result       : std_logic_vector(15 downto 0);
  signal alu_src_mux_out  : std_logic_vector(15 downto 0);
  signal sign_ex_out      : std_logic_vector(15 downto 0);
  signal rs_data          : std_logic_vector(15 downto 0);
  signal rt_data          : std_logic_vector(15 downto 0);
  signal cout             : std_logic;
  signal reg_dest_mux_out : std_logic_vector( 3 downto 0);
  signal reg_src_mux_out  : std_logic_vector(15 downto 0);

  signal ctrl_alu_src   : std_logic;
  signal ctrl_alu_op    : std_logic_vector( 1 downto 0);
  signal ctrl_reg_dest  : std_logic;
  signal ctrl_reg_src   : std_logic_vector( 1 downto 0);
  signal ctrl_reg_load  : std_logic;
  signal ctrl_mem_read  : std_logic;
  signal ctrl_mem_write : std_logic;
  signal ctrl_pc_src    : std_logic_vector( 1 downto 0);

  signal slt_input : std_logic_vector(15 downto 0);

  signal reg_src_mux_input3 : std_logic_vector(15 downto 0);
  signal pc_plus_2          : std_logic_vector(15 downto 0);
  signal pc_reg_output      : std_logic_vector(15 downto 0);
  signal jump_target        : std_logic_vector(15 downto 0);
  signal branch_target      : std_logic_vector(15 downto 0);
  signal pc_src_mux_out     : std_logic_vector(15 downto 0);

begin

  -- Instruction Fetch

  pc_plus_2 <= std_logic_vector(unsigned(pc_reg_output) + 2);

  -- JMP keeps the top four bits of its own address.
  jump_target <= pc_reg_output(15 downto 12) & instruction(11 downto 0);

  -- BNE: the ALU computes rs - rd. The offset is unsigned and counts bytes.
  branch_target <= std_logic_vector(unsigned(pc_plus_2) + unsigned(rt)) when alu_result /= x"0000" else
                   pc_plus_2;

  cpu_pc_src_mux : component mux3_1
    generic map (
      WIDTH => 16
    )
    port map (
      input1 => pc_plus_2,
      input2 => jump_target,
      input3 => branch_target,
      s      => ctrl_pc_src,
      sout   => pc_src_mux_out
    );

  cpu_pc : component pc_reg
    port map (
      clk    => clk,
      reset  => clear,
      input  => pc_src_mux_out,
      output => pc_reg_output
    );

  cpu_instr_mem : component memory
    generic map (
      INPUT => "Instr.txt"
    )
    port map (
      clk      => clk,
      read_en  => '1',
      write_en => '0',
      addr     => pc_reg_output,
      data_in  => x"0000",
      data_out => instruction,
      mem_dump => '0'
    );

  op <= instruction(15 downto 12);
  rd <= instruction(11 downto  8);
  rs <= instruction(7  downto  4);
  rt <= instruction(3  downto  0);
  -- Instruction Decode

  cpu_control_0 : component control
    port map (
      op        => op,
      alu_op    => ctrl_alu_op,
      alu_src   => ctrl_alu_src,
      reg_dest  => ctrl_reg_dest,
      reg_load  => ctrl_reg_load,
      reg_src   => ctrl_reg_src,
      mem_read  => ctrl_mem_read,
      mem_write => ctrl_mem_write,
      pc_src    => ctrl_pc_src
    );

  cpu_registers_0 : component registers
    port map (
      clk    => clk,
      clear  => clear,
      a_addr => rd,
      a_data => reg_src_mux_out,
      load   => ctrl_reg_load,
      b_addr => rs,
      c_addr => reg_dest_mux_out,
      b_data => rs_data,
      c_data => rt_data
    );

  cpu_signextend_0 : component signextend
    port map (
      immin  => rt,
      immout => sign_ex_out
    );

  cpu_reg_dest_mux : component mux2_1
    generic map (
      WIDTH => 4
    )
    port map (
      input1 => rt,
      input2 => rd,
      s      => ctrl_reg_dest,
      sout   => reg_dest_mux_out
    );

  -- Execute
  cpu_alu_src_mux : component mux2_1
    generic map (
      WIDTH => 16
    )
    port map (
      input1 => rt_data,
      input2 => sign_ex_out,
      s      => ctrl_alu_src,
      sout   => alu_src_mux_out
    );

  cpu_alu_0 : component alu_16bit
    port map (
      a    => rs_data,
      b    => alu_src_mux_out,
      s    => ctrl_alu_op,
      sout => alu_result,
      cout => cout
    );

  -- Memory

  cpu_mem_0 : component memory
    port map (
      clk      => clk,
      read_en  => ctrl_mem_read,
      write_en => ctrl_mem_write,
      addr     => alu_result,
      data_in  => rt_data,
      data_out => reg_src_mux_input3,
      mem_dump => '0'
    );

  -- Write Back

  -- SLT writes the sign bit of rs - rt. Signed overflow is not corrected.
  slt_input <= "000000000000000" & alu_result(15);

  cpu_reg_src_mux : component mux3_1
    generic map (
      WIDTH => 16
    )
    port map (
      input1 => reg_src_mux_input3,
      input2 => alu_result,
      input3 => slt_input,
      s      => ctrl_reg_src,
      sout   => reg_src_mux_out
    );

end architecture behavioral;
