from math import comb
from fractions import Fraction

def extended_eulerian(n: int, k: int, s: Fraction) -> Fraction:
    """A(n,k,s) via an alternating binomial sum with incremental C(n+1,i)."""
    total = Fraction(0)
    binom = 1  # C(n+1, 0)
    for i in range(k + 1):
        total += Fraction((-1) ** i) * binom * (Fraction(k + 1 - i) - s) ** n
        binom = binom * (n + 1 - i) // (i + 1)  # advance to C(n+1, i+1)
    return total
