from math import isqrt
from typing import List, Optional

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def fib_rank(m: int) -> int:
    a, b = 0, 1
    for k in range(1, m * m + 1):
        a, b = b, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError("unreachable")

def prime_factors(n: int) -> List[int]:
    fs, d = [], 2
    while d * d <= n:
        if n % d == 0:
            fs.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        fs.append(n)
    return fs

def primitive_divisor(p: int) -> Optional[int]:
    """A primitive prime divisor of F_p for prime p >= 3 (rank(q) == p)."""
    F = fib(p)
    for q in prime_factors(F):
        if fib_rank(q) == p:
            return q
    return None  # unreachable by Theorem 7.1
