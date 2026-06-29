"""
Numerical demonstrations for:

  "Irrational Densities from Parabola-Circumscribed Quadrilaterals
   in Aperiodic Tilings"

This self-contained script illustrates the three proved cornerstones:

  1. Concyclic Criterion  (concyclic_iff_sum_zero):
     four points (t, t^2) on the parabola y = x^2 are concyclic
     iff the sum of their abscissae is zero.

  2. Golden Slope Irrationality  (goldenSlope_irrational):
     the golden ratio phi = (1 + sqrt 5)/2 is irrational.

  3. Tile Density Limit  (tileDensity_tendsto):
     the Beatty striping of slope alpha has tile density
     floor(N*alpha)/N -> alpha, and at alpha = phi this limit is irrational,
     certifying that the tiling is aperiodic.

Run:  python demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. Concyclic criterion on the parabola y = x^2
# ---------------------------------------------------------------------------

def abscissa_sum(a: float, b: float, c: float, d: float) -> float:
    """Return a + b + c + d, the quantity governing concyclicity."""
    return a + b + c + d


def concyclic_by_criterion(
    a: float, b: float, c: float, d: float, tol: float = 1e-9
) -> bool:
    """Concyclic test via the proved criterion: a + b + c + d == 0."""
    return abs(abscissa_sum(a, b, c, d)) < tol


def fit_circle_through_three(
    p1: Tuple[float, float],
    p2: Tuple[float, float],
    p3: Tuple[float, float],
) -> Tuple[float, float, float]:
    """
    Fit a circle x^2 + y^2 + D x + E y + F = 0 through three points by
    solving the 3x3 linear system in (D, E, F). Returns (D, E, F).
    """
    rows: List[List[float]] = []
    rhs: List[float] = []
    for (x, y) in (p1, p2, p3):
        rows.append([x, y, 1.0])
        rhs.append(-(x * x + y * y))
    return _solve3(rows, rhs)


def _solve3(a: List[List[float]], b: List[float]) -> Tuple[float, float, float]:
    """Solve a 3x3 linear system a @ x = b by Cramer's rule."""
    def det3(m: List[List[float]]) -> float:
        return (
            m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
            - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
            + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0])
        )

    d = det3(a)
    if abs(d) < 1e-15:
        raise ValueError("degenerate system (collinear points)")
    cols: List[float] = []
    for j in range(3):
        m = [row[:] for row in a]
        for i in range(3):
            m[i][j] = b[i]
        cols.append(det3(m) / d)
    return cols[0], cols[1], cols[2]


def concyclic_by_geometry(
    a: float, b: float, c: float, d: float, tol: float = 1e-6
) -> bool:
    """
    Independent geometric certificate: fit a circle through the lifted points
    (a,a^2),(b,b^2),(c,c^2) and check whether (d,d^2) lies on it.
    """
    pts = [(t, t * t) for t in (a, b, c, d)]
    D, E, F = fit_circle_through_three(pts[0], pts[1], pts[2])
    x, y = pts[3]
    residual = x * x + y * y + D * x + E * y + F
    return abs(residual) < tol


def demo_concyclic() -> None:
    print("=" * 70)
    print("1. CONCYCLIC CRITERION:  (t, t^2) concyclic  <=>  sum of t = 0")
    print("=" * 70)
    quadruples: List[Tuple[float, float, float, float]] = [
        (-3.0, -1.0, 1.0, 3.0),   # sum 0  -> concyclic
        (-2.0, -1.0, 1.0, 2.0),   # sum 0  -> concyclic
        (1.0, 2.0, 3.0, 4.0),     # sum 10 -> NOT concyclic
        (-5.0, 0.0, 2.0, 3.0),    # sum 0  -> concyclic
        (0.5, 1.5, -1.0, -1.0),   # repeated value (degenerate-ish)
    ]
    for (a, b, c, d) in quadruples:
        s = abscissa_sum(a, b, c, d)
        crit = concyclic_by_criterion(a, b, c, d)
        try:
            geom = concyclic_by_geometry(a, b, c, d)
            geom_str = str(geom)
        except ValueError:
            geom_str = "degenerate"
        print(
            f"  a,b,c,d = {(a, b, c, d)!s:28}  sum = {s:+.1f}"
            f"   criterion={crit!s:5}  geometry={geom_str}"
        )
    print()


