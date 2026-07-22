from typing import Set


def sieve_primes(limit: int) -> Set[int]:
    """Sieve of Eratosthenes returning all primes <= limit."""
    if limit < 2:
        return set()
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return {i for i in range(limit + 1) if sieve[i]}


def goldbach_partition_count(n: int) -> int:
    """Number of unordered prime pairs (p, q) with p + q = n and p <= q.

    Complexity: O(n log log n) for the sieve plus O(n) for the scan.
    By the universal upper bound, the result never exceeds floor(n/2) + 1.
    """
    primes = sieve_primes(n)
    return sum(1 for p in range(n // 2 + 1) if p in primes and (n - p) in primes)
