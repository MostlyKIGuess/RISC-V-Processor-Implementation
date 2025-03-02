#!/bin/bash

mkdir -p test_results

if [ $# -eq 0 ]; then
    echo "Usage: $0 <test_file>"
    exit 1
fi

TEST_FILE=$1

echo "Assembling test file..."
python3 testcases/assembler.py "$TEST_FILE"

echo "Compiling Verilog files..."
iverilog -o test_results/cpu_test \
    verilog/cpu_sequential.v \
    verilog/testbench_sequential.v \
    -I modules/

if [ $? -eq 0 ]; then
    echo "Compiled!"
    
    echo "Running sims haha get it?..."
    vvp test_results/cpu_test
    
    # if you wanna generate waveforms bruhhhh
    if [ -f test_results/cpu_sequential_test.vcd ]; then
        echo "Generating waveform..."
        gtkwave test_results/cpu_sequential_test.vcd &
    else
        echo "Error: Waveform file not generated"
    fi
else
    echo "Error: Compilation failed"
    exit 1
fi
