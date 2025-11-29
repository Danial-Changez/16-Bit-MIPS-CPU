# 16-Bit MIPS CPU

This project implements a 16-bit MIPS CPU using VHDL in Vivado. It supports basic MIPS instructions across different instruction formats, with Part A implementing core ALU operations, load/store, and set-less-than instructions, while Part B adds branching and jump instructions. This CPU is designed to be tested with a preloaded instruction memory to verify correct execution of instructions.

## Table of Contents
- [Project Overview](#project-overview)
- [System Design](#system-design)
- [Instructions Implemented](#instructions-implemented)
- [Instruction Tracing](#instruction-tracing)
- [Verification](#verification)
- [Errors and Issues](#errors-and-issues)
- [Conclusion](#conclusion)
- [Usage](#usage)

## Project Overview

The objective was to build a hierarchical 16-bit MIPS CPU module by combining previously developed subsystems. The CPU is capable of handling R, I, and J instruction formats and supports operations like ALU-based computations, memory storage/loading, and conditional branching. The project was completed as a lab assignment, with verification done via testbenches using `Instr.txt` and `Instr2.txt` files.

## System Design

The CPU is organized with several core modules:

- **Program Counter (PC)**: Sequences instructions by updating the address sent to instruction memory. It increments by two bits each cycle.
- **Instruction Memory**: Stores a set of 16-bit instructions loaded from files. This module provides read-only access to instructions.
- **Control Module**: Decodes a 4-bit opcode to generate control signals, directing the CPU’s operations across registers, memory, and the ALU.
- **Sign Extend**: Extends 4-bit immediate values to 16 bits for I-type instructions.
- **Data Memory**: A 2D array that stores data processed by the ALU, with control signals for read and write operations.

### Additional Modules (Part B)
- **Branch if Not Equal (BNE)**: Conditional branching module that updates the PC based on the result of a comparison.
- **Jump Block**: Executes jumps to a new program address based on a 12-bit immediate value.
- **PC Control MUX**: Selects the next PC address based on inputs from the PC increment, BNE block, or Jump block.

### Block Diagram
<img width="913" height="578" alt="image" src="https://github.com/user-attachments/assets/17a470fd-73a6-43b1-b8e6-b6dec64e9279" />

## Instructions Implemented

The following instructions are supported:

| Opcode | Instruction | Description |
|--------|-------------|-------------|
| `0000` | ADD         | Adds two registers and stores result in destination register |
| `0001` | SUB         | Subtracts source register from destination register |
| `0010` | AND         | Bitwise AND operation between two registers |
| `0011` | OR          | Bitwise OR operation between two registers |
| `0100` | ADDI        | Adds immediate value to a register |
| `0101` | SUBI        | Subtracts immediate value from a register |
| `0111` | SLT         | Sets destination register if source is less than target |
| `1000` | LW          | Loads word from data memory to register |
| `1100` | SW          | Stores word from register to data memory |
| `1001` | BNE         | Branches to an offset if registers are not equal |
| `1010` | JMP         | Jumps to address specified by 12-bit immediate value |

## Instruction Tracing

Each instruction is executed by following the CPU's data flow:
1. **Fetch**: PC provides the address to fetch an instruction from memory.
2. **Decode**: Instruction is split into opcode, destination, source, and immediate values as applicable.
3. **Execute**: Depending on the instruction, operations are performed using ALU or memory modules.
4. **Write-back**: Resulting data is written to a register or memory location.

## Verification

Waveform simulation in Vivado verified the following:

- **Part A**: Tested with `Instr.txt`, covering basic ALU operations, load/store, and set-less-than instructions.
- **Part B**: Additional testing with `Instr2.txt`, which introduced branching and jump instructions.

Results matched expected values, confirming correct CPU behavior.

## Errors and Issues

- **Data Memory Offset Issue**: Initial misalignment in memory addressing was corrected after debugging.
- **Jump Instruction Error**: The Jump instruction initially bypassed certain instructions due to an incorrect offset calculation, which was later resolved.
- **Syntax Errors**: Minor syntax errors in VHDL code were encountered and resolved.

## Conclusion

This project successfully implemented a 16-bit MIPS CPU supporting both standard and branching instructions. The design demonstrated expected functionality during testbench simulations, making it a viable CPU model for executing a limited instruction set.

## Usage

1. **Prerequisites**: Vivado or a compatible VHDL simulation environment.
2. **Cloning the Repository**:
    ```bash
    git clone https://github.com/Danial-Changez/16-Bit-MIPS-CPU.git
    ```
3. **Simulating the Project**:
   - Open Vivado and load the project files.
   - Run the simulation with `Instr.txt`.
   - Verify the waveform outputs against expected results.

## Official Report

For a detailed analysis, design breakdown, and verification results, please refer to the official project report:

[16-Bit MIPS CPU Project Report (PDF)](Project%20Report.pdf)

This report includes:
- Problem statement and project objectives
- Assumptions, constraints, and design considerations
- Detailed descriptions of each module and their functions
- Instruction tracing and waveform analysis
- Errors encountered and solutions implemented
- Project conclusions and reflections

---

To access the report, you can either view it directly in this repository or download it to reference our complete project documentation.


## Contributors
- Muhammad Shayan
- Zain Siddiqui

---

This repository contains the HDL files and testbenches necessary to simulate the CPU’s functionality as described.
