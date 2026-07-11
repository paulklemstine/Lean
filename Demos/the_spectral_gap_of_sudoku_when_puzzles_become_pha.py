"""
The Spectral Gap of Constraint-Satisfaction Swap Chains
=======================================================

Self-contained numerical demonstrations (pure Python, no external
dependencies) of the results in the accompanying paper.

We model the swap chain on a finite *move graph* G whose vertices are the
admissible completions of a puzzle and whose edges are the compatible swaps.
For a holding rate c, the transition matrix is

    P(x, x) = 1 - c * deg(x)
    P(x, y) = c            if x ~ y
    P(x, y) = 0            otherwise.

One step of the chain equals I - c*L, where L is the graph Laplacian.
The spectral gap 1 - lambda_2 is:
    * 0      whenever the move graph is disconnected (Theorem: reducibility),
    * > 0    whenever the move graph is connected     (Theorem: irreducibility),
    * 2c     exactly, in the connected two-state model.

The key point demonstrated below: the gap depends on the CONNECTIVITY of the
move graph, not on any clue count.
"""

from __future__ import annotations

import math
from typing import Dict, List, Sequence, Tuple

Matrix = List[List[float]]
Graph = Dict[int, List[int]]


# --------------------------------------------------------------------------- #
#  Move-graph utilities                                                        #
# --------------------------------------------------------------------------- #
def degree(graph: Graph, x: int) -> int:
    """Number of compatible swaps out of vertex x."""
    return len(graph[x])


def max_degree(graph: Graph) -> int:
    """Maximum degree Delta of the move graph."""
    return max((len(nbrs) for nbrs in graph.values()), default=0)


def swap_matrix(graph: Graph, c: float) -> Matrix:
    """Assemble the swap-chain transition matrix P = I - c*L on `graph`."""
    n = len(graph)
    verts = sorted(graph)
    index = {v: i for i, v in enumerate(verts)}
    P = [[0.0 for _ in range(n)] for _ in range(n)]
    for v in verts:
        i = index[v]
        P[i][i] = 1.0 - c * degree(graph, v)
        for w in graph[v]:
            P[i][index[w]] = c
    return P


def is_connected(graph: Graph) -> bool:
    """Breadth-first connectivity test on the move graph."""
    verts = sorted(graph)
    if not verts:
        return True
    seen = {verts[0]}
    frontier = [verts[0]]
    while frontier:
        x = frontier.pop()
        for y in graph[x]:
            if y not in seen:
                seen.add(y)
                frontier.append(y)
    return len(seen) == len(verts)


# --------------------------------------------------------------------------- #
#  Symmetric eigenvalues via the classical Jacobi rotation method             #
# --------------------------------------------------------------------------- #
def eigenvalues_symmetric(matrix: Matrix, sweeps: int = 100,
                          tol: float = 1e-12) -> List[float]:
    """Return the eigenvalues of a real symmetric matrix, descending.

    Uses cyclic Jacobi rotations; adequate for the small dense matrices here.
    """
    n = len(matrix)
    A = [row[:] for row in matrix]
    for _ in range(sweeps):
        off = 0.0
        for p in range(n):
            for q in range(p + 1, n):
                off += A[p][q] * A[p][q]
        if off <= tol:
            break
        for p in range(n):
            for q in range(p + 1, n):
                if abs(A[p][q]) <= tol:
                    continue
                theta = (A[q][q] - A[p][p]) / (2.0 * A[p][q])
                t = math.copysign(1.0, theta) / (abs(theta) + math.sqrt(theta * theta + 1.0))
                cs = 1.0 / math.sqrt(t * t + 1.0)
                sn = t * cs
                for k in range(n):
                    akp, akq = A[k][p], A[k][q]
                    A[k][p] = cs * akp - sn * akq
                    A[k][q] = sn * akp + cs * akq
                for k in range(n):
                    apk, aqk = A[p][k], A[q][k]
                    A[p][k] = cs * apk - sn * aqk
                    A[q][k] = sn * apk + cs * aqk
    return sorted((A[i][i] for i in range(n)), reverse=True)


def spectral_gap(graph: Graph, c: float) -> float:
    """Spectral gap lambda_1 - lambda_2 = 1 - lambda_2 of the swap chain."""
    P = swap_matrix(graph, c)
    eig = eigenvalues_symmetric(P)
    if len(eig) < 2:
        return 0.0
    return eig[0] - eig[1]


# --------------------------------------------------------------------------- #
#  Power-method mixing time                                                    #
# --------------------------------------------------------------------------- #
def mixing_time(graph: Graph, c: float, eps: float = 1e-3,
                max_steps: int = 100_000) -> int:
    """Empirical mixing time: steps until TV distance to uniform < eps."""
    n = len(graph)
    if n <= 1:
        return 0
    mu = [0.0] * n
    mu[0] = 1.0
    uniform = 1.0 / n
    P = swap_matrix(graph, c)
    for step in range(1, max_steps + 1):
        nxt = [sum(mu[i] * P[i][j] for i in range(n)) for j in range(n)]
        mu = nxt
        tv = 0.5 * sum(abs(mu[j] - uniform) for j in range(n))
        if tv < eps:
            return step
    return max_steps


