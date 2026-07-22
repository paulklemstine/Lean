from math import prod
from typing import Sequence

def boundary_prime_partition(primes: Sequence[int], n_max: int, beta: float) -> float:
    """O(kN) evaluation of the finite boundary product."""
    if n_max < 0:
        raise ValueError("n_max must be nonnegative")
    return prod(sum(p ** (-beta*n) for n in range(n_max+1)) for p in primes)
