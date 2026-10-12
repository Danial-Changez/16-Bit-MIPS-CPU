# 16-Bit MIPS-Style CPU

A single-cycle, 16-bit MIPS-style CPU in VHDL: program counter, instruction
memory, control unit, 16-register file, ripple-carry ALU, sign extension and
data memory. It was the final project of a computer organization course
(ENGG 3380) and is a **three-person group project**; see
[Contributors](#contributors).

It implements eleven instructions: arithmetic, logic, set-less-than, load,
store, branch if not equal and jump.

## Origin of the code

- The top level `cpu_3380.vhd` started from a skeleton supplied by the
  course, with numbered to-do markers that the group filled in.
- The building blocks (gates, full adder, ALU, muxes, register file, control,
  sign extension) were written in earlier labs of the same course and
  combined here.
- A later cleanup (layout, formatting, `numeric_std`, latch removal,
  testbench, CI) is separate from the course work. The Git history shows
  which commits are which.
- `BNE` and `JMP` were added after the course, following the report's
  Part B (see below); the group's Part B code was never in this
  repository.

## Instructions implemented

A 16-bit instruction is `opcode[15:12] rd[11:8] rs[7:4] rt/imm[3:0]`, or
`opcode[15:12] target[11:0]` for `JMP`. The 4-bit immediate is
sign-extended (-8 to 7), except in `BNE`, where it is an unsigned byte
offset (0 to 15; only even values keep the PC aligned).

| Opcode | Instruction | Effect |
|--------|-------------|--------|
| `0000` | `ADD rd, rs, rt` | `rd = rs + rt` |
| `0001` | `SUB rd, rs, rt` | `rd = rs - rt` |
| `0010` | `AND rd, rs, rt` | `rd = rs and rt` |
| `0011` | `OR rd, rs, rt` | `rd = rs or rt` |
| `0100` | `ADDI rd, rs, imm` | `rd = rs + imm` |
| `0101` | `SUBI rd, rs, imm` | `rd = rs - imm` |
| `0111` | `SLT rd, rs, rt` | `rd = 1` if bit 15 of `rs - rt` is set, else `0` |
| `1000` | `LW rd, imm(rs)` | `rd = mem[rs + imm]` (16-bit word) |
| `1001` | `BNE rd, rs, imm` | if `rs - rd` is not zero, `PC = PC + 2 + imm`; else `PC = PC + 2` |
| `1011` | `JMP target` | `PC = PC[15:12] & target`, with `PC` the address of the `JMP` |
| `1100` | `SW rd, imm(rs)` | `mem[rs + imm] = rd` (16-bit word) |

That is the complete list. Every other opcode falls into the control unit's
default case, which writes nothing.

`BNE` and `JMP` are the project report's "Part B". Its VHDL listings for a
BNE block, a jump block and a PC multiplexer, and its test program
`Instr2.txt`, were never committed here, so the two instructions were
rebuilt from the report: the opcodes from its Part B table and waveforms,
the offset added unchanged to `PC + 2` as in its BNE listing, and the top
four PC bits kept as in its jump listing.

## Design

<img width="913" height="578" alt="Block diagram from the project report" src="https://github.com/user-attachments/assets/17a470fd-73a6-43b1-b8e6-b6dec64e9279" />

The diagram is taken from the report. The hand-drawn Jump, BNE and 3-1 MUX
blocks at the bottom are Part B: in `cpu_3380.vhd` they are the
`jump_target` and `branch_target` assignments and a `mux3_1` instance.

- **Program counter** (`pc_reg.vhd`): 16-bit register with an asynchronous,
  active-low reset (`clear`). The next value is `PC + 2`, the jump target or
  the branch target, chosen by the control unit's `pc_src`.
- **Memories** (`memory.vhd`, instantiated twice): 34 bytes each, so 17
  instructions or 17 data words, low byte first. Asynchronous read,
  synchronous write. Contents are loaded from the text files `Instr.txt`
  and `in.txt` in the simulator's working directory.
- **Control** (`control.vhd`): decodes the opcode into the ALU operation,
  the mux selects (including the next-PC select) and the register and
  memory write enables.
- **Register file** (`registers.vhd`): sixteen 16-bit registers. `r0` always
  reads 0 and `r1` always reads 1; writes to them are ignored.
- **ALU** (`alu_16bit.vhd`, `alu.vhd`): sixteen one-bit slices with a ripple
  carry; add, subtract, AND, OR.
- **Sign extend** (`signextend.vhd`), **muxes** (`mux2_1.vhd`, `mux3_1.vhd`,
  `mux31.vhd`).

The top level has only inputs (`clk`, `clear`, `mem_dump`), so results can
be observed in simulation only.

## Repository layout

```
rtl/            the CPU and its building blocks, one entity per file
tb/             testbench, and one directory of memory images per program
scripts/        test runner
docs/           project report
```

## Verification

```sh
scripts/run_tests.sh
```

needs GHDL on the `PATH` (or `GHDL=/path/to/ghdl`). To run it in the
container CI uses:

```sh
docker run --rm -v "$PWD":/src -w /src ghdl/ghdl:5.0.1-mcode-ubuntu-24.04 sh scripts/run_tests.sh
```

The script

1. analyses all VHDL with `--std=08 -Wall -Wno-delayed-checks -Werror`
   (the one disabled warning only says that a check on the memory's
   file-reading function is deferred to elaboration);
2. runs `ghdl --synth` on the CPU, which fails if a latch is inferred;
3. runs `tb/cpu_3380_tb.vhd` on five programs.

The testbench releases reset and, before every clock edge, compares the PC,
the fetched instruction word, the pending register or memory write
(destination and value) and the next PC with an expected trace. The first
mismatch ends the run with a non-zero exit status.

| Program | What it is |
|---------|------------|
| `tb/part_a` | The program supplied with the course project, unchanged: 15 instructions using `ADDI`, `SLT`, `SW`, `LW`, `ADD`, `OR`, `SUBI` and `SUB`. |
| `tb/directed` | 17 instructions written for this testbench: the nine Part A opcodes with operands that tell the operations apart, negative immediates, a negative store offset, a load of the initial data memory contents, and writes to `r0` and `r1`. |
| `tb/part_b` | The report's Part B program, rebuilt from its instruction table and waveform: a loop closed by `JMP` and left by `BNE`, 36 instructions executed. Two words the report does not show were filled in: at PC 12, which the jump skips, a store that would change the value loaded next, and at PC 32 a halt (`JMP 32`). |
| `tb/branch` | 17 instructions written for this testbench: `BNE` taken and not taken, offsets 0 and 14, `r0` against `r1`, a difference only in bit 4, forward and backward jumps, back-to-back transfers, stores that a taken branch skips, and a halt through a jump target with bits 11:8 set. |
| `tb/values` | Written for this testbench, 13 instructions executed: `BNE` on equal negative values and on the same register twice (not taken), and on differences of `0x8000`, `0xFF00`, `1`, `2` and `0xFFFF` (taken), with the operands loaded from data memory. |

Register and memory writes are checked as requests on the write ports; the
stored values are confirmed by later instructions that read them back.

Not covered: opcodes outside the eleven, loads with a negative offset or
right after an instruction in subtract mode or with an ALU result above 32
(see below), `SLT` when the subtraction overflows, odd branch offsets, and
jumps from an address above `0x0FFF`, so keeping the top four PC bits is
untested (the 34-byte memory cannot reach one).

Style check:

```sh
pip install vsg==3.35.0
vsg -c vsg.yaml
```

The VHDL follows the rule set documented by
[VHDL Style Guide](https://vhdl-style-guide.readthedocs.io) (vsg defaults).
`vsg.yaml` lists the few rules that deviate and why.

GitHub Actions runs the style check and `scripts/run_tests.sh` on every push
and pull request.

To simulate in Vivado instead, add `rtl/*.vhd` and `tb/cpu_3380_tb.vhd` to a
new project, set the testbench to VHDL-2008, add the two files of one
program directory as simulation sources and set the `PROGRAM` generic to
match. This flow has not been tried with the new testbench.

## Known limitations

- No halt instruction. A program either runs off the end of the
  instruction memory or ends in a `JMP` to its own address.
- `BNE` branches forward only, by at most 15 bytes.
- `memory.vhd` indexes its 34 bytes with eight address bits and no range
  check, and reads asynchronously. In simulation an address above 32 is a
  fatal error, including one that appears only while the ripple-carry ALU
  is settling. The testbench therefore stops the clock after the last
  instruction and uses loads with small non-negative addresses. A load
  with a negative offset aborts this way, and so can a load right after an
  instruction in subtract mode (`SUB`, `SUBI`, `SLT`, `BNE`) or one whose
  ALU result is above 32. That includes `JMP`, whose ALU adds the
  registers named by target bits 7:4 and 3:0: a load right after a `JMP`
  can abort when those two registers sum to more than 32.
- `SLT` takes the sign bit of `rs - rt`, so the result is wrong when that
  subtraction overflows.
- The `mem_dump` input and the memory's `OUTPUT` generic are unused; the
  skeleton's memory-dump code was never enabled.

## Project report

[docs/project_report.pdf](docs/project_report.pdf) is the group's original
report: design description, per-instruction tracing, Vivado waveforms and
the Part B material mentioned above. Its cover page, which listed student
numbers, has been removed; the rest is unchanged.

## Contributors

- Muhammad Shayan
- Zain Siddiqui
- Danial Changez (repository owner)
