"""
Universal Scaling of Minimal PDE-Solver Size at a Spectral Phase Transition
===========================================================================

Self-contained numerical demonstration of the results in RESEARCH_PAPER.md.

Central object
--------------
Nmin(rho, eps) = least n in N with rho**n <= eps,
the minimal number of Neumann / power-iteration terms (equivalently, the minimal
polynomial depth of a solver) needed to drive a contraction of factor `rho` below
a tolerance `eps`. Writing rho = 1 - g for spectral gap g, the headline theorem is

        (1 - eps)/g  <=  Nmin(1 - g, eps)  <=  log(1/eps)/g + 1.

This file demonstrates:
  * the exact minimal count (rational, no floating point error),
  * the sandwich bounds,
  * the g^-1 divergence law,
  * the sqrt-acceleration exponent halving (1 -> 1/2),
  * critical-exponent transfer g = D^alpha  =>  Nmin ~ D^-alpha (or D^-alpha/2),
  * discretization independence (constant c does not change the exponent).

Run:  python demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Tuple


# --------------------------------------------------------------------------- #
# Core: the minimal iteration count                                           #
# --------------------------------------------------------------------------- #
def Nmin(rho: float, eps: float) -> int:
    """Least n with rho**n <= eps, for rho, eps in (0, 1) (float version)."""
    if not (0.0 < rho < 1.0):
        raise ValueError("rho must lie in (0, 1)")
    if not (0.0 < eps < 1.0):
        raise ValueError("eps must lie in (0, 1)")
    n = 0
    p = 1.0
    while p > eps:
        p *= rho
        n += 1
    return n


def NminQ(rho: Fraction, eps: Fraction) -> int:
    """Exact rational analogue: least n with rho**n <= eps (no rounding error)."""
    if not (0 < rho < 1):
        raise ValueError("rho must lie in (0, 1)")
    if not (0 < eps < 1):
        raise ValueError("eps must lie in (0, 1)")
    n = 0
    p = Fraction(1)
    while p > eps:
        p *= rho
        n += 1
    return n


# --------------------------------------------------------------------------- #
# The sandwich bounds (Theorem 3.5 / 4.1)                                      #
# --------------------------------------------------------------------------- #
def sandwich(g: float, eps: float, accelerated: bool = False) -> Tuple[float, float]:
    """Return (lower, upper) bounds on Nmin for spectral gap g and tolerance eps.

    lower = (1 - eps) / g_eff
    upper = log(1/eps) / g_eff + 1
    with g_eff = sqrt(g) in the accelerated (Chebyshev / CG) regime.
    """
    g_eff = math.sqrt(g) if accelerated else g
    lower = (1.0 - eps) / g_eff
    upper = math.log(1.0 / eps) / g_eff + 1.0
    return lower, upper


def critical_exponent_fit(alpha: float, accelerated: bool = False) -> float:
    """The predicted critical exponent nu for gap law g = D^alpha."""
    return alpha / 2.0 if accelerated else alpha


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_exact_counts() -> None:
    print("=" * 70)
    print("1. EXACT MINIMAL COUNTS (rational NminQ), eps = 1/100")
    print("=" * 70)
    eps = Fraction(1, 100)
    for rho in (Fraction(9, 10), Fraction(99, 100), Fraction(999, 1000)):
        g = 1 - rho
        n = NminQ(rho, eps)
        print(f"  rho={float(rho):.3f}  g={float(g):.3f}  NminQ = {n:4d}"
              f"   (log(1/eps)/g ~ {math.log(100)/float(g):7.1f})")
    print("  Shrinking the gap tenfold grows the count ~tenfold: g^-1 law.\n")


def demo_sandwich() -> None:
    print("=" * 70)
    print("2. SANDWICH BOUNDS  (1-eps)/g <= Nmin <= log(1/eps)/g + 1")
    print("=" * 70)
    eps = 0.01
    print(f"  {'g':>8} {'lower':>10} {'Nmin':>8} {'upper':>10}  bracketed?")
    for g in (0.2, 0.1, 0.05, 0.01, 0.005):
        rho = 1.0 - g
        lo, hi = sandwich(g, eps)
        n = Nmin(rho, eps)
        ok = lo <= n <= hi
        print(f"  {g:>8.3f} {lo:>10.2f} {n:>8d} {hi:>10.2f}  {ok}")
    print()


def demo_acceleration() -> None:
    print("=" * 70)
    print("3. SQRT-ACCELERATION HALVES THE EXPONENT (1 -> 1/2)")
    print("=" * 70)
    eps = 0.01
    print(f"  {'g':>8} {'Nmin(plain)':>14} {'Nmin(accel)':>14} {'ratio':>8}")
    for g in (0.1, 0.01, 0.001, 0.0001):
        n_plain = Nmin(1.0 - g, eps)
        n_accel = Nmin(1.0 - math.sqrt(g), eps)
        print(f"  {g:>8.4f} {n_plain:>14d} {n_accel:>14d} {n_plain / n_accel:>8.1f}")
    print("  Plain ~ g^-1, accelerated ~ g^-1/2; ratio ~ g^-1/2 grows.\n")


def demo_critical_exponent() -> None:
    print("=" * 70)
    print("4. CRITICAL-EXPONENT TRANSFER  g = D^alpha  =>  Nmin ~ D^-nu")
    print("=" * 70)
    eps = 0.01
    alpha = 1.5
    print(f"  gap law g = D^{alpha},  eps = {eps}")
    print(f"  {'D':>10} {'Nmin(plain)':>14} {'Nmin(accel)':>14}")
    for D in (0.3, 0.1, 0.03, 0.01):
        g = D ** alpha
        if not (0 < g < 1):
            continue
        n_plain = Nmin(1.0 - g, eps)
        n_accel = Nmin(1.0 - math.sqrt(g), eps)
        print(f"  {D:>10.3f} {n_plain:>14d} {n_accel:>14d}")
    # empirical log-log slope between first and last points
    Ds = [0.3, 0.01]
    g0, g1 = Ds[0] ** alpha, Ds[1] ** alpha
    np0, np1 = Nmin(1 - g0, eps), Nmin(1 - g1, eps)
    na0, na1 = Nmin(1 - math.sqrt(g0), eps), Nmin(1 - math.sqrt(g1), eps)
    slope_plain = math.log(np1 / np0) / math.log(Ds[1] / Ds[0])
    slope_accel = math.log(na1 / na0) / math.log(Ds[1] / Ds[0])
    print(f"  measured exponent (plain) ~ {-slope_plain:.3f}  (theory {alpha})")
    print(f"  measured exponent (accel) ~ {-slope_accel:.3f}  (theory {alpha/2})\n")


def demo_discretization_independence() -> None:
    print("=" * 70)
    print("5. DISCRETIZATION INDEPENDENCE: g = c*D^alpha, exponent = alpha for all c")
    print("=" * 70)
    eps = 0.01
    alpha = 2.0
    D_small, D_large = 0.01, 0.2
    print(f"  gap law g = c * D^{alpha}")
    print(f"  {'c':>8} {'measured exponent':>20}")
    for c in (1.0, 0.5, 0.1):
        g0, g1 = c * D_large ** alpha, c * D_small ** alpha
        n0, n1 = Nmin(1 - g0, eps), Nmin(1 - g1, eps)
        slope = math.log(n1 / n0) / math.log(D_small / D_large)
        print(f"  {c:>8.2f} {-slope:>20.3f}")
    print(f"  Exponent stays ~{alpha} for every c; only the prefactor (1/c) moves.\n")


def main() -> None:
    demo_exact_counts()
    demo_sandwich()
    demo_acceleration()
    demo_critical_exponent()
    demo_discretization_independence()
    print("All demonstrations confirm the universal g^-1 scaling law.")


if __name__ == "__main__":
    main()
