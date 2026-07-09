from functools import reduce
from typing import List

def is_prime(p: int) -> bool:
    if p < 2:
        return False
    return all(p % d for d in range(2, int(p ** 0.5) + 1))

def universal_denominator(n: int, prime_bound: int = 500) -> int:
    """Compute D(n), the largest integer dividing a^n - a for all integers a.

    By the classification, a prime p divides D(n) iff (p-1) | (n-1), and D(n)
    is squarefree. So D(n) is the product of all such primes.
    """
    primes: List[int] = [p for p in range(2, prime_bound + 1) if is_prime(p)]
    factors: List[int] = [p for p in primes if (n - 1) % (p - 1) == 0]
    return reduce(lambda x, y: x * y, factors, 1)
