from math import gcd
from typing import List


def fib(n: int) -> int:
    """F(0)=0, F(1)=1, F(n+2)=F(n+1)+F(n)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def proper_divisors(n: int) -> List[int]:
    """All d with 0 < d < n and d | n."""
    return [d for d in range(1, n) if n % d == 0]


def strip_all(r: int, m: int) -> int:
    """Repeatedly divide out gcd(r, m) until r and m are coprime."""
    if m <= 1:
        return r
    while True:
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g


def prim_part(n: int) -> int:
    """Primitive part of F(n): start from F(n) and strip every prime shared with
    F(d) for each proper divisor d of n.  Returns a divisor of F(n) coprime to
    every F(d); if it exceeds 1, its prime factors are all primitive for F(n)."""
    r = fib(n)
    for d in proper_divisors(n):
        r = strip_all(r, fib(d))
    return r
