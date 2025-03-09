# visualize_pipeline.sh
#!/bin/bash

mkdir -p test_results
mkdir -p visualization

# Check for test file argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <test_file>"
    exit 1
fi

TEST_FILE=$1

# Assemble the test file
echo "Assembling test file..."
python3 testcases/assembler.py "$TEST_FILE"

# Compile Verilog files
echo "Compiling Verilog files..."
iverilog -o test_results/cpu_test \
    verilog/cpu_pipelined.v \
    verilog/testbench_pipelined.v \
    -I modules/

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    
    # Run simulation and capture output
    echo "Running simulation..."
    vvp test_results/cpu_test | tee test_results/simulation_output.txt
    
    # Generate visualization data
    echo "Generating visualization data..."
    python3 visualization/parse-pipeline.py test_results/simulation_output.txt
    
    # Open visualization in browser
    echo "Opening visualization in browser..."
    xdg-open visualization/index.html 2>/dev/null || \
    open visualization/index.html 2>/dev/null || \
    echo "Please open visualization/index.html in your browser manually"
    
    echo "Visualization complete!"
else
    echo "Compilation failed."
    exit 1
fi