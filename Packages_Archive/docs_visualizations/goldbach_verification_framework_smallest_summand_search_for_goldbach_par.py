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


def smallest_goldbach_summand(n: int) -> int:
    """Smallest prime p such that n - p is also prime (n even, n >= 4).

    Iterates primes in increasing order and returns the first p <= n/2 with
    n - p prime. Empirically the answer grows only poly-logarithmically in n,
    motivating the bounded-summand conjecture p <= C (log n)^2.
    Returns -1 if no representation is found (never expected for even n >= 4).
    """
    primes = sieve_primes(n)
    for p in sorted(primes):
        if p > n // 2:
            break
        if (n - p) in primes:
            return p
    return -1
