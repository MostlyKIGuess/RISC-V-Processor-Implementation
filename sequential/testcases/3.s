begin:
    addi x10, x0, 0
    ld x11, 0(x10)
    ld x12, 8(x10)
    addi x10, x10, 8
    ld x13, 0(x10)

exit:
    nop


# only works if you have the following in data memory
# EF
# CD
# AB
# 89
# 67
# 45
# 23
# 01
# 10
# 32
# 54
# 76
# 98
# BA
# DC
# FE
# EF
# CD
# AB
# 89
# 67
# 45
# 23
# 01