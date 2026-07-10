"""
Numerical demonstrations for
    "The Poincare Conjecture for Data: Sharp Scaling of the Manifold-Detection Threshold"

This self-contained script illustrates the four verdicts proved in the paper, working
in the discrete Chebyshev (l-infinity) grid-cube model:

    1. The packing lower bound   m^d <= |S| * (2r+1)^d   for every r-cover S.
    2. Sharpness of the exponent -1/d via the explicit grid cover of size (m/(2r+1))^d.
    3. The l-infinity -> l2 comparison  ||x||_inf <= ||x||_2 <= sqrt(d) ||x||_inf, tight at (1,...,1).
    4. The disproof of the exact power law: the minimal covering radius is a step function of n.

Run:  python demo.py
Requires only the Python standard library (no third-party packages).
"""

from __future__ import annotations

import itertools
import math
from typing import Iterable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core covering primitives (Chebyshev / l-infinity metric on the integer grid)
# ---------------------------------------------------------------------------

def cheb_distance(x: Sequence[int], s: Sequence[int]) -> int:
    """Chebyshev (l-infinity) distance between two grid points."""
    return max(abs(int(a) - int(b)) for a, b in zip(x, s))


def is_r_cover(points: Sequence[Sequence[int]],
               centers: Sequence[Sequence[int]],
               r: int) -> bool:
    """Return True iff every point lies within Chebyshev radius r of some center."""
    for x in points:
        if not any(cheb_distance(x, s) <= r for s in centers):
            return False
    return True


def grid_cube(m: int, d: int) -> List[Tuple[int, ...]]:
    """All m^d points of the discrete d-cube {0,...,m-1}^d."""
    return list(itertools.product(range(m), repeat=d))


# ---------------------------------------------------------------------------
# 1-D minimal covering radius (used in the disproof)
# ---------------------------------------------------------------------------

def coverable_1d(m: int, n: int, r: int) -> bool:
    """Can {0,...,m-1} be r-covered with at most n samples?

    Greedy left-to-right placement is optimal for interval covering, giving the
    closed form: coverable iff ceil(m / (2r+1)) <= n.
    """
    width = 2 * r + 1
    needed = math.ceil(m / width)
    return needed <= n


def min_radius_1d(m: int, n: int) -> int:
    """Minimal Chebyshev covering radius of {0,...,m-1} using <= n samples."""
    r = 0
    while not coverable_1d(m, n, r):
        r += 1
    return r


# ---------------------------------------------------------------------------
# Optimal grid cover in d dimensions (Construction 4.1)
# ---------------------------------------------------------------------------

def grid_cover(r: int, t: int, d: int) -> List[Tuple[int, ...]]:
    """The provably optimal r-cover of the cube of side m = (2r+1)*t.

    Block centers per coordinate are c_k = k*(2r+1) + r, k = 0..t-1.
    Returns the t^d product points.
    """
    centers_1d = [k * (2 * r + 1) + r for k in range(t)]
    return list(itertools.product(centers_1d, repeat=d))


# ---------------------------------------------------------------------------
# Norm comparison (Section 5)
# ---------------------------------------------------------------------------

def linf_norm(x: Sequence[float]) -> float:
    return max(abs(v) for v in x)


def l2_norm(x: Sequence[float]) -> float:
    return math.sqrt(sum(v * v for v in x))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_packing_lower_bound() -> None:
    print("=" * 72)
    print("1. Packing lower bound:  m^d <= |S| * (2r+1)^d")
    print("=" * 72)
    for (m, d, r) in [(9, 1, 1), (9, 2, 1), (7, 2, 1), (8, 3, 1)]:
        t_like = m  # arbitrary cube
        # Build a random-ish cover: the grid cover if divisible, else brute cover-check.
        lhs = m ** d
        # minimal cover cardinality lower bound
        min_cover_bound = math.ceil(lhs / (2 * r + 1) ** d)
        print(f"  m={m}, d={d}, r={r}:  m^d = {lhs},  "
              f"(2r+1)^d = {(2*r+1)**d},  "
              f"=> any r-cover needs |S| >= {min_cover_bound}")
    print()


def demo_exponent_sharpness() -> None:
    print("=" * 72)
    print("2. Sharpness of exponent -1/d: grid cover attains |S| = t^d = (m/(2r+1))^d")
    print("=" * 72)
    for (r, t, d) in [(1, 3, 1), (1, 3, 2), (1, 2, 3), (2, 2, 2)]:
        m = (2 * r + 1) * t
        cover = grid_cover(r, t, d)
        pts = grid_cube(m, d)
        ok = is_r_cover(pts, cover, r)
        predicted = t ** d
        # verify the packing bound is met with equality-in-cardinality
        lower = math.ceil(m ** d / (2 * r + 1) ** d)
        print(f"  m={m}, d={d}, r={r}:  |grid cover| = {len(cover)} "
              f"(= t^d = {predicted}), is r-cover? {ok}, "
              f"packing lower bound = {lower}  "
              f"[match: {len(cover) == lower}]")
    print()


def demo_norm_comparison() -> None:
    print("=" * 72)
    print("3. Norm comparison:  ||x||_inf <= ||x||_2 <= sqrt(d)*||x||_inf  (tight at 1s)")
    print("=" * 72)
    for d in [1, 2, 3, 5, 10]:
        ones = [1.0] * d
        li, l2 = linf_norm(ones), l2_norm(ones)
        print(f"  d={d:2d}:  all-ones vector  ||x||_inf={li:.4f}, "
              f"||x||_2={l2:.4f}, sqrt(d)*||x||_inf={math.sqrt(d):.4f}  "
              f"[ratio l2/linf = {l2/li:.4f} = sqrt(d)]")
    # a random-ish check of the two-sided inequality
    print("  Two-sided inequality check on assorted vectors:")
    for x in [[3.0, -1.0], [2.0, 2.0, 1.0], [0.0, 5.0, -5.0, 1.0]]:
        d = len(x)
        li, l2 = linf_norm(x), l2_norm(x)
        holds = li <= l2 + 1e-12 <= math.sqrt(d) * li + 1e-9
        print(f"    x={x}:  {li:.3f} <= {l2:.3f} <= {math.sqrt(d)*li:.3f}  "
              f"[holds: {holds}]")
    print()


def demo_step_function_disproof() -> None:
    print("=" * 72)
    print("4. Disproof of the exact power law: minimal radius is a STEP function of n")
    print("=" * 72)
    m = 7
    print(f"  1-D grid of m={m} points.  Minimal covering radius vs sample budget n:")
    radii = {}
    for n in range(1, m + 1):
        radii[n] = min_radius_1d(m, n)
    for n in range(1, m + 1):
        print(f"    n={n}:  minRad(7,n) = {radii[n]}")
    print()
    print(f"  Observe minRad(7,3) = {radii[3]} = minRad(7,4) = {radii[4]} even though 3 != 4.")
    print("  An exact law minRad = C/n would require C/3 = C/4, i.e. C = 0 -- contradiction.")
    print("  Hence NO positive constant C reproduces the threshold exactly.")
    print(f"  Indeed minRad(7,n) = 1 is constant for n in {{3,4,5,6}}: a staircase, not a curve.")
    print()


def main() -> None:
    print()
    print("Numerical demonstrations for the Poincare Conjecture for Data")
    print()
    demo_packing_lower_bound()
    demo_exponent_sharpness()
    demo_norm_comparison()
    demo_step_function_disproof()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