# ---------------------------------------------------------------------------
# 2. Golden ratio and its irrationality (numerical evidence)
# ---------------------------------------------------------------------------

def golden_ratio() -> float:
    """phi = (1 + sqrt 5) / 2, positive root of x^2 = x + 1."""
    return (1.0 + math.sqrt(5.0)) / 2.0


def best_rational_approx(x: float, max_den: int) -> Fraction:
    """Best rational approximation to x with denominator <= max_den."""
    return Fraction(x).limit_denominator(max_den)


def demo_golden() -> None:
    print("=" * 70)
    print("2. GOLDEN SLOPE IRRATIONALITY:  phi = (1 + sqrt 5)/2")
    print("=" * 70)
    phi = golden_ratio()
    print(f"  phi              = {phi:.15f}")
    print(f"  phi^2 - phi - 1  = {phi * phi - phi - 1:.2e}   (should be ~0)")
    print("  Rational approximations never stabilize (hallmark of irrationality):")
    for den in (10, 100, 1000, 10000, 100000):
        approx = best_rational_approx(phi, den)
        err = abs(float(approx) - phi)
        print(f"    den<= {den:>6}:  {str(approx):>15}  error = {err:.3e}")
    print("  The convergents are ratios of consecutive Fibonacci numbers,")
    print("  whose denominators grow without bound -> no exact fraction exists.")
    print()


# ---------------------------------------------------------------------------
# 3. Beatty striping: tile density -> alpha, irrational at the golden slope
# ---------------------------------------------------------------------------

def tile_density(alpha: float, n: int) -> float:
    """rho_alpha(N) = floor(N*alpha)/N, the vertical-stripe density."""
    return math.floor(n * alpha) / n


def beatty_word(alpha: float, length: int) -> List[int]:
    """
    Sturmian step word of slope alpha:
    w[n] = floor((n+1)*alpha) - floor(n*alpha)  for n = 0..length-1.
    Each step is either floor(alpha) or floor(alpha)+1.
    """
    return [
        math.floor((n + 1) * alpha) - math.floor(n * alpha)
        for n in range(length)
    ]


def least_period(word: List[int], max_period: Optional[int] = None) -> Optional[int]:
    """
    Return the least period p (1 <= p <= max_period) such that the word is
    periodic with period p, or None if no such period is found.
    """
    n = len(word)
    cap = n // 2 if max_period is None else min(max_period, n // 2)
    for p in range(1, cap + 1):
        if all(word[i] == word[i + p] for i in range(n - p)):
            return p
    return None


def demo_density() -> None:
    print("=" * 70)
    print("3. TILE DENSITY LIMIT:  floor(N*alpha)/N -> alpha")
    print("=" * 70)
    phi = golden_ratio()

    print("  Golden slope alpha = phi:")
    for n in (10, 100, 1000, 10000, 100000, 1000000):
        rho = tile_density(phi, n)
        print(
            f"    N = {n:>8}:  rho_N = {rho:.9f}"
            f"   |rho_N - phi| = {abs(rho - phi):.3e}   (bound 1/N = {1/n:.1e})"
        )
    print(f"  Limit equals phi = {phi:.9f}, which is IRRATIONAL.")
    print()

    print("  Aperiodicity check on the golden Sturmian word (length 2000):")
    w = beatty_word(phi, 2000)
    p = least_period(w, max_period=500)
    print(f"    least period found (<=500): {p}   (None => no period => aperiodic)")
    print()

    print("  Contrast with a RATIONAL slope alpha = 3/5 (periodic, rational density):")
    rat = 3.0 / 5.0
    wr = beatty_word(rat, 2000)
    pr = least_period(wr, max_period=50)
    print(f"    tile density at N=100000: {tile_density(rat, 100000):.6f}  (= 3/5)")
    print(f"    least period of step word: {pr}   (finite => periodic)")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    demo_concyclic()
    demo_golden()
    demo_density()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
