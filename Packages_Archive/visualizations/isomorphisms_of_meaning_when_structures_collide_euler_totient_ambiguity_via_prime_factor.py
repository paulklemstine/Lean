from __future__ import annotations
from typing import Dict


def prime_factorization(n: int) -> Dict[int, int]:
    """Return the prime factorization of n as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def euler_totient(n: int) -> int:
    """phi(n) via the product formula n * prod_{p|n} (1 - 1/p)."""
    if n < 1:
        raise ValueError("n must be positive")
    result = n
    for p in prime_factorization(n):
        result -= result // p
    return result
