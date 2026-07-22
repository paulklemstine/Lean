from itertools import product
from math import exp, log
from typing import Sequence

def bulk_prime_partition(primes: Sequence[int], n_max: int, beta: float) -> float:
    """O(k(N+1)^k) direct evaluation over the occupation lattice."""
    if n_max < 0:
        raise ValueError("n_max must be nonnegative")
    total = 0.0
    for occupation in product(range(n_max+1), repeat=len(primes)):
        energy = sum(a*log(p) for p, a in zip(primes, occupation))
        total += exp(-beta*energy)
    return total
