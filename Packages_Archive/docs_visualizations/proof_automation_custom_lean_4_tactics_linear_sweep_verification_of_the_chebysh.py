from math import prod
from typing import List


def sieve(n: int) -> List[int]:
    """All primes <= n via the sieve of Eratosthenes, O(n log log n)."""
    if n < 2:
        return []
    flags = bytearray([1]) * (n + 1)
    flags[0] = flags[1] = 0
    p = 2
    while p * p <= n:
        if flags[p]:
            for k in range(p * p, n + 1, p):
                flags[k] = 0
        p += 1
    return [i for i in range(2, n + 1) if flags[i]]


def verify_primorial_bound(n_max: int) -> bool:
    """Verify prod_{p<=n} p < 4^n for every 1 <= n <= n_max by a linear sweep,
    accumulating the primorial incrementally."""
    primorial_val = 1
    primes = set(sieve(n_max))
    for n in range(1, n_max + 1):
        if n in primes:
            primorial_val *= n
        if not (primorial_val < 4 ** n):
            return False
    return True
