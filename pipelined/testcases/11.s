start:
    load x1, 0(x0)    # Load n
    addi x2, x0, 0     # x2 = 0 (Fib(0))
    addi x3, x0, 1     # x3 = 1 (Fib(1))
    beq x1, x0, done   # If n == 0, return Fib(0)
    addi x1, x1, -1   # Decrement n by 1 to account for Fib(1)
    beq x1, x0, done1  # If n == 1, return Fib(1)

loop:
    add x4, x2, x3   # x4 = x2 + x3 (Fib(n) = Fib(n-1) + Fib(n-2))
    add x2, x3, x0    # x2 = x3 (shift Fib(n-1) to Fib(n-2))
    add x3, x4, x0    # x3 = x4 (shift Fib(n) to Fib(n-1))
    addi x1, x1, -1   # Decrement n
    beq x1, x0, done1  # Repeat until n == 0
    beq x0, x0, loop

done1:
    add x4, x3, x0    # Return Fib(1)

done:
    # x4 holds the Fibonacci result
    addi x0 x0 0
    nop
