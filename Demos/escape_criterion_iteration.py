"""
Numerical demonstrations for
"An Exact Escape Criterion for the Quadratic Family:
 Iteration Bounds, Escape Times, and the Escape-Rate Potential"

All results below are illustrations of theorems proved in the paper, for the
quadratic family

        f_c(z) = z^2 + c ,      z_n = f_c^n(z) ,     R(c) = max(2, |c|).

Contents
--------
  1. One-step growth and forward invariance of {|z| > R(c)}.
  2. Geometric growth bound          |z_n| >= (|z|-1)^n |z|.
  3. Doubly exponential bound        log|z_n| - 1 >= 2^n (log|z| - 1).
  4. Effective escape times: linear (geometric) vs. log-log (logarithmic).
  5. Sound-and-complete escape test; the radius-2 test for the Mandelbrot set.
  6. Sharpness of the radius 2 at c = -2.
  7. The escape rate G_c(z) = lim 2^{-n} log|z_n|:
        - certified error envelope |2^{-n} log|z_n| - G_c(z)| <= 2^{-n},
        - a priori bound |G_c(z) - log|z|| <= 2/|z|,
        - functional equation G_c(f_c(z)) = 2 G_c(z).
  8. The Douady-Hubbard potential G_M(c) = (1/2) G_c(c^2 + c) for |c| > 2.

Self-contained: standard library only (cmath, math). Python 3.9+.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, List, Optional, Tuple

# --------------------------------------------------------------------------
# 0. Core dynamics
# --------------------------------------------------------------------------


def f_c(c: complex, z: complex) -> complex:
    """The quadratic map f_c(z) = z^2 + c."""
    return z * z + c


def escape_radius(c: complex) -> float:
    """R(c) = max(2, |c|), the escape radius of the parameter c."""
    return max(2.0, abs(c))


def orbit(c: complex, z: complex, n: int) -> List[complex]:
    """The first n+1 orbit points z_0 = z, z_1, ..., z_n under f_c."""
    pts: List[complex] = [z]
    w = z
    for _ in range(n):
        w = f_c(c, w)
        pts.append(w)
    return pts


# --------------------------------------------------------------------------
# 1. One-step growth and forward invariance
# --------------------------------------------------------------------------


def check_one_step_growth(c: complex, z: complex) -> Tuple[bool, bool]:
    """Verify, for |z| > R(c):

        (a)  |f_c(z)| >= (|z| - 1) |z|          (one-step growth)
        (b)  |f_c(z)| >  R(c)                   (forward invariance)

    Returns the pair of booleans (a), (b).
    """
    R = escape_radius(c)
    assert abs(z) > R, "z must lie strictly outside the escape radius"
    w = f_c(c, z)
    tol = 1e-12 * max(1.0, abs(w))
    return (abs(w) >= (abs(z) - 1.0) * abs(z) - tol, abs(w) > R)


# --------------------------------------------------------------------------
# 2-3. The two lower bounds on |z_n|
# --------------------------------------------------------------------------


def geometric_bound(z: complex, n: int) -> float:
    """Certified lower bound (|z| - 1)^n |z| for |z_n| (geometric estimate)."""
    return (abs(z) - 1.0) ** n * abs(z)


def doubly_exponential_bound(z: complex, n: int) -> float:
    """Certified lower bound exp(2^n (log|z| - 1) + 1) for |z_n|.

    Vacuous (below |z|) while |z| < e; overwhelming once |z| > e.
    """
    return math.exp(min(700.0, 2.0**n * (math.log(abs(z)) - 1.0) + 1.0))


def growth_table(c: complex, z: complex, steps: int) -> None:
    """Print actual |z_n| against both certified lower bounds."""
    pts = orbit(c, z, steps)
    print(f"    c = {c},  z = {z},  R(c) = {escape_radius(c):.4f}")
    print(f"    {'n':>2} | {'|z_n| actual':>16} | {'geometric':>14} | {'doubly exp':>14}")
    print("    " + "-" * 56)
    for n, w in enumerate(pts):
        print(
            f"    {n:>2} | {abs(w):>16.5g} | {geometric_bound(z, n):>14.5g} "
            f"| {doubly_exponential_bound(z, n):>14.5g}"
        )
        assert abs(w) >= geometric_bound(z, n) - 1e-9
        assert abs(w) >= doubly_exponential_bound(z, n) - 1e-9


# --------------------------------------------------------------------------
# 4. Effective escape times
# --------------------------------------------------------------------------


def escape_time_linear(z: complex, B: float, eps: float) -> int:
    """Certified escape time from the geometric bound.

    If |z| >= 2 + eps and |z| > R(c), then n >= B / (eps |z|) forces
    |z_n| >= B.  Cost in iterations: Theta(B).
    """
    assert abs(z) >= 2.0 + eps
    return math.ceil(B / (eps * abs(z)))


def escape_time_loglog(z: complex, B: float) -> int:
    """Certified escape time from the doubly exponential bound.

    If |z| >= 3 and 2^n >= (log B - 1) / (log|z| - 1), then |z_n| >= B.
    Cost in iterations: Theta(log log B).
    """
    assert abs(z) >= 3.0 and B > 0.0
    ratio = (math.log(B) - 1.0) / (math.log(abs(z)) - 1.0)
    return 0 if ratio <= 1.0 else math.ceil(math.log2(ratio))


# --------------------------------------------------------------------------
# 5-6. The escape-time test
# --------------------------------------------------------------------------


def escapes(c: complex, z: complex, budget: int = 500) -> Optional[int]:
    """First index n <= budget with |z_n| > R(c), or None if the test never fires.

    Soundness/completeness theorem: the orbit of z is bounded if and only if
    this function returns None for every budget.
    """
    R = escape_radius(c)
    w = z
    if abs(w) > R:
        return 0
    for n in range(1, budget + 1):
        w = f_c(c, w)
        if abs(w) > R:
            return n
    return None


def in_mandelbrot(c: complex, budget: int = 500) -> bool:
    """Radius-2 test: c is (not refuted to be) in M iff |f_c^n(0)| <= 2 for n <= budget.

    Theorem: c lies in the Mandelbrot set iff |f_c^n(0)| <= 2 for ALL n.
    A finite budget therefore certifies non-membership only.
    """
    w = 0j
    for _ in range(budget):
        w = f_c(c, w)
        if abs(w) > 2.0:
            return False
    return True


# --------------------------------------------------------------------------
# 7. The escape rate (Green's function)
# --------------------------------------------------------------------------


def escape_rate(c: complex, z: complex, tol: float = 1e-12) -> float:
    """G_c(z) = lim_n 2^{-n} log|z_n|, computed to within `tol`.

    Certified stopping rule: |2^{-n} log|z_n| - G_c(z)| <= 2^{-n}.
    Iteration is halted early at a large bailout to avoid floating overflow;
    by the functional equation this costs nothing, since 2^{-n} log|z_n| is
    already within 2^{-n} * (2/|z_n|) of the limit at that point.
    """
    R = escape_radius(c)
    assert abs(z) > R, "escape rate is defined on the escaping region"
    n_needed = max(1, math.ceil(math.log2(1.0 / tol)))
    w = z
    for n in range(n_needed):
        nxt = f_c(c, w)
        if abs(nxt) > 1e100:  # further steps change 2^{-n} log|z_n| below tol
            return math.log(abs(w)) / 2.0**n
        w = nxt
    return math.log(abs(w)) / 2.0**n_needed


def escape_rate_approximants(c: complex, z: complex, steps: int) -> List[float]:
    """The sequence 2^{-n} log|z_n|, n = 0..steps."""
    return [math.log(abs(w)) / 2.0**n for n, w in enumerate(orbit(c, z, steps))]


def mandelbrot_potential(c: complex) -> float:
    """Douady-Hubbard potential G_M(c) = (1/2) G_c(c^2 + c), defined for |c| > 2.

    Equivalently G_M(c) = lim_n 2^{-n} log|f_c^n(c)|: the escape rate of the
    critical VALUE c (not of the critical point 0, which differs by a factor 2).
    """
    assert abs(c) > 2.0
    return 0.5 * escape_rate(c, c * c + c)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_one_step() -> None:
    print("=" * 70)
    print("1. One-step growth  |f_c(z)| >= (|z|-1)|z|  and forward invariance")
    print("=" * 70)
    samples = [(0.3 + 0.1j, 2.5 + 0j), (-1 + 0j, 3 - 1j), (3 + 4j, 6 + 0j), (0j, 2.1j)]
    for c, z in samples:
        a, b = check_one_step_growth(c, z)
        print(
            f"    c = {c!s:>12}  z = {z!s:>10}  R(c) = {escape_radius(c):6.3f}  "
            f"|f_c(z)| = {abs(f_c(c, z)):12.5g}   growth: {a}   invariance: {b}"
        )
    # A randomised sweep, deterministic seed-free grid.
    bad = 0
    for i in range(-30, 31):
        for j in range(-30, 31):
            c = complex(i / 10.0, j / 10.0)
            z = complex(escape_radius(c) + 0.37, 0.21)
            a, b = check_one_step_growth(c, z)
            bad += (not a) + (not b)
    print(f"    grid sweep over 3721 parameters: {bad} violations")


def demo_growth_bounds() -> None:
    print()
    print("=" * 70)
    print("2-3. Certified lower bounds vs. actual growth")
    print("=" * 70)
    growth_table(0.3 + 0.1j, 2.5 + 0j, 4)
    print()
    print("    Once |z| > e the doubly exponential bound takes over completely:")
    growth_table(0.3 + 0.1j, 5 + 0j, 4)


def demo_escape_times() -> None:
    print()
    print("=" * 70)
    print("4. Certified escape times: Theta(B) versus Theta(log log B)")
    print("=" * 70)
    z = 3.0 + 0j
    print(f"    starting point |z| = {abs(z)}")
    print(f"    {'B':>12} | {'linear bound n':>16} | {'log-log bound n':>16} | {'actual':>8}")
    print("    " + "-" * 62)
    for B in [1e2, 1e6, 1e20, 1e100]:
        n_lin = escape_time_linear(z, B, 1.0)
        n_ll = escape_time_loglog(z, B)
        pts = orbit(0.1 + 0j, z, 12)
        actual = next(n for n, w in enumerate(pts) if abs(w) >= B or abs(w) > 1e300)
        print(f"    {B:>12.0e} | {n_lin:>16d} | {n_ll:>16d} | {actual:>8d}")
    print("    (the 'actual' column is for c = 0.1; the bounds hold for every c")
    print("     with |z| > max(2,|c|), which is why they are slightly loose)")


def demo_test_and_sharpness() -> None:
    print()
    print("=" * 70)
    print("5-6. Sound-and-complete escape test; sharpness of the radius 2")
    print("=" * 70)
    params = [0j, -1 + 0j, -2 + 0j, 0.25 + 0j, 0.26 + 0j, 0.3 + 0.5j, -0.75 + 0.1j, 1 + 0j]
    for c in params:
        inside = in_mandelbrot(c, 2000)
        n = escapes(c, 0j, 2000)
        verdict = "in M (undecided by finite test)" if inside else f"escapes at n = {n}"
        print(f"    c = {c!s:>12}   {verdict}")
    print()
    print("    Sharpness at c = -2: critical orbit =", [complex(round(w.real, 12), round(w.imag, 12)) for w in orbit(-2 + 0j, 0j, 5)])
    print("    modulus reaches exactly 2 and stays there; c = -2 IS in M,")
    print("    so no bailout radius R < 2 gives a sound test.")


def demo_escape_rate() -> None:
    print()
    print("=" * 70)
    print("7. The escape rate G_c(z) = lim 2^{-n} log|z_n|")
    print("=" * 70)
    print("    (a) c = 0: the orbit is z^(2^n), so G_0(z) = log|z| exactly.")
    for z in [2.5 + 0j, 4 + 3j, 100 + 0j]:
        G = escape_rate(0j, z)
        print(f"        z = {z!s:>10}   G_0(z) = {G:.12f}   log|z| = {math.log(abs(z)):.12f}")
    print()
    print("    (b) c = -1, z = 4: approximants 2^{-n} log|z_n| and the 2^{-n} envelope")
    approx = escape_rate_approximants(-1 + 0j, 4 + 0j, 6)
    G = escape_rate(-1 + 0j, 4 + 0j)
    print(f"        {'n':>2} | {'2^-n log|z_n|':>16} | {'|.-G|':>12} | {'2^-n':>10}")
    print("        " + "-" * 48)
    for n, a in enumerate(approx):
        print(f"        {n:>2} | {a:>16.9f} | {abs(a - G):>12.3e} | {2.0**-n:>10.4f}")
        assert abs(a - G) <= 2.0**-n + 1e-12
    print(f"        G_-1(4) = {G:.9f},  log 4 = {math.log(4):.9f},"
          f"  |G - log|z|| = {abs(G - math.log(4)):.6f} <= 2/|z| = {2/4:.4f}")
    print()
    print("    (c) functional equation  G_c(f_c(z)) = 2 G_c(z)")
    for c, z in [(-1 + 0j, 4 + 0j), (0.3 + 0.1j, 2.5 + 0j), (1 + 1j, 5 - 2j)]:
        G = escape_rate(c, z)
        Gf = escape_rate(c, f_c(c, z))
        print(f"        c = {c!s:>10}  z = {z!s:>10}   G = {G:.9f}   "
              f"G(f_c z) = {Gf:.9f}   ratio = {Gf / G:.12f}")
        assert abs(Gf - 2 * G) < 1e-8


def demo_potential() -> None:
    print()
    print("=" * 70)
    print("8. The Douady-Hubbard potential G_M(c) = (1/2) G_c(c^2+c),  |c| > 2")
    print("=" * 70)
    print(f"    {'c':>14} | {'G_M(c)':>12} | {'log|c|':>12} | {'lower bd':>12}")
    print("    " + "-" * 58)
    for c in [2.5 + 0j, -3 + 0j, 4 + 4j, 10 + 0j, 1000 + 0j]:
        GM = mandelbrot_potential(c)
        w = c * c + c
        lower = 0.5 * (math.log(abs(w)) - 2.0 / abs(w))
        print(f"    {c!s:>14} | {GM:>12.8f} | {math.log(abs(c)):>12.8f} | {lower:>12.8f}")
        assert GM > 0.0 and GM >= lower - 1e-9
    print("    G_M(c) - log|c| -> 0 as |c| -> infinity, at rate O(1/|c|):")
    for c in [10 + 0j, 100 + 0j, 1000 + 0j, 10000 + 0j]:
        GM = mandelbrot_potential(c)
        print(f"        |c| = {abs(c):>9.0f}   G_M - log|c| = {GM - math.log(abs(c)):+.3e}"
              f"   (2/|c| = {2/abs(c):.3e})")
    print()
    print("    Consistency with the defining limit  G_M(c) = lim 2^-n log|f_c^n(c)|:")
    for c in [2.5 + 0j, -3 + 0j, 4 + 4j]:
        w = c
        seq = []
        for n in range(6):
            seq.append(math.log(abs(w)) / 2.0**n)
            w = f_c(c, w)
        print(f"        c = {c!s:>10}   approximants " +
              ", ".join(f"{s:.6f}" for s in seq) +
              f"   ->  {mandelbrot_potential(c):.6f}")


def main() -> None:
    demo_one_step()
    demo_growth_bounds()
    demo_escape_times()
    demo_test_and_sharpness()
    demo_escape_rate()
    demo_potential()
    print()
    print("All assertions passed: every certified bound held on every sample.")


if __name__ == "__main__":
    main()
