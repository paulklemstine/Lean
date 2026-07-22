from __future__ import annotations
import cmath
from typing import Optional

W5: complex = cmath.exp(2j * cmath.pi / 5)

def sigma5(n: int, tol: float = 1e-9) -> Optional[float]:
    """Minimal absolute value of a non-vanishing sum of n fifth roots of unity.

    Enumerates all compositions (a0,a1,a2,a3,a4) with a0+...+a4 = n, forms the
    sum S = sum_r a_r * W5**r, discards vanishing sums, and returns the least
    positive modulus.  Complexity O(n^4).
    """
    if n <= 0:
        return None
    best: Optional[float] = None
    for a0 in range(n + 1):
        for a1 in range(n + 1 - a0):
            for a2 in range(n + 1 - a0 - a1):
                for a3 in range(n + 1 - a0 - a1 - a2):
                    a4 = n - a0 - a1 - a2 - a3
                    s = a0 + a1 * W5 + a2 * W5**2 + a3 * W5**3 + a4 * W5**4
                    m = abs(s)
                    if m > tol and (best is None or m < best):
                        best = m
    return best
