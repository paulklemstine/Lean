from __future__ import annotations
from typing import List, Tuple

Mat = List[List[int]]

def hypercube_boundary_map(n: int) -> Mat:
    """Graph boundary map d1 of Q_n as a |V| x |E| GF(2) matrix.
    Vertices are integers 0..2^n-1; an edge joins vertices differing in one bit."""
    edges: List[Tuple[int, int]] = []
    for v in range(1 << n):
        for bit in range(n):
            w = v ^ (1 << bit)
            if v < w:
                edges.append((v, w))
    M: Mat = [[0] * len(edges) for _ in range(1 << n)]
    for col, (u, v) in enumerate(edges):
        M[u][col] = 1
        M[v][col] = 1
    return M

def hypercube_betti1(n: int) -> int:
    """Closed form first Betti number of Q_n: n*2^(n-1) - 2^n + 1."""
    return n * (1 << (n - 1)) - (1 << n) + 1
