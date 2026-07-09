from __future__ import annotations
import math


def gamma_quadratic_estimate(tol: float) -> tuple[int, float]:
    """Estimate gamma to ~tol using the quadratic midpoint rate.

    Since m_n - gamma ~ 1/(24 n^2), choosing n ~ sqrt(1/(24*tol)) gives
    accuracy ~tol with only O(1/sqrt(tol)) harmonic terms (vs O(1/tol)
    for the classical linear approximant b_n).
    Returns (n, m_n) with m_n = H_n - ln(n + 1/2).
    """
    n: int = max(1, math.ceil(math.sqrt(1.0 / (24.0 * tol))))
    h: float = sum(1.0 / k for k in range(1, n + 1))
    return n, h - math.log(n + 0.5)


if __name__ == "__main__":
    for tol in (1e-4, 1e-6, 1e-8):
        n, est = gamma_quadratic_estimate(tol)
        print(f"tol={tol:.0e}: n={n}, m_n={est:.12f}")
