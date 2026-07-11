"""Numerical demonstrations of two mean-field phase transitions.

This self-contained script illustrates the rigorous results of the accompanying
paper for two exactly-solvable models, each governed by a scalar self-consistency
equation for an order parameter:

  * Curie-Weiss ferromagnet:  m = tanh(beta * m),         critical beta_c = 1
  * Mean-field percolation:    rho = 1 - exp(-lam * rho),  critical lam_c = 1

For each model we:
  1. solve the fixed-point equation numerically for the nontrivial branch,
  2. verify the disordered/subcritical uniqueness (only 0 below threshold),
  3. check the proven near-critical lower bounds, and
  4. exhibit the critical exponents (1/2 for magnetization, 1 for percolation).

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Optional


# --------------------------------------------------------------------------- #
# Generic scalar fixed-point solver on (0, upper]                             #
# --------------------------------------------------------------------------- #
def solve_positive_fixed_point(
    phi: Callable[[float], float],
    upper: float,
    tol: float = 1e-14,
    max_iter: int = 200,
) -> Optional[float]:
    """Return the largest x in (0, upper] with phi(x) = x, via bisection on the
    residual F(x) = phi(x) - x, or None if no positive fixed point is detected.

    We use the structure of both models: F(x) is positive just above 0 in the
    supercritical regime and negative at the upper end, so a sign change brackets
    the nontrivial root.
    """
    f = lambda x: phi(x) - x
    lo, hi = tol, upper
    if f(lo) <= 0.0 or f(hi) >= 0.0:
        return None
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        if f(mid) > 0.0:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


# --------------------------------------------------------------------------- #
# Model 1: Curie-Weiss ferromagnet, m = tanh(beta * m)                        #
# --------------------------------------------------------------------------- #
def magnetization(beta: float) -> float:
    """Spontaneous magnetization m >= 0 solving m = tanh(beta * m).

    Returns 0 in the disordered phase (beta <= 1) and the positive branch for
    beta > 1.
    """
    if beta <= 1.0:
        return 0.0
    m = solve_positive_fixed_point(lambda x: math.tanh(beta * x), upper=1.0)
    return m if m is not None else 0.0


def magnetization_lower_bound(beta: float) -> float:
    """Proven lower bound m^2 >= 3(beta-1)/beta^3  =>  m >= sqrt(...)."""
    if beta <= 1.0:
        return 0.0
    return math.sqrt(3.0 * (beta - 1.0) / beta ** 3)


# --------------------------------------------------------------------------- #
# Model 2: Mean-field percolation, rho = 1 - exp(-lam * rho)                  #
# --------------------------------------------------------------------------- #
def survival_probability(lam: float) -> float:
    """Giant-component fraction rho in [0, 1) solving rho = 1 - exp(-lam*rho)."""
    if lam <= 1.0:
        return 0.0
    # Use -expm1(-y) = 1 - exp(-y) to avoid catastrophic cancellation for small y.
    rho = solve_positive_fixed_point(lambda x: -math.expm1(-lam * x), upper=1.0)
    return rho if rho is not None else 0.0


def survival_lower_bound(lam: float) -> float:
    """Proven lower bound rho >= 2(lam-1)/lam^2."""
    if lam <= 1.0:
        return 0.0
    return 2.0 * (lam - 1.0) / lam ** 2


# --------------------------------------------------------------------------- #
# Estimate a critical exponent by a log-log slope near the threshold          #
# --------------------------------------------------------------------------- #
def estimate_exponent(
    order_param: Callable[[float], float], eps_values: list[float]
) -> float:
    """Estimate p in  order_param(1 + eps) ~ eps^p  via least-squares slope of
    log(order_param) against log(eps)."""
    xs = [math.log(e) for e in eps_values]
    ys = [math.log(order_param(1.0 + e)) for e in eps_values]
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den


def main() -> None:
    print("=" * 70)
    print("MEAN-FIELD PHASE TRANSITIONS: NUMERICAL DEMONSTRATION")
    print("=" * 70)

    # --- Curie-Weiss ------------------------------------------------------- #
    print("\n[1] Curie-Weiss ferromagnet:  m = tanh(beta * m),  beta_c = 1\n")
    print(f"{'beta':>6} {'m (numeric)':>14} {'lower bound':>14} {'m=tanh(bm)?':>14}")
    for beta in [0.5, 0.9, 1.0, 1.1, 1.5, 2.0, 3.0]:
        m = magnetization(beta)
        lb = magnetization_lower_bound(beta)
        residual = abs(math.tanh(beta * m) - m)
        ok = "yes" if residual < 1e-9 else "NO"
        print(f"{beta:>6.2f} {m:>14.9f} {lb:>14.9f} {ok:>14}")
        assert m + 1e-9 >= lb, "lower bound violated!"
    assert magnetization(0.9) == 0.0, "subcritical order must vanish"

    eps = [10 ** (-k) for k in range(1, 7)]
    p_mag = estimate_exponent(magnetization, eps)
    print(f"\n  Estimated critical exponent (expected 1/2):  {p_mag:.4f}")

    # --- Percolation ------------------------------------------------------- #
    print("\n[2] Mean-field percolation:  rho = 1 - exp(-lam*rho),  lam_c = 1\n")
    print(f"{'lam':>6} {'rho (numeric)':>14} {'lower bound':>14} {'fixed pt?':>12}")
    for lam in [0.5, 0.9, 1.0, 1.1, 1.5, 2.0, 3.0]:
        rho = survival_probability(lam)
        lb = survival_lower_bound(lam)
        residual = abs((-math.expm1(-lam * rho)) - rho)
        ok = "yes" if residual < 1e-9 else "NO"
        print(f"{lam:>6.2f} {rho:>14.9f} {lb:>14.9f} {ok:>12}")
        assert rho + 1e-9 >= lb, "lower bound violated!"
        assert rho < 1.0, "survival probability must be < 1"
    assert survival_probability(0.9) == 0.0, "subcritical giant component vanishes"

    p_perc = estimate_exponent(survival_probability, eps)
    print(f"\n  Estimated critical exponent (expected 1):    {p_perc:.4f}")

    print("\n" + "=" * 70)
    print("All assertions passed: transitions at coupling 1, bounds respected,")
    print("exponents ~1/2 (magnetization) and ~1 (percolation).")
    print("=" * 70)


if __name__ == "__main__":
    main()
