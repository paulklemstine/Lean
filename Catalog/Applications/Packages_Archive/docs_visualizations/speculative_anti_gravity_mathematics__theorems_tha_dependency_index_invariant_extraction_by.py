from __future__ import annotations
from typing import List


def prime_factors_list(n: int) -> List[int]:
    """Prime factors of n with multiplicity (mirrors Nat.primeFactorsList).

    Returns [] for n in {0, 1}. Trial division up to sqrt(n).
    """
    if n < 2:
        return []
    factors: List[int] = []
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors.append(d)
            m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors


def weight(depth: int) -> int:
    """weight(T) = T.depth  (OWFStratum.weight)."""
    return depth


def proof_complexity(depth: int) -> int:
    """proofComplexity(T) = Omega(depth)  (OWFStratum.proofComplexity)."""
    return len(prime_factors_list(depth))


def is_anti_gravity(depth: int) -> bool:
    """IsAntiGravity: 2 ** proofComplexity == weight  (OWFStratum.IsAntiGravity)."""
    return 2 ** proof_complexity(depth) == weight(depth)


def check_tradeoff(depth: int) -> bool:
    """Anti-Gravity Trade-off: 2 ** proofComplexity <= weight for depth > 0."""
    return depth == 0 or 2 ** proof_complexity(depth) <= weight(depth)
