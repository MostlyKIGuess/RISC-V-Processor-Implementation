# RISC-V Implementation in Verilog

## Sequential Implementation

Add the assembly code in the `sequential/testcases` directory and run the following commands to test the code. A few examples are provided there already to refer to syntax. `sequential/modules/data_memory.hex` contains the data memory, which is long term.

```bash
cd sequential
chmod +x test_sequential.sh
./test_sequential.sh <filename>.s
```


NOTES: 
- `ld` and `sd` are used to load and store double words. But, they use the same instructions as `lw` and `sw` that are not implemented in this version.
- Since data memory only supports 64 bit read and write, remember to only use addresses that are multiples of 8.