from itertools import combinations
from typing import List

Matrix = List[List[float]]

def submatrix_det_bareiss(M: Matrix) -> float:
    """Fraction-free Bareiss determinant (exact for integer/rational input)."""
    n = len(M); A = [row[:] for row in M]; prev = 1.0; sign = 1
    for k in range(n - 1):
        if A[k][k] == 0:
            swap = next((r for r in range(k + 1, n) if A[r][k] != 0), None)
            if swap is None:
                return 0.0
            A[k], A[swap] = A[swap], A[k]; sign = -sign
        for i in range(k + 1, n):
            for j in range(k + 1, n):
                A[i][j] = (A[i][j] * A[k][k] - A[i][k] * A[k][j]) / prev
        prev = A[k][k]
    return sign * A[n - 1][n - 1]

def is_mds(M: Matrix) -> bool:
    """
    Decide the Maximum Distance Separable property: every k x k submatrix,
    over all sizes k and all row/column subsets, has nonzero determinant.
    Complexity: sum_{k=1}^n C(n,k)^2 = C(2n,n) - 1 determinant evaluations,
    each O(k^3); exact and practical for the small matrices used in code design.
    """
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                sub = [[M[r][c] for c in cols] for r in rows]
                if abs(submatrix_det_bareiss(sub)) < 1e-9:
                    return False
    return True
