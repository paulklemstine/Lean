from typing import List

Matrix = List[List[int]]
Poly = List[int]


def _mat_mul(A: Matrix, B: Matrix, p: int) -> Matrix:
    n = len(A)
    return [[sum(A[i][k] * B[k][j] for k in range(n)) % p for j in range(n)]
            for i in range(n)]


def charpoly(M: Matrix, p: int) -> Poly:
    """Characteristic polynomial of M over F_p via Faddeev-LeVerrier."""
    n = len(M)
    I = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    Mk = [row[:] for row in I]
    coeffs = [0] * (n + 1)
    coeffs[n] = 1
    for k in range(1, n + 1):
        Mk = _mat_mul(M, Mk, p)
        trace = sum(Mk[i][i] for i in range(n)) % p
        inv_k = pow(k, p - 2, p)
        c = (-trace * inv_k) % p
        coeffs[n - k] = c
        for i in range(n):
            Mk[i][i] = (Mk[i][i] + c) % p
    while len(coeffs) > 1 and coeffs[-1] % p == 0:
        coeffs.pop()
    return [x % p for x in coeffs]
