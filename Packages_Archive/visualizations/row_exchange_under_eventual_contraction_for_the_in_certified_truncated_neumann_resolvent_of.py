from typing import List, Tuple

Matrix = List[List[float]]


def identity(n: int) -> Matrix:
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    n, k, m = len(a), len(b), len(b[0])
    out = [[0.0] * m for _ in range(n)]
    for i in range(n):
        for t in range(k):
            v = a[i][t]
            if v:
                for j in range(m):
                    out[i][j] += v * b[t][j]
    return out


def matadd(a: Matrix, b: Matrix) -> Matrix:
    return [[a[i][j] + b[i][j] for j in range(len(a[0]))] for i in range(len(a))]


def linfty_norm(a: Matrix) -> float:
    return max(sum(abs(x) for x in row) for row in a)


def neumann_resolvent(a: Matrix, tol: float = 1e-12) -> Tuple[Matrix, int, float]:
    """Truncated Neumann series for (I - A)^-1 with a certified tail bound.

    Chooses T so that ||A||^T / (1 - ||A||) <= tol, the operator-norm tail
    estimate guaranteed by the Neumann bound theorem. Requires ||A|| < 1.
    """
    n = len(a)
    nrm = linfty_norm(a)
    if nrm >= 1.0:
        raise ValueError("need ||A|| < 1")
    bound = 1.0 / (1.0 - nrm)
    T = 1
    while (nrm ** T) * bound > tol:
        T += 1
    term = identity(n)
    total = identity(n)
    for _ in range(1, T):
        term = matmul(term, a)
        total = matadd(total, term)
    return total, T, (nrm ** T) * bound
