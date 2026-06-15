from typing import List

def fib_entry(m: int, limit: int = 100_000) -> int:
    """Rank of apparition alpha(m): least k>0 with m | F(k), via residue scan."""
    if m <= 0:
        raise ValueError("m must be positive")
    if m == 1:
        return 1
    a, b = 0, 1  # (F(0), F(1)) mod m
    for k in range(1, limit + 1):
        a, b = b % m, (a + b) % m  # now a = F(k) mod m
        if a == 0:
            return k
    return 0
