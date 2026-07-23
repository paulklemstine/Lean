from math import gcd
from typing import List, Optional


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def min_prime_factor(n: int, trial_bound: int = 5_000_000) -> int:
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n and d <= trial_bound:
        if n % d == 0:
            return d
        d += 2
    return n  # n is prime (or has no small factor)


def proper_divisors(n: int) -> List[int]:
    return [d for d in range(1, n) if n % d == 0]


def strip_all(r: int, m: int) -> int:
    if m <= 1:
        return r
    while True:
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g


def prim_part(n: int) -> int:
    r = fib(n)
    for d in proper_divisors(n):
        r = strip_all(r, fib(d))
    return r


def primitive_witness(n: int) -> Optional[int]:
    """Explicit primitive prime divisor of F(n) for n >= 3, via the two-pillar
    proof: the prime-index theorem for prime n, the primitive-part certificate
    otherwise.  Returns None exactly on the exceptional indices {6, 12}."""
    if n < 3:
        return None
    if is_prime(n):
        return min_prime_factor(fib(n))     # prime-index theorem
    pp = prim_part(n)
    if pp > 1:
        return min_prime_factor(pp)         # composite certificate
    return None
