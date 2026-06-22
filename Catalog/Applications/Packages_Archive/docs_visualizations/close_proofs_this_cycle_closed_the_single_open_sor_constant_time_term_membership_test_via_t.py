from math import gcd
from typing import Callable

def divides_term(u: Callable[[int], int], p: int, m: int,
                 rank: int) -> bool:
    """Decide p | u(m) in O(1) given the precomputed rank of apparition of p.

    Pinning law (Theorem 5.1): p | u(m) iff rank | m. This replaces computing the
    possibly astronomically large term u(m) with a single divisibility check on
    the index, costing O(log m) bit operations instead of exponential work.
    """
    return m % rank == 0
