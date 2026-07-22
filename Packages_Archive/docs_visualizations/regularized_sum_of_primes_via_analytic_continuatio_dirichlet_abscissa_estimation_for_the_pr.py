from __future__ import annotations
from math import log
from typing import List

def primes_up_to(limit: int) -> List[int]:
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, p in enumerate(sieve) if p]

def estimate_abscissa(primes: List[int]) -> float:
    """Estimate the abscissa of convergence of the prime Dirichlet series
    sum_p p^{-s} = sum_n exp(-s * log p_n).

    For a Dirichlet series with nonnegative coefficients a_n = 1 and exponents
    lambda_n = log p_n whose coefficient partial sums A_n = n diverge, the
    abscissa of convergence equals  limsup_n  log(A_n) / lambda_n  =
    limsup_n  log(n) / log(p_n).  Since p_n ~ n log n, this tends to 1, the
    sharp threshold of Theorem primeZeta_summable_iff.
    """
    best = 0.0
    for n, p in enumerate(primes, start=1):
        if n >= 2:  # need log(n) > 0 and p > 1
            best = max(best, log(n) / log(p))
    return best
