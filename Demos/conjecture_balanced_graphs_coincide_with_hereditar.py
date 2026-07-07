"""
Numerical demonstrations for:

    The Octahedron as the Minimal Obstruction to Hereditary Clique-Helliness

This self-contained script verifies, by direct combinatorial computation, that
the octahedron K_{2,2,2} = complement of 3K_2 is NOT clique-Helly. It exhibits
three maximal cliques that pairwise intersect yet have empty common intersection,
and it contrasts this with a graph that IS clique-Helly.

All functions are inlined and use only the Python standard library.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]
Clique = FrozenSet[Vertex]


# ---------------------------------------------------------------------------
# Graph construction
# ---------------------------------------------------------------------------
def octahedron() -> Graph:
    """Return the octahedron K_{2,2,2} on vertices 0..5.

    Vertices are split into parts by i // 2: {0,1}, {2,3}, {4,5}.
    Two distinct vertices are adjacent iff they lie in different parts.
    """
    verts = list(range(6))
    adj: Graph = {v: set() for v in verts}
    for u, v in combinations(verts, 2):
        if u // 2 != v // 2:
            adj[u].add(v)
            adj[v].add(u)
    return adj


def complete_graph(n: int) -> Graph:
    """Return the complete graph K_n (a clique-Helly graph)."""
    verts = list(range(n))
    return {v: {w for w in verts if w != v} for v in verts}


# ---------------------------------------------------------------------------
# Clique machinery
# ---------------------------------------------------------------------------
def is_clique(graph: Graph, s: Set[Vertex]) -> bool:
    """True iff every two distinct vertices of s are adjacent."""
    return all(v in graph[u] for u, v in combinations(sorted(s), 2))


def maximal_cliques(graph: Graph) -> List[Clique]:
    """Enumerate all maximal cliques by brute force over subsets.

    Adequate for the small graphs in this demo; exponential in general.
    """
    verts = sorted(graph)
    cliques: List[Set[Vertex]] = []
    for r in range(1, len(verts) + 1):
        for combo in combinations(verts, r):
            s = set(combo)
            if is_clique(graph, s):
                cliques.append(s)
    # keep only maximal ones
    maximal: List[Clique] = []
    for s in cliques:
        if not any(s < t for t in cliques):
            maximal.append(frozenset(s))
    return maximal


def pairwise_intersecting(family: List[Clique]) -> bool:
    """True iff every two members of the family share a vertex."""
    return all(len(a & b) > 0 for a, b in combinations(family, 2))


def common_intersection(family: List[Clique]) -> FrozenSet[Vertex]:
    """Intersection of all members of the family."""
    if not family:
        return frozenset()
    result = set(family[0])
    for c in family[1:]:
        result &= c
    return frozenset(result)


def is_clique_helly(graph: Graph) -> Tuple[bool, List[Clique]]:
    """Test the clique-Helly property.

    Returns (True, []) if clique-Helly. Otherwise returns
    (False, witness) where witness is a pairwise-intersecting family of
    maximal cliques with empty common intersection.
    """
    maximal = maximal_cliques(graph)
    for r in range(2, len(maximal) + 1):
        for family in combinations(maximal, r):
            fam = list(family)
            if pairwise_intersecting(fam) and len(common_intersection(fam)) == 0:
                return False, fam
    return True, []


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_octahedron_not_helly() -> None:
    print("=" * 70)
    print("Octahedron K_{2,2,2}: NOT clique-Helly")
    print("=" * 70)
    g = octahedron()

    A, B, C = frozenset({0, 2, 4}), frozenset({0, 3, 5}), frozenset({1, 2, 5})
    for name, s in [("A", A), ("B", B), ("C", C)]:
        print(f"  {name} = {set(s)}   is_clique = {is_clique(g, set(s))}")

    print(f"\n  A ∩ B = {set(A & B)}")
    print(f"  A ∩ C = {set(A & C)}")
    print(f"  B ∩ C = {set(B & C)}")
    print(f"  pairwise intersecting = {pairwise_intersecting([A, B, C])}")
    print(f"  A ∩ B ∩ C = {set(common_intersection([A, B, C]))}")

    helly, witness = is_clique_helly(g)
    print(f"\n  clique-Helly = {helly}")
    if not helly:
        print(f"  witness family (pairwise meet, empty core):")
        for c in witness:
            print(f"      {set(c)}")
    assert helly is False, "Octahedron must fail the Helly property"
    print("  [verified] octahedron is NOT clique-Helly\n")


def demo_complete_graph_is_helly() -> None:
    print("=" * 70)
    print("Complete graph K_5: clique-Helly (single maximal clique)")
    print("=" * 70)
    g = complete_graph(5)
    mc = maximal_cliques(g)
    print(f"  maximal cliques: {[set(c) for c in mc]}")
    helly, _ = is_clique_helly(g)
    print(f"  clique-Helly = {helly}")
    assert helly is True
    print("  [verified] K_5 is clique-Helly\n")


def demo_clique_matrix() -> None:
    print("=" * 70)
    print("Clique matrix of the octahedron (rows = vertices, cols = cliques)")
    print("=" * 70)
    g = octahedron()
    mc = sorted((tuple(sorted(c)) for c in maximal_cliques(g)))
    print(f"  number of maximal cliques = {len(mc)} (expected 8 triangles)")
    header = "      " + " ".join(f"{c}" for c in mc)
    print(header)
    for v in range(6):
        row = " ".join(" 1 " if v in c else " . " for c in mc)
        print(f"  v{v}: {row}")
    print()


if __name__ == "__main__":
    demo_octahedron_not_helly()
    demo_complete_graph_is_helly()
    demo_clique_matrix()
    print("All demonstrations completed successfully.")
