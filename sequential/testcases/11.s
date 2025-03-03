start:
    addi x10, x0, 10    # Load n
    addi x11, x0, 0     # x11 = 0 (Fib(0))
    addi x12, x0, 1     # x12 = 1 (Fib(1))
    beq x10, x0, done   # If n == 0, return Fib(0)
    addi x10, x10, -1   # Decrement n by 1 to account for Fib(1)
    beq x10, x0, done1  # If n == 1, return Fib(1)

loop:
    add x13, x11, x12   # x13 = x11 + x12 (Fib(n) = Fib(n-1) + Fib(n-2))
    add x11, x12, x0    # x11 = x12 (shift Fib(n-1) to Fib(n-2))
    add x12, x13, x0    # x12 = x13 (shift Fib(n) to Fib(n-1))
    addi x10, x10, -1   # Decrement n
    beq x10, x0, done1  # Repeat until n == 0
    beq x0, x0, loop

done1:
    add x13, x12, x0    # Return Fib(1)

done:
    # x13 holds the Fibonacci result
    nop
