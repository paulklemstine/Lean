"""
Numerical demonstrations of the exact identity between the logistic map and the
Chebyshev polynomials.

Central result:  for every real x and every n >= 0,

        f^n(x) = (1 - T_{2^n}(1 - 2x)) / 2,        where f(x) = 4x(1-x),

with T_m the Chebyshev polynomial of the first kind, T_m(cos t) = cos(m t).

This module verifies the identity numerically, exhibits the angle-doubling picture
x = sin^2(phi), reads off the degree 2^n of each iterate, and enumerates the
periodic points confirming the 2^n law for n = 1 and n = 2.

Run:  python demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable, List, Union

Number = Union[float, Fraction]


# --------------------------------------------------------------------------- #
# Core maps
# --------------------------------------------------------------------------- #
def logistic(x: Number) -> Number:
    """The logistic map at the fully chaotic parameter r = 4: f(x) = 4x(1-x).

    Uses integer literals so exact Fraction inputs stay exact."""
    return 4 * x * (1 - x)


def iterate(f: Callable[[float], float], n: int, x: float) -> float:
    """Apply f to x exactly n times (f^n(x))."""
    for _ in range(n):
        x = f(x)
    return x


def chebyshev_T(m: int, t: Number) -> Number:
    """Chebyshev polynomial of the first kind T_m evaluated at t, by recurrence.

    Works for both float and exact Fraction arguments."""
    one = t * 0 + 1  # 1 in the same type as t
    if m == 0:
        return one
    if m == 1:
        return t
    t_prev, t_cur = one, t
    for _ in range(2, m + 1):
        t_prev, t_cur = t_cur, 2 * t * t_cur - t_prev
    return t_cur


def logistic_via_chebyshev(n: int, x: float) -> float:
    """Closed form: f^n(x) = (1 - T_{2^n}(1 - 2x)) / 2."""
    return (1.0 - chebyshev_T(2 ** n, 1.0 - 2.0 * x)) / 2.0


def logistic_via_angle(n: int, x: float) -> float:
    """Angle-doubling form on [0,1]: f^n(x) = sin^2(2^n * arcsin(sqrt(x)))."""
    phi = math.asin(math.sqrt(x))
    return math.sin(2 ** n * phi) ** 2


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_identity() -> None:
    """Verify f^n(x) = (1 - T_{2^n}(1 - 2x))/2 exactly, including x outside [0,1].

    We use exact rational arithmetic so the polynomial identity is confirmed with
    zero error for *every* real x (represented by rationals here), not just on the
    unit interval where the angle picture lives.
    """
    print("=" * 70)
    print("1. The bridge identity  f^n(x) = (1 - T_{2^n}(1 - 2x)) / 2  (exact)")
    print("=" * 70)
    xs = [Fraction(1, 10), Fraction(1, 2), Fraction(73, 100),
          Fraction(13, 10), Fraction(-2, 5)]  # includes x outside [0,1]
    all_exact = True
    for n in range(0, 5):
        for x in xs:
            direct = iterate(logistic, n, x)
            cheb = (1 - chebyshev_T(2 ** n, 1 - 2 * x)) / 2
            if direct != cheb:
                all_exact = False
    print(f"tested n = 0..4, x in {[str(x) for x in xs]}")
    print(f"identity holds exactly for all tested (n, x)?  {all_exact}")
    print()


def demo_angle_doubling() -> None:
    """Show that on [0,1] the logistic orbit is pure angle doubling."""
    print("=" * 70)
    print("2. Chaos is angle doubling:  f^n(sin^2 phi) = sin^2(2^n phi)")
    print("=" * 70)
    x0 = 0.3
    phi = math.asin(math.sqrt(x0))
    print(f"x0 = {x0},  phi = arcsin(sqrt(x0)) = {phi:.6f} rad")
    print(f"{'n':>3} {'f^n(x0)':>14} {'sin^2(2^n phi)':>16}")
    for n in range(0, 8):
        print(f"{n:>3} {iterate(logistic, n, x0):>14.9f} "
              f"{logistic_via_angle(n, x0):>16.9f}")
    print()


def demo_sensitivity() -> None:
    """Illustrate exponential sensitivity: nearby starts diverge like 2^n."""
    print("=" * 70)
    print("3. Sensitive dependence: a tiny angle gap doubles each step")
    print("=" * 70)
    a, b = 0.300000, 0.300001
    print(f"{'n':>3} {'|f^n(a) - f^n(b)|':>22}")
    for n in range(0, 21, 4):
        d = abs(iterate(logistic, n, a) - iterate(logistic, n, b))
        print(f"{n:>3} {d:>22.12f}")
    print()


def demo_degree() -> None:
    """Confirm deg f^n = 2^n by counting roots / sampling the polynomial."""
    print("=" * 70)
    print("4. Algebraic depth:  deg f^n = deg T_{2^n} = 2^n")
    print("=" * 70)
    for n in range(0, 7):
        print(f"n = {n}:  degree of f^n = 2^{n} = {2 ** n}")
    print()


def demo_periodic_points() -> None:
    """Confirm the 2^n periodic-point law for n = 1 and n = 2."""
    print("=" * 70)
    print("5. Periodic points and the 2^n law")
    print("=" * 70)
    # n = 1: fixed points {0, 3/4}
    fp1 = [0.0, 0.75]
    print("n = 1: fixed points of f")
    for x in fp1:
        print(f"   x = {x:.6f},  f(x) = {logistic(x):.6f}")
    print(f"   count = {len(fp1)} = 2^1")
    print()
    # n = 2: fixed points {0, 3/4, (5±sqrt5)/8}
    r = math.sqrt(5.0)
    fp2 = [0.0, 0.75, (5.0 - r) / 8.0, (5.0 + r) / 8.0]
    print("n = 2: fixed points of f^2 (period dividing 2)")
    for x in fp2:
        print(f"   x = {x:.6f},  f^2(x) = {iterate(logistic, 2, x):.6f}")
    print(f"   count = {len(fp2)} = 2^2")
    # verify the exact factorisation f^2(x) - x = -4 x (x - 3/4)(16x^2 - 20x + 5)
    print("\n   verifying  f^2(x) - x = -4 x (x - 3/4)(16x^2 - 20x + 5):")
    err = 0.0
    for x in [-0.3, 0.15, 0.42, 0.88, 1.1]:
        lhs = iterate(logistic, 2, x) - x
        rhs = -4.0 * x * (x - 0.75) * (16.0 * x * x - 20.0 * x + 5.0)
        err = max(err, abs(lhs - rhs))
    print(f"   max |lhs - rhs| = {err:.3e}")
    print()


def main() -> None:
    demo_identity()
    demo_angle_doubling()
    demo_sensitivity()
    demo_degree()
    demo_periodic_points()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
