"""Numerical demonstrations of edge-spectral triangle supersaturation.

This self-contained script demonstrates, for finite simple graphs:

    Edge bridge      tr(A^2) = 2m           (m = number of edges)
    Triangle bridge  tr(A^3) = 6t           (t = number of triangles)
    Supersaturation  lambda * q <= 3t       (q = lambda^2 - m, spectral excess)
    Sqrt scaling     sqrt(m) * q <= 3t      (when q >= 0)
    Nosal            triangle-free => lambda^2 <= m

where A is the real adjacency matrix of the graph and lambda is the
spectrum-dominating (Perron-Frobenius) eigenvalue, i.e. |mu_i| <= lambda.

Only the Python standard library is used; a tiny pure-Python symmetric
eigenvalue solver (Jacobi rotation) avoids any external dependency.
"""

from __future__ import annotations

import math
from itertools import combinations, permutations
from typing import Dict, List, Sequence, Tuple

Matrix = List[List[float]]
Graph = Dict[int, set]  # adjacency sets keyed by vertex 0..n-1


# --------------------------------------------------------------------------- #
# Graph construction and basic invariants
# --------------------------------------------------------------------------- #
def make_graph(n: int, edges: Sequence[Tuple[int, int]]) -> Graph:
    """Build a simple graph on vertices {0,...,n-1} from an undirected edge list."""
    g: Graph = {v: set() for v in range(n)}
    for u, v in edges:
        if u == v:
            raise ValueError("simple graphs have no loops")
        g[u].add(v)
        g[v].add(u)
    return g


def adjacency_matrix(g: Graph) -> Matrix:
    """Return the real 0/1 adjacency matrix of g."""
    n = len(g)
    a: Matrix = [[0.0] * n for _ in range(n)]
    for u in range(n):
        for v in g[u]:
            a[u][v] = 1.0
    return a


def edge_count(g: Graph) -> int:
    """Number of edges m."""
    return sum(len(nbrs) for nbrs in g.values()) // 2


def triangle_count(g: Graph) -> int:
    """Number of triangles t, by brute-force over 3-subsets of vertices."""
    n = len(g)
    t = 0
    for u, v, w in combinations(range(n), 3):
        if v in g[u] and w in g[u] and w in g[v]:
            t += 1
    return t


# --------------------------------------------------------------------------- #
# Linear algebra: matrix powers, trace, symmetric eigenvalues (Jacobi)
# --------------------------------------------------------------------------- #
def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    """Standard matrix product."""
    n, m, p = len(a), len(b), len(b[0])
    out: Matrix = [[0.0] * p for _ in range(n)]
    for i in range(n):
        ai = a[i]
        for k in range(m):
            aik = ai[k]
            if aik:
                bk = b[k]
                for j in range(p):
                    out[i][j] += aik * bk[j]
    return out


def mat_pow(a: Matrix, k: int) -> Matrix:
    """k-th matrix power (k >= 1)."""
    result = [row[:] for row in a]
    for _ in range(k - 1):
        result = mat_mul(result, a)
    return result


def trace(a: Matrix) -> float:
    """Trace = sum of diagonal entries."""
    return sum(a[i][i] for i in range(len(a)))


def symmetric_eigenvalues(a: Matrix, sweeps: int = 100) -> List[float]:
    """Eigenvalues of a real symmetric matrix via the cyclic Jacobi method."""
    n = len(a)
    m = [row[:] for row in a]
    for _ in range(sweeps):
        off = 0.0
        for p in range(n):
            for q in range(p + 1, n):
                off += m[p][q] * m[p][q]
        if off < 1e-24:
            break
        for p in range(n):
            for q in range(p + 1, n):
                if abs(m[p][q]) < 1e-18:
                    continue
                theta = (m[q][q] - m[p][p]) / (2.0 * m[p][q])
                sign = 1.0 if theta >= 0 else -1.0
                tval = sign / (abs(theta) + math.sqrt(theta * theta + 1.0))
                c = 1.0 / math.sqrt(tval * tval + 1.0)
                s = tval * c
                for k in range(n):
                    mkp, mkq = m[k][p], m[k][q]
                    m[k][p] = c * mkp - s * mkq
                    m[k][q] = s * mkp + c * mkq
                for k in range(n):
                    mpk, mqk = m[p][k], m[q][k]
                    m[p][k] = c * mpk - s * mqk
                    m[q][k] = s * mpk + c * mqk
    return sorted((m[i][i] for i in range(n)), reverse=True)


