from __future__ import annotations
import math
from typing import List

Matrix = List[List[float]]


def jacobi_eigenvalues(A: Matrix, sweeps: int = 100, tol: float = 1e-14) -> List[float]:
    """Classical Jacobi eigenvalue algorithm for a symmetric matrix.

    Repeatedly zeroes the largest off-diagonal entry via Givens rotations.
    Converges quadratically; cost O(n^3) per sweep. Used to extract the
    spectral gap mu (smallest nonzero eigenvalue) and top eigenvalue lam of
    the Hodge Laplacian, which feed the depth-threshold formula.
    """
    n = len(A)
    M = [row[:] for row in A]
    for _ in range(sweeps):
        p, q, off = 0, 1, 0.0
        for i in range(n):
            for j in range(i + 1, n):
                if abs(M[i][j]) > off:
                    off, p, q = abs(M[i][j]), i, j
        if off < tol:
            break
        theta = (math.pi / 4 if abs(M[p][p] - M[q][q]) < 1e-30
                 else 0.5 * math.atan2(2 * M[p][q], M[p][p] - M[q][q]))
        c, s = math.cos(theta), math.sin(theta)
        for k in range(n):
            a, b = M[k][p], M[k][q]
            M[k][p], M[k][q] = c * a + s * b, -s * a + c * b
        for k in range(n):
            a, b = M[p][k], M[q][k]
            M[p][k], M[q][k] = c * a + s * b, -s * a + c * b
    return [M[i][i] for i in range(n)]
