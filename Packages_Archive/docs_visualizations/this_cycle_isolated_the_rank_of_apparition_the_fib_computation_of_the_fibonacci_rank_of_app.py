def fib_rank(m: int) -> int:
    """Least k > 0 with m | F_k. Existence holds for every m >= 1."""
    if m < 1:
        raise ValueError("modulus must be positive")
    a, b = 0, 1            # (F_0 mod m, F_1 mod m)
    for k in range(1, m * m + 1):
        a, b = b, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError("unreachable: rank must exist below m^2")
