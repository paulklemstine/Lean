from math import gcd
from typing import Dict, Optional

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def least_prime_factor(n: int) -> int:
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n

def certify_primitive_divisor(n: int) -> Optional[int]:
    """Return a primitive prime divisor of F(n) certified by the primitive-part
    construction, or None if primPart(n) == 1 (no certificate)."""
    from math import gcd as _gcd
    r = fib(n)
    for d in (x for x in range(1, n) if n % x == 0):
        m = fib(d)
        while True:
            g = _gcd(r, m)
            if g <= 1:
                break
            r //= g
    if r <= 1:
        return None
    return least_prime_factor(r)