# --------------------------------------------------------------------------- #
# The combinatorial 3! = 6 ordering fact
# --------------------------------------------------------------------------- #
def ordered_triples_of_3set(s: Sequence[int]) -> int:
    """Number of ordered triples (x,y,z) with {x,y,z} = s, for |s| = 3."""
    assert len(set(s)) == 3, "expects a 3-element set"
    return len(set(permutations(s)))  # == 6


# --------------------------------------------------------------------------- #
# The supersaturation certificate
# --------------------------------------------------------------------------- #
def certificate(name: str, g: Graph) -> None:
    """Print all invariants and verify every inequality for graph g."""
    a = adjacency_matrix(g)
    m = edge_count(g)
    t = triangle_count(g)
    tr2 = trace(mat_pow(a, 2))
    tr3 = trace(mat_pow(a, 3))
    eig = symmetric_eigenvalues(a)
    lam = max(abs(mu) for mu in eig)  # spectrum-dominating eigenvalue
    q = lam * lam - m

    print(f"=== {name} ===")
    print(f"  vertices n = {len(g)},  edges m = {m},  triangles t = {t}")
    print(f"  eigenvalues = {[round(mu, 4) for mu in eig]}")
    print(f"  dominant lambda = {lam:.6f},  spectral excess q = lambda^2 - m = {q:.6f}")
    print(f"  edge bridge:     tr(A^2) = {tr2:.4f}  vs 2m = {2 * m}")
    print(f"  triangle bridge: tr(A^3) = {tr3:.4f}  vs 6t = {6 * t}")
    print(f"  supersaturation: lambda*q = {lam * q:.6f}  <=  3t = {3 * t}"
          f"   -> {'OK' if lam * q <= 3 * t + 1e-6 else 'FAIL'}")
    if q >= -1e-9:
        lhs = math.sqrt(max(m, 0.0)) * q
        print(f"  sqrt scaling:    sqrt(m)*q = {lhs:.6f}  <=  3t = {3 * t}"
              f"   -> {'OK' if lhs <= 3 * t + 1e-6 else 'FAIL'}")
    if t == 0:
        print(f"  Nosal:           lambda^2 = {lam * lam:.6f}  <=  m = {m}"
              f"   -> {'OK' if lam * lam <= m + 1e-6 else 'FAIL'}")
    print()


def complete_graph(n: int) -> Graph:
    """K_n."""
    return make_graph(n, list(combinations(range(n), 2)))


def cycle_graph(n: int) -> Graph:
    """C_n (triangle-free for n >= 4)."""
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


def complete_bipartite(a: int, b: int) -> Graph:
    """K_{a,b} (triangle-free)."""
    edges = [(i, a + j) for i in range(a) for j in range(b)]
    return make_graph(a + b, edges)


def main() -> None:
    print("3! = 6 ordering count for {7,8,9}:", ordered_triples_of_3set((7, 8, 9)))
    print()

    # K_3: the extremal small case.
    certificate("K_3 (triangle)", complete_graph(3))
    # K_4, K_5: dense, triangle-rich.
    certificate("K_4", complete_graph(4))
    certificate("K_5", complete_graph(5))
    # C_5: triangle-free, checks Nosal.
    certificate("C_5 (5-cycle, triangle-free)", cycle_graph(5))
    # K_{3,3}: bipartite, triangle-free.
    certificate("K_{3,3} (complete bipartite, triangle-free)", complete_bipartite(3, 3))
    # A graph with a large hub -> high spectral excess -> forced triangles.
    hub = make_graph(6, [(0, 1), (0, 2), (0, 3), (0, 4), (0, 5),
                         (1, 2), (2, 3), (3, 4)])
    certificate("Hub graph (fan-like)", hub)


if __name__ == "__main__":
    main()
