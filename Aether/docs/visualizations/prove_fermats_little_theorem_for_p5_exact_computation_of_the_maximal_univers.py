from __future__ import annotations

def is_prime(k: int) -> bool:
    """Deterministic trial-division primality test."""
    if k < 2:
        return False
    if k % 2 == 0:
        return k == 2
    d = 3
    while d * d <= k:
        if k % d == 0:
            return False
        d += 2
    return True

def universal_divisor(n: int) -> int:
    """Return D(n) = product of primes p with (p-1) | (n-1).

    Only primes p <= n can qualify (since p-1 <= n-1), so we enumerate
    candidate primes up to n and test the exponent-divisibility criterion.
    Complexity O(n * sqrt(n)) dominated by primality testing.
    """
    if n < 2:
        return 1
    product = 1
    for p in range(2, n + 1):
        if is_prime(p) and (n - 1) % (p - 1) == 0:
            product *= p
    return product
