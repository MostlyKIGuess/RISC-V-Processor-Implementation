begin:
    addi x6, x0, 10

    addi x7, x0, 0
    addi x8, x0, 1024

    sd x6 0(x7)
    sd x6 0(x8)

end:
    nop