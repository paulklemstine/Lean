from typing import List

Matrix = List[List[float]]


def trop_matmul(a: Matrix, b: Matrix) -> Matrix:
    """Tropical (min-plus) matrix product: (A (x) B)[i][j] = min_k (A[i][k]+B[k][j])."""
    n = len(a)
    return [
        [min(a[i][k] + b[k][j] for k in range(n)) for j in range(n)]
        for i in range(n)
    ]


def trop_matpow(a: Matrix, e: int) -> Matrix:
    """The e-fold tropical product A^{(x)e} via repeated squaring (O(n^3 log e))."""
    if e < 1:
        raise ValueError("exponent must be >= 1 (no tropical identity over a field)")
    result, base, t = a, a, e - 1
    while t > 0:
        if t & 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        t >>= 1
    return result
