from math import gcd
from functools import lru_cache


@lru_cache(maxsize=None)
def fib(n: int) -> int:
    """n-th Fibonacci number, F(0)=0, F(1)=1."""
    if n < 2:
        return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def fib_divides(m: int, n: int) -> bool:
    """Decide whether F(m) divides F(n) using ONLY the indices (m >= 3).

    Correctness: Theorem 3.3, F(m) | F(n) <=> m | n for m >= 3.
    Cost: O(1) integer operations, independent of the size of F(m), F(n).
    """
    if m < 3:
        raise ValueError("characterization valid only for m >= 3")
    return n % m == 0


def fib_gcd(m: int, n: int) -> int:
    """Return gcd(F(m), F(n)) via the index gcd (Theorem 3.1)."""
    return fib(gcd(m, n))
