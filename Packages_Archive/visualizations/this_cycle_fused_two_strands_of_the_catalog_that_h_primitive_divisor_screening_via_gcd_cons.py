from __future__ import annotations
from math import gcd
from typing import List, Optional

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def proper_divisors(n: int) -> List[int]:
    return [d for d in range(1, n) if n % d == 0]

def primitive_part(n: int) -> int:
    r: int = fib(n)
    for d in proper_divisors(n):
        fd = fib(d)
        if fd <= 1:
            continue
        g = gcd(r, fd)
        while g > 1:
            r //= g
            g = gcd(r, fd)
    return r

def smallest_prime_factor(m: int) -> int:
    d = 2
    while d * d <= m:
        if m % d == 0:
            return d
        d += 1
    return m

def primitive_divisor(n: int) -> Optional[int]:
    r = primitive_part(n)
    if r <= 1:
        return None
    return smallest_prime_factor(r)