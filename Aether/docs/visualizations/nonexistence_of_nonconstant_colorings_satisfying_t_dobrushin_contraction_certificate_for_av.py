from __future__ import annotations
from typing import List

def mat_mult(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][k] * B[k][j] for k in range(m)) for j in range(p)]
            for i in range(n)]

def mat_pow(W: List[List[float]], r: int) -> List[List[float]]:
    n = len(W)
    P = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
    for _ in range(r):
        P = mat_mult(P, W)
    return P

def dobrushin_coefficient(W: List[List[float]]) -> float:
    """delta(W) = 1 - min_{i,i'} sum_j min(W[i][j], W[i'][j]) in [0, 1].

    delta(W^r) < 1 certifies the averaging map contracts the coloring spread by
    that factor every r steps -> geometric convergence to consensus.
    """
    n = len(W)
    worst = 1.0
    for i in range(n):
        for ip in range(i + 1, n):
            overlap = sum(min(W[i][j], W[ip][j]) for j in range(n))
            worst = min(worst, overlap)
    return 1.0 - worst

def contraction_rate(W: List[List[float]], r: int) -> float:
    return dobrushin_coefficient(mat_pow(W, r))
