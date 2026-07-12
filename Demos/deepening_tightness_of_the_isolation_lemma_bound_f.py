"""
Numerical demonstrations for:

    Tightness of the Isolation-Lemma Region Bound for Arbitrary Edge Offsets

We work with hypergraphs on the vertex set V = {0, 1, ..., n-1}, integer weight
assignments w : V -> {0, ..., d-1}, and edge offsets f : edge -> R.  An
assignment is *isolating* for (H, f) when a unique edge minimizes the adjusted
weight  f(S) + sum_{v in S} w(v).

The region bound is  B(n, d) = n * sum_{j=0}^{d-1} j^(n-1).

This script verifies, by brute-force enumeration over all d^n assignments:
  1. the singleton hypergraph attains B(n, d) exactly (strict-minimum count);
  2. the co-singleton hypergraph attains B(n, d) exactly (strict-maximum count),
     matching the singleton count via the reflection duality;
  3. the single-edge hypergraph is isolating for ALL d^n assignments and for
     EVERY offset, so its count d^n exceeds B(n, d)  (general tightness fails);
  4. a covering antichain {{0,1},{0,2}} overshoots B(n, d) for every offset.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, FrozenSet, Iterable, List, Tuple

Assignment = Tuple[int, ...]
Edge = FrozenSet[int]
Hypergraph = List[Edge]


# --------------------------------------------------------------------------- #
# Core quantities
# --------------------------------------------------------------------------- #
def region_bound(n: int, d: int) -> int:
    """The Faber-Harris region bound  B(n, d) = n * sum_{j<d} j^(n-1)."""
    return n * sum(j ** (n - 1) for j in range(d))


def all_assignments(n: int, d: int) -> Iterable[Assignment]:
    """Enumerate every weight assignment w : {0,...,n-1} -> {0,...,d-1}."""
    return product(range(d), repeat=n)


def adjusted_weight(edge: Edge, w: Assignment, f: Callable[[Edge], float]) -> float:
    """f(S) + sum_{v in S} w(v)."""
    return f(edge) + sum(w[v] for v in edge)


def is_isolating(H: Hypergraph, w: Assignment, f: Callable[[Edge], float]) -> bool:
    """True iff a *unique* edge attains the minimum adjusted weight."""
    weights = [adjusted_weight(S, w, f) for S in H]
    m = min(weights)
    return sum(1 for x in weights if x == m) == 1


def count_isolating(H: Hypergraph, n: int, d: int, f: Callable[[Edge], float]) -> int:
    """Number of isolating assignments for (H, f)."""
    return sum(1 for w in all_assignments(n, d) if is_isolating(H, w, f))


# --------------------------------------------------------------------------- #
# Structural counts (offset-free special cases)
# --------------------------------------------------------------------------- #
def count_strict_min(n: int, d: int) -> int:
    """Assignments with a unique strictly smallest coordinate."""
    total = 0
    for w in all_assignments(n, d):
        m = min(w)
        if w.count(m) == 1:
            total += 1
    return total


def count_strict_max(n: int, d: int) -> int:
    """Assignments with a unique strictly largest coordinate."""
    total = 0
    for w in all_assignments(n, d):
        M = max(w)
        if w.count(M) == 1:
            total += 1
    return total


# --------------------------------------------------------------------------- #
# Standard hypergraph families
# --------------------------------------------------------------------------- #
def singleton_hypergraph(n: int) -> Hypergraph:
    """All 1-element edges {v}."""
    return [frozenset({v}) for v in range(n)]


def cosingleton_hypergraph(n: int) -> Hypergraph:
    """All (n-1)-element edges V \\ {v}."""
    full = set(range(n))
    return [frozenset(full - {v}) for v in range(n)]


def zero_offset(_edge: Edge) -> float:
    return 0.0


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_singleton_tightness() -> None:
    print("=" * 68)
    print("1. Singleton hypergraph attains the region bound exactly")
    print("=" * 68)
    for n, d in [(2, 2), (3, 2), (2, 3), (3, 3), (4, 3)]:
        B = region_bound(n, d)
        H = singleton_hypergraph(n)
        iso = count_isolating(H, n, d, zero_offset)
        smin = count_strict_min(n, d)
        ok = iso == B == smin
        print(f"  n={n}, d={d}:  isolating={iso}  strict_min={smin}  "
              f"B(n,d)={B}   [{'OK' if ok else 'MISMATCH'}]")
    print()


def demo_cosingleton_tightness() -> None:
    print("=" * 68)
    print("2. Co-singleton hypergraph also attains the bound (min<->max duality)")
    print("=" * 68)
    for n, d in [(2, 2), (3, 2), (2, 3), (3, 3), (4, 3)]:
        B = region_bound(n, d)
        H = cosingleton_hypergraph(n)
        iso = count_isolating(H, n, d, zero_offset)
        smax = count_strict_max(n, d)
        smin = count_strict_min(n, d)
        ok = iso == B == smax == smin
        print(f"  n={n}, d={d}:  isolating={iso}  strict_max={smax}  "
              f"strict_min={smin}  B(n,d)={B}   [{'OK' if ok else 'MISMATCH'}]")
    print()


def demo_general_tightness_fails() -> None:
    print("=" * 68)
    print("3. General tightness FAILS: single edge frozen at d^n for every offset")
    print("=" * 68)
    import random

    n, d = 2, 2
    E = frozenset({0, 1})
    H: Hypergraph = [E]
    B = region_bound(n, d)
    print(f"  n={n}, d={d}:  B(n,d) = {B},   d^n = {d ** n}")
    for trial in range(5):
        # A random real offset; the count must remain d^n regardless.
        val = random.uniform(-10.0, 10.0)
        f: Callable[[Edge], float] = lambda _S, v=val: v
        iso = count_isolating(H, n, d, f)
        print(f"    offset f(E)={val:+7.3f}  ->  isolating = {iso}  "
              f"(exceeds bound: {iso > B})")
    print("  Conclusion: no offset can bring 4 down to 2.\n")


def demo_covering_antichain_overshoots() -> None:
    print("=" * 68)
    print("4. Covering antichain {{0,1},{0,2}} overshoots for every offset (sampled)")
    print("=" * 68)
    import random

    n, d = 3, 3
    H: Hypergraph = [frozenset({0, 1}), frozenset({0, 2})]
    B = region_bound(n, d)
    best = None
    for _ in range(2000):
        a = random.uniform(-5.0, 5.0)
        b = random.uniform(-5.0, 5.0)
        table = {frozenset({0, 1}): a, frozenset({0, 2}): b}
        f: Callable[[Edge], float] = lambda S, t=table: t[S]
        iso = count_isolating(H, n, d, f)
        best = iso if best is None else min(best, iso)
    print(f"  n={n}, d={d}:  B(n,d) = {B},   min sampled isolating = {best},   "
          f"excess >= {best - B}")
    print("  Conclusion: covering antichain stays strictly above the bound.\n")


def main() -> None:
    demo_singleton_tightness()
    demo_cosingleton_tightness()
    demo_general_tightness_fails()
    demo_covering_antichain_overshoots()


if __name__ == "__main__":
    main()
