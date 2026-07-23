from math import gcd
from typing import Tuple

Matrix = Tuple[int, int, int, int]  # (p, q, r, s)

def det(M: Matrix) -> int:
    p, q, r, s = M
    return p * s - q * r

def primitive(M: Matrix) -> Tuple[Matrix, int]:
    p, q, r, s = M
    g = gcd(gcd(abs(p), abs(q)), gcd(abs(r), abs(s)))
    if g == 0:
        return M, 1
    return (p // g, q // g, r // g, s // g), g

def smith_diagonal(M: Matrix) -> Tuple[int, int]:
    """Return (D1, D2) of the Smith normal form; for primitive M, (1, |det M|)."""
    M0, _ = primitive(M)
    D = abs(det(M0))
    return (1, D)
