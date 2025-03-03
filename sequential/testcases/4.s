
begin:
    addi x7, x0, 10    # Load value 10
    addi x8, x0, 20    # Load value 20

    addi x5, x0, 5

    sd x7, 0(x5)       # Store 10 at memory[0]
    sd x8, 8(x5)       # Store 20 at memory[8]
    
exit:
    nop

