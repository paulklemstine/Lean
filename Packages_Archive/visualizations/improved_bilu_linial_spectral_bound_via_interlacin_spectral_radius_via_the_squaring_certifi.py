from __future__ import annotations
from typing import List

Matrix = List[List[float]]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Multiply two conformable square matrices."""
    n = len(a)
    out = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for k in range(n):
            aik = a[i][k]
            for j in range(n):
                out[i][j] += aik * b[k][j]
    return out


def is_two_identity(m: Matrix, tol: float = 1e-12) -> bool:
    """Check whether m equals 2 * I to within tolerance."""
    n = len(m)
    for i in range(n):
        for j in range(n):
            target = 2.0 if i == j else 0.0
            if abs(m[i][j] - target) > tol:
                return False
    return True


def spectral_radius_via_squaring(b: Matrix) -> float:
    """
    Certificate-based spectral radius for a signed adjacency matrix whose square
    is a scalar multiple of the identity. If B^2 = 2 I, then every eigenvalue mu
    satisfies mu^2 = 2, hence the spectral radius is sqrt(2). Returns sqrt(2) when
    the certificate holds, otherwise raises.
    """
    b2 = matmul(b, b)
    if not is_two_identity(b2):
        raise ValueError("B^2 is not 2*I; squaring certificate does not apply.")
    return 2.0 ** 0.5


if __name__ == "__main__":
    B = [[0, 1, 0, -1], [1, 0, 1, 0], [0, 1, 0, 1], [-1, 0, 1, 0]]
    B = [[float(x) for x in row] for row in B]
    print("spectral radius =", spectral_radius_via_squaring(B))
