# RISC-V Implementation in Verilog

## Sequential Implementation

Add the assembly code in the `sequential/testcases` directory and run the following commands to test the code. A few examples are provided there already to refer to syntax.

```bash
cd sequential
chmod +x test_sequential.sh
./test_sequential.sh <filename>.s
```


NOTE: `ld` and `sd` are used to load and store double words. But, they use the same instructions as `lw` and `sw` that are not implemented in this version.