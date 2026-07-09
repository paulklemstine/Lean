from math import comb
from typing import List

def row_sums_direct(n_max: int) -> List[int]:
    """Naive double sum s(n) = sum_k C(n+k, 2k); O(n^2) total."""
    return [sum(comb(n + k, 2 * k) for k in range(n + 1)) for n in range(n_max + 1)]

def row_sums_recurrence(n_max: int) -> List[int]:
    """Fast s(n) via s(n+2) = 3 s(n+1) - s(n), s0=1, s1=2; O(n)."""
    s = [1, 2]
    while len(s) <= n_max:
        s.append(3 * s[-1] - s[-2])
    return s[: n_max + 1]

def fib_fast_doubling(n: int) -> int:
    """F(n) via fast doubling in O(log n)."""
    def fd(m: int):
        if m == 0:
            return (0, 1)
        a, b = fd(m >> 1)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if (m & 1) else (c, d)
    return fd(n)[0]

def row_sums_as_odd_fibonacci(n_max: int) -> List[int]:
    """s(n) = F(2n+1)."""
    return [fib_fast_doubling(2 * n + 1) for n in range(n_max + 1)]
