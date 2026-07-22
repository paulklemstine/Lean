from math import prod
from typing import Sequence

def cutoff_decomposition(primes: Sequence[int], n_max: int, beta: float) -> tuple[float, float, float]:
    """Return truncated Z, unrestricted finite-prime Z, and their exact ratio."""
    if beta <= 0 or n_max < 0:
        raise ValueError("require beta > 0 and n_max >= 0")
    unrestricted = prod(1/(1-p**(-beta)) for p in primes)
    ratio = prod(1-p**(-beta*(n_max+1)) for p in primes)
    return unrestricted*ratio, unrestricted, ratio
