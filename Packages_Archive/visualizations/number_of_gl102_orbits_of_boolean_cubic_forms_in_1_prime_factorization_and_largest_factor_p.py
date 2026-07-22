from __future__ import annotations
from math import isqrt
from typing import Dict

def factor_and_certify(n: int) -> Dict[str, object]:
    """Trial-division factorization plus a primality check on the largest factor.

    Returns the prime factorization and whether the largest prime factor is
    prime by exhaustive trial division up to its square root. Applied to
    3,691,560 this recovers 2^3 * 3 * 5 * 30763 with 30763 prime.
    """
    factors: Dict[int, int] = {}
    m, d = n, 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    largest = max(factors)
    largest_prime = largest >= 2 and all(largest % k for k in range(2, isqrt(largest) + 1))
    return {"factors": factors, "largest_factor": largest,
            "largest_is_prime": largest_prime}
