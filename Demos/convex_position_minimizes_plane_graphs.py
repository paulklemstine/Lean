"""
Convex Position Minimizes Plane Graphs -- Numerical Demonstrations
=================================================================

This self-contained script demonstrates, by direct computation, the results of the
accompanying paper on plane (crossing-free straight-line) graphs on points in
convex position.

For n points in convex position labeled 0, 1, ..., n-1 around the hull, a chord is
a pair (i, j) with i < j, and two chords (a, b), (c, d) cross iff their endpoints
strictly interleave: a < c < b < d or c < a < d < b. A plane graph is a set of
chords no two of which cross.

The script:
  1. computes N(n) = number of plane graphs, exactly, by enumeration, and
     validates against OEIS A054726 (1, 1, 2, 8, 48, 352, ...);
  2. verifies the star lower bound  N(n) >= 2^(n-1);
  3. verifies the fan  lower bound  N(n) >= 2^(2n-3)  (tight at n = 3);
  4. exhibits the triangulation-subset floor L(n,h) = 2^(3n-3-h) and its strict
     decrease in the hull size h, minimized at convex position h = n;
  5. verifies the parity theorem: N(n) is even for n >= 2, via the hull-edge
     toggling involution.

Enumeration is exponential (2^C(n,2) subsets), so exact counts are computed only for
small n; all closed-form bounds are evaluated for a wide range.
"""

from __future__ import annotations

from itertools import combinations
from typing import List, Tuple

Chord = Tuple[int, int]


# --------------------------------------------------------------------------- #
# Core combinatorial model
# --------------------------------------------------------------------------- #
def chords(n: int) -> List[Chord]:
    """All chords (i, j) with 0 <= i < j <= n-1 of the convex n-gon."""
    return [(i, j) for i in range(n) for j in range(i + 1, n)]


def cross(x: Chord, y: Chord) -> bool:
    """True iff chords x and y strictly interleave (i.e. their segments cross)."""
    a, b = x
    c, d = y
    return (a < c < b < d) or (c < a < d < b)


def is_plane(graph: Tuple[Chord, ...]) -> bool:
    """True iff no two chords in `graph` cross."""
    for i in range(len(graph)):
        for j in range(i + 1, len(graph)):
            if cross(graph[i], graph[j]):
                return False
    return True


def num_plane(n: int) -> int:
    """N(n): number of plane graphs on n convex points, by full enumeration."""
    cs = chords(n)
    total = 0
    for k in range(len(cs) + 1):
        for subset in combinations(cs, k):
            if is_plane(subset):
                total += 1
    return total


# --------------------------------------------------------------------------- #
# Explicit plane graphs used in the lower bounds
# --------------------------------------------------------------------------- #
def star(n: int) -> List[Chord]:
    """Star at vertex 0: all chords with lower endpoint 0. Size n-1, plane."""
    return [(0, j) for j in range(1, n)]


def fan(n: int) -> List[Chord]:
    """Fan triangulation from vertex 0: star plus all boundary edges. Size 2n-3."""
    diagonals = [(0, j) for j in range(1, n)]
    boundary = [(k, k + 1) for k in range(n - 1)]
    return sorted(set(diagonals) | set(boundary))


# --------------------------------------------------------------------------- #
# Closed-form floors
# --------------------------------------------------------------------------- #
def star_bound(n: int) -> int:
    """2^(n-1)."""
    return 2 ** max(n - 1, 0)


def fan_bound(n: int) -> int:
    """2^(2n-3) for n >= 2 (the convex triangulation floor L(n,n))."""
    return 2 ** max(2 * n - 3, 0)


def tri_floor(n: int, h: int) -> int:
    """L(n,h) = 2^(3n-3-h): floor from any triangulation with hull size h."""
    return 2 ** (3 * n - 3 - h)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_validation(max_n: int = 5) -> None:
    print("=" * 68)
    print(" 1. Exact count N(n) vs OEIS A054726")
    print("=" * 68)
    oeis = {0: 1, 1: 1, 2: 2, 3: 8, 4: 48, 5: 352}
    print(f"{'n':>3} | {'N(n)':>8} | {'A054726':>8} | match")
    print("-" * 40)
    for n in range(max_n + 1):
        val = num_plane(n)
        ref = oeis.get(n, None)
        ok = "yes" if ref == val else ("--" if ref is None else "NO")
        ref_s = str(ref) if ref is not None else "?"
        print(f"{n:>3} | {val:>8} | {ref_s:>8} | {ok}")
    print()


