from typing import List

Matrix = List[List[float]]

def trop_mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Min-plus matrix product: (A (x) B)_{ij} = min_k (A_{ik} + B_{kj})."""
    n = len(A)
    return [[min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)] for i in range(n)]

def trop_mat_pow(A: Matrix, k: int) -> Matrix:
    """Tropical power A^{(x)(k+1)} via repeated squaring in O(n^3 log k) tropical ops."""
    t = k + 1
    result: "Matrix | None" = None
    base = [row[:] for row in A]
    while t > 0:
        if t & 1:
            result = base if result is None else trop_mat_mul(result, base)
        t >>= 1
        if t > 0:
            base = trop_mat_mul(base, base)
    assert result is not None
    return result
