"""
Numerical demonstrations for:

    Non-embeddability of the Petersen graph into tropical abelian Cayley graphs.

This self-contained script illustrates the three pillars of the theorem:

  1. The Petersen graph (Kneser model K(5,2)) is NOT 2-colorable: it contains
     an odd (length-5) closed walk, and BFS 2-coloring fails.

  2. An odd-valuation Cayley graph -- vertices of an abelian group A, with two
     vertices adjacent iff their difference has ODD tropical valuation -- IS
     2-colorable, certified by the parity of the valuation v(g) mod 2.

  3. Coloring is preserved by isometric maps, so a non-bipartite graph cannot
     embed isometrically into a bipartite host. Hence the Petersen graph has no
     isometric embedding into any odd-valuation Cayley graph.

Everything is elementary and dependency-free (standard library only).
"""

from __future__ import annotations

from collections import deque
from itertools import combinations, product
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Tuple

# ---------------------------------------------------------------------------
# Generic graph utilities
# ---------------------------------------------------------------------------

Vertex = object
Graph = Dict[Vertex, List[Vertex]]


def bfs_distances(graph: Graph, source: Vertex) -> Dict[Vertex, int]:
    """Shortest-path (unweighted) distances from `source` via breadth-first search."""
    dist: Dict[Vertex, int] = {source: 0}
    queue: deque = deque([source])
    while queue:
        u = queue.popleft()
        for w in graph[u]:
            if w not in dist:
                dist[w] = dist[u] + 1
                queue.append(w)
    return dist


def two_color(graph: Graph) -> Optional[Dict[Vertex, int]]:
    """Return a proper 2-coloring if one exists, else None (graph not bipartite)."""
    color: Dict[Vertex, int] = {}
    for start in graph:
        if start in color:
            continue
        color[start] = 0
        queue: deque = deque([start])
        while queue:
            u = queue.popleft()
            for w in graph[u]:
                if w not in color:
                    color[w] = 1 - color[u]
                    queue.append(w)
                elif color[w] == color[u]:
                    return None
    return color


def is_proper_coloring(graph: Graph, coloring: Dict[Vertex, int]) -> bool:
    """Check that no edge joins two equally-colored vertices."""
    return all(coloring[u] != coloring[w] for u in graph for w in graph[u])


# ---------------------------------------------------------------------------
# 1. The Petersen graph as the Kneser graph K(5,2)
# ---------------------------------------------------------------------------

PetersenVertex = FrozenSet[int]


def build_petersen() -> Graph:
    """Kneser graph K(5,2): 2-subsets of {0..4}, adjacent iff disjoint."""
    verts: List[PetersenVertex] = [frozenset(s) for s in combinations(range(5), 2)]
    graph: Graph = {v: [] for v in verts}
    for a, b in combinations(verts, 2):
        if a.isdisjoint(b):
            graph[a].append(b)
            graph[b].append(a)
    return graph


def petersen_pentagon() -> List[PetersenVertex]:
    """The explicit odd (length-5) closed walk used in the proof."""
    return [
        frozenset({0, 1}),
        frozenset({2, 3}),
        frozenset({4, 0}),
        frozenset({1, 2}),
        frozenset({3, 4}),
        frozenset({0, 1}),
    ]


def is_closed_walk(graph: Graph, walk: List[Vertex]) -> bool:
    """True iff consecutive vertices are adjacent and the walk returns to start."""
    if walk[0] != walk[-1]:
        return False
    return all(walk[i + 1] in graph[walk[i]] for i in range(len(walk) - 1))


# ---------------------------------------------------------------------------
# 2. Odd-valuation tropical abelian Cayley graphs (finite window of Z^k)
# ---------------------------------------------------------------------------

LatticePoint = Tuple[int, ...]


def coordinate_sum_valuation(point: LatticePoint) -> int:
    """The tropical valuation v(x_1,...,x_k) = x_1 + ... + x_k."""
    return sum(point)


def build_odd_valuation_cayley(
    dim: int,
    radius: int,
    valuation: Callable[[LatticePoint], int] = coordinate_sum_valuation,
) -> Graph:
    """
    Finite window [-radius, radius]^dim of the Cayley graph of Z^dim whose
    connection set is {a : valuation(a) is odd}. Two points are adjacent iff
    the valuation of their difference is odd.
    """
    pts: List[LatticePoint] = list(
        product(range(-radius, radius + 1), repeat=dim)
    )
    graph: Graph = {p: [] for p in pts}
    for p, q in combinations(pts, 2):
        diff: LatticePoint = tuple(pi - qi for pi, qi in zip(p, q))
        if valuation(diff) % 2 == 1:
            graph[p].append(q)
            graph[q].append(p)
    return graph


