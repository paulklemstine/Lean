from math import prod

def primes_up_to(limit: int) -> list[int]:
    sieve = [True] * (limit + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, is_p in enumerate(sieve) if is_p]

def universal_divisor(n: int, bound: int = 200) -> int:
    """Largest M with M | a^n - a for all a: product of primes p with (p-1)|(n-1)."""
    return prod(p for p in primes_up_to(bound) if (n - 1) % (p - 1) == 0)
