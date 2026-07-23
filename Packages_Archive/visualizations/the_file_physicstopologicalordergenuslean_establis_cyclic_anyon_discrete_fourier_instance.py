from __future__ import annotations

import cmath
import math
from typing import List


def cyclic_braiding_nondegenerate(n: int) -> bool:
    """Witness nondegeneracy of the Z_n braiding chi_a(b)=exp(2 pi i ab/n).

    chi_a is trivial (==1 for all b) only when a==0, by primitivity of the
    n-th root of unity. Returns True iff this holds. Complexity O(n^2).
    """
    for a in range(n):
        trivial = all(abs(cmath.exp(2j * math.pi * (a * b % n) / n) - 1) < 1e-9
                      for b in range(n))
        if trivial and a != 0:
            return False
    return True


def cyclic_smatrix(n: int) -> List[List[complex]]:
    """Discrete Fourier S-matrix S_{a,b} = (1/sqrt n) exp(2 pi i ab/n)."""
    norm = 1.0 / math.sqrt(n)
    return [[norm * cmath.exp(2j * math.pi * (a * b % n) / n)
             for b in range(n)] for a in range(n)]
