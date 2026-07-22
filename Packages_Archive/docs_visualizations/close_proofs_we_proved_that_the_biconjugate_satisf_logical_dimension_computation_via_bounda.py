from __future__ import annotations
from typing import List

Matrix = List[List[int]]  # GF(2) entries in {0,1}

def rank_gf2(a: Matrix) -> int:
    """Rank of a GF(2) matrix by Gaussian elimination."""
    m = [row[:] for row in a]
    rows = len(m); cols = len(m[0]) if rows else 0
    rank = 0
    for col in range(cols):
        piv = next((r for r in range(rank, rows) if m[r][col]), None)
        if piv is None:
            continue
        m[rank], m[piv] = m[piv], m[rank]
        for r in range(rows):
            if r != rank and m[r][col]:
                m[r] = [x ^ y for x, y in zip(m[r], m[rank])]
        rank += 1
    return rank

def matmul_gf2(a: Matrix, b: Matrix) -> Matrix:
    rows, inner, cols = len(a), len(b), len(b[0]) if b else 0
    out = [[0]*cols for _ in range(rows)]
    for i in range(rows):
        for k in range(inner):
            if a[i][k]:
                for j in range(cols):
                    out[i][j] ^= b[k][j]
    return out

def logical_dimension(d1: Matrix, d2: Matrix, n: int) -> int:
    """Logical qubits k = beta_1 of the CSS code induced by a chain complex
    F^m --d2--> F^n --d1--> F^p  with d1.d2 = 0.

    By the Homological Dimension Theorem and the two rank-nullity laws,
        k = beta_1 = dim ker(d1) - dim im(d2) = n - rank(d1) - rank(d2).
    Raises ValueError if the chain condition d1.d2 = 0 fails.
    """
    prod = matmul_gf2(d1, d2)
    if any(v for row in prod for v in row):
        raise ValueError("chain condition d1.d2 = 0 violated: not a CSS code")
    return n - rank_gf2(d1) - rank_gf2(d2)
