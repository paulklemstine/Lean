from typing import List

def prime_factors_with_multiplicity(d: int) -> List[int]:
    """Return prime factors of d (>=1) with multiplicity; product equals d."""
    if d < 1:
        raise ValueError("d must be positive")
    factors: List[int] = []
    m, p = d, 2
    while p * p <= m:
        while m % p == 0:
            factors.append(p)
            m //= p
        p += 1
    if m > 1:
        factors.append(m)
    return factors

def proof_cost(d: int) -> int:
    """proofCost(d) = Omega(d): number of prime factors with multiplicity."""
    return len(prime_factors_with_multiplicity(d))
