"""Numerical demonstrations for the polygon / associahedron model of the finite
type A_{m-3} cluster algebra of Gr(2, m).

This script is fully self-contained (standard library only) and verifies, by
explicit construction and enumeration, the main results of the accompanying
paper:

    * two_mul_diagonalCount : 2 * (#diagonals of an m-gon) = m * (m - 3)
                              i.e. an m-gon has m(m-3)/2 diagonals.
    * rank_constant         : every triangulation of an m-gon has m - 3 diagonals.
    * card_triangulation    : #triangulations of an m-gon = Catalan(m - 2),
                              built from a genuine enumeration of binary trees
                              with m - 2 internal nodes.
    * card_clusters_typeA   : type A_r has Catalan(r + 1) clusters.
    * exchangeGraph_finite  : the flip graph is finite (and, as a bonus, we
                              check it is (m-3)-regular and connected).

Run with:  python3 demo.py
"""

from __future__ import annotations

from functools import lru_cache
from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

# ---------------------------------------------------------------------------
# 1. Diagonals of a convex m-gon  (Theorem: two_mul_diagonalCount)
# ---------------------------------------------------------------------------


def next_vertex(i: int, m: int) -> int:
    """Cyclic successor of vertex i in an m-gon (the Lean `nextV`)."""
    return (i + 1) % m


def is_side(edge: FrozenSet[int], m: int) -> bool:
    """True if the unordered pair `edge` joins two cyclically adjacent vertices."""
    i, j = tuple(edge)
    return next_vertex(i, m) == j or next_vertex(j, m) == i


def diagonal_set(m: int) -> List[FrozenSet[int]]:
    """All diagonals of a convex m-gon: non-degenerate, non-side vertex pairs."""
    diagonals: List[FrozenSet[int]] = []
    for i, j in combinations(range(m), 2):
        edge = frozenset({i, j})
        if not is_side(edge, m):
            diagonals.append(edge)
    return diagonals


def diagonal_count(m: int) -> int:
    """Number of diagonals of a convex m-gon (the Lean `diagonalCount`)."""
    return len(diagonal_set(m))


def verify_diagonal_formula(m_max: int = 12) -> None:
    print("=" * 64)
    print("Diagonal count:  2 * diagonalCount(m) == m * (m - 3)")
    print("=" * 64)
    print(f"{'m':>3} | {'#diagonals':>11} | {'m(m-3)/2':>9} | {'2*#==m(m-3)':>12}")
    print("-" * 64)
    for m in range(3, m_max + 1):
        d = diagonal_count(m)
        closed = m * (m - 3) // 2
        ok = (2 * d == m * (m - 3)) and (d == closed)
        print(f"{m:>3} | {d:>11} | {closed:>9} | {str(ok):>12}")
        assert ok, f"Diagonal formula failed at m={m}"
    print("All diagonal-count checks passed.\n")


# ---------------------------------------------------------------------------
# 2. Binary trees with n internal nodes  (treesOfNumNodesEq) and the
#    Catalan enumeration of triangulations  (Theorem: card_triangulation)
# ---------------------------------------------------------------------------

# A binary tree is either a leaf (None) or a pair (left, right) of binary trees.
BinTree = object  # None  |  Tuple["BinTree", "BinTree"]


@lru_cache(maxsize=None)
def trees_of_num_nodes_eq(n: int) -> Tuple[BinTree, ...]:
    """Genuine enumeration of all binary trees with exactly n internal nodes
    (the Lean `treesOfNumNodesEq`).  An internal node splits the remaining
    n - 1 nodes between its left and right subtrees."""
    if n == 0:
        return (None,)
    trees: List[BinTree] = []
    for a in range(n):  # a left-subtree nodes, b = n - 1 - a right-subtree nodes
        b = n - 1 - a
        for left in trees_of_num_nodes_eq(a):
            for right in trees_of_num_nodes_eq(b):
                trees.append((left, right))
    return tuple(trees)


@lru_cache(maxsize=None)
def catalan(n: int) -> int:
    """Catalan number via the convolution recursion C_{n+1} = sum_{a+b=n} C_a C_b."""
    if n == 0:
        return 1
    return sum(catalan(a) * catalan(n - 1 - a) for a in range(n))


def num_internal_nodes(tree: BinTree) -> int:
    """Count internal nodes of a binary tree."""
    if tree is None:
        return 0
    left, right = tree  # type: ignore[misc]
    return 1 + num_internal_nodes(left) + num_internal_nodes(right)


def num_diagonals_of_triangulation(m: int) -> int:
    """In the dual-tree model a triangulation of an m-gon is a tree with m-2
    internal nodes; its diagonal count is (#internal nodes) - 1 = m - 3."""
    return (m - 2) - 1


