"""Numerical demonstrations for the balanced / clique-Helly bridge.

This self-contained script illustrates the central results:

* the octahedron K_{2,2,2} is the complement of the perfect matching 3K_2;
* three of its transversal triangles form a "bad triple": pairwise
  intersecting maximal cliques with empty total intersection;
* that bad triple simultaneously breaks the clique-Helly property (a Helly
  fact about set systems) and balancedness (a fact about 0/1 matrices);
* both failures come from the identical 3x3 two-per-row-and-column submatrix.

Run with:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Sequence, Set, Tuple

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]
Clique = FrozenSet[Vertex]


# --------------------------------------------------------------------------
# Graph builders
# --------------------------------------------------------------------------
def make_graph(n: int, adj: Sequence[Tuple[Vertex, Vertex]]) -> Graph:
    """Build an undirected simple graph on vertices 0..n-1 from an edge list."""
    g: Graph = {v: set() for v in range(n)}
    for u, v in adj:
        if u != v:
            g[u].add(v)
            g[v].add(u)
    return g


def antipodal_pair(i: Vertex) -> int:
    """Antipodal-pair index: {0,1}->0, {2,3}->1, {4,5}->2."""
    return i // 2


def octahedron() -> Graph:
    """K_{2,2,2} on 6 vertices: adjacent iff in different antipodal pairs."""
    edges = [
        (i, j)
        for i in range(6)
        for j in range(i + 1, 6)
        if antipodal_pair(i) != antipodal_pair(j)
    ]
    return make_graph(6, edges)


def three_k2() -> Graph:
    """Perfect matching 3K_2: adjacent iff same antipodal pair."""
    edges = [(0, 1), (2, 3), (4, 5)]
    return make_graph(6, edges)


def complement(g: Graph) -> Graph:
    """Complement graph on the same vertex set."""
    n = len(g)
    edges = [
        (i, j)
        for i in range(n)
        for j in range(i + 1, n)
        if j not in g[i]
    ]
    return make_graph(n, edges)


# --------------------------------------------------------------------------
# Cliques
# --------------------------------------------------------------------------
def is_clique(g: Graph, s: Sequence[Vertex]) -> bool:
    """Every pair of distinct vertices in s is adjacent."""
    return all(v in g[u] for u, v in combinations(s, 2))


def maximal_cliques(g: Graph) -> List[Clique]:
    """All maximal cliques via brute-force subset search (small graphs)."""
    verts = list(g)
    cliques: List[Clique] = []
    for r in range(1, len(verts) + 1):
        for combo in combinations(verts, r):
            if not is_clique(g, combo):
                continue
            outside = [w for w in verts if w not in combo]
            if all(not is_clique(g, tuple(combo) + (w,)) for w in outside):
                cliques.append(frozenset(combo))
    # dedup while preserving order
    seen: Set[Clique] = set()
    out: List[Clique] = []
    for c in cliques:
        if c not in seen:
            seen.add(c)
            out.append(c)
    return out


# --------------------------------------------------------------------------
# The bad triple and its two consequences
# --------------------------------------------------------------------------
def is_bad_triple(k0: Clique, k1: Clique, k2: Clique) -> bool:
    """Pairwise intersecting maximal cliques with empty total intersection."""
    pairwise = (k0 & k1) and (k0 & k2) and (k1 & k2)
    total_empty = not (k0 & k1 & k2)
    return bool(pairwise) and total_empty


def find_bad_triple(cliques: Sequence[Clique]) -> Tuple[Clique, Clique, Clique] | None:
    """Return a bad triple among the given maximal cliques, if any."""
    for k0, k1, k2 in combinations(cliques, 3):
        if is_bad_triple(k0, k1, k2):
            return (k0, k1, k2)
    return None


def clique_helly_violation(cliques: Sequence[Clique]) -> bool:
    """True iff some subfamily is pairwise intersecting with empty overlap."""
    return find_bad_triple(cliques) is not None


def incidence_submatrix(
    rows: Sequence[Clique], cols: Sequence[Vertex]
) -> List[List[int]]:
    """0/1 submatrix M[i][j] = 1 iff cols[j] in rows[i]."""
    return [[1 if c in k else 0 for c in cols] for k in rows]


def is_two_regular_odd(matrix: List[List[int]]) -> bool:
    """Square, odd order, exactly two 1's in every row and column."""
    k = len(matrix)
    if k % 2 == 0 or any(len(row) != k for row in matrix):
        return False
    rows_ok = all(sum(row) == 2 for row in matrix)
    cols_ok = all(sum(matrix[i][j] for i in range(k)) == 2 for j in range(k))
    return rows_ok and cols_ok


# --------------------------------------------------------------------------
# Demonstration
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 68)
    print("The octahedron as the bridge between two worlds")
    print("=" * 68)

    oct_g = octahedron()
    comp = complement(three_k2())

    same = all(oct_g[v] == comp[v] for v in oct_g)
    print(f"\n(3K_2)^c == octahedron K_(2,2,2)? {same}")

    cliques = maximal_cliques(oct_g)
    print(f"\nMaximal cliques of the octahedron ({len(cliques)} of them):")
    for c in cliques:
        print("   ", sorted(c))

    triple = find_bad_triple(cliques)
    assert triple is not None, "octahedron must carry a bad triple"
    k0, k1, k2 = triple
    print("\nA bad triple (pairwise intersecting, empty total overlap):")
    print("   K0 =", sorted(k0))
    print("   K1 =", sorted(k1))
    print("   K2 =", sorted(k2))
    print("   K0 & K1 =", sorted(k0 & k1))
    print("   K0 & K2 =", sorted(k0 & k2))
    print("   K1 & K2 =", sorted(k1 & k2))
    print("   K0 & K1 & K2 =", sorted(k0 & k1 & k2))

    print("\n=> Clique-Helly property FAILS:", clique_helly_violation(cliques))

    # Choose the three meeting vertices as columns to expose the pattern.
    a = next(iter(k1 & k2))
    b = next(iter(k0 & k2))
    c = next(iter(k0 & k1))
    cols = [a, b, c]
    sub = incidence_submatrix([k0, k1, k2], cols)
    print(f"\n3x3 incidence submatrix on columns {cols} (rows K0,K1,K2):")
    for row in sub:
        print("   ", row)
    print("=> odd two-per-row-and-column forbidden pattern:", is_two_regular_odd(sub))
    print("=> Balancedness FAILS (same configuration).")

    print("\n" + "-" * 68)
    print("Sanity check: a triangle-free / bipartite graph is balanced &")
    print("clique-Helly. Take a 4-cycle C4 (0-1-2-3-0).")
    c4 = make_graph(4, [(0, 1), (1, 2), (2, 3), (3, 0)])
    c4_cliques = maximal_cliques(c4)
    print("   maximal cliques of C4:", [sorted(x) for x in c4_cliques])
    print("   clique-Helly violation:", clique_helly_violation(c4_cliques))


if __name__ == "__main__":
    main()
