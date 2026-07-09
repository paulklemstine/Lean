from __future__ import annotations

from fractions import Fraction
from typing import List


def omega_trace(d: int) -> int:
    """T = Tr(omega): 1 if d == 1 (mod 4) else 0."""
    return 1 if d % 4 == 1 else 0


def omega_norm(d: int) -> int:
    """M = N(omega): (1 - d)//4 if d == 1 (mod 4) else -d."""
    return (1 - d) // 4 if d % 4 == 1 else -d


def fundamental_disc(d: int) -> int:
    """D_K: d if d == 1 (mod 4) else 4d."""
    return d if d % 4 == 1 else 4 * d


def gram_matrix(t: int, m: int) -> List[List[int]]:
    """Block-diagonal Gram matrix: hyperbolic U plus binary norm block."""
    return [
        [0, 1, 0, 0],
        [1, 0, 0, 0],
        [0, 0, -2, -t],
        [0, 0, -t, -2 * m],
    ]


def det4(matrix: List[List[int]]) -> int:
    """Exact integer determinant of a 4x4 matrix via Fraction elimination."""
    n = len(matrix)
    a = [[Fraction(x) for x in row] for row in matrix]
    det = Fraction(1)
    for col in range(n):
        piv = next((r for r in range(col, n) if a[r][col] != 0), None)
        if piv is None:
            return 0
        if piv != col:
            a[col], a[piv] = a[piv], a[col]
            det = -det
        det *= a[col][col]
        inv = a[col][col]
        for r in range(col + 1, n):
            f = a[r][col] / inv
            for k in range(col, n):
                a[r][k] -= f * a[col][k]
    return int(det)


def gram_discriminant(d: int) -> int:
    """End-to-end: from squarefree d<0 to det Gram(S_K), verified == D_K."""
    t, m = omega_trace(d), omega_norm(d)
    g = det4(gram_matrix(t, m))
    assert g == t ** 2 - 4 * m == fundamental_disc(d)
    return g
