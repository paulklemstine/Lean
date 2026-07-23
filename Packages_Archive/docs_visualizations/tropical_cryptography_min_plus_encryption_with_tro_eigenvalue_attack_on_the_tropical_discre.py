from __future__ import annotations
from fractions import Fraction
from typing import List, Optional
Matrix = List[List[float]]

def eigenvalue_attack(a: Matrix, b: Matrix, min_cycle_mean) -> Optional[int]:
    """
    Solve the tropical discrete logarithm problem: given A and B = A^{otimes k},
    recover k using lambda(B) = k * lambda(A). Requires lambda(A) != 0.
    Complexity is dominated by two minimum-cycle-mean computations, O(n^3),
    independent of the size of k.
    """
    lam_a: Optional[Fraction] = min_cycle_mean(a)
    lam_b: Optional[Fraction] = min_cycle_mean(b)
    if lam_a is None or lam_a == 0 or lam_b is None:
        return None
    ratio = lam_b / lam_a
    return int(ratio) if ratio.denominator == 1 else None
