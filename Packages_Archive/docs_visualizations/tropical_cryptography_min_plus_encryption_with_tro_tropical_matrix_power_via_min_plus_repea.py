from typing import List
INF = float('inf')
Matrix = List[List[float]]

def trop_matmul(A: Matrix, B: Matrix) -> Matrix:
    n, m, p = len(A), len(B), len(B[0])
    C: Matrix = [[INF] * p for _ in range(n)]
    for i in range(n):
        for j in range(p):
            best = INF
            for l in range(m):
                best = min(best, A[i][l] + B[l][j])
            C[i][j] = best
    return C

def trop_identity(n: int) -> Matrix:
    return [[0.0 if i == j else INF for j in range(n)] for i in range(n)]

def trop_pow(A: Matrix, k: int) -> Matrix:
    R = trop_identity(len(A))
    base = [row[:] for row in A]
    while k > 0:
        if k & 1:
            R = trop_matmul(R, base)
        base = trop_matmul(base, base)
        k >>= 1
    return R
