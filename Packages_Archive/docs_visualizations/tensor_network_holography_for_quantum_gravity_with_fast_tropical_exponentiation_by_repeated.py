from typing import List

Matrix = List[List[float]]

def trop_mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Tropical (min-plus) product: (A (X) B)(i,j) = min_k A(i,k)+B(k,j)."""
    n = len(A)
    return [[min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)]
            for i in range(n)]

def trop_mat_pow_fast(A: Matrix, k: int) -> Matrix:
    """A^{(X)(k+1)} via repeated tropical squaring in O(n^3 log k).

    Uses field-friendly indexing tropMatPow(A,k)=A^{(X)(k+1)}, so the
    exponent processed is e = k+1. Correctness rests on power
    multiplicativity (tropMatMul_tropMatPow_add) and associativity.
    """
    if k < 0:
        raise ValueError("k must be a natural number")
    e = k + 1
    base: Matrix = [row[:] for row in A]
    result: Matrix | None = None
    while e > 0:
        if e & 1:
            result = base if result is None else trop_mat_mul(result, base)
        e >>= 1
        if e > 0:
            base = trop_mat_mul(base, base)
    assert result is not None
    return result
