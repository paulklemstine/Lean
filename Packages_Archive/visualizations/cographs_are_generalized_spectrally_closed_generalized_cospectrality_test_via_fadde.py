from __future__ import annotations
from itertools import combinations

def adjacency(n: int, edge_list: list[tuple[int, int]]) -> list[list[float]]:
    E = {frozenset(e) for e in edge_list}
    return [[1.0 if frozenset((i, j)) in E else 0.0 for j in range(n)]
            for i in range(n)]

def complement(A: list[list[float]]) -> list[list[float]]:
    n = len(A)
    return [[1.0 - (1.0 if i == j else 0.0) - A[i][j] for j in range(n)]
            for i in range(n)]

def charpoly(A: list[list[float]]) -> list[float]:
    """Faddeev-LeVerrier: characteristic-polynomial coefficients. O(n^4)."""
    n = len(A)
    M = [[0.0] * n for _ in range(n)]
    c = [1.0]
    def mul(X, Y):
        return [[sum(X[i][k] * Y[k][j] for k in range(n)) for j in range(n)]
                for i in range(n)]
    for k in range(1, n + 1):
        AM = mul(A, M)
        for i in range(n):
            AM[i][i] += c[-1]
        M = AM
        c.append(-sum(mul(A, M)[i][i] for i in range(n)) / k)
    return [round(x, 8) for x in c]

def generalized_cospectral(n: int,
                           edges_g: list[tuple[int, int]],
                           edges_h: list[tuple[int, int]]) -> bool:
    """True iff G and H share both the adjacency and complement char polys."""
    Ag, Ah = adjacency(n, edges_g), adjacency(n, edges_h)
    return (charpoly(Ag) == charpoly(Ah)
            and charpoly(complement(Ag)) == charpoly(complement(Ah)))
