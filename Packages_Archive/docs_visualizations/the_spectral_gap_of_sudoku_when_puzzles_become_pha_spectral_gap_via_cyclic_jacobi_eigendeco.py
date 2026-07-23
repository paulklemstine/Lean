import math
from typing import List

Matrix = List[List[float]]


def eigenvalues_symmetric(matrix: Matrix, sweeps: int = 100,
                          tol: float = 1e-12) -> List[float]:
    """Eigenvalues of a real symmetric matrix (descending) via cyclic Jacobi."""
    n = len(matrix)
    A = [row[:] for row in matrix]
    for _ in range(sweeps):
        off = sum(A[p][q] ** 2 for p in range(n) for q in range(p + 1, n))
        if off <= tol:
            break
        for p in range(n):
            for q in range(p + 1, n):
                if abs(A[p][q]) <= tol:
                    continue
                theta = (A[q][q] - A[p][p]) / (2.0 * A[p][q])
                t = math.copysign(1.0, theta) / (abs(theta) + math.sqrt(theta * theta + 1.0))
                cs = 1.0 / math.sqrt(t * t + 1.0)
                sn = t * cs
                for k in range(n):
                    akp, akq = A[k][p], A[k][q]
                    A[k][p] = cs * akp - sn * akq
                    A[k][q] = sn * akp + cs * akq
                for k in range(n):
                    apk, aqk = A[p][k], A[q][k]
                    A[p][k] = cs * apk - sn * aqk
                    A[q][k] = sn * apk + cs * aqk
    return sorted((A[i][i] for i in range(n)), reverse=True)


def spectral_gap(matrix: Matrix) -> float:
    """Return lambda_1 - lambda_2 = 1 - lambda_2 for a symmetric stochastic P."""
    eig = eigenvalues_symmetric(matrix)
    return 0.0 if len(eig) < 2 else eig[0] - eig[1]
