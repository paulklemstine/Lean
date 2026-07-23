from fractions import Fraction
from math import comb, factorial
from typing import Dict, List

def deformation_sweep(n: int, shifts: List[Fraction]) -> Dict[Fraction, Fraction]:
    """For each shift s, return the row sum; all values equal n! (invariance)."""
    def A(k: int, s: Fraction) -> Fraction:
        return sum(Fraction((-1) ** i) * comb(n + 1, i) * (Fraction(k + 1 - i) - s) ** n
                   for i in range(k + 1))
    result = {}
    for s in shifts:
        result[s] = sum(A(k, s) for k in range(n + 1))
        assert result[s] == factorial(n)
    return result
