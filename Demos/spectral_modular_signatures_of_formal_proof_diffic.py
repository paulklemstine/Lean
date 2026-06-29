"""
Numerical demonstration of the Component-Kernel Theorem and the
Spectral Modular Signature of a finite simple graph.

Ground truth (proved in Lean):

    specModSig(G) := dim_R (harmonic kernel of G) = #(connected components of G)

where the *harmonic kernel* is the space of vertex functions f : V -> R that are
constant across every edge (f(u) = f(v) whenever u ~ v).

This script computes the signature two independent ways and checks they agree:

  1. As the number of connected components (combinatorial side).
  2. As the nullity of the combinatorial Laplacian L = D - A computed by
     Gaussian elimination over the rationals (algebraic / spectral side).

It also verifies the corollaries: positivity, the vertex-count bound, the
connectivity characterization (signature == 1), the edgeless characterization
(signature == #V), and isomorphism invariance under vertex relabeling.

Self-contained: standard library only (uses fractions.Fraction for exact rank).
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Graph = Tuple[int, Set[Edge]]  # (number_of_vertices, set_of_undirected_edges)


# ---------------------------------------------------------------------------
# Graph construction helpers
# ---------------------------------------------------------------------------

def make_graph(n: int, edges: Iterable[Tuple[int, int]]) -> Graph:
    """Build a finite simple graph on vertices {0, ..., n-1}.

    Self-loops are rejected (simple graph); reversed duplicates are merged.
    """
    edge_set: Set[Edge] = set()
    for u, v in edges:
        if u == v:
            raise ValueError(f"self-loop ({u},{v}) not allowed in a simple graph")
        if not (0 <= u < n and 0 <= v < n):
            raise ValueError(f"edge ({u},{v}) out of range for {n} vertices")
        edge_set.add(frozenset((u, v)))
    return (n, edge_set)


def adjacency(g: Graph) -> List[List[int]]:
    """Dense 0/1 adjacency matrix."""
    n, edges = g
    a = [[0] * n for _ in range(n)]
    for e in edges:
        u, v = tuple(e)
        a[u][v] = 1
        a[v][u] = 1
    return a


# ---------------------------------------------------------------------------
# Combinatorial side: number of connected components (union-find)
# ---------------------------------------------------------------------------

def num_components(g: Graph) -> int:
    """Count connected components via union-find. Equals specModSig(G)."""
    n, edges = g
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[rx] = ry

    for e in edges:
        u, v = tuple(e)
        union(u, v)

    return len({find(x) for x in range(n)})


# ---------------------------------------------------------------------------
# Algebraic / spectral side: nullity of the Laplacian L = D - A
# ---------------------------------------------------------------------------

def laplacian(g: Graph) -> List[List[Fraction]]:
    """Combinatorial Laplacian L = D - A over the rationals."""
    n = g[0]
    a = adjacency(g)
    deg = [sum(a[i]) for i in range(n)]
    return [[Fraction(deg[i] if i == j else -a[i][j]) for j in range(n)]
            for i in range(n)]


def matrix_rank(mat: List[List[Fraction]]) -> int:
    """Exact rank over the rationals by Gaussian elimination."""
    m = [row[:] for row in mat]
    rows = len(m)
    cols = len(m[0]) if rows else 0
    rank = 0
    pivot_col = 0
    for r in range(rows):
        if pivot_col >= cols:
            break
        # find a pivot in column pivot_col at or below row r
        piv = None
        for rr in range(r, rows):
            if m[rr][pivot_col] != 0:
                piv = rr
                break
        if piv is None:
            pivot_col += 1
            # retry same row with next column
            # (decrement r effect via while-style loop)
            # implement by recursion-free adjustment:
            return matrix_rank_from(m, r, pivot_col)
        m[r], m[piv] = m[piv], m[r]
        inv = m[r][pivot_col]
        m[r] = [x / inv for x in m[r]]
        for rr in range(rows):
            if rr != r and m[rr][pivot_col] != 0:
                factor = m[rr][pivot_col]
                m[rr] = [a - factor * b for a, b in zip(m[rr], m[r])]
        rank += 1
        pivot_col += 1
    return rank


def matrix_rank_from(m: List[List[Fraction]], start_row: int,
                     start_col: int) -> int:
    """Continue Gaussian elimination from a given (row, col); helper."""
    rows = len(m)
    cols = len(m[0]) if rows else 0
    rank = start_row
    pivot_col = start_col
    for r in range(start_row, rows):
        while pivot_col < cols:
            piv = None
            for rr in range(r, rows):
                if m[rr][pivot_col] != 0:
                    piv = rr
                    break
            if piv is None:
                pivot_col += 1
                continue
            m[r], m[piv] = m[piv], m[r]
            inv = m[r][pivot_col]
            m[r] = [x / inv for x in m[r]]
            for rr in range(rows):
                if rr != r and m[rr][pivot_col] != 0:
                    factor = m[rr][pivot_col]
                    m[rr] = [a - factor * b for a, b in zip(m[rr], m[r])]
            rank += 1
            pivot_col += 1
            break
    return rank


def laplacian_nullity(g: Graph) -> int:
    """Nullity of L = #V - rank(L). Equals specModSig(G) and #components."""
    n = g[0]
    if n == 0:
        return 0
    return n - matrix_rank(laplacian(g))


