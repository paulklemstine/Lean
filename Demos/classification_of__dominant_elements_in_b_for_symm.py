"""
Numerical demonstration of the degree criterion for dominance of the weights
lambda_{D,I} = 2*rho - beta_I - beta_D in the simply-laced case.

Core facts demonstrated:
  * Coroot pairing:  <beta_S, alpha_i^v> = 2 - deg_S(i)   if i in S
                                         = - deg_S(i)      if i not in S
  * Whole-diagram coordinate identity:
        <lambda_{D,V}, alpha_i^v> = deg(i) + deg_D(i) - 2*[i in D]
  * Dominance criterion (I = whole diagram):
        lambda_{D,V} dominant  <=>  for all i in D:  deg(i) + deg_D(i) >= 2
  * Leaf obstruction: singleton {v} is dominant iff deg(v) >= 2
  * Forest characterization: a connected graph has a dominant singleton at
    every vertex iff every vertex has degree >= 2 iff it contains a cycle.

Self-contained: uses only the Python standard library.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

# A simple graph is stored as: vertices (a set) + an adjacency map v -> set of neighbors.
Graph = Tuple[Set[int], Dict[int, Set[int]]]


def make_graph(vertices: Iterable[int], edges: Iterable[Tuple[int, int]]) -> Graph:
    """Build a finite simple graph (irreflexive, symmetric) from vertices and edges."""
    V: Set[int] = set(vertices)
    adj: Dict[int, Set[int]] = {v: set() for v in V}
    for (a, b) in edges:
        if a == b:
            raise ValueError("simple graphs have no loops")
        adj[a].add(b)
        adj[b].add(a)
    return V, adj


def degree(graph: Graph, i: int) -> int:
    """Ordinary vertex degree deg(i)."""
    _, adj = graph
    return len(adj[i])


def deg_in(graph: Graph, S: Set[int], i: int) -> int:
    """Degree of i into the set S: number of neighbors of i lying in S."""
    _, adj = graph
    return sum(1 for j in adj[i] if j in S)


def cartan_entry(graph: Graph, i: int, j: int) -> int:
    """Simply-laced generalized Cartan matrix entry A_ij = (2 Id - Adj)_ij."""
    _, adj = graph
    if i == j:
        return 2
    return -1 if j in adj[i] else 0


def beta_pair(graph: Graph, S: Set[int], i: int) -> int:
    """Coroot pairing <beta_S, alpha_i^v> = sum_{j in S} A_ij, computed directly."""
    return sum(cartan_entry(graph, i, j) for j in S)


def beta_pair_closed_form(graph: Graph, S: Set[int], i: int) -> int:
    """Closed-form value of the coroot pairing from the main theorem."""
    d = deg_in(graph, S, i)
    return (2 - d) if i in S else (-d)


def lambda_coord(graph: Graph, I: Set[int], D: Set[int], i: int) -> int:
    """i-th coordinate <lambda_{D,I}, alpha_i^v> = 2 - <beta_I,.> - <beta_D,.>."""
    return 2 - beta_pair(graph, I, i) - beta_pair(graph, D, i)


def is_dominant(graph: Graph, I: Set[int], D: Set[int]) -> bool:
    """lambda_{D,I} dominant: all coordinates nonnegative."""
    V, _ = graph
    return all(lambda_coord(graph, I, D, i) >= 0 for i in V)


def is_dominant_by_criterion(graph: Graph, D: Set[int]) -> bool:
    """Whole-diagram criterion: for all i in D, deg(i) + deg_D(i) >= 2."""
    return all(degree(graph, i) + deg_in(graph, D, i) >= 2 for i in D)


def dominant_singleton_vertices(graph: Graph) -> List[int]:
    """Vertices v whose singleton {v} yields a dominant weight, i.e. deg(v) >= 2."""
    V, _ = graph
    return sorted(v for v in V if degree(graph, v) >= 2)


def enumerate_admissible_markings(graph: Graph) -> List[FrozenSet[int]]:
    """All subsets D (I = whole diagram) with lambda_{D,V} dominant."""
    V, _ = graph
    result: List[FrozenSet[int]] = []
    vs = sorted(V)
    for k in range(len(vs) + 1):
        for combo in combinations(vs, k):
            D = set(combo)
            if is_dominant(graph, set(V), D):
                result.append(frozenset(D))
    return result


def demo() -> None:
    print("=" * 70)
    print("Degree criterion for dominance of lambda_{D,I} (simply-laced)")
    print("=" * 70)

    examples = {
        "Path P3 (1-2-3)": make_graph([1, 2, 3], [(1, 2), (2, 3)]),
        "Cycle C4": make_graph([1, 2, 3, 4], [(1, 2), (2, 3), (3, 4), (4, 1)]),
        "Star K_{1,3}": make_graph([0, 1, 2, 3], [(0, 1), (0, 2), (0, 3)]),
        "Path P4 (1-2-3-4)": make_graph([1, 2, 3, 4], [(1, 2), (2, 3), (3, 4)]),
    }

    for name, G in examples.items():
        V, _ = G
        print(f"\n### {name}")
        print("  degrees:", {v: degree(G, v) for v in sorted(V)})

        # 1. Verify the closed-form pairing against the direct column-sum.
        ok = True
        for S in (set(V), set()):
            for i in V:
                if beta_pair(G, S, i) != beta_pair_closed_form(G, S, i):
                    ok = False
        print("  pairing closed-form matches direct sum:", ok)

        # 2. Verify the whole-diagram coordinate identity.
        identity_ok = True
        for D_test in [set(), set(V)] + [{v} for v in V]:
            for i in V:
                lhs = lambda_coord(G, set(V), D_test, i)
                rhs = degree(G, i) + deg_in(G, D_test, i) - (2 if i in D_test else 0)
                if lhs != rhs:
                    identity_ok = False
        print("  coordinate identity deg(i)+deg_D(i)-2[i in D] holds:", identity_ok)

        # 3. Dominant singletons (leaf obstruction).
        print("  dominant singletons (deg>=2):", dominant_singleton_vertices(G))

        # 4. Cross-check criterion vs. direct dominance on all subsets.
        crit_ok = all(
            is_dominant(G, set(V), set(D)) == is_dominant_by_criterion(G, set(D))
            for k in range(len(V) + 1)
            for D in combinations(sorted(V), k)
        )
        print("  criterion agrees with direct dominance on all subsets:", crit_ok)

        # 5. Forest characterization.
        every_vertex_ok = len(dominant_singleton_vertices(G)) == len(V)
        print("  every vertex carries a dominant singleton (=> has a cycle):",
              every_vertex_ok)

        adm = enumerate_admissible_markings(G)
        print(f"  number of admissible markings D: {len(adm)} (empty set always admissible)")

    # Highlight the "rescue by adjacency" phenomenon on P3.
    print("\n### Rescue by adjacency (Path P3)")
    G = make_graph([1, 2, 3], [(1, 2), (2, 3)])
    print("  {1} dominant:", is_dominant(G, {1, 2, 3}, {1}), "(leaf, forbidden)")
    print("  {1,2} dominant:", is_dominant(G, {1, 2, 3}, {1, 2}),
          "(leaf 1 rescued by marking neighbor 2)")


if __name__ == "__main__":
    demo()
