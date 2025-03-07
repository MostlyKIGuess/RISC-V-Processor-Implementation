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
    verilog/cpu_pipelined.v \
    verilog/testbench_pipelined.v \
    -I modules/


if [ $? -eq 0 ]; then
    echo "Compiled!"
    
    echo "Running sims haha get it?..."
    
    vvp test_results/cpu_test | tee test_results/simulation_output.txt
    
    # if you wanna generate waveforms bruhhhh
    if [ -f test_results/cpu_pipelined_test.vcd ]; then
        echo "Generating waveform..."
        gtkwave -A --rcvar 'fontname_signals Monospace 12' --rcvar 'fontname_waves Monospace 12' test_results/cpu_pipelined_test.vcd &
    else
        echo "Error: Waveform file not generated"
    fi

else
    echo "Error: Compilation failed"
    exit 1
fi
