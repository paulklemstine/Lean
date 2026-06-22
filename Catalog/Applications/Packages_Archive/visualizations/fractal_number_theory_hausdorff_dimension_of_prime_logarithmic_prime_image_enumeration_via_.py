from __future__ import annotations
import math

def log_prime_image(limit: int) -> list[float]:
    """Enumerate S = {1/log p : p prime, p <= limit}, sorted ascending."""
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    primes = [i for i, v in enumerate(sieve) if v]
    return sorted(1.0 / math.log(p) for p in primes)
