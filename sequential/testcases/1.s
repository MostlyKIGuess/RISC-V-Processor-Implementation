begin:
    addi x1, x0, 3
    addi x2, x0, 7

loop:
    beq x1, x0, exit
    add x2, x2, x1
    addi x1, x1, -1
    beq x0, x0, loop

exit:
    nop