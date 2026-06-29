"""Visualization: growth of iterExp n and the tight separation.

Plots, on a log-of-log axis to tame the magnitudes, the canonical tower heights
and the polynomial-argument majorant, illustrating why depth (n-1) cannot catch
iterExp n. Requires matplotlib.
"""
from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def safe_exp(t: float) -> float:
    try:
        return math.exp(t)
    except OverflowError:
        return math.inf


def iter_exp(n: int, x: float) -> float:
    v = x
    for _ in range(n):
        v = safe_exp(v)
    return v


def main() -> None:
    # Reduce by (n-1) logs: target -> exp(x), rival -> C*x^N.
    xs: List[float] = [2 + 0.5 * i for i in range(0, 100)]
    C, N = 5.0, 3
    target = [math.exp(x) for x in xs]
    rival = [C * x ** N for x in xs]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(xs, target, label="reduced target: exp(x)  (=> iterExp n)")
    ax.semilogy(xs, rival, label=f"reduced rival: {C}*x^{N}  (=> iterExp (n-1) majorant)")
    ax.set_xlabel("x")
    ax.set_ylabel("value (log scale)")
    ax.set_title("Tight separation: one exponential outgrows any polynomial")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("tight_separation.png", dpi=150)
    print("wrote tight_separation.png")


if __name__ == "__main__":
    main()
