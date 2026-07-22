from math import prod
from itertools import combinations
from typing import List, Set, Tuple

def prime_factors(n: int) -> Set[int]:
    factors: Set[int] = set()
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors.add(d); m //= d
        d += 1
    if m > 1:
        factors.add(m)
    return factors

def divisor_to_subset(d: int) -> Set[int]:
    """Forward map of the bijection: a squarefree divisor -> its prime set."""
    return prime_factors(d)

def subset_to_divisor(s: Set[int]) -> int:
    """Backward map: a subset of primes -> the product (a squarefree divisor)."""
    return prod(s) if s else 1

def all_divisor_subset_pairs(N: int) -> List[Tuple[int, Tuple[int, ...]]]:
    """Enumerate the full divisor <-> subset-of-primes bijection for squarefree N."""
    primes = sorted(prime_factors(N))
    pairs: List[Tuple[int, Tuple[int, ...]]] = []
    for r in range(len(primes) + 1):
        for combo in combinations(primes, r):
            pairs.append((subset_to_divisor(set(combo)), combo))
    return sorted(pairs)
