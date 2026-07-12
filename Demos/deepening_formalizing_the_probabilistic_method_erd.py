"""
Property B: two-colorability of sparse hypergraphs (Erdos, 1963).

This self-contained script demonstrates the key results:

  * The Boolean-lattice interval counts  #{A in P(G) : S subset A}
      = #{A in P(G) : A disjoint S} = 2^(|G|-|S|).
  * The first-moment union bound  m * 2^(N-k+1) < 2^N  when m < 2^(k-1).
  * Exhaustive verification that sparse hypergraphs have Property B.
  * The triangle as a non-two-colorable 2-uniform hypergraph (m(2) = 3)
    and the Fano plane (m(3) = 7).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, Iterable, List, Optional, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Hypergraph = List[Edge]
Coloring = FrozenSet[Vertex]  # the set of "red" vertices


# --------------------------------------------------------------------------
# Boolean-lattice interval counts (Lemmas 3.1 and 3.2)
# --------------------------------------------------------------------------
def count_supersets(ground: FrozenSet[Vertex], s: FrozenSet[Vertex]) -> int:
    """Number of subsets A of `ground` with s subset A (brute force)."""
    assert s <= ground
    verts = list(ground)
    total = 0
    for r in range(len(verts) + 1):
        for combo in combinations(verts, r):
            a = frozenset(combo)
            if s <= a:
                total += 1
    return total


def count_disjoint(ground: FrozenSet[Vertex], s: FrozenSet[Vertex]) -> int:
    """Number of subsets A of `ground` with A disjoint from s (brute force)."""
    assert s <= ground
    verts = list(ground)
    total = 0
    for r in range(len(verts) + 1):
        for combo in combinations(verts, r):
            a = frozenset(combo)
            if a.isdisjoint(s):
                total += 1
    return total


def predicted_count(ground: FrozenSet[Vertex], s: FrozenSet[Vertex]) -> int:
    """Closed form 2^(|G|-|S|)."""
    return 2 ** (len(ground) - len(s))


# --------------------------------------------------------------------------
# Property B: coloring, monochromaticity, exhaustive two-colorability
# --------------------------------------------------------------------------
def is_monochromatic(edge: Edge, red: Coloring) -> bool:
    """True if `edge` is all-red (edge subset red) or all-blue (disjoint)."""
    return edge <= red or edge.isdisjoint(red)


def is_proper(hg: Hypergraph, red: Coloring) -> bool:
    """True if no edge is monochromatic under the coloring `red`."""
    return all(not is_monochromatic(e, red) for e in hg)


def all_colorings(vertices: Iterable[Vertex]) -> Iterable[Coloring]:
    verts = list(vertices)
    for r in range(len(verts) + 1):
        for combo in combinations(verts, r):
            yield frozenset(combo)


def find_proper_coloring(hg: Hypergraph, vertices: Iterable[Vertex]
                         ) -> Optional[Coloring]:
    """Return a proper coloring if one exists, else None (Algorithm A)."""
    for red in all_colorings(vertices):
        if is_proper(hg, red):
            return red
    return None


def has_property_B(hg: Hypergraph, vertices: Iterable[Vertex]) -> bool:
    return find_proper_coloring(hg, list(vertices)) is not None


# --------------------------------------------------------------------------
# First-moment certificate (Algorithm B) and union-bound arithmetic
# --------------------------------------------------------------------------
def first_moment_guarantees(k: int, m: int) -> bool:
    """Theorem 4.1 certificate: edges of size >= k and m edges imply
    Property B when m < 2^(k-1)."""
    return m < 2 ** (k - 1)


def union_bound(n: int, k: int, m: int) -> Tuple[int, int]:
    """Return (bad_upper_bound, total) = (m * 2^(n-k+1), 2^n)."""
    return m * 2 ** (n - k + 1), 2 ** n


# --------------------------------------------------------------------------
# Concrete hypergraphs
# --------------------------------------------------------------------------
def triangle() -> Tuple[Hypergraph, List[Vertex]]:
    edges = [frozenset({0, 1}), frozenset({1, 2}), frozenset({0, 2})]
    return edges, [0, 1, 2]


def fano_plane() -> Tuple[Hypergraph, List[Vertex]]:
    lines = [
        {0, 1, 2}, {0, 3, 4}, {0, 5, 6}, {1, 3, 5},
        {1, 4, 6}, {2, 3, 6}, {2, 4, 5},
    ]
    return [frozenset(L) for L in lines], list(range(7))


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 66)
    print("1. Boolean-lattice interval counts  (Lemmas 3.1 / 3.2)")
    print("=" * 66)
    ground = frozenset(range(5))
    for s in (frozenset(), frozenset({0, 1}), frozenset({0, 1, 2, 3})):
        sup = count_supersets(ground, s)
        dis = count_disjoint(ground, s)
        pred = predicted_count(ground, s)
        print(f"  |G|={len(ground)}, |S|={len(s)}:  supersets={sup}, "
              f"disjoint={dis}, predicted 2^(|G|-|S|)={pred}  "
              f"[{'OK' if sup == dis == pred else 'FAIL'}]")

    print()
    print("=" * 66)
    print("2. First-moment union bound  m * 2^(N-k+1) < 2^N  when m < 2^(k-1)")
    print("=" * 66)
    for n, k, m in [(10, 4, 7), (12, 5, 15), (8, 3, 3)]:
        bad, total = union_bound(n, k, m)
        cert = first_moment_guarantees(k, m)
        print(f"  N={n}, k={k}, m={m}:  bad<= {bad}, total={total}, "
              f"m<2^(k-1)={cert}, bad<total={bad < total}")

    print()
    print("=" * 66)
    print("3. Sparse hypergraph is two-colorable (exhaustive check)")
    print("=" * 66)
    # A 3-uniform hypergraph on 6 vertices with 3 edges (< 2^(3-1)=4).
    hg = [frozenset({0, 1, 2}), frozenset({2, 3, 4}), frozenset({4, 5, 0})]
    coloring = find_proper_coloring(hg, list(range(6)))
    print(f"  edges={[set(e) for e in hg]}")
    print(f"  k=3, m=3 < 2^(k-1)=4  -> certificate says two-colorable: "
          f"{first_moment_guarantees(3, 3)}")
    print(f"  found proper coloring (red set) = "
          f"{set(coloring) if coloring else None}")

    print()
    print("=" * 66)
    print("4. Extremal witnesses:  m(2)=3 (triangle),  m(3)=7 (Fano plane)")
    print("=" * 66)
    tri, tv = triangle()
    print(f"  Triangle: 2-uniform, {len(tri)} edges, "
          f"two-colorable={has_property_B(tri, tv)}  "
          f"(expected False -> m(2) <= 3)")
    fano, fv = fano_plane()
    print(f"  Fano plane: 3-uniform, {len(fano)} edges, "
          f"two-colorable={has_property_B(fano, fv)}  "
          f"(expected False -> m(3) <= 7)")


if __name__ == "__main__":
    main()
