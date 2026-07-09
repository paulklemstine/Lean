"""
Visualization: the ratio spectrum k(x/D)/k(x) filling the interval [1/D, D].

Samples many quadratic irrationals x = q + sqrt(2) (q rational), computes the
exact Lagrange-constant ratio k(x/D)/k(x) for each via continued fractions, and
plots a histogram showing the ratios densely populating [1/D, D] with the
reciprocal endpoints and the central value 1 marked.

Self-contained except for matplotlib/numpy. Saves 'ratio_spectrum.png'.
"""

from __future__ import annotations

import math
from fractions import Fraction

import matplotlib.pyplot as plt
import numpy as np


def cf_quadratic_surd(P0: int, N: int, Q0: int, n_terms: int = 200) -> list[int]:
    """Exact partial quotients of (P0 + sqrt N)/Q0 (N not a perfect square)."""
    if (N - P0 * P0) % Q0 != 0:
        P0, N, Q0 = P0 * abs(Q0), N * Q0 * Q0, Q0 * abs(Q0)
    a: list[int] = []
    P, Q = P0, Q0
    sqrtN = math.isqrt(N)
    for _ in range(n_terms):
        ai = (P + sqrtN) // Q if Q > 0 else -((-P - sqrtN - 1) // (-Q))
        a.append(ai)
        P = ai * Q - P
        Q = (N - P * P) // Q
    return a


def _tail(a: list[int]) -> float:
    v = float(a[-1])
    for ai in reversed(a[:-1]):
        v = ai + 1.0 / v
    return v


def lagrange_constant(a: list[int]) -> float:
    """k(x) = 1 / limsup_i ([a_i; ...] + [0; a_{i-1}, ..., a_1])."""
    best = 0.0
    for i in range(len(a) // 4, 3 * len(a) // 4):
        best = max(best, _tail(a[i:]) + _tail([0] + a[1:i][::-1]))
    return 1.0 / best


def ratio_for(q: Fraction, D: int) -> float:
    """k((q+sqrt2)/D) / k(q+sqrt2)."""
    e, f = q.numerator, q.denominator
    k_x = lagrange_constant(cf_quadratic_surd(e, 2 * f * f, f))
    k_xD = lagrange_constant(cf_quadratic_surd(e, 2 * f * f, f * D))
    return k_xD / k_x


def main() -> None:
    D = 3
    ratios: list[float] = []
    for num in range(-40, 41):
        for den in range(1, 30):
            q = Fraction(num, den)
            try:
                ratios.append(ratio_for(q, D))
            except Exception:
                pass
    ratios = [r for r in ratios if 1.0 / D - 1e-6 <= r <= D + 1e-6]

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.hist(ratios, bins=60, range=(1.0 / D, D), color="#3b6ea5", alpha=0.85,
            edgecolor="white")
    ax.axvline(1.0 / D, color="#c0392b", lw=2, ls="--", label=f"1/D = {1/D:.3f}")
    ax.axvline(D, color="#c0392b", lw=2, ls="--", label=f"D = {D}")
    ax.axvline(1.0, color="#27ae60", lw=2, label="1 (k-invariant)")
    ax.set_xscale("log")
    ax.set_xlabel("ratio  k(x/D) / k(x)")
    ax.set_ylabel("count among sampled quadratic irrationals")
    ax.set_title(f"Ratio spectrum of x -> x/{D} filling [1/{D}, {D}]")
    ax.legend()
    fig.tight_layout()
    fig.savefig("ratio_spectrum.png", dpi=140)
    print(f"Sampled {len(ratios)} ratios in [{1/D:.3f}, {D}]; saved ratio_spectrum.png")


if __name__ == "__main__":
    main()
