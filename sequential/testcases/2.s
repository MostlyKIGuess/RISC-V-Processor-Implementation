begin:
    addi x1, x0, 5
    addi x2, x0, 2
    add x3, x0, x0

outer_loop:
    beq x1, x0, exit
    addi x4, x2, 0

inner_loop:
    beq x4, x0, end_inner
    add x3, x3, x1
    addi x4, x4, -1
    beq x0, x0, inner_loop

end_inner:
    addi x1, x1, -1
    beq x0, x0, outer_loop

exit:
    nop
