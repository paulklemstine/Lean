from __future__ import annotations
import cmath, math
from typing import List, Tuple

def dft(f: List[complex]) -> List[complex]:
    n = len(f)
    return [sum(f[j]*cmath.exp(-2j*math.pi*j*k/n) for j in range(n)) for k in range(n)]

def support_size(f: List[complex], tol: float = 1e-9) -> int:
    return sum(1 for z in f if abs(z) > tol)

def uncertainty_check(f: List[complex], tol: float = 1e-9) -> Tuple[int, int, int, bool]:
    """Return (|supp f|, |supp f_hat|, product, product >= N)."""
    n = len(f)
    s, sh = support_size(f, tol), support_size(dft(f), tol)
    return s, sh, s*sh, s*sh >= n