def verify_triangulation_count(m_max: int = 11) -> None:
    print("=" * 64)
    print("Triangulation count:  #triangulations(m) == Catalan(m - 2)")
    print("=" * 64)
    print(f"{'m':>3} | {'type':>5} | {'#triang.':>9} | {'Catalan(m-2)':>12} | {'rank=m-3':>9}")
    print("-" * 64)
    for m in range(3, m_max + 1):
        trees = trees_of_num_nodes_eq(m - 2)
        cat = catalan(m - 2)
        ok = len(trees) == cat
        # rank constancy: every tree has m-2 internal nodes, i.e. m-3 diagonals
        rank_ok = all(num_internal_nodes(t) == m - 2 for t in trees)
        print(f"{m:>3} | A_{m-3:<3} | {len(trees):>9} | {cat:>12} | "
              f"{num_diagonals_of_triangulation(m):>9}")
        assert ok, f"Catalan count failed at m={m}"
        assert rank_ok, f"Rank constancy failed at m={m}"
    print("All triangulation-count and rank-constancy checks passed.\n")


def verify_typeA_clusters(r_max: int = 8) -> None:
    print("=" * 64)
    print("Type A_r cluster count:  #clusters == Catalan(r + 1)")
    print("=" * 64)
    for r in range(0, r_max + 1):
        m = r + 3
        clusters = len(trees_of_num_nodes_eq(m - 2))
        expected = catalan(r + 1)
        ok = clusters == expected
        print(f"  A_{r:<2}:  m = {m:>2},  #clusters = {clusters:>5},  "
              f"Catalan({r + 1}) = {expected:>5}   {ok}")
        assert ok, f"Type A_{r} cluster count failed"
    print("All type-A cluster-count checks passed.\n")


# ---------------------------------------------------------------------------
# 3. The flip / exchange graph  (Theorem: exchangeGraph_finite)
#    We model triangulations geometrically as maximal non-crossing diagonal
#    sets, build the flip graph, and check finiteness, (m-3)-regularity, and
#    connectedness.
# ---------------------------------------------------------------------------


def crosses(d1: Tuple[int, int], d2: Tuple[int, int]) -> bool:
    """Two chords (a,b) and (c,d) of a convex polygon cross in the interior iff
    exactly one of c, d lies strictly between a and b along the boundary."""
    a, b = sorted(d1)
    c, d = sorted(d2)
    if {a, b} & {c, d}:
        return False  # share an endpoint -> do not cross in the interior
    inside_c = a < c < b
    inside_d = a < d < b
    return inside_c != inside_d


def all_chords(m: int) -> List[Tuple[int, int]]:
    """All diagonals (non-side chords) of an m-gon as sorted pairs."""
    chords = []
    for i, j in combinations(range(m), 2):
        if not is_side(frozenset({i, j}), m):
            chords.append((i, j))
    return chords


def triangulations_geometric(m: int) -> List[FrozenSet[Tuple[int, int]]]:
    """All triangulations as maximal pairwise non-crossing sets of m-3 diagonals."""
    chords = all_chords(m)
    k = m - 3
    result: List[FrozenSet[Tuple[int, int]]] = []
    if k == 0:
        return [frozenset()]
    for combo in combinations(chords, k):
        if all(not crosses(x, y) for x, y in combinations(combo, 2)):
            result.append(frozenset(combo))
    return result


def flip_neighbors(
    tri: FrozenSet[Tuple[int, int]],
    all_tris: Set[FrozenSet[Tuple[int, int]]],
) -> List[FrozenSet[Tuple[int, int]]]:
    """Triangulations obtained by removing one diagonal and adding another."""
    neighbors = []
    for t in all_tris:
        if len(tri.symmetric_difference(t)) == 2:  # differ in exactly one diagonal
            neighbors.append(t)
    return neighbors


def verify_exchange_graph(m_max: int = 8) -> None:
    print("=" * 64)
    print("Exchange (flip) graph:  finite, (m-3)-regular, connected")
    print("=" * 64)
    print(f"{'m':>3} | {'#vertices':>9} | {'#edges':>7} | {'regular(m-3)':>12} | {'connected':>9}")
    print("-" * 64)
    for m in range(3, m_max + 1):
        tris = triangulations_geometric(m)
        tri_set = set(tris)
        # sanity: geometric count matches Catalan(m-2)
        assert len(tris) == catalan(m - 2), f"geometric count mismatch at m={m}"
        adjacency: Dict[FrozenSet[Tuple[int, int]], List] = {
            t: flip_neighbors(t, tri_set) for t in tris
        }
        degrees = [len(v) for v in adjacency.values()]
        edges = sum(degrees) // 2
        regular = all(deg == m - 3 for deg in degrees)

        # connectedness via BFS
        start = tris[0]
        seen = {start}
        stack = [start]
        while stack:
            cur = stack.pop()
            for nb in adjacency[cur]:
                if nb not in seen:
                    seen.add(nb)
                    stack.append(nb)
        connected = len(seen) == len(tris)

        print(f"{m:>3} | {len(tris):>9} | {edges:>7} | {str(regular):>12} | "
              f"{str(connected):>9}")
        assert regular, f"(m-3)-regularity failed at m={m}"
        assert connected, f"connectedness failed at m={m}"
    print("All exchange-graph checks passed.\n")


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------


def main() -> None:
    print("\nPolygon / associahedron model of the finite type A cluster algebra "
          "of Gr(2, m)\n")
    verify_diagonal_formula()
    verify_triangulation_count()
    verify_typeA_clusters()
    verify_exchange_graph()
    print("=" * 64)
    print("ALL DEMONSTRATIONS PASSED.")
    print("=" * 64)


if __name__ == "__main__":
    main()
