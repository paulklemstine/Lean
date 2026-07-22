from __future__ import annotations
from math import gcd

def divisibility_density(p: int, n: int) -> float:
    """Exact limiting density of a with p | (a^n - a).

    Equals (gcd(n-1, p-1) + 1) / p: the residue 0 always qualifies, and
    exactly gcd(n-1, p-1) units satisfy a^(n-1) = 1 in the cyclic group
    of order p-1. Returns 1.0 precisely when (p-1) | (n-1).
    """
    return (gcd(n - 1, p - 1) + 1) / p
