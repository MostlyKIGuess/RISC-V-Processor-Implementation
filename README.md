
# RISC-V Implementation in Verilog


## Sequential Implementation

Add the assembly code in the `sequential/testcases` directory and run the following commands to test the code. A few examples are provided there already to refer to syntax. `sequential/modules/data_memory.hex` contains the data memory, which is long term.

```bash
cd sequential
chmod +x test_sequential.sh
./test_sequential.sh <filename>.s
```

PS: I recommend testing 2.s ( a really long programme that checks all the ALU funciton) and 5.s ( has all the instructions.)
```bash
./test_sequential.sh 5.s
./test_sequential.sh 2.s
```


### NOTES: 
- `ld` and `sd` are used to load and store double words. But, they use the same instructions as `lw` and `sw` that are not implemented in this version.
- Since data memory only supports 64 bit read and write, remember to only use addresses that are multiples of 8.

## Web visulization:
- if doesn't run by doing the test_sequential.sh otherwise it should just open a web browser
```bash
cd sequential
mkdir -p visualization test_results
chmod +x visualize.sh
```

## Reset Memory
- To make the .hex file all 0s.
```sh
./reset_memory.sh
```


## Project Structure

- [pipelined/](pipelined/)
  - Holds the pipelined Verilog implementation ([cpu_pipelined.v](pipelined/verilog/cpu_pipelined.v)) and testbench.
  - [simulations/](pipelined/simulations/) includes simulation logs and waveforms.
- [report/](report/)
  - Contains the LaTeX and PDF files ([design_report.tex](report/design_report.tex), [design_report.pdf](report/design_report.pdf)).
- [sequential/](sequential/)
  - Houses the single-cycle Verilog files, test scripts, and memory files ([data_memory.v](sequential/modules/data_memory.v), [instruction_memory.v](sequential/modules/instruction_memory.v)).
  - [testcases/](sequential/testcases/) holds example assembly programs (e.g., [1.s](sequential/testcases/1.s)).
  - [visualization/](sequential/visualization/) includes the visualization page ([index.html](sequential/visualization/index.html)), JavaScript ([visualizer.js](sequential/visualization/visualizer.js)) and CSS ([styles.css](sequential/visualization/styles.css)).
  - [test_sequential.sh](sequential/test_sequential.sh) runs the Verilog testbench on a specified .s file.
  - [reset_memory.sh](sequential/reset_memory.sh) resets the data memory to all zeros.
- [README.md](README.md)
  - Main documentation with setup instructions.
