from __future__ import annotations
import math
from typing import List
Complex = complex
Matrix = List[List[Complex]]

def smallest_eigenvalue_2x2(a: Matrix) -> float:
    a00, a11 = a[0][0].real, a[1][1].real
    off = a[0][1]
    tr = a00 + a11
    det = a00 * a11 - (off * off.conjugate()).real
    return tr / 2 - math.sqrt(max(tr * tr / 4 - det, 0.0))

def mat_add(a: Matrix, b: Matrix) -> Matrix:
    return [[a[i][j] + b[i][j] for j in range(len(a[i]))] for i in range(len(a))]

def frustration_energy(terms: List[Matrix]) -> float:
    """Ground energy of the sum minus the additive floor; > 0 means frustrated."""
    total: Matrix = [[0j, 0j], [0j, 0j]]
    floor: float = 0.0
    for h in terms:
        total = mat_add(total, h)
        floor += smallest_eigenvalue_2x2(h)
    return smallest_eigenvalue_2x2(total) - floor

if __name__ == "__main__":
    H_Z: Matrix = [[0j, 0j], [0j, 1 + 0j]]
    H_X: Matrix = [[0.5 + 0j, -0.5 + 0j], [-0.5 + 0j, 0.5 + 0j]]
    print("frustration energy:", frustration_energy([H_Z, H_X]))  # (2 - sqrt 2)/2
