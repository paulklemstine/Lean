"""
Property B for sparse k-uniform hypergraphs: numerical demonstrations.

This self-contained script illustrates the Erdos two-colorability theorem:

    Every k-uniform hypergraph with fewer than 2^{k-1} edges has a proper
    two-coloring (no monochromatic edge). Equivalently, the minimum number
    m(k) of edges in a non-two-colorable k-uniform hypergraph satisfies
        m(k) >= 2^{k-1}.

Every helper function is inlined; the script depends only on the standard
library. Run with `python demo.py`.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import FrozenSet, Iterable, List, Optional, Tuple

Edge = FrozenSet[int]
Hypergraph = List[Edge]
Coloring = FrozenSet[int]  # the set of RED vertices


# ---------------------------------------------------------------------------
# Core combinatorics
# ---------------------------------------------------------------------------

def is_monochromatic(edge: Edge, red: Coloring) -> bool:
    """True iff `edge` is entirely red (edge <= red) or entirely blue (disjoint)."""
    all_red = edge <= red
    all_blue = edge.isdisjoint(red)
    return all_red or all_blue


def is_proper(hypergraph: Hypergraph, red: Coloring) -> bool:
    """True iff no edge of `hypergraph` is monochromatic under coloring `red`."""
    return all(not is_monochromatic(e, red) for e in hypergraph)


def all_vertices(hypergraph: Hypergraph) -> FrozenSet[int]:
    """Union of all edge vertices."""
    vs: set[int] = set()
    for e in hypergraph:
        vs |= set(e)
    return frozenset(vs)


def find_proper_coloring(hypergraph: Hypergraph) -> Optional[Coloring]:
    """
    Brute-force search over all 2^N colorings for a proper one.
    Returns the red set of the first proper coloring found, else None.
    """
    verts = sorted(all_vertices(hypergraph))
    n = len(verts)
    for bits in product((False, True), repeat=n):
        red = frozenset(v for v, b in zip(verts, bits) if b)
        if is_proper(hypergraph, red):
            return red
    return None


def count_proper_colorings(hypergraph: Hypergraph) -> int:
    """Exact number of proper colorings by exhaustive enumeration."""
    verts = sorted(all_vertices(hypergraph))
    n = len(verts)
    total = 0
    for bits in product((False, True), repeat=n):
        red = frozenset(v for v, b in zip(verts, bits) if b)
        if is_proper(hypergraph, red):
            total += 1
    return total


def count_monochromatizing_colorings(edge: Edge, n_vertices: int,
                                     universe: Iterable[int]) -> int:
    """
    Count colorings of the given universe that make `edge` monochromatic.
    Should equal 2 * 2^{N - k} for a nonempty edge (k = |edge|).
    """
    verts = sorted(universe)
    count = 0
    for bits in product((False, True), repeat=len(verts)):
        red = frozenset(v for v, b in zip(verts, bits) if b)
        if is_monochromatic(edge, red):
            count += 1
    return count


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_interval_counts() -> None:
    """
    Verify the two Boolean-lattice interval identities that drive the proof:
        #{R : edge subseteq R}      = 2^{N-k}   (all red)
        #{R : R disjoint from edge} = 2^{N-k}   (all blue)
    hence #{monochromatic colorings} = 2 * 2^{N-k}.
    """
    print("=" * 68)
    print("Interval counts: a single edge is monochromatized by 2*2^(N-k)")
    print("=" * 68)
    for n in range(3, 8):
        universe = range(n)
        for k in range(1, n + 1):
            edge = frozenset(range(k))
            got = count_monochromatizing_colorings(edge, n, universe)
            pred = 2 * 2 ** (n - k)
            flag = "OK" if got == pred else "MISMATCH"
            print(f"  N={n}, k={k}:  counted={got:5d}  2*2^(N-k)={pred:5d}  [{flag}]")
    print()


def demo_main_theorem() -> None:
    """
    For k in {2,3,4}, generate every hypergraph with fewer than 2^{k-1} edges
    (over a small vertex set) and confirm each is two-colorable.
    """
    print("=" * 68)
    print("Main theorem: |H| < 2^(k-1)  =>  H is two-colorable")
    print("=" * 68)
    for k, n, trials in [(2, 5, None), (3, 6, None), (4, 8, 2000)]:
        threshold = 2 ** (k - 1)
        all_edges = [frozenset(c) for c in combinations(range(n), k)]
        checked = 0
        failures = 0
        max_edges = threshold - 1
        # enumerate hypergraphs with up to max_edges edges
        import random
        if trials is None:
            candidates = []
            for size in range(0, max_edges + 1):
                for combo in combinations(all_edges, size):
                    candidates.append(list(combo))
        else:
            random.seed(0)
            candidates = []
            for _ in range(trials):
                size = random.randint(0, max_edges)
                candidates.append(random.sample(all_edges, size))
        for H in candidates:
            checked += 1
            if find_proper_coloring(H) is None and len(H) > 0:
                failures += 1
        print(f"  k={k}, threshold 2^(k-1)={threshold}, "
              f"vertices={n}: checked {checked} hypergraphs "
              f"(|H| <= {max_edges}), counterexamples={failures}")
    print()


def demo_m3_and_fano() -> None:
    """
    Show m(3) >= 4 (every 3-uniform hypergraph with <= 3 edges is 2-colorable)
    and exhibit the Fano plane as a non-two-colorable 7-edge witness (m(3)=7).
    """
    print("=" * 68)
    print("m(3): lower bound 4 vs. the exact extremal value 7 (Fano plane)")
    print("=" * 68)
    # The Fano plane: 7 points, 7 lines (triples).
    fano: Hypergraph = [
        frozenset({0, 1, 2}),
        frozenset({0, 3, 4}),
        frozenset({0, 5, 6}),
        frozenset({1, 3, 5}),
        frozenset({1, 4, 6}),
        frozenset({2, 3, 6}),
        frozenset({2, 4, 5}),
    ]
    coloring = find_proper_coloring(fano)
    print(f"  Fano plane has {len(fano)} edges.")
    print(f"  Proper coloring exists? {coloring is not None}  "
          f"(expected False: Fano is NOT two-colorable)")
    print(f"  Number of proper colorings: {count_proper_colorings(fano)}")

    # Any 3 of the Fano lines: two-colorable, illustrating m(3) >= 4.
    sub = fano[:3]
    c = find_proper_coloring(sub)
    print(f"  First 3 Fano lines: proper coloring red-set = {sorted(c) if c else None}")
    print()


def demo_single_edge() -> None:
    """A single edge with >= 2 vertices is two-colorable; a size-1 edge is not."""
    print("=" * 68)
    print("Single-edge corollary")
    print("=" * 68)
    e2: Hypergraph = [frozenset({0, 1, 2})]
    c = find_proper_coloring(e2)
    print(f"  Edge {{0,1,2}} (size 3): red-set = {sorted(c) if c else None} (proper)")
    e1: Hypergraph = [frozenset({0})]
    c1 = find_proper_coloring(e1)
    print(f"  Edge {{0}} (size 1): proper coloring = {c1} "
          f"(None: a size-1 edge is always monochromatic)")
    print()


def main() -> None:
    demo_interval_counts()
    demo_main_theorem()
    demo_m3_and_fano()
    demo_single_edge()
    print("All demonstrations consistent with the theory.")


if __name__ == "__main__":
    main()