# ---------------------------------------------------------------------------
# The signature and its corollaries
# ---------------------------------------------------------------------------

def spec_mod_sig(g: Graph) -> int:
    """Spectral modular signature, computed via the cheap component count."""
    return num_components(g)


def is_connected(g: Graph) -> bool:
    n = g[0]
    return n > 0 and spec_mod_sig(g) == 1


def is_edgeless(g: Graph) -> bool:
    return len(g[1]) == 0


def relabel(g: Graph, perm: List[int]) -> Graph:
    """Apply a vertex permutation perm (a bijection of {0,..,n-1})."""
    n, edges = g
    new_edges = {frozenset((perm[u], perm[v])) for u, v in (tuple(e) for e in edges)}
    return (n, new_edges)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def show_graph(name: str, g: Graph) -> None:
    comp = num_components(g)
    null = laplacian_nullity(g)
    sig = spec_mod_sig(g)
    n = g[0]
    assert comp == null == sig, f"MISMATCH on {name}: {comp}, {null}, {sig}"
    print(f"{name:32s} |V|={n:2d}  #edges={len(g[1]):2d}  "
          f"components={comp:2d}  nullity(L)={null:2d}  signature={sig:2d}")
    # corollaries
    assert sig <= n, "vertex-count bound violated"
    if n > 0:
        assert sig >= 1, "positivity violated"
    assert is_connected(g) == (sig == 1)
    assert is_edgeless(g) == (sig == n)


def main() -> None:
    banner("Component-Kernel Theorem:  specModSig(G) = #components(G) = nullity(D-A)")

    # 1. Path P4: 0-1-2-3  -> connected, signature 1
    p4 = make_graph(4, [(0, 1), (1, 2), (2, 3)])
    show_graph("Path P4 (connected)", p4)

    # 2. Cycle C5 -> connected, signature 1
    c5 = make_graph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])
    show_graph("Cycle C5 (connected)", c5)

    # 3. Two disjoint triangles -> 2 components, signature 2
    two_tri = make_graph(6, [(0, 1), (1, 2), (2, 0), (3, 4), (4, 5), (5, 3)])
    show_graph("Two disjoint triangles", two_tri)

    # 4. Edgeless graph on 5 vertices -> signature 5 = |V| (maximal)
    edgeless = make_graph(5, [])
    show_graph("Edgeless E5 (maximal)", edgeless)

    # 5. Complete graph K4 -> connected, signature 1
    k4 = make_graph(4, list(combinations(range(4), 2)))
    show_graph("Complete K4 (connected)", k4)

    # 6. A forest: star + isolated vertex + an edge -> 3 components
    mixed = make_graph(8, [(0, 1), (0, 2), (0, 3), (5, 6)])
    # vertices: {0,1,2,3} star, {4} isolated, {5,6} edge, {7} isolated -> 4 comps
    show_graph("Mixed forest", mixed)

    banner("Isomorphism invariance:  relabeling vertices preserves the signature")
    perm = [3, 0, 5, 1, 4, 2]  # a permutation of {0,..,5}
    g = two_tri
    h = relabel(g, perm)
    sg, sh = spec_mod_sig(g), spec_mod_sig(h)
    print(f"original signature = {sg}, relabeled signature = {sh}  -> "
          f"{'EQUAL (invariant)' if sg == sh else 'DIFFERENT (bug!)'}")
    assert sg == sh

    banner("Adding an edge fuses two components: signature is monotone non-increasing")
    base = make_graph(6, [(0, 1), (2, 3), (4, 5)])  # 3 disjoint edges -> sig 3
    print(f"three disjoint edges:           signature = {spec_mod_sig(base)}")
    plus1 = make_graph(6, [(0, 1), (2, 3), (4, 5), (1, 2)])  # fuse two -> sig 2
    print(f"after adding edge (1,2):        signature = {spec_mod_sig(plus1)}")
    plus2 = make_graph(6, [(0, 1), (2, 3), (4, 5), (1, 2), (3, 4)])  # -> sig 1
    print(f"after adding edge (3,4):        signature = {spec_mod_sig(plus2)}")
    assert spec_mod_sig(base) == 3
    assert spec_mod_sig(plus1) == 2
    assert spec_mod_sig(plus2) == 1

    banner("All checks passed: combinatorial = algebraic = spectral on every example.")


if __name__ == "__main__":
    main()
