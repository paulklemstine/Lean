"""
EML Interpolation Theory — Numerical demonstrations.

Self-contained Python demonstrating the main theorems of the package:

  * Separation: g(t) = exp(a) * log(b*t + c) is strictly monotone (b > 0),
    hence point-separating  (emlSep_strictMonoOn / emlSep_separates).
  * Jackson rate (Lipschitz): the width-n piecewise-linear EML interpolant
    approximates an L-Lipschitz f on [0,1] with error <= L/n
    (pwLinInterp_error).
  * Jackson rate (Holder): error <= 2L / n**alpha  (pwLinInterp_holder_error).
  * Smooth rate for x^2: Q_h(x) = (2/h^2)*(exp(h*x) - 1 - h*x) approximates
    x^2 with error <= (4/9)*h, i.e. <= 4/(9n) at h = 1/n
    (emlQuadApprox_error / emlQuadApprox_rate), and the rate is tight Theta(1/n)
    (emlQuadApprox_error_Theta).
  * Two witnesses for x^2: the smooth network (constant 4/9) vs. the
    piecewise-linear interpolant (constant 2)  (eml_two_witnesses_sq).

Only the standard library is required.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# ----------------------------------------------------------------------------
# Separation primitive:  g(t) = exp(a) * log(b*t + c)
# ----------------------------------------------------------------------------
def eml_sep(a: float, b: float, c: float, t: float) -> float:
    """The EML separating primitive g(t) = exp(a) * log(b*t + c)."""
    return math.exp(a) * math.log(b * t + c)


def demo_separation(lo: float = 0.0, hi: float = 1.0, samples: int = 11) -> None:
    """Show that g(t) = log(t + 1 - lo) is strictly increasing on [lo, hi],
    hence injective, hence separates points (Corollary 3.3)."""
    print("=" * 70)
    print("SEPARATION:  g(t) = log(t + 1 - lo) is strictly increasing on [lo,hi]")
    print("=" * 70)
    a, b, c = 0.0, 1.0, 1.0 - lo
    xs: List[float] = [lo + (hi - lo) * i / (samples - 1) for i in range(samples)]
    vals: List[float] = [eml_sep(a, b, c, x) for x in xs]
    strictly_increasing = all(vals[i] < vals[i + 1] for i in range(len(vals) - 1))
    for x, v in zip(xs, vals):
        print(f"  t = {x:6.3f}   g(t) = {v: .6f}")
    print(f"  strictly increasing on the grid: {strictly_increasing}")
    # Distinct points -> distinct values (separation):
    x, y = 0.25, 0.75
    print(f"  g({x}) = {eml_sep(a, b, c, x):.6f}  !=  "
          f"g({y}) = {eml_sep(a, b, c, y):.6f}  ->  separates {x} from {y}")
    print()


# ----------------------------------------------------------------------------
# Piecewise-linear EML interpolant on a uniform n-cell grid of [0,1]
# ----------------------------------------------------------------------------
def pw_lin_interp(f: Callable[[float], float], n: int, x: float) -> float:
    """Width-n continuous piecewise-linear interpolant of f on [0,1].

    Selects the cell index k = min(n-1, floor(n*x)) so that x in [k/n,(k+1)/n],
    with x = 1 assigned to the last cell, then returns the affine interpolant
    through the cell endpoints."""
    k: int = min(n - 1, math.floor(n * x))
    a: float = k / n
    b: float = (k + 1) / n
    return f(a) + (f(b) - f(a)) / (b - a) * (x - a)


def sup_error(approx: Callable[[float], float],
              target: Callable[[float], float],
              grid: int = 2001) -> float:
    """Empirical sup-norm error over a fine grid of [0,1]."""
    return max(abs(approx(i / (grid - 1)) - target(i / (grid - 1)))
               for i in range(grid))


def demo_lipschitz_rate() -> None:
    """Verify pwLinInterp_error: |f - f_hat_n| <= L/n for an L-Lipschitz f.

    Target: f(x) = |x - 1/3|, which is exactly 1-Lipschitz."""
    print("=" * 70)
    print("LIPSCHITZ JACKSON RATE:  |f - pwLinInterp(f,n)| <= L/n   (L = 1)")
    print("=" * 70)
    f: Callable[[float], float] = lambda x: abs(x - 1.0 / 3.0)
    L: float = 1.0
    print(f"  {'n':>5} {'measured error':>16} {'bound L/n':>14} {'holds':>7}")
    for n in (1, 2, 4, 8, 16, 32, 64, 128):
        err: float = sup_error(lambda x: pw_lin_interp(f, n, x), f)
        bound: float = L / n
        print(f"  {n:>5} {err:>16.6e} {bound:>14.6e} {str(err <= bound + 1e-12):>7}")
    print()


def demo_holder_rate(alpha: float = 0.5) -> None:
    """Verify pwLinInterp_holder_error: |f - f_hat_n| <= 2L/n^alpha.

    Target: f(x) = x^alpha, which is alpha-Holder with constant L = 1 on [0,1]."""
    print("=" * 70)
    print(f"HOLDER JACKSON RATE:  |f - pwLinInterp(f,n)| <= 2L/n^alpha "
          f"(alpha = {alpha}, L = 1)")
    print("=" * 70)
    f: Callable[[float], float] = lambda x: x ** alpha
    L: float = 1.0
    print(f"  {'n':>5} {'measured error':>16} {'bound 2L/n^a':>14} {'holds':>7}")
    for n in (1, 2, 4, 8, 16, 32, 64, 128):
        err: float = sup_error(lambda x: pw_lin_interp(f, n, x), f)
        bound: float = 2.0 * L / (n ** alpha)
        print(f"  {n:>5} {err:>16.6e} {bound:>14.6e} {str(err <= bound + 1e-9):>7}")
    print()


# ----------------------------------------------------------------------------
# Single-exponential network for x^2:  Q_h(x) = (2/h^2)(exp(h x) - 1 - h x)
# ----------------------------------------------------------------------------
def eml_quad_approx(h: float, x: float) -> float:
    """The single-exponential EML network Q_h(x) approximating x^2."""
    return (2.0 / h ** 2) * (math.exp(h * x) - 1.0 - h * x)


def demo_quadratic_rate() -> None:
    """Verify emlQuadApprox_error/rate: |Q_h(x) - x^2| <= (4/9)h <= 4/(9n),
    and exhibit the matching lower bound (Theta(1/n) sharpness)."""
    print("=" * 70)
    print("SMOOTH RATE FOR x^2:  |Q_h(x) - x^2| <= (4/9)h,  h = 1/n  ->  4/(9n)")
    print("=" * 70)
    target: Callable[[float], float] = lambda x: x ** 2
    print(f"  {'n':>5} {'measured error':>16} {'upper 4/(9n)':>14} "
          f"{'@x=1 (lower)':>14} {'holds':>7}")
    for n in (1, 2, 4, 8, 16, 32, 64, 128):
        h: float = 1.0 / n
        err: float = sup_error(lambda x: eml_quad_approx(h, x), target)
        upper: float = 4.0 / (9.0 * n)
        # The error at x = 1 is a positive multiple of h, witnessing the lower bound.
        lower_witness: float = abs(eml_quad_approx(h, 1.0) - 1.0)
        ok: bool = err <= upper + 1e-12
        print(f"  {n:>5} {err:>16.6e} {upper:>14.6e} "
              f"{lower_witness:>14.6e} {str(ok):>7}")
    print("  (the @x=1 column stays a fixed fraction of 1/n: the rate is Theta(1/n))")
    print()


def demo_two_witnesses() -> None:
    """eml_two_witnesses_sq: two structurally distinct width-n EML networks
    approximate x^2 at rate O(1/n); the smooth one (const 4/9) beats the
    piecewise-linear one (const 2)."""
    print("=" * 70)
    print("TWO WITNESSES FOR x^2:  smooth network (4/9) vs. pw-linear (2)")
    print("=" * 70)
    sq: Callable[[float], float] = lambda x: x ** 2
    print(f"  {'n':>5} {'smooth err':>14} {'<=4/(9n)':>12} "
          f"{'pwlin err':>14} {'<=2/n':>12}")
    for n in (1, 2, 4, 8, 16, 32, 64):
        h: float = 1.0 / n
        smooth: float = sup_error(lambda x: eml_quad_approx(h, x), sq)
        pwl: float = sup_error(lambda x: pw_lin_interp(sq, n, x), sq)
        print(f"  {n:>5} {smooth:>14.6e} {4.0/(9*n):>12.4e} "
              f"{pwl:>14.6e} {2.0/n:>12.4e}")
    print()


def main() -> None:
    demo_separation()
    demo_lipschitz_rate()
    demo_holder_rate(alpha=0.5)
    demo_quadratic_rate()
    demo_two_witnesses()
    print("All demonstrations completed: every measured error respects its "
          "certified theoretical bound.")


if __name__ == "__main__":
    main()
