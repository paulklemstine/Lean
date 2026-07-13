"""
Numerical demonstrations of edge-spectral supersaturation for triangles.

Central results demonstrated:
  * Trace identities  : sum mu_i^2 = tr(A^2) = 2m,  sum mu_i^3 = tr(A^3) = 6t.
  * Cubic domination  : |mu| <= lam  =>  -lam*mu^2 <= mu^3.
  * Eigenvalue bound  : 2*lam^3 - lam*sum(mu^2) <= sum(mu^3).
  * Supersaturation   : lam*q <= 3t  and  sqrt(m)*q <= 3t, where q = lam^2 - m.
  * Nosal endpoint    : triangle-free (sum mu^3 = 0) forces lam^2 <= m.

Self-contained: uses only the Python standard library.
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# Minimal symmetric-eigenvalue solver (Jacobi rotation), no numpy required.   #
# --------------------------------------------------------------------------- #
def symmetric_eigenvalues(A: List[List[float]], iters: int = 200) -> List[float]:
    """Return the eigenvalues of a real symmetric matrix via Jacobi rotations."""
    n = len(A)
    M = [row[:] for row in A]
    for _ in range(iters):
        # find largest off-diagonal magnitude
        p, q, off = 0, 1, 0.0
        for i in range(n):
            for j in range(i + 1, n):
                if abs(M[i][j]) > off:
                    off, p, q = abs(M[i][j]), i, j
        if off < 1e-14:
            break
        app, aqq, apq = M[p][p], M[q][q], M[p][q]
        phi = 0.5 * math.atan2(2 * apq, aqq - app) if aqq != app else math.pi / 4
        c, s = math.cos(phi), math.sin(phi)
        for k in range(n):
            mkp, mkq = M[k][p], M[k][q]
            M[k][p] = c * mkp - s * mkq
            M[k][q] = s * mkp + c * mkq
        for k in range(n):
            mpk, mqk = M[p][k], M[q][k]
            M[p][k] = c * mpk - s * mqk
            M[q][k] = s * mpk + c * mqk
    return sorted((M[i][i] for i in range(n)), reverse=True)


# --------------------------------------------------------------------------- #
# Graph invariants                                                            #
# --------------------------------------------------------------------------- #
def adjacency(n: int, edges: List[Tuple[int, int]]) -> List[List[float]]:
    A = [[0.0] * n for _ in range(n)]
    for u, v in edges:
        A[u][v] = A[v][u] = 1.0
    return A


def edge_count(edges: List[Tuple[int, int]]) -> int:
    return len(edges)


def triangle_count(n: int, edges: List[Tuple[int, int]]) -> int:
    E = {frozenset(e) for e in edges}
    return sum(
        1
        for a, b, c in combinations(range(n), 3)
        if {frozenset((a, b)), frozenset((b, c)), frozenset((a, c))} <= E
    )


def report(name: str, n: int, edges: List[Tuple[int, int]]) -> None:
    A = adjacency(n, edges)
    mu = symmetric_eigenvalues(A)
    lam = mu[0]
    m = edge_count(edges)
    t = triangle_count(n, edges)
    q = lam ** 2 - m
    p2 = sum(x ** 2 for x in mu)
    p3 = sum(x ** 3 for x in mu)

    print(f"=== {name} ===")
    print(f"  spectrum         : {[round(x, 4) for x in mu]}")
    print(f"  lambda           : {lam:.4f}")
    print(f"  edges m          : {m}    (2m = {2*m})   sum mu^2 = {p2:.4f}")
    print(f"  triangles t      : {t}    (6t = {6*t})   sum mu^3 = {p3:.4f}")
    print(f"  excess q=lam^2-m : {q:.4f}")
    # eigenvalue supersaturation inequality
    lhs = 2 * lam ** 3 - lam * p2
    print(f"  eigen ineq       : 2lam^3 - lam*sum(mu^2) = {lhs:.4f} <= sum(mu^3) = {p3:.4f}"
          f"  -> {lhs <= p3 + 1e-6}")
    # main supersaturation bounds
    print(f"  lam*q <= 3t      : {lam*q:.4f} <= {3*t}   -> {lam*q <= 3*t + 1e-6}")
    if q >= -1e-9:
        print(f"  sqrt(m)*q <= 3t  : {math.sqrt(m)*q:.4f} <= {3*t}"
              f"   -> {math.sqrt(m)*q <= 3*t + 1e-6}")
    # Nosal endpoint check when triangle-free
    if t == 0:
        print(f"  Nosal lam^2<=m   : {lam**2:.4f} <= {m}  -> {lam**2 <= m + 1e-6}")
    print()


def main() -> None:
    # K3: the smallest triangle, spectrum (2,-1,-1)
    report("K3 (triangle)", 3, [(0, 1), (1, 2), (0, 2)])

    # K4: complete graph on 4 vertices, spectrum (3,-1,-1,-1), t = 4
    report("K4", 4, list(combinations(range(4), 2)))

    # K5
    report("K5", 5, list(combinations(range(5), 2)))

    # Complete bipartite K_{2,3}: triangle-free, sits at/below Nosal threshold
    edges_23 = [(i, j) for i in range(2) for j in range(2, 5)]
    report("K_{2,3} (triangle-free)", 5, edges_23)

    # C5: 5-cycle, triangle-free
    report("C5 (triangle-free)", 5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])

    # A "book" B3: three triangles sharing an edge -> supersaturation
    book = [(0, 1), (0, 2), (1, 2), (0, 3), (1, 3), (0, 4), (1, 4)]
    report("Book B3 (3 triangles on a spine)", 5, book)


if __name__ == "__main__":
    main()