def demo_lower_bounds(max_n: int = 5) -> None:
    print("=" * 68)
    print(" 2-3. Star and fan lower bounds (verified <= exact count)")
    print("=" * 68)
    print(f"{'n':>3} | {'2^(n-1)':>9} | {'2^(2n-3)':>10} | {'N(n)':>8} | fan tight?")
    print("-" * 55)
    for n in range(2, max_n + 1):
        sb, fb, nn = star_bound(n), fan_bound(n), num_plane(n)
        # sanity: constructions really are plane and have the claimed sizes
        assert is_plane(tuple(star(n))) and len(star(n)) == n - 1
        assert is_plane(tuple(fan(n))) and len(fan(n)) == 2 * n - 3
        assert sb <= nn and fb <= nn
        tight = "yes" if fb == nn else "no"
        print(f"{n:>3} | {sb:>9} | {fb:>10} | {nn:>8} | {tight}")
    print()


def demo_floor_monotonicity(n: int = 12) -> None:
    print("=" * 68)
    print(f" 4. Triangulation floor L(n,h)=2^(3n-3-h) is minimized at h=n  (n={n})")
    print("=" * 68)
    print(f"{'h':>3} | {'edges 3n-3-h':>12} | {'L(n,h)':>14}")
    print("-" * 40)
    for h in range(3, n + 1):
        print(f"{h:>3} | {3 * n - 3 - h:>12} | {tri_floor(n, h):>14}")
    # strict monotone decrease
    vals = [tri_floor(n, h) for h in range(3, n + 1)]
    assert all(vals[i] > vals[i + 1] for i in range(len(vals) - 1))
    print(f"\n  Minimum at h = n = {n}: L = 2^(2n-3) = {tri_floor(n, n)}  (convex position)")
    print()


def demo_parity(max_n: int = 5) -> None:
    print("=" * 68)
    print(" 5. Parity: N(n) is even for n >= 2 (hull-edge toggling involution)")
    print("=" * 68)
    for n in range(2, max_n + 1):
        nn = num_plane(n)
        # demonstrate the involution: toggling hull edge (0,1) pairs plane graphs
        cs = chords(n)
        planar = [frozenset(s) for k in range(len(cs) + 1)
                  for s in combinations(cs, k) if is_plane(s)]
        e = (0, 1)
        planar_set = set(planar)
        # toggling the hull edge (0,1) is a fixed-point-free involution on plane graphs
        involution_ok = all((pg ^ {e}) in planar_set for pg in planar)
        no_fixed_point = all((pg ^ {e}) != pg for pg in planar)
        print(f"  n={n}: N(n)={nn}, even={nn % 2 == 0}, "
              f"involution well-defined={involution_ok}, fixed-point-free={no_fixed_point}")
    print()


def demo_extremal_gap() -> None:
    print("=" * 68)
    print(" 6. Extremal gap: small-hull configurations beat convex growth base")
    print("=" * 68)
    beta_convex = 11.6534   # growth base of N(n) (convex position)
    base_small_hull = 12.24  # Omega(12.24^n) for hull size O(n/log n)
    print(f"  convex position growth base   ~ {beta_convex}")
    print(f"  small-hull growth base (>=)   ~ {base_small_hull}")
    for n in (50, 100, 200):
        ratio = (base_small_hull / beta_convex) ** n
        print(f"  n={n:>4}: (small-hull / convex) count ratio >= {ratio:.3e}")
    print("\n  => far from convex position there are exponentially MORE plane graphs.")
    print()


def main() -> None:
    demo_validation(max_n=5)
    demo_lower_bounds(max_n=5)
    demo_floor_monotonicity(n=12)
    demo_parity(max_n=5)
    demo_extremal_gap()


if __name__ == "__main__":
    main()
