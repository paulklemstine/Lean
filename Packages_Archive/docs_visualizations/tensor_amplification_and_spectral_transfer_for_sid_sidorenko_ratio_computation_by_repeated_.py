from typing import List
Matrix = List[List[float]]

def mat_mul(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    return [[sum(A[i][k] * B[k][j] for k in range(n)) for j in range(n)] for i in range(n)]

def mat_pow(A: Matrix, k: int) -> Matrix:
    n = len(A)
    R: Matrix = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
    B = [row[:] for row in A]
    while k:
        if k & 1:
            R = mat_mul(R, B)
        B = mat_mul(B, B)
        k >>= 1
    return R

def sidorenko_ratio(k: int, A: Matrix) -> float:
    """R_k(A) = (trace(A^k)/N^k) / (total_weight(A)/N^2)^k."""
    n = len(A)
    t_edge = sum(sum(r) for r in A) / n ** 2
    P = mat_pow(A, k)
    t_cycle = sum(P[i][i] for i in range(n)) / n ** k
    return t_cycle / t_edge ** k