# --------------------------------------------------------------------------- #
#  Sudoku conservation law                                                     #
# --------------------------------------------------------------------------- #
def row_sum(row: Sequence[int]) -> int:
    """Entry-sum of a Sudoku row (symbols 0..8); invariant equals 36."""
    return sum(row)


def is_valid_row(row: Sequence[int]) -> bool:
    """A valid row is a bijection onto {0,...,8}."""
    return sorted(row) == list(range(9))


def apply_swap(row: List[int], i: int, j: int) -> List[int]:
    """A compatible swap exchanges two entries within the line."""
    new = row[:]
    new[i], new[j] = new[j], new[i]
    return new


# --------------------------------------------------------------------------- #
#  Named example move graphs                                                   #
# --------------------------------------------------------------------------- #
def path_graph(n: int) -> Graph:
    g: Graph = {i: [] for i in range(n)}
    for i in range(n - 1):
        g[i].append(i + 1)
        g[i + 1].append(i)
    return g


def two_state_connected() -> Graph:
    return {0: [1], 1: [0]}


def two_state_disconnected() -> Graph:
    return {0: [], 1: []}


def two_components(size_a: int, size_b: int) -> Graph:
    """Two complete-graph components with no bridge between them."""
    g: Graph = {}
    a = list(range(size_a))
    b = list(range(size_a, size_a + size_b))
    for x in a:
        g[x] = [y for y in a if y != x]
    for x in b:
        g[x] = [y for y in b if y != x]
    return g


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_two_state() -> None:
    print("=" * 70)
    print("Demo 1: two-state model -- same counts, opposite gaps")
    print("=" * 70)
    c = 0.25
    conn = two_state_connected()
    disc = two_state_disconnected()
    print(f"holding rate c = {c}")
    print(f"connected  (one compatible swap):  gap = {spectral_gap(conn, c):.6f}"
          f"   (theory 2c = {2 * c})")
    print(f"disconnected (no swap):            gap = {spectral_gap(disc, c):.6f}"
          f"   (theory 0)")
    print("Both puzzles have exactly TWO completions; the gap differs solely")
    print("because of whether a compatible swap connects them.\n")


def demo_connectivity_order_parameter() -> None:
    print("=" * 70)
    print("Demo 2: connectivity, not size, is the order parameter")
    print("=" * 70)
    c = 0.1
    for n in (2, 4, 6, 8):
        g = path_graph(n)
        print(f"connected path on {n} states: connected={is_connected(g)}, "
              f"gap = {spectral_gap(g, c):.6f} > 0")
    for (a, b) in ((1, 1), (2, 2), (3, 3)):
        g = two_components(a, b)
        print(f"two components sizes ({a},{b}): connected={is_connected(g)}, "
              f"gap = {spectral_gap(g, c):.6f}")
    print()


def demo_laplacian_identity() -> None:
    print("=" * 70)
    print("Demo 3: one step of the chain equals I - c*L")
    print("=" * 70)
    g = path_graph(4)
    c = 0.2
    P = swap_matrix(g, c)
    f = [1.0, 4.0, 9.0, 16.0]
    n = len(g)
    Pf = [sum(P[i][j] * f[j] for j in range(n)) for i in range(n)]
    # (Lf)(x) = deg(x) f(x) - sum_{y~x} f(y); one step should give f - c*Lf.
    Lf = [degree(g, i) * f[i] - sum(f[j] for j in g[i]) for i in range(n)]
    ImcL = [f[i] - c * Lf[i] for i in range(n)]
    print("P f      =", [round(v, 6) for v in Pf])
    print("(I-cL) f =", [round(v, 6) for v in ImcL])
    print("match    =", all(abs(a - b) < 1e-9 for a, b in zip(Pf, ImcL)), "\n")


def demo_mixing_time() -> None:
    print("=" * 70)
    print("Demo 4: mixing time scales like 1/gap")
    print("=" * 70)
    c = 0.1
    for n in (2, 4, 6, 8, 10):
        g = path_graph(n)
        gap = spectral_gap(g, c)
        tm = mixing_time(g, c, eps=1e-3)
        print(f"path on {n:2d} states: gap = {gap:.5f}, "
              f"mixing time = {tm:5d}, gap*mixing = {gap * tm:8.2f}")
    print()


def demo_sudoku_invariant() -> None:
    print("=" * 70)
    print("Demo 5: Sudoku row-multiset conservation law (sum = 36)")
    print("=" * 70)
    row = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    print(f"valid row?           {is_valid_row(row)}")
    print(f"row sum              {row_sum(row)}  (invariant 0+1+...+8 = 36)")
    swapped = apply_swap(row, 2, 5)
    print(f"after compatible swap {swapped}")
    print(f"still valid?         {is_valid_row(swapped)}")
    print(f"row sum unchanged    {row_sum(swapped)}")
    print("Every compatible swap preserves the multiset -> level sets ->")
    print("the move graph decomposes into invariant blocks.\n")


def main() -> None:
    demo_two_state()
    demo_connectivity_order_parameter()
    demo_laplacian_identity()
    demo_mixing_time()
    demo_sudoku_invariant()


if __name__ == "__main__":
    main()
