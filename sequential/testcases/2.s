begin:
    addi x1, x0, 5          # x1 = 5
    addi x2, x0, 2          # x2 = 2
    add x3, x0, x0          # x3 = 0 (accumulator)

outer_loop:
    beq x1, x0, exit        # if x1 == 0, exit
    addi x4, x2, 0          # x4 = x2 (initialize inner loop counter)

inner_loop:
    beq x4, x0, end_inner   # if x4 == 0, end inner loop
    add x3, x3, x1          # x3 = x3 + x1
    addi x4, x4, -1         # decrement x4 by 1
    beq x0, x0, inner_loop  # continue inner loop

end_inner:
    addi x1, x1, -1         # decrement x1 by 1
    beq x0, x0, outer_loop  # continue outer loop

exit:
    nop
