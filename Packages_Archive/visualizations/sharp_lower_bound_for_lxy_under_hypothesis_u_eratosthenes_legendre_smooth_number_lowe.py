from __future__ import annotations
from typing import List


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
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


def large_primes(x: int, y: int) -> List[int]:
    """Primes in the half-open interval (y, x]."""
    return [p for p in range(y + 1, x + 1) if is_prime(p)]


def sieve_lower_bound(x: int, y: int) -> int:
    """Eratosthenes/Legendre lower bound  x - sum_{y<p<=x} floor(x/p).

    Returns a guaranteed lower bound for L(x, y), the count of y-smooth
    integers in (0, x].  Complexity: O(pi(x) - pi(y)) arithmetic operations
    once the primes in (y, x] are listed; generating those primes by trial
    division costs O(x * sqrt(x)) in the naive form above and O(x log log x)
    with a segmented sieve.
    """
    contribution = sum(x // p for p in large_primes(x, y))
    return max(0, x - contribution)