def valuation_parity_coloring(
    graph: Graph, valuation: Callable[[LatticePoint], int]
) -> Dict[Vertex, int]:
    """The certificate 2-coloring g -> v(g) mod 2."""
    return {p: valuation(p) % 2 for p in graph}


# ---------------------------------------------------------------------------
# 3. Coloring pullback under isometry (the metric obstruction)
# ---------------------------------------------------------------------------

def pullback_coloring(
    embedding: Dict[Vertex, Vertex], host_coloring: Dict[Vertex, int]
) -> Dict[Vertex, int]:
    """Pull a host coloring back along f: c'(v) = c(f(v))."""
    return {v: host_coloring[embedding[v]] for v in embedding}


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_petersen_not_bipartite() -> None:
    print("=" * 70)
    print("1. The Petersen graph K(5,2) is NOT 2-colorable")
    print("=" * 70)
    G = build_petersen()
    print(f"   vertices: {len(G)}   edges: {sum(len(a) for a in G.values()) // 2}")
    degrees = {len(a) for a in G.values()}
    print(f"   degree set (3-regular): {degrees}")

    walk = petersen_pentagon()
    print(f"   explicit closed walk length {len(walk) - 1}: "
          f"{[sorted(s) for s in walk]}")
    print(f"   is a valid closed walk?  {is_closed_walk(G, walk)}")
    print(f"   length is odd?           {(len(walk) - 1) % 2 == 1}")

    coloring = two_color(G)
    print(f"   BFS 2-coloring result:   "
          f"{'FAILED (not bipartite)' if coloring is None else 'succeeded'}")
    assert coloring is None
    print()


def demo_cayley_is_bipartite() -> None:
    print("=" * 70)
    print("2. Odd-valuation Cayley graph of Z^k IS 2-colorable")
    print("=" * 70)
    for dim, radius in [(1, 4), (2, 2), (3, 1)]:
        H = build_odd_valuation_cayley(dim, radius)
        cert = valuation_parity_coloring(H, coordinate_sum_valuation)
        proper = is_proper_coloring(H, cert)
        bfs = two_color(H)
        print(f"   Z^{dim} window radius {radius}: "
              f"{len(H)} vertices, "
              f"parity coloring proper? {proper}, "
              f"BFS bipartite? {bfs is not None}")
        assert proper and bfs is not None
    print()


def demo_pullback_principle() -> None:
    print("=" * 70)
    print("3. Coloring is preserved by isometric maps  =>  no embedding")
    print("=" * 70)
    # A small sanity check of the pullback: any map whose image edges are
    # properly colored pulls a proper coloring back. We verify on a triangle
    # mapped injectively into a properly-3-colored triangle host.
    triangle: Graph = {"a": ["b", "c"], "b": ["a", "c"], "c": ["a", "b"]}
    host: Graph = {0: [1, 2], 1: [0, 2], 2: [0, 1]}
    host_coloring = {0: 0, 1: 1, 2: 2}
    embed = {"a": 0, "b": 1, "c": 2}
    pulled = pullback_coloring(embed, host_coloring)
    print(f"   pulled-back coloring proper on source? "
          f"{is_proper_coloring(triangle, pulled)}")

    print()
    print("   Consequence for Petersen (n = 2):")
    print("     - Petersen is NOT 2-colorable        (Section 1)")
    print("     - odd-valuation Cayley host IS 2-colorable (Section 2)")
    print("     - isometry would pull the 2-coloring back to Petersen")
    print("     => contradiction; NO isometric embedding exists.")
    print()


def demo_petersen_metric() -> None:
    print("=" * 70)
    print("4. Petersen metric profile (diameter 2, girth 5)")
    print("=" * 70)
    G = build_petersen()
    v0 = frozenset({0, 1})
    dist = bfs_distances(G, v0)
    diameter = max(dist.values())
    profile: Dict[int, int] = {}
    for d in dist.values():
        profile[d] = profile.get(d, 0) + 1
    print(f"   from {sorted(v0)}: distance distribution {dict(sorted(profile.items()))}")
    print(f"   eccentricity (=diameter, vertex-transitive): {diameter}")
    print()


def main() -> None:
    demo_petersen_not_bipartite()
    demo_cayley_is_bipartite()
    demo_pullback_principle()
    demo_petersen_metric()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
