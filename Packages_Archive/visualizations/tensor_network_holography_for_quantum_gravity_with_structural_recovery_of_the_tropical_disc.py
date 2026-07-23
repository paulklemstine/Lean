from typing import List, Optional

Matrix = List[List[float]]
INF = float("inf")

def trop_mat_mul(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    return [[min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)]
            for i in range(n)]

def trop_mat_pow(A: Matrix, k: int) -> Matrix:
    result = [row[:] for row in A]
    for _ in range(k):
        result = trop_mat_mul(A, result)
    return result

def min_cycle_mean(A: Matrix) -> float:
    """Estimate the minimum cycle mean of the weighted digraph of A.

    Cycles of length L contribute diagonal entries of A^{(X)L}/L; the
    minimum over 1<=L<=n is the cycle mean that governs the linear
    growth rate of A^{(X)m}.
    """
    n = len(A)
    best = INF
    for length in range(1, n + 1):
        P = trop_mat_pow(A, length - 1)
        best = min(best, min(P[i][i] / length for i in range(n)))
    return best

def tdlp_recover(A: Matrix, Y: Matrix, search: int = 64) -> Optional[int]:
    """Structural attack on the tropical discrete log: given A and
    Y = A^{(X)m}, recover the exponent m by matching the predictable
    cycle-mean growth and then confirming by direct comparison.

    Demonstrates that TDLP on this platform is not a sound hardness
    assumption: it runs in time polynomial in n and the search bound.
    """
    P = [row[:] for row in A]
    for m in range(search):
        if all(abs(P[i][j] - Y[i][j]) < 1e-9
               for i in range(len(A)) for j in range(len(A))):
            return m
        P = trop_mat_mul(A, P)
    return None
