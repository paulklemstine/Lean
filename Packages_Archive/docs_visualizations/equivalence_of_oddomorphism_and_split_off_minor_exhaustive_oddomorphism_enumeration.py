from __future__ import annotations
from itertools import product
from typing import List, Sequence, Tuple

Matrix = List[List[int]]
Edge = Tuple[int, int]


def _mul(a: Matrix, b: Matrix) -> Matrix:
    r, k, c = len(a), len(b), len(b[0])
    out = [[0] * c for _ in range(r)]
    for i in range(r):
        for t in range(k):
            if a[i][t] & 1:
                for j in range(c):
                    out[i][j] ^= b[t][j] & 1
    return out


def _adj(n: int, edges: Sequence[Edge]) -> Matrix:
    a = [[0] * n for _ in range(n)]
    for u, v in edges:
        a[u][v] = a[v][u] = 1
    return a


def _fmat(phi: Sequence[int], m: int) -> Matrix:
    mat = [[0] * m for _ in range(len(phi))]
    for u, im in enumerate(phi):
        mat[u][im] = 1
    return mat


def enumerate_oddomorphisms(
    n: int, edges_f: Sequence[Edge], m: int, edges_g: Sequence[Edge],
) -> List[Tuple[int, ...]]:
    """Return every oddomorphism V(F) -> V(G) by exhaustive GF(2) search."""
    a_f, a_g = _adj(n, edges_f), _adj(m, edges_g)
    results: List[Tuple[int, ...]] = []
    for phi in product(range(m), repeat=n):
        mp = _fmat(phi, m)
        if _mul(a_f, mp) == _mul(mp, a_g):
            results.append(phi)
    return results
