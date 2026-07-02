"""
Numerical demonstrations for:

    Uniqueness of the Critical Two-Point Augmentation of a 27-Point Unit-Distance Graph

This self-contained script illustrates the arithmetic core behind the phenomenon
whereby a 27-point planar unit-distance configuration G27 (independence number 7),
after the addition of exactly two points, acquires an independence ratio strictly
below 1/4 and hence a fractional chromatic number strictly greater than 4.

Key facts demonstrated:
  * a/m < 1/4  <=>  4a < m                       (threshold identity)
  * least added vertices = 4a - n + 1            (minimal augmentation)
  * 7/27 > 1/4, 7/28 = 1/4, 7/29 < 1/4           (G27 boundary values)
  * independence number is monotone under         (graph augmentation)
    adding vertices
  * the ratio lower bound chi_f >= m / alpha      (forcing above 4)

No third-party dependencies; uses only the standard library (fractions).
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple


# ---------------------------------------------------------------------------
# 1. The arithmetic core
# ---------------------------------------------------------------------------

def below_quarter(a: int, m: int) -> bool:
    """Return True iff a/m < 1/4, using the exact integer test 4a < m (m > 0)."""
    if m <= 0:
        raise ValueError("m must be positive")
    return 4 * a < m


def threshold_identity_holds(a: int, m: int) -> bool:
    """Verify (a/m < 1/4) agrees with (4a < m) using exact rational arithmetic."""
    rational_side = Fraction(a, m) < Fraction(1, 4)
    integer_side = 4 * a < m
    return rational_side == integer_side


def least_augmentation(a: int, n: int) -> int:
    """
    Least number k of vertices to add to an n-vertex base graph of independence
    number a (with n <= 4a) so that a/(n+k) < 1/4.  Equals 4a - n + 1.
    """
    if n <= 0:
        raise ValueError("n must be positive")
    if not (n <= 4 * a):
        raise ValueError("base must sit at or above threshold: require n <= 4a")
    return 4 * a - n + 1


def fractional_lower_bound(m: int, alpha: int) -> Fraction:
    """The independence-ratio lower bound chi_f(G) >= m / alpha, exact rational."""
    if alpha <= 0:
        raise ValueError("independence number must be positive")
    return Fraction(m, alpha)


# ---------------------------------------------------------------------------
# 2. Independence number of a finite graph (small graphs only)
# ---------------------------------------------------------------------------

Graph = Dict[int, Set[int]]


def is_independent(graph: Graph, subset: Iterable[int]) -> bool:
    """Return True iff no two vertices in `subset` are adjacent."""
    s = list(subset)
    for u, v in combinations(s, 2):
        if v in graph.get(u, set()):
            return False
    return True


def independence_number(graph: Graph) -> int:
    """
    Maximum size of an independent set, by descending exhaustive search.
    Intended for small graphs (m <= ~29) as in the G27 study.
    """
    vertices = list(graph.keys())
    n = len(vertices)
    for size in range(n, 0, -1):
        for subset in combinations(vertices, size):
            if is_independent(graph, subset):
                return size
    return 0


def induced_subgraph(graph: Graph, keep: Set[int]) -> Graph:
    """The subgraph induced on the vertex set `keep` (models f^* G)."""
    return {v: (graph[v] & keep) for v in keep}


# ---------------------------------------------------------------------------
# 3. Demonstrations
# ---------------------------------------------------------------------------

def demo_threshold_identity() -> None:
    print("=" * 70)
    print("Threshold identity:  a/m < 1/4  <=>  4a < m")
    print("=" * 70)
    ok = True
    for a in range(0, 12):
        for m in range(1, 60):
            ok = ok and threshold_identity_holds(a, m)
    print(f"Identity verified for all 0<=a<=11, 1<=m<=59:  {ok}")
    print()


def demo_g27_boundary() -> None:
    print("=" * 70)
    print("G27 boundary values (independence number a = 7)")
    print("=" * 70)
    for m, label in [(27, "base G27"), (28, "one added vertex"),
                     (29, "two added vertices (G29)")]:
        r = Fraction(7, m)
        rel = "<" if r < Fraction(1, 4) else ("=" if r == Fraction(1, 4) else ">")
        forced = below_quarter(7, m)
        print(f"  m = {m:2d} ({label:24s}):  7/{m} = {float(r):.4f}  "
              f"{rel} 1/4    forces chi_f>4: {forced}")
    print()
    print(f"  Least vertices to add to G27 to force chi_f>4: "
          f"{least_augmentation(7, 27)}")
    print()


def demo_minimal_crossing_law() -> None:
    print("=" * 70)
    print("Minimal-crossing law:  least added vertices = 4a - n + 1")
    print("=" * 70)
    print(f"  {'a':>3} {'n':>4} {'k_min':>6}   check: a/(n+k_min) < 1/4 and "
          f"a/(n+k_min-1) not < 1/4")
    for a, n in [(7, 27), (5, 20), (6, 24), (10, 40), (3, 10)]:
        k = least_augmentation(a, n)
        crosses = below_quarter(a, n + k)
        just_below = (not below_quarter(a, n + k - 1)) if k >= 1 else True
        print(f"  {a:>3} {n:>4} {k:>6}   crosses={crosses}, "
              f"prev_not_below={just_below}")
    print()


def demo_independence_monotone() -> None:
    print("=" * 70)
    print("Monotonicity: adding vertices cannot shrink the independence number")
    print("=" * 70)
    # A small unit-distance-flavored graph: a 5-cycle plus two pendant vertices.
    g: Graph = {
        0: {1, 4}, 1: {0, 2}, 2: {1, 3}, 3: {2, 4}, 4: {3, 0},   # C5, alpha=2
        5: {0}, 6: {2},                                          # pendants
    }
    full_alpha = independence_number(g)
    base = induced_subgraph(g, {0, 1, 2, 3, 4})
    base_alpha = independence_number(base)
    print(f"  independence number of base (C5)          : {base_alpha}")
    print(f"  independence number after adding 2 vertices: {full_alpha}")
    print(f"  monotone (base <= augmented)?              : {base_alpha <= full_alpha}")
    print()


def demo_fractional_bound() -> None:
    print("=" * 70)
    print("Independence-ratio lower bound  chi_f >= m / alpha")
    print("=" * 70)
    for m in (27, 28, 29):
        lb = fractional_lower_bound(m, 7)
        print(f"  m = {m}: chi_f >= {m}/7 = {float(lb):.4f}   > 4 ? {lb > 4}")
    print()


def main() -> None:
    demo_threshold_identity()
    demo_g27_boundary()
    demo_minimal_crossing_law()
    demo_independence_monotone()
    demo_fractional_bound()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
