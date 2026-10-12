#!/bin/sh
# Analyses the VHDL with GHDL, checks that it synthesises without latches
# and runs the self-checking testbench on each program.
# Exits non-zero on the first warning, error or failed assertion.
#
#   scripts/run_tests.sh                 uses ghdl from PATH
#   GHDL=/path/to/ghdl scripts/run_tests.sh
set -eu
cd "$(dirname "$0")/.."

GHDL=${GHDL:-ghdl}
STD=--std=08
# -Wdelayed-checks is only a notice that GHDL checks memory.vhd's
# file-reading function at elaboration instead of at analysis.
STRICT="$STD -Wall -Wno-delayed-checks -Werror"
WORK=$PWD/build/ghdl
rm -rf build/ghdl
mkdir -p "$WORK"

echo "== Analysis"
$GHDL -a $STRICT --workdir="$WORK" \
  rtl/and_gate.vhd \
  rtl/or_gate.vhd \
  rtl/full_adder.vhd \
  rtl/mux31.vhd \
  rtl/alu.vhd \
  rtl/alu_16bit.vhd \
  rtl/mux2_1.vhd \
  rtl/mux3_1.vhd \
  rtl/signextend.vhd \
  rtl/registers.vhd \
  rtl/memory.vhd \
  rtl/pc_reg.vhd \
  rtl/control.vhd \
  rtl/cpu_3380.vhd \
  tb/cpu_3380_tb.vhd

# The memories load Instr.txt and in.txt from the current directory.
for program in part_a directed part_b branch values; do
  cd "tb/$program"
  if [ "$program" = part_a ]; then
    echo "== Synthesis check: ghdl --synth fails on an inferred latch"
    $GHDL --synth $STD --workdir="$WORK" cpu_3380 > /dev/null
  fi
  echo "== Testbench: $program"
  # IEEE package warnings at time 0 come from signals not yet driven.
  $GHDL --elab-run $STD --workdir="$WORK" cpu_3380_tb "-gPROGRAM=$program" \
    --assert-level=error --ieee-asserts=disable-at-0
  cd ../..
done

echo "== All tests passed"
