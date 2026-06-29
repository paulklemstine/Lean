def fib_rank_direct(m: int) -> int:
    """Least k > 0 with m | F(k), via the shift permutation walk."""
    if m <= 0:
        raise ValueError("modulus must be positive")
    if m == 1:
        return 1
    a, b, k = 0 % m, 1 % m, 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k
