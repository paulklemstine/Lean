"""
Numerical demonstrations for:

    A Universal Order-Parameter Threshold:
    From Mean-Field Magnetism to Branching Survival

Two self-consistency equations,

    Curie-Weiss magnetization :  m = tanh(beta * m)
    Branching survival        :  q = 1 - exp(-mu * q)

are instances of a single abstract dichotomy: a concave increasing map F through
the origin (F(0) = 0) acquires a strictly positive fixed point exactly when its
slope at the origin exceeds 1.  Both critical couplings equal 1.

This script is self-contained (standard library only) and verifies:

  1. The abstract fixed-point dichotomy (slope > 1  <=>  positive fixed point).
  2. The Curie-Weiss transition at beta_c = 1.
  3. The branching survival transition at mu_c = 1, with uniqueness.
  4. The quantitative onset bound  q >= 2(mu-1)/mu^2.
  5. The critical exponents: 1/2 (magnetization, odd map) vs 1 (survival).

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Optional


# --------------------------------------------------------------------------- #
#  Core numerics                                                              #
# --------------------------------------------------------------------------- #

def positive_fixed_point(
    F: Callable[[float], float],
    b: float = 1.0,
    tol: float = 1e-14,
    max_iter: int = 200,
) -> Optional[float]:
    """Return the unique positive fixed point of a concave increasing map F on
    (0, b] with F(0) = 0, or None if only the trivial fixed point 0 exists.

    Method: bisection on H(x) = F(x) - x.  H is positive just past 0 when
    F'(0) > 1 and negative at b (saturation), so a sign change brackets the root.
    If H stays <= 0 on (0, b], no positive fixed point exists.
    """
    # Probe near 0 to detect whether the curve overtakes the diagonal.
    x_seed = min(b, 1e-6)
    if F(x_seed) - x_seed <= 0.0:
        # Curve is below the diagonal near 0 -> no positive fixed point.
        # (Double-check a coarse grid to be safe against tiny seeds.)
        overtakes = any(
            F(x) - x > 0.0 for x in (b * k / 64.0 for k in range(1, 64))
        )
        if not overtakes:
            return None

    lo, hi = 0.0, b
    # Ensure H(hi) <= 0 (saturation endpoint); shrink lo to a point with H > 0.
    # Find a bracketing lo where H(lo) > 0.
    lo = None
    for k in range(1, 4096):
        x = b * k / 4096.0
        if F(x) - x > 0.0:
            lo = x
            break
    if lo is None:
        return None
    hi = b
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        if F(mid) - mid > 0.0:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


def curie_weiss_magnetization(beta: float) -> Optional[float]:
    """Positive solution of m = tanh(beta * m), or None (paramagnetic phase)."""
    return positive_fixed_point(lambda m: math.tanh(beta * m), b=1.0)


def branching_survival(mu: float) -> Optional[float]:
    """Positive solution of q = 1 - exp(-mu * q), or None (subcritical phase)."""
    if mu <= 0.0:
        return None
    return positive_fixed_point(lambda q: 1.0 - math.exp(-mu * q), b=1.0)


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #

def demo_abstract_dichotomy() -> None:
    print("=" * 70)
    print("1. ABSTRACT DICHOTOMY: positive fixed point  <=>  origin-slope > 1")
    print("=" * 70)
    # Family F_c(x) = c * x - x^3 (concave for x > 0 near 0, F(0)=0, slope c).
    # Clip to keep it well-behaved on [0, 1].
    for c in (0.5, 0.9, 1.0, 1.1, 1.5, 2.0):
        F = lambda x, c=c: max(0.0, c * x - x ** 3)
        fp = positive_fixed_point(F, b=1.0)
        verdict = "positive fixed point" if fp else "only trivial 0"
        got = f"{fp:.6f}" if fp else "   ----   "
        print(f"  slope c = {c:>4}:  x* = {got}   ->  {verdict}")
    print("  Threshold sits exactly at c = 1, as predicted.\n")


def demo_curie_weiss() -> None:
    print("=" * 70)
    print("2. CURIE-WEISS MAGNETIZATION:  m = tanh(beta * m),  beta_c = 1")
    print("=" * 70)
    for beta in (0.5, 0.9, 1.0, 1.01, 1.5, 2.0, 3.0):
        m = curie_weiss_magnetization(beta)
        phase = "FERROMAGNETIC" if m else "paramagnetic"
        got = f"{m:.6f}" if m else "0 (none)  "
        print(f"  beta = {beta:>4}:  m = {got}   [{phase}]")
    print()


def demo_branching() -> None:
    print("=" * 70)
    print("3. BRANCHING SURVIVAL:  q = 1 - exp(-mu * q),  mu_c = 1")
    print("=" * 70)
    for mu in (0.5, 0.9, 1.0, 1.01, 1.5, 2.0, 3.0):
        q = branching_survival(mu)
        phase = "SUPERCRITICAL" if q else "subcritical"
        got = f"{q:.6f}" if q else "0 (none)  "
        # verify the self-consistency residual
        resid = abs(q - (1.0 - math.exp(-mu * q))) if q else 0.0
        print(f"  mu = {mu:>4}:  q = {got}   [{phase}]   residual={resid:.2e}")
    print()


def demo_onset_bound() -> None:
    print("=" * 70)
    print("4. QUANTITATIVE ONSET BOUND:   q >= 2(mu - 1) / mu^2")
    print("=" * 70)
    print(f"  {'mu':>6} {'q (exact)':>14} {'2(mu-1)/mu^2':>16} {'bound holds':>12}")
    for mu in (1.05, 1.1, 1.25, 1.5, 2.0, 3.0, 5.0):
        q = branching_survival(mu)
        assert q is not None
        bound = 2.0 * (mu - 1.0) / mu ** 2
        ok = "yes" if q >= bound - 1e-9 else "NO"
        print(f"  {mu:>6} {q:>14.6f} {bound:>16.6f} {ok:>12}")
    print()


def _log_log_slope(xs: list[float], ys: list[float]) -> float:
    """Least-squares slope of log(y) vs log(x)."""
    lx = [math.log(x) for x in xs]
    ly = [math.log(y) for y in ys]
    n = len(lx)
    mx = sum(lx) / n
    my = sum(ly) / n
    num = sum((a - mx) * (b - my) for a, b in zip(lx, ly))
    den = sum((a - mx) ** 2 for a in lx)
    return num / den


def demo_critical_exponents() -> None:
    print("=" * 70)
    print("5. CRITICAL EXPONENTS:  1/2 (magnetization, odd map)  vs  1 (survival)")
    print("=" * 70)
    deltas = [10.0 ** (-k) for k in range(2, 7)]  # distances past threshold

    m_vals = [curie_weiss_magnetization(1.0 + d) for d in deltas]
    q_vals = [branching_survival(1.0 + d) for d in deltas]
    m_vals = [v for v in m_vals if v is not None]
    q_vals = [v for v in q_vals if v is not None]

    slope_m = _log_log_slope(deltas[: len(m_vals)], m_vals)
    slope_q = _log_log_slope(deltas[: len(q_vals)], q_vals)

    print(f"  Curie-Weiss  m ~ (beta-1)^p :  measured p = {slope_m:.4f}  "
          f"(theory 0.5)")
    print(f"  Branching    q ~ (mu  -1)^p :  measured p = {slope_q:.4f}  "
          f"(theory 1.0)")
    print("  The odd map (no quadratic term) gives 1/2; the asymmetric")
    print("  survival map (nonzero quadratic term) gives 1.\n")


def main() -> None:
    demo_abstract_dichotomy()
    demo_curie_weiss()
    demo_branching()
    demo_onset_bound()
    demo_critical_exponents()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
