from __future__ import annotations
from typing import List, Sequence

Matrix = List[List[int]]


def function_matrix(phi: Sequence[int], m: int) -> Matrix:
    mat: Matrix = [[0] * m for _ in range(len(phi))]
    for u, im in enumerate(phi):
        mat[u][im] = 1
    return mat


def compose(psi: Sequence[int], phi: Sequence[int]) -> List[int]:
    """Function composition (psi . phi)(u) = psi(phi(u))."""
    return [psi[phi[u]] for u in range(len(phi))]


def _mul(a: Matrix, b: Matrix) -> Matrix:
    r, k, c = len(a), len(b), len(b[0])
    out = [[0] * c for _ in range(r)]
    for i in range(r):
        for t in range(k):
            if a[i][t] & 1:
                for j in range(c):
                    out[i][j] ^= b[t][j] & 1
    return out


def verify_functoriality(phi: Sequence[int], psi: Sequence[int],
                         m: int, k: int) -> bool:
    """Check the contravariant law M_phi @ M_psi = M_{psi . phi} over GF(2)."""
    lhs = _mul(function_matrix(phi, m), function_matrix(psi, k))
    rhs = function_matrix(compose(psi, phi), k)
    return lhs == rhs
