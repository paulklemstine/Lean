from __future__ import annotations
import math
from typing import List, Tuple
Complex = complex
Matrix = List[List[Complex]]

def smallest_eigenvalue_2x2(a: Matrix) -> float:
    """Closed-form smallest eigenvalue of a 2x2 Hermitian matrix."""
    a00, a11 = a[0][0].real, a[1][1].real
    off = a[0][1]
    tr = a00 + a11
    det = a00 * a11 - (off * off.conjugate()).real
    return tr / 2 - math.sqrt(max(tr * tr / 4 - det, 0.0))

def additive_certificate(terms: List[Matrix]) -> float:
    """Certified global energy lower bound = sum of per-term smallest eigenvalues."""
    total: float = 0.0
    for h in terms:
        total += smallest_eigenvalue_2x2(h)
    return total

if __name__ == "__main__":
    H_Z: Matrix = [[0j, 0j], [0j, 1 + 0j]]
    H_X: Matrix = [[0.5 + 0j, -0.5 + 0j], [-0.5 + 0j, 0.5 + 0j]]
    print("additive floor:", additive_certificate([H_Z, H_X]))  # 0.0 (sound, not tight)
