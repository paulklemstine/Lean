from math import isqrt
from typing import List, Optional, Tuple

def fib(n: int) -> int:
    def _fd(k: int) -> Tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = _fd(k >> 1)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if k & 1 else (c, d)
    return _fd(n)[0]

def fib_rank(m: int) -> int:
    if m == 1:
        return 1
    a, b, k = 0, 1, 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k

def prime_factors(n: int) -> List[int]:
    out: List[int] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            out.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out.append(n)
    return out

def primitive_prime_divisor(p: int) -> Optional[int]:
    """For a prime p >= 3, return a prime q dividing F_p with rank(q) = p.
    Such a q exists by the prime case of Carmichael's theorem and is a
    primitive prime divisor of F_p (it divides no earlier Fibonacci number)."""
    fp = fib(p)
    for q in prime_factors(fp):
        if fib_rank(q) == p:
            return q
    return None
