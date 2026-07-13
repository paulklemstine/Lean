"""
Numerical demonstrations of the logistic-tent conjugacy.

The logistic map  f(x) = 4 x (1 - x)  and the tent map  T(t) = 1 - |2t - 1|
on the unit interval [0, 1] are topologically conjugate via the strictly
increasing homeomorphism  h(t) = sin^2(pi t / 2), which satisfies

        f(h(t)) = h(T(t))       and hence     f^n(h(t)) = h(T^n(t)).

This script verifies the conjugacy numerically and demonstrates its
consequences: the intertwining of iterates, the exact fixed set {0, 3/4},
the transported period-three orbit, and the arcsine invariant measure.

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List


# --------------------------------------------------------------------------
# Core maps
# --------------------------------------------------------------------------

def logistic(x: float) -> float:
    """The logistic map f(x) = 4 x (1 - x)."""
    return 4.0 * x * (1.0 - x)


def tent(t: float) -> float:
    """The tent map T(t) = 1 - |2t - 1|."""
    return 1.0 - abs(2.0 * t - 1.0)


def h(t: float) -> float:
    """The conjugating homeomorphism h(t) = sin^2(pi t / 2)."""
    return math.sin(math.pi * t / 2.0) ** 2


def h_inv(x: float) -> float:
    """Inverse coordinate h^{-1}(x) = (2/pi) arcsin(sqrt(x))."""
    return (2.0 / math.pi) * math.asin(math.sqrt(max(0.0, min(1.0, x))))


def iterate(g: Callable[[float], float], n: int, x: float) -> float:
    """Apply g to x a total of n times."""
    for _ in range(n):
        x = g(x)
    return x


# --------------------------------------------------------------------------
# 1. The conjugacy identity f(h(t)) = h(T(t))
# --------------------------------------------------------------------------

def demo_conjugacy(num_samples: int = 11) -> None:
    print("=" * 64)
    print("1. Conjugacy identity  f(h(t)) = h(T(t))")
    print("=" * 64)
    max_err = 0.0
    for i in range(num_samples):
        t = i / (num_samples - 1)
        lhs = logistic(h(t))
        rhs = h(tent(t))
        max_err = max(max_err, abs(lhs - rhs))
        print(f"  t={t:.3f}   f(h(t))={lhs:.10f}   h(T(t))={rhs:.10f}")
    print(f"  --> maximum discrepancy: {max_err:.2e}\n")


# --------------------------------------------------------------------------
# 2. Intertwining of all iterates f^n(h(t)) = h(T^n(t))
# --------------------------------------------------------------------------

def demo_intertwining(t: float = 0.31, max_n: int = 8) -> None:
    print("=" * 64)
    print(f"2. Intertwining of iterates at t = {t}")
    print("=" * 64)
    for n in range(1, max_n + 1):
        lhs = iterate(logistic, n, h(t))
        rhs = h(iterate(tent, n, t))
        print(f"  n={n}   f^n(h(t))={lhs:.10f}   h(T^n(t))={rhs:.10f}   "
              f"|diff|={abs(lhs - rhs):.2e}")
    print()


# --------------------------------------------------------------------------
# 3. The logistic fixed set is exactly {0, 3/4}
# --------------------------------------------------------------------------

def demo_fixed_points() -> None:
    print("=" * 64)
    print("3. Logistic fixed points: solving 4x(1-x) = x  =>  x(4x-3)=0")
    print("=" * 64)
    roots = [0.0, 0.75]
    for x in roots:
        print(f"  x={x:.4f}   f(x)={logistic(x):.10f}   fixed: {math.isclose(logistic(x), x)}")
    print(f"  --> exactly {len(roots)} fixed points = 2^1\n")


# --------------------------------------------------------------------------
# 4. The transported period-three orbit
# --------------------------------------------------------------------------

def demo_period_three() -> None:
    print("=" * 64)
    print("4. Period-three orbit transported from the tent 3-cycle")
    print("=" * 64)
    tent_cycle = [2 / 7, 4 / 7, 6 / 7]
    print("  Tent 3-cycle:")
    for t in tent_cycle:
        print(f"    T({t:.6f}) = {tent(t):.6f}")
    x0 = h(2 / 7)
    print(f"\n  Transported logistic seed x0 = h(2/7) = sin^2(pi/7) = {x0:.10f}")
    orbit = [x0, iterate(logistic, 1, x0), iterate(logistic, 2, x0)]
    for k, x in enumerate(orbit):
        print(f"    f^{k}(x0) = {x:.10f}")
    print(f"    f^3(x0) = {iterate(logistic, 3, x0):.10f}  (should equal x0)")
    distinct = len({round(v, 9) for v in orbit}) == 3
    print(f"  --> three distinct points, exact period three: {distinct}\n")


# --------------------------------------------------------------------------
# 5. Counting reduction: period-n points of both maps agree
# --------------------------------------------------------------------------

def count_fixed(g: Callable[[float], float], n: int, grid: int = 200000) -> int:
    """Count sign changes of g^n(x) - x on a fine grid (=# period-n points)."""
    def gn(x: float) -> float:
        return iterate(g, n, x) - x

    count = 0
    prev = gn(0.0)
    if abs(prev) < 1e-12:
        count += 1
    for i in range(1, grid + 1):
        x = i / grid
        cur = gn(x)
        if prev == 0.0:
            prev = cur
            continue
        if (prev < 0.0 <= cur) or (prev > 0.0 >= cur):
            count += 1
        prev = cur
    return count


def demo_counting(max_n: int = 5) -> None:
    print("=" * 64)
    print("5. Counting reduction: #period-n points, both maps -> 2^n")
    print("=" * 64)
    for n in range(1, max_n + 1):
        ct = count_fixed(tent, n)
        cl = count_fixed(logistic, n)
        print(f"  n={n}   tent count~{ct:>3}   logistic count~{cl:>3}   2^n={2**n}")
    print("  (grid-based estimates; exact theory gives 2^n)\n")


# --------------------------------------------------------------------------
# 6. Arcsine invariant measure from pushforward of uniform measure
# --------------------------------------------------------------------------

def demo_arcsine(num_iters: int = 200000, bins: int = 10) -> None:
    print("=" * 64)
    print("6. Invariant measure of logistic map = arcsine law")
    print("=" * 64)
    x = 0.234123  # generic seed avoiding eventually-periodic traps
    hist = [0] * bins
    for _ in range(num_iters):
        x = logistic(x)
        idx = min(bins - 1, int(x * bins))
        hist[idx] += 1

    def arcsine_mass(a: float, b: float) -> float:
        """Integral of 1/(pi sqrt(x(1-x))) from a to b = (2/pi)(asin sqrt b - asin sqrt a)."""
        return (2.0 / math.pi) * (math.asin(math.sqrt(b)) - math.asin(math.sqrt(a)))

    print("  bin        empirical    arcsine-theory")
    for i in range(bins):
        a, b = i / bins, (i + 1) / bins
        emp = hist[i] / num_iters
        theo = arcsine_mass(a, b)
        print(f"  [{a:.1f},{b:.1f})   {emp:.4f}       {theo:.4f}")
    print()


# --------------------------------------------------------------------------

def main() -> None:
    demo_conjugacy()
    demo_intertwining()
    demo_fixed_points()
    demo_period_three()
    demo_counting()
    demo_arcsine()


if __name__ == "__main__":
    main()
