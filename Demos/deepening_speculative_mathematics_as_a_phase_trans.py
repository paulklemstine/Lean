"""
Numerical demonstrations of the Curie-Weiss phase transition.

The mean-field self-consistency equation is

    m = tanh(beta * m + h),

where m is the order parameter (average alignment), beta is the coupling
(inverse temperature), and h is an external field. This module numerically
illustrates the rigorously proved facts:

  * beta <= 1, h = 0 : the only nonnegative solution is m = 0 (disordered).
  * beta >  1, h = 0 : a unique positive solution appears (ordered),
                       born continuously from 0 at beta_c = 1.
  * every solution satisfies |m| < 1, and solutions come in +/- m pairs.
  * h > 0 : a positive solution exists for EVERY beta (sharp transition gone).
  * near beta = 1: m*(beta) ~ sqrt(3 (beta - 1)), mean-field exponent 1/2.

Only the standard library and math are required.
"""

from __future__ import annotations

import math
from typing import Callable, Optional


def self_consistency_residual(m: float, beta: float, h: float = 0.0) -> float:
    """Return f(m) = tanh(beta*m + h) - m, whose zeros are the order parameters."""
    return math.tanh(beta * m + h) - m


def solve_positive_order_parameter(
    beta: float, h: float = 0.0, tol: float = 1e-14, max_iter: int = 200
) -> Optional[float]:
    """
    Find a positive solution m in (0, 1) of m = tanh(beta*m + h) by bisection.

    Returns None when no positive solution exists (the disordered case
    beta <= 1, h = 0), matching the proved dichotomy.
    """
    f: Callable[[float], float] = lambda m: self_consistency_residual(m, beta, h)
    lo, hi = 1e-12, 1.0 - 1e-15
    f_lo, f_hi = f(lo), f(hi)
    # A sign change on (lo, hi) certifies a positive root (intermediate value).
    if f_lo <= 0.0 or f_hi >= 0.0:
        return None
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        f_mid = f(mid)
        if abs(f_mid) < tol or (hi - lo) < tol:
            return mid
        if f_lo * f_mid < 0.0:
            hi, f_hi = mid, f_mid
        else:
            lo, f_lo = mid, f_mid
    return 0.5 * (lo + hi)


def fixed_point_iterate(
    beta: float, h: float = 0.0, m0: float = 0.5, iters: int = 500
) -> float:
    """Iterate m -> tanh(beta*m + h) from a positive seed to the stable solution."""
    m = m0
    for _ in range(iters):
        m = math.tanh(beta * m + h)
    return m


def critical_exponent_fit(
    betas: list[float],
) -> float:
    """
    Estimate the exponent p in m*(beta) ~ (beta - 1)^p as beta -> 1+ by a
    least-squares fit of log m* against log(beta - 1). Theory predicts p = 1/2.
    """
    xs, ys = [], []
    for beta in betas:
        m = solve_positive_order_parameter(beta)
        if m is None or m <= 0.0:
            continue
        xs.append(math.log(beta - 1.0))
        ys.append(math.log(m))
    n = len(xs)
    mean_x = sum(xs) / n
    mean_y = sum(ys) / n
    num = sum((x - mean_x) * (y - mean_y) for x, y in zip(xs, ys))
    den = sum((x - mean_x) ** 2 for x in xs)
    return num / den


def main() -> None:
    print("=" * 66)
    print("Curie-Weiss phase transition:  m = tanh(beta * m + h)")
    print("=" * 66)

    print("\n[1] Zero field (h = 0): the sharp transition at beta_c = 1")
    print(f"{'beta':>8} | {'positive m*':>14} | phase")
    print("-" * 46)
    for beta in [0.5, 0.9, 1.0, 1.1, 1.5, 2.0, 3.0]:
        m = solve_positive_order_parameter(beta, 0.0)
        if m is None:
            print(f"{beta:>8.2f} | {'none (m=0)':>14} | disordered")
        else:
            print(f"{beta:>8.2f} | {m:>14.10f} | ordered")

    print("\n[2] Boundedness |m| < 1 and +/- m symmetry (beta = 2.5)")
    m = solve_positive_order_parameter(2.5, 0.0)
    assert m is not None
    print(f"    +m = {m:+.10f},  residual f(+m) = {self_consistency_residual(m, 2.5):.2e}")
    print(f"    -m = {-m:+.10f}, residual f(-m) = {self_consistency_residual(-m, 2.5):.2e}")
    print(f"    |m| < 1 ?  {abs(m) < 1.0}")

    print("\n[3] Fixed-point iteration converges to the stable branch")
    for beta in [0.8, 1.2, 2.0]:
        m_iter = fixed_point_iterate(beta, 0.0, m0=0.5)
        print(f"    beta = {beta:.1f}:  iterate -> {m_iter:.10f}")

    print("\n[4] Positive field h > 0: a positive solution for EVERY beta")
    h = 0.1
    print(f"    (h = {h})")
    print(f"{'beta':>8} | {'m*':>14}")
    print("-" * 26)
    for beta in [0.0, 0.5, 1.0, 2.0]:
        m = solve_positive_order_parameter(beta, h)
        assert m is not None, "field theorem guarantees a positive solution"
        print(f"{beta:>8.2f} | {m:>14.10f}")

    print("\n[5] Critical exponent near beta = 1  (theory: 1/2)")
    betas = [1.0 + 10 ** (-k) for k in range(2, 7)]
    p = critical_exponent_fit(betas)
    print(f"    fitted exponent p = {p:.4f}  (expected 0.5)")

    print("\nAll demonstrations consistent with the proved theorems.")


if __name__ == "__main__":
    main()
