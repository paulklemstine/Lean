from __future__ import annotations
from typing import List, Sequence

Matrix = List[List[int]]


def mat_mul_gf2(a: Matrix, b: Matrix) -> Matrix:
    """Product of two matrices over GF(2)."""
    r, k, c = len(a), len(b), len(b[0])
    out: Matrix = [[0] * c for _ in range(r)]
    for i in range(r):
        for t in range(k):
            if a[i][t] & 1:
                for j in range(c):
                    out[i][j] ^= b[t][j] & 1
    return out


def function_matrix(phi: Sequence[int], m: int) -> Matrix:
    """0/1 function matrix M[u][a] = 1 iff phi(u) = a."""
    mat: Matrix = [[0] * m for _ in range(len(phi))]
    for u, im in enumerate(phi):
        mat[u][im] = 1
    return mat


def is_oddomorphism(a_f: Matrix, a_g: Matrix, phi: Sequence[int]) -> bool:
    """True iff phi is an oddomorphism: A_F M_phi == M_phi A_G over GF(2)."""
    mp = function_matrix(phi, len(a_g))
    return mat_mul_gf2(a_f, mp) == mat_mul_gf2(mp, a_g)
