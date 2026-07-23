from typing import List

Matrix = List[List[float]]
INF = float("inf")

def trop_matmul(A: Matrix, B: Matrix) -> Matrix:
    """Tropical (min-plus) product: (A (x) B)[i][j] = min_k (A[i][k] + B[k][j])."""
    n = len(A)
    return [[min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)]
            for i in range(n)]

def trop_identity(n: int) -> Matrix:
    """0 on the diagonal, +inf off-diagonal."""
    return [[0.0 if i == j else INF for j in range(n)] for i in range(n)]

def trop_power(A: Matrix, k: int) -> Matrix:
    """Tropical power A^{(x)k} by repeated squaring.  Cost: O(n^3 log k)."""
    n = len(A)
    result = trop_identity(n)
    base = [row[:] for row in A]
    while k > 0:
        if k & 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        k >>= 1
    return result
