"""
Numerical demonstrations of the power-of-two perfect-matching law.

A *perfect matching* of a finite simple graph is a fixed-point-free
involution f of its vertex set such that every vertex v is adjacent to
f(v).  The number of perfect matchings is the *matching count* M(G).

This script demonstrates, entirely from first principles and with no
external dependencies, the following results:

    1. M(C_4) = 2 and M(C_6) = 2  (even cycles are two-choice gadgets).
    2. The multiplicative law:  M(Block(n, G)) = M(G)^n,
       where Block(n, G) is n disjoint copies of G with no edges
       between distinct copies.
    3. The power-of-two law:  M(Block(n, C_4)) = 2^n.

All matching counts are computed by brute-force enumeration over
involutions, so the closed-form predictions are checked against ground
truth.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Hashable, List, Set, Tuple

# A graph is represented as an adjacency map: vertex -> set of neighbours.
Vertex = Hashable
Graph = Dict[Vertex, Set[Vertex]]


def cycle_graph(n: int) -> Graph:
    """Return the cycle C_n on vertices 0..n-1 (each joined to its neighbours)."""
    return {i: {(i - 1) % n, (i + 1) % n} for i in range(n)}


def block_graph(n: int, g: Graph) -> Graph:
    """Return n disjoint copies of g, with no edges between distinct copies.

    Vertices of the block graph are pairs (i, v) for i in 0..n-1 and v a
    vertex of g.  Two vertices (i, a) and (j, b) are adjacent iff i == j and
    a is adjacent to b in g.
    """
    block: Graph = {}
    for i in range(n):
        for v, nbrs in g.items():
            block[(i, v)] = {(i, w) for w in nbrs}
    return block


def perfect_matchings(g: Graph) -> List[Dict[Vertex, Vertex]]:
    """Enumerate all perfect matchings of g as involutions v -> partner(v).

    A perfect matching pairs every vertex with a distinct neighbour so that
    the pairing is symmetric.  We build matchings recursively: repeatedly
    take the first unmatched vertex and try each of its unmatched neighbours
    as a partner.
    """
    vertices = sorted(g.keys(), key=repr)
    results: List[Dict[Vertex, Vertex]] = []

    def extend(matched: Dict[Vertex, Vertex]) -> None:
        # Find the first unmatched vertex.
        v = next((u for u in vertices if u not in matched), None)
        if v is None:
            results.append(dict(matched))
            return
        for w in g[v]:
            if w not in matched:
                matched[v] = w
                matched[w] = v
                extend(matched)
                del matched[v]
                del matched[w]

    extend({})
    return results


def matching_count(g: Graph) -> int:
    """Return M(g), the number of perfect matchings of g."""
    return len(perfect_matchings(g))


def print_matchings(name: str, g: Graph) -> None:
    """Pretty-print every perfect matching of g as a set of unordered pairs."""
    ms = perfect_matchings(g)
    print(f"{name}: matching count = {len(ms)}")
    for k, m in enumerate(ms, 1):
        pairs: Set[Tuple[Vertex, Vertex]] = set()
        for v, w in m.items():
            pairs.add(tuple(sorted((v, w), key=repr)))
        pretty = ", ".join("{%s,%s}" % (a, b) for a, b in sorted(pairs, key=repr))
        print(f"   matching {k}: {pretty}")


def main() -> None:
    print("=" * 66)
    print("1. Even cycles are two-choice gadgets")
    print("=" * 66)
    c4 = cycle_graph(4)
    c6 = cycle_graph(6)
    print_matchings("C_4 (square)", c4)
    print_matchings("C_6 (hexagon)", c6)
    assert matching_count(c4) == 2
    assert matching_count(c6) == 2
    # Odd cycles have no perfect matching.
    assert matching_count(cycle_graph(5)) == 0
    print("   (C_5, an odd cycle, has 0 perfect matchings, as expected.)")

    print()
    print("=" * 66)
    print("2. Multiplicative law:  M(Block(n, G)) = M(G)^n")
    print("=" * 66)
    for g, gname, mg in [(c4, "C_4", 2), (c6, "C_6", 2), (cycle_graph(8), "C_8", 2)]:
        for n in range(1, 4):
            actual = matching_count(block_graph(n, g))
            predicted = mg ** n
            status = "OK" if actual == predicted else "MISMATCH"
            print(f"   M(Block({n}, {gname})) = {actual:6d}   "
                  f"M({gname})^{n} = {predicted:6d}   [{status}]")
            assert actual == predicted

    print()
    print("=" * 66)
    print("3. Power-of-two law:  M(Block(n, C_4)) = 2^n")
    print("=" * 66)
    for n in range(0, 6):
        actual = matching_count(block_graph(n, c4))
        predicted = 2 ** n
        status = "OK" if actual == predicted else "MISMATCH"
        print(f"   n = {n}:  M(Block(n, C_4)) = {actual:6d}   "
              f"2^{n} = {predicted:6d}   [{status}]")
        assert actual == predicted

    print()
    print("=" * 66)
    print("4. A mixed-block sanity check")
    print("=" * 66)
    # Two independent copies of a single edge K_2 (matching count 1 each):
    # the count stays 1 = 1^2, confirming powers-of-one behave correctly.
    k2: Graph = {0: {1}, 1: {0}}
    assert matching_count(block_graph(3, k2)) == 1
    print("   M(Block(3, K_2)) = 1 = 1^3  (single-choice blocks give 1).")
    # A block graph mixing is not needed; the theorem is per-uniform-block.
    print("\nAll closed-form predictions verified against brute force.")


if __name__ == "__main__":
    main()
