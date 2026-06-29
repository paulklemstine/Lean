"""
Numerical demonstrations of the local monochromatic-matching bounds for
bounded-degree (random-like) uniform hypergraphs, and the constant-factor gap to
the Alon-Frankl-Lovasz (AFL) threshold.

This file is self-contained: every helper is inlined and type-hinted, and it uses
only the Python standard library.

The mathematical facts demonstrated (all formally proved in the accompanying Lean
development) are:

  * Pigeonhole on a matching        : r * |M_i| >= |M| for the heaviest color i.
  * Maximal matchings are covers    : every edge meets supp(M).
  * Greedy bound                    : |H| <= t * Delta * |M| for maximal M.
  * Monochromatic lower bound       : r*t*Delta*|M'| >= |H|.
  * Constant gap                    : r+t-1 <= r*t, strict for r,t >= 2.
  * Finite deficit (K_4, r=t=2)     : a 2-coloring with no mono matching of size 2.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, FrozenSet, List, Sequence, Tuple

Edge = FrozenSet[int]
Hypergraph = List[Edge]


# ----------------------------------------------------------------------------- #
# Core combinatorial primitives
# ----------------------------------------------------------------------------- #
def is_matching(edges: Sequence[Edge]) -> bool:
    """Return True iff the given edges are pairwise disjoint."""
    seen: set[int] = set()
    for e in edges:
        if seen & e:
            return False
        seen |= e
    return True


def support(edges: Sequence[Edge]) -> FrozenSet[int]:
    """Union of the vertices covered by a collection of edges (supp M)."""
    s: set[int] = set()
    for e in edges:
        s |= e
    return frozenset(s)


def max_degree(h: Hypergraph) -> int:
    """Maximum number of edges incident to any single vertex."""
    deg: Dict[int, int] = {}
    for e in h:
        for v in e:
            deg[v] = deg.get(v, 0) + 1
    return max(deg.values(), default=0)


def greedy_maximal_matching(h: Hypergraph) -> Hypergraph:
    """Algorithm A: greedily build a maximal matching by scanning edges once."""
    used: set[int] = set()
    m: Hypergraph = []
    for e in h:
        if not (used & e):
            m.append(e)
            used |= e
    return m


def heaviest_color_class(
    matching: Sequence[Edge], coloring: Dict[Edge, int], r: int
) -> Tuple[int, Hypergraph]:
    """Algorithm B: return (color, color-class) maximizing the class size."""
    best_color, best_class = 0, []  # type: Tuple[int, Hypergraph]
    for i in range(r):
        cls = [e for e in matching if coloring[e] == i]
        if len(cls) > len(best_class):
            best_color, best_class = i, cls
    return best_color, best_class


def guaranteed_mono_matching(
    h: Hypergraph, coloring: Dict[Edge, int], r: int
) -> Hypergraph:
    """Algorithm C: greedy maximal matching, then heaviest color class."""
    m = greedy_maximal_matching(h)
    _, mono = heaviest_color_class(m, coloring, r)
    return mono


# ----------------------------------------------------------------------------- #
# Host constructors
# ----------------------------------------------------------------------------- #
def complete_t_graph(n: int, t: int) -> Hypergraph:
    """K_n^{(t)}: all t-subsets of {0,...,n-1}."""
    return [frozenset(c) for c in combinations(range(n), t)]


def cyclic_regular_t_graph(n: int, t: int) -> Hypergraph:
    """A d-regular-like t-graph: the n cyclic 'intervals' {i, i+1, ..., i+t-1}."""
    return [frozenset((i + j) % n for j in range(t)) for i in range(n)]


# ----------------------------------------------------------------------------- #
# Exact worst-case monochromatic matching number (brute force, small hosts)
# ----------------------------------------------------------------------------- #
def max_matching_size(edges: Sequence[Edge]) -> int:
    """Maximum size of a matching among the given edges (exact, exponential)."""
    edges = list(edges)
    best = 0
    # Branch-and-bound over the edges.
    def rec(idx: int, used: frozenset, count: int) -> None:
        nonlocal best
        best = max(best, count)
        for k in range(idx, len(edges)):
            if not (used & edges[k]):
                rec(k + 1, used | edges[k], count + 1)
    rec(0, frozenset(), 0)
    return best


def worst_case_mono_matching(h: Hypergraph, r: int) -> int:
    """
    min over all r-colorings of (max monochromatic matching size).
    Exact brute force; only feasible for very small hosts.
    """
    best_over_colorings = None
    for assignment in product(range(r), repeat=len(h)):
        coloring = {h[i]: assignment[i] for i in range(len(h))}
        mono = 0
        for color in range(r):
            cls = [e for e in h if coloring[e] == color]
            mono = max(mono, max_matching_size(cls))
        if best_over_colorings is None or mono < best_over_colorings:
            best_over_colorings = mono
    return best_over_colorings if best_over_colorings is not None else 0


# ----------------------------------------------------------------------------- #
# Demonstrations
# ----------------------------------------------------------------------------- #
def demo_greedy_and_mono_bound() -> None:
    print("=" * 70)
    print("Greedy bound  |H| <= t * Delta * |M|   and   r*t*Delta*|M'| >= |H|")
    print("=" * 70)
    for (n, t, r) in [(12, 3, 2), (15, 3, 3), (20, 2, 2), (18, 4, 2)]:
        h = cyclic_regular_t_graph(n, t)
        delta = max_degree(h)
        m = greedy_maximal_matching(h)
        assert is_matching(m)
        # Verify maximal-matching cover property: every edge meets supp(M).
        s = support(m)
        assert all(s & e for e in h), "cover property failed"
        # Greedy bound.
        assert len(h) <= t * delta * len(m), "greedy bound violated"
        # Round-robin coloring, then guaranteed monochromatic matching.
        coloring = {e: i % r for i, e in enumerate(h)}
        mono = guaranteed_mono_matching(h, coloring, r)
        assert is_matching(mono)
        assert r * t * delta * len(mono) >= len(h), "mono bound violated"
        lower = len(h) / (r * t * delta)
        print(
            f"  n={n:2d} t={t} r={r} | |H|={len(h):3d} Delta={delta} "
            f"|M|={len(m):2d} |M'|={len(mono):2d} "
            f">= |H|/(r t Delta)={lower:5.2f}  [OK]"
        )
    print()


def demo_constant_gap() -> None:
    print("=" * 70)
    print("Constant gap:  r+t-1 <= r*t   (strict for r,t >= 2);  gap=(r-1)(t-1)")
    print("=" * 70)
    print(f"  {'r':>2} {'t':>2} | {'r+t-1':>6} {'r*t':>4} {'(r-1)(t-1)':>10} "
          f"{'1/(r+t-1)':>10} {'1/(rt)':>8} {'rt/(r+t-1)':>11}")
    for r in range(1, 5):
        for t in range(1, 5):
            afl = r + t - 1
            loc = r * t
            gap = (r - 1) * (t - 1)
            assert afl <= loc
            if r >= 2 and t >= 2:
                assert afl < loc
            print(f"  {r:>2} {t:>2} | {afl:>6} {loc:>4} {gap:>10} "
                  f"{1/afl:>10.4f} {1/loc:>8.4f} {loc/afl:>11.4f}")
    print()


def demo_k4_finite_deficit() -> None:
    print("=" * 70)
    print("Finite deficit witness: K_4, r=t=2, no monochromatic matching of size 2")
    print("=" * 70)
    h = complete_t_graph(4, 2)  # 6 edges
    # Brute force the worst-case monochromatic matching number over all 2-colorings.
    wc = worst_case_mono_matching(h, r=2)
    print(f"  K_4 has |H| = {len(h)} edges (t=2).")
    print(f"  Worst-case monochromatic matching number over all 2-colorings: {wc}")
    print(f"  Limiting AFL value n/(r+t-1) = 4/3 = {4/3:.4f} 'wants' size 2,")
    print(f"  but a 2-coloring forces the maximum down to {wc}  => genuine deficit.")
    assert wc == 1, "expected worst-case mono matching number 1 for K_4"
    # Exhibit an explicit bad coloring (opposite edges get different colors).
    pairs = [
        (frozenset({0, 1}), frozenset({2, 3})),
        (frozenset({0, 2}), frozenset({1, 3})),
        (frozenset({0, 3}), frozenset({1, 2})),
    ]
    coloring: Dict[Edge, int] = {}
    for k, (a, b) in enumerate(pairs):
        coloring[a] = 0
        coloring[b] = 1
    for color in range(2):
        cls = [e for e in h if coloring[e] == color]
        assert max_matching_size(cls) <= 1
    print("  Explicit coloring (opposite edges differ) verified: no size-2 mono "
          "matching.\n")


def demo_complete_host_scaling() -> None:
    print("=" * 70)
    print("Scaling on complete hosts K_n^{(t)}: empirical vs asymptotic n/(rt)")
    print("=" * 70)
    for (n, t, r) in [(8, 2, 2), (9, 3, 2), (7, 2, 3)]:
        h = complete_t_graph(n, t)
        delta = max_degree(h)
        m = greedy_maximal_matching(h)
        lower = len(h) / (r * t * delta)
        print(f"  K_{n}^({t}) r={r}: |H|={len(h):4d} Delta={delta:3d} "
              f"|M|={len(m)} guaranteed >= {lower:5.2f}  (n/(rt)={n/(r*t):.2f})")
    print()


def main() -> None:
    demo_greedy_and_mono_bound()
    demo_constant_gap()
    demo_k4_finite_deficit()
    demo_complete_host_scaling()
    print("All demonstrations completed and assertions passed.")


if __name__ == "__main__":
    main()
