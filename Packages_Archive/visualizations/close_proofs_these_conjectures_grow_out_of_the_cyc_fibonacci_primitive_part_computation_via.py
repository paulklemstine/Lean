from math import gcd
from typing import List, Optional

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def primitive_part(n: int) -> int:
    """Primitive part of F_n: strip every prime already occurring in some F_d
    (d a proper divisor of n) using gcd(F_n, F_d) = F_gcd(n,d)."""
    r = fib(n)
    for d in (d for d in range(1, n) if n % d == 0):
        fd = fib(d)
        g = gcd(r, fd)
        while g > 1:
            r //= g
            g = gcd(r, fd)
    return r

def primitive_divisor(n: int) -> Optional[int]:
    """A primitive prime divisor of F_n, or None (only for n in {1,2,6,12})."""
    pp = primitive_part(n)
    if pp <= 1:
        return None
    m = pp
    p = 2
    while p * p <= m:
        if m % p == 0:
            return p
        p += 1
    return m
