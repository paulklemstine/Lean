from __future__ import annotations
from typing import List, Tuple

Matrix = List[List[int]]
Vector = Tuple[int, ...]

def gf2_kernel_basis(J: Matrix) -> List[Vector]:
    """A basis of the GF(2) kernel of J (the all-crossing directions)."""
    n = len(J)
    M = [row[:] for row in J]
    pivot_of = {}
    rank = 0
    for col in range(n):
        pr = next((r for r in range(rank, n) if M[r][col] == 1), None)
        if pr is None:
            continue
        M[rank], M[pr] = M[pr], M[rank]
        for r in range(n):
            if r != rank and M[r][col] == 1:
                M[r] = [a ^ b for a, b in zip(M[r], M[rank])]
        pivot_of[col] = rank
        rank += 1
    pivots = set(pivot_of)
    basis: List[Vector] = []
    for free in range(n):
        if free in pivots:
            continue
        vec = [0] * n
        vec[free] = 1
        for col, row in pivot_of.items():
            vec[col] = M[row][free]
        basis.append(tuple(vec))
    return basis

def enumerate_bipartite_duals(J: Matrix, t: Vector) -> List[Vector]:
    """All bipartite partial duals as the coset t + span(kernel basis)."""
    basis = gf2_kernel_basis(J)
    out = [t]
    for b in basis:
        out = out + [tuple((x ^ y) for x, y in zip(v, b)) for v in out]
    return out
