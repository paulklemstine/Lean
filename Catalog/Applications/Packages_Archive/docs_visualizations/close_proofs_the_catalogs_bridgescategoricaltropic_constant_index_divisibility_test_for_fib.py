from typing import Optional

def fib_divides_value(m: int, n: int) -> bool:
    """Decide whether m | F(n) WITHOUT computing F(n).

    By the law of apparition, m | F(n) <=> z(m) | n. This reduces a divisibility
    question about a possibly astronomically large Fibonacci value to a single
    integer division on the index n.
    """
    z = fib_rank(m)
    return n % z == 0

def fib_rank(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0 % m, 1 % m
    k = 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k
