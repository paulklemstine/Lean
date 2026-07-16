#!/usr/bin/env python3
"""Numerical demonstrations for the pair-star hypergraph construction.

The script uses only Python's standard library. It constructs finite pair-star
3-graphs, checks their exact counts and intersection profile, finds a canonical
maximum matching, and exhaustively searches for Berge triangles in small cases.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Tuple

Vertex = str
Edge = FrozenSet[Vertex]


@dataclass(frozen=True)
class PairStar:
    """A pair-star 3-uniform hypergraph with s spines and t outside vertices."""

    s: int
    t: int
    vertices: FrozenSet[Vertex]
    edges: Tuple[Edge, ...]


def spine_vertex(i: int, side: int) -> Vertex:
    """Return a stable label for one endpoint of spine i."""
    return f"p{i}_{side}"


def outside_vertex(j: int) -> Vertex:
    """Return a stable label for outside vertex j."""
    return f"x{j}"


def make_pair_star(s: int, t: int) -> PairStar:
    """Construct all edges {p_i, q_i, x_j} in O(s*t) time."""
    if s < 0 or t < 0:
        raise ValueError("s and t must be nonnegative")
    spines = {
        spine_vertex(i, side) for i in range(s) for side in (0, 1)
    }
    outside = {outside_vertex(j) for j in range(t)}
    edges = tuple(
        frozenset((spine_vertex(i, 0), spine_vertex(i, 1), outside_vertex(j)))
        for i in range(s)
        for j in range(t)
    )
    return PairStar(s, t, frozenset(spines | outside), edges)


def canonical_maximum_matching(h: PairStar) -> Tuple[Edge, ...]:
    """Return min(s,t) disjoint diagonal edges, a maximum matching."""
    m = min(h.s, h.t)
    return tuple(
        frozenset((spine_vertex(i, 0), spine_vertex(i, 1), outside_vertex(i)))
        for i in range(m)
    )


def is_matching(edges: Iterable[Edge]) -> bool:
    """Test pairwise disjointness."""
    chosen = tuple(edges)
    return all(e.isdisjoint(f) for e, f in combinations(chosen, 2))


def expected_intersection(i: int, x: int, j: int, y: int) -> int:
    """Evaluate the four-case pair-star intersection formula."""
    if i == j:
        return 3 if x == y else 2
    return 1 if x == y else 0


def verify_intersection_formula(h: PairStar) -> bool:
    """Check the exact intersection theorem on every ordered edge pair."""
    for i in range(h.s):
        for x in range(h.t):
            e = h.edges[i * h.t + x]
            for j in range(h.s):
                for y in range(h.t):
                    f = h.edges[j * h.t + y]
                    if len(e & f) != expected_intersection(i, x, j, y):
                        return False
    return True


def find_berge_triangle(h: PairStar) -> Optional[Tuple[Tuple[Vertex, Vertex, Vertex], Tuple[Edge, Edge, Edge]]]:
    """Exhaustively find a Berge triangle, or return None.

    Pair-to-edge indexing avoids enumerating every ordered edge triple. For each
    core triangle, it tests whether its three pairs admit distinct representatives.
    This is intended for small numerical examples.
    """
    containing: Dict[FrozenSet[Vertex], List[Edge]] = {}
    for edge in h.edges:
        for pair in combinations(sorted(edge), 2):
            containing.setdefault(frozenset(pair), []).append(edge)

    for a, b, c in combinations(sorted(h.vertices), 3):
        ab = containing.get(frozenset((a, b)), [])
        bc = containing.get(frozenset((b, c)), [])
        ca = containing.get(frozenset((c, a)), [])
        for e_ab in ab:
            for e_bc in bc:
                if e_bc == e_ab:
                    continue
                for e_ca in ca:
                    if e_ca != e_ab and e_ca != e_bc:
                        return ((a, b, c), (e_ab, e_bc, e_ca))
    return None


def summarize(n: int, s: int, exhaustive: bool = True) -> None:
    """Build the extremal specialization t=n-2s and print its invariants."""
    if n < 3 * s:
        raise ValueError("the extremal specialization requires n >= 3s")
    t = n - 2 * s
    h = make_pair_star(s, t)
    matching = canonical_maximum_matching(h)
    triangle = find_berge_triangle(h) if exhaustive else None

    assert len(h.vertices) == n
    assert len(h.edges) == s * (n - 2 * s)
    assert all(len(edge) == 3 for edge in h.edges)
    assert len(set(h.edges)) == len(h.edges)
    assert verify_intersection_formula(h)
    assert len(matching) == s
    assert is_matching(matching)
    if exhaustive:
        assert triangle is None

    print(f"n={n}, s={s}, t={t}")
    print(f"  vertices: {len(h.vertices)} (predicted {n})")
    print(f"  edges:    {len(h.edges)} (predicted s(n-2s)={s * (n - 2 * s)})")
    print(f"  matching: {len(matching)} disjoint edges (predicted {s})")
    print("  intersection formula: verified")
    print("  Berge triangle: none found" if exhaustive else "  Berge triangle search: skipped")


def parameter_table(cases: Sequence[Tuple[int, int]]) -> None:
    """Print numerical values of the construction for several (n,s) cases."""
    print("Pair-star extremal parameter table")
    print(" n   s   t=n-2s   vertices   edges   matching")
    for n, s in cases:
        if n < 3 * s:
            raise ValueError(f"invalid case {(n, s)}: n must be at least 3s")
        t = n - 2 * s
        h = make_pair_star(s, t)
        m = canonical_maximum_matching(h)
        print(f"{n:2d}  {s:2d}     {t:2d}         {len(h.vertices):2d}      {len(h.edges):3d}       {len(m):2d}")


def main() -> None:
    """Run three representative demonstrations."""
    parameter_table(((6, 2), (9, 3), (12, 3), (20, 5)))
    print()
    summarize(n=12, s=3, exhaustive=True)
    print()

    rectangular = make_pair_star(s=5, t=2)
    matching = canonical_maximum_matching(rectangular)
    assert len(rectangular.edges) == 10
    assert len(matching) == 2
    assert is_matching(matching)
    assert find_berge_triangle(rectangular) is None
    print("Rectangular case s=5, t=2")
    print(f"  edges={len(rectangular.edges)}, matching number=min(5,2)={len(matching)}")
    print("  exhaustive Berge-triangle search found none")


if __name__ == "__main__":
    main()
