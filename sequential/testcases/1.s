begin:
    addi x1, x0, 3      # x1 = 3
    addi x2, x0, 7      # x2 = 7

loop:
    beq x1, x0, exit    # if x1==0, end program
    add x2, x2, x1      # x2 = x1 + x2
    addi x1, x1, -1     # x1--
    beq x0, x0, loop    # loop

exit:
    nop