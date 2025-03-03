start:
    addi x10, x0, 20  # Load n
    addi x11, x0, 1   # x11 = 1 (accumulator for factorial)
    beq x10, x0, done # If n == 0, factorial is 1

loop:
    add x12, x0, x11  # x12 = x11 (initialize for multiplication)
    add x13, x0, x10  # x13 = x10 (multiplier counter)
    addi x11, x0, 0   # Reset x11 to 0

mul_loop:
    beq x13, x0, end_mul # If x13 == 0, end multiplication
    add x11, x11, x12    # x11 = x11 + x12 (multiplication by addition)
    addi x13, x13, -1    # Decrement multiplier counter
    beq x0, x0, mul_loop # Continue multiplication loop

end_mul:
    addi x10, x10, -1 # Decrement x10 by 1
    beq x10, x0, done # If x10 != 0, repeat loop
    beq x0, x0, loop

done:
    # x11 holds the factorial result
    nop               # End program (can replace with ecall to exit in real environment)
