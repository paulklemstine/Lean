"""
Numerical demonstrations for the Erdos extremal function m(k) of Property B
(hypergraph two-colourability).

A hypergraph is a family of edges, each a subset of a finite vertex set. A
two-colouring is described by its "red set" R (a subset of the vertices); the
complement is blue. A colouring is PROPER if no edge is monochromatic, i.e. every
edge e satisfies  (e is not a subset of R)  and  (e intersects R).

This script verifies, by exhaustive and exact computation:

  * the two Boolean-lattice interval counts   #{A : S subset A} = #{A : A disj S}
                                              = 2^(N - |S|);
  * the sharp existence theorem: |H| < 2^(k-1)  =>  H is two-colourable;
  * the exact values  m(1) = 1  and  m(2) = 3, with the triangle as witness;
  * that the triangle is non-two-colourable while every graph with <= 2 edges is
    two-colourable.

Everything is self-contained and uses only the standard library.
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, Iterable, List, Optional, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Hypergraph = List[Edge]


# --------------------------------------------------------------------------- #
# Core predicates
# --------------------------------------------------------------------------- #
def is_monochromatic(edge: Edge, red: FrozenSet[Vertex]) -> bool:
    """True if `edge` is entirely red (subset of `red`) or entirely blue."""
    all_red = edge <= red
    all_blue = edge.isdisjoint(red)
    return all_red or all_blue


def is_proper_coloring(hypergraph: Hypergraph, red: FrozenSet[Vertex]) -> bool:
    """True if no edge of `hypergraph` is monochromatic under red set `red`."""
    return all(not is_monochromatic(e, red) for e in hypergraph)


def all_red_sets(vertices: Iterable[Vertex]) -> Iterable[FrozenSet[Vertex]]:
    """Enumerate all 2^N red sets over the given vertices."""
    verts = list(vertices)
    for size in range(len(verts) + 1):
        for combo in combinations(verts, size):
            yield frozenset(combo)


def find_proper_coloring(
    hypergraph: Hypergraph, num_vertices: int
) -> Optional[FrozenSet[Vertex]]:
    """Return a proper red set if one exists, else None (exhaustive census)."""
    for red in all_red_sets(range(num_vertices)):
        if is_proper_coloring(hypergraph, red):
            return red
    return None


def is_non_two_colorable(hypergraph: Hypergraph, num_vertices: int) -> bool:
    """True if NO proper two-colouring exists (H fails Property B)."""
    return find_proper_coloring(hypergraph, num_vertices) is None


# --------------------------------------------------------------------------- #
# Boolean-lattice interval counts (Lemmas 3.1 and 3.2)
# --------------------------------------------------------------------------- #
def count_supersets(num_vertices: int, s: FrozenSet[Vertex]) -> int:
    """Count subsets A of {0,...,N-1} with S subset A."""
    return sum(1 for A in all_red_sets(range(num_vertices)) if s <= A)


def count_disjoint(num_vertices: int, s: FrozenSet[Vertex]) -> int:
    """Count subsets A of {0,...,N-1} with A disjoint from S."""
    return sum(1 for A in all_red_sets(range(num_vertices)) if A.isdisjoint(s))


# --------------------------------------------------------------------------- #
# The Erdos extremal function m(k) by brute-force search
# --------------------------------------------------------------------------- #
def k_uniform_hypergraphs(
    num_vertices: int, k: int, num_edges: int
) -> Iterable[Hypergraph]:
    """Enumerate k-uniform hypergraphs with exactly `num_edges` edges on N verts."""
    possible_edges = [frozenset(c) for c in combinations(range(num_vertices), k)]
    for chosen in combinations(possible_edges, num_edges):
        yield list(chosen)


def smallest_non_two_colorable(k: int, max_vertices: int) -> Tuple[int, Hypergraph]:
    """
    Search for the fewest edges of a non-two-colourable k-uniform hypergraph,
    scanning vertex counts up to `max_vertices`. Returns (edge_count, witness).
    """
    for num_edges in range(1, 2 ** (max_vertices) + 1):
        for n in range(k, max_vertices + 1):
            for H in k_uniform_hypergraphs(n, k, num_edges):
                if is_non_two_colorable(H, n):
                    return num_edges, H
    raise RuntimeError("no witness found within search bounds")


# --------------------------------------------------------------------------- #
# Named witnesses
# --------------------------------------------------------------------------- #
SINGLE_VERTEX_EDGE: Hypergraph = [frozenset({0})]  # m(1) witness on Fin 1

TRIANGLE: Hypergraph = [           # m(2) witness on Fin 3
    frozenset({0, 1}),
    frozenset({1, 2}),
    frozenset({0, 2}),
]


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_interval_counts() -> None:
    print("=" * 70)
    print("Boolean-lattice interval counts:  #supersets = #disjoint = 2^(N-|S|)")
    print("=" * 70)
    for n in range(1, 6):
        for s_size in range(0, n + 1):
            s = frozenset(range(s_size))
            sup = count_supersets(n, s)
            dis = count_disjoint(n, s)
            expected = 2 ** (n - s_size)
            ok = sup == dis == expected
            print(f"  N={n}, |S|={s_size}: supersets={sup}, disjoint={dis}, "
                  f"2^(N-|S|)={expected}  {'OK' if ok else 'MISMATCH'}")
            assert ok
    print()


def demo_existence_theorem() -> None:
    print("=" * 70)
    print("Sharp existence:  |H| < 2^(k-1)  =>  H is two-colourable")
    print("=" * 70)
    # Every k-uniform hypergraph with fewer than 2^(k-1) edges is colourable.
    for k in range(1, 4):
        threshold = 2 ** (k - 1)
        n = 2 * k + 1
        all_ok = True
        for num_edges in range(0, threshold):  # strictly fewer than 2^(k-1)
            for H in k_uniform_hypergraphs(n, k, num_edges):
                if find_proper_coloring(H, n) is None:
                    all_ok = False
        print(f"  k={k}: threshold 2^(k-1)={threshold}; all hypergraphs on "
              f"{n} verts with <{threshold} edges are colourable: {all_ok}")
        assert all_ok
    print()


def demo_m_one() -> None:
    print("=" * 70)
    print("m(1) = 1:  a single vertex-edge is non-two-colourable")
    print("=" * 70)
    non = is_non_two_colorable(SINGLE_VERTEX_EDGE, 1)
    print(f"  H = {{{{0}}}} on Fin 1  ->  non-two-colourable: {non}")
    assert non
    print("  Hence m(1) <= 1; the lower bound 2^0 = 1 gives m(1) = 1.\n")


def demo_m_two() -> None:
    print("=" * 70)
    print("m(2) = 3:  the triangle is the sparsest non-two-colourable graph")
    print("=" * 70)
    # Every graph with <= 2 edges is two-colourable.
    for num_edges in (0, 1, 2):
        colourable = all(
            find_proper_coloring(H, 4) is not None
            for H in k_uniform_hypergraphs(4, 2, num_edges)
        )
        print(f"  every 2-uniform graph with {num_edges} edges "
              f"(on 4 verts) is colourable: {colourable}")
        assert colourable
    # The triangle (3 edges) is non-two-colourable.
    non = is_non_two_colorable(TRIANGLE, 3)
    print(f"  triangle {{01,12,02}} on Fin 3  ->  non-two-colourable: {non}")
    assert non
    print("  So no graph with <=2 edges works, the triangle works with 3 edges:")
    print("  m(2) = 3.\n")


def demo_search() -> None:
    print("=" * 70)
    print("Brute-force extremal search: smallest non-two-colourable witness")
    print("=" * 70)
    for k, max_v in ((1, 2), (2, 4)):
        edges, H = smallest_non_two_colorable(k, max_v)
        pretty = "{" + ", ".join("{" + ",".join(map(str, sorted(e))) + "}"
                                 for e in H) + "}"
        print(f"  m({k}) = {edges}  witness: {pretty}")
    print()


def main() -> None:
    demo_interval_counts()
    demo_existence_theorem()
    demo_m_one()
    demo_m_two()
    demo_search()
    print("All demonstrations passed: m(1) = 1, m(2) = 3, lower bound 2^(k-1).")


if __name__ == "__main__":
    main()
