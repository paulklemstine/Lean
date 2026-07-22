from __future__ import annotations
from math import isqrt

def has_proper_divisor(n: int) -> bool:
    return any(n % d == 0 for d in range(2, n))

def trial_prime(n: int) -> bool:
    return n >= 2 and not has_proper_divisor(n)

def trial_prime_fast(n: int) -> bool:
    if n < 2:
        return False
    return all(n % d != 0 for d in range(2, isqrt(n) + 1))
