from math import gcd
from typing import Dict

def lcm(a: int, b: int) -> int:
    return 0 if a == 0 or b == 0 else a // gcd(a, b) * b

def prime_factorization(m: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors

def fib_entry_scan(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0, 1
    k = 0
    while True:
        k += 1
        a, b = b % m, (a + b) % m
        if a == 0:
            return k

def fib_entry_crt(m: int) -> int:
    """alpha(m) = lcm over prime-power factors (Algorithm 5.1)."""
    if m == 1:
        return 1
    result = 1
    for p, e in prime_factorization(m).items():
        result = lcm(result, fib_entry_scan(p ** e))
    return result
