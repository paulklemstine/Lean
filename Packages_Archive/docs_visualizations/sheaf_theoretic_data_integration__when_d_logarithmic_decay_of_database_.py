"""
Visualization: Exponential Decay of Consistency Probability
===========================================================

Plots consistencyProbability(r, C) = (1 - r)^C against the number of overlap
constraints C, for several conflict rates r, on a logarithmic y-axis. Overlays
the quadratic constraint count C(n,2)*k as vertical markers to show how quickly
realistic databases fall into the "essentially never consistent" regime
(theorems: consistency_prob_mono_constraints, consistency_prob_mono_rate,
overlap_quadratic_growth, conjecture_exponential_decay_testable).

Run:  python visualization_decay.py   (saves consistency_decay.png)
"""

from __future__ import annotations

from math import comb
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def consistency_probability(r: float, c: np.ndarray) -> np.ndarray:
    """(1 - r)^c, vectorized over constraint counts c."""
    return np.power(1.0 - r, c)


def main() -> None:
    constraints = np.arange(0, 1200, 1)
    rates: List[float] = [0.05, 0.1, 0.2, 0.3]

    fig, ax = plt.subplots(figsize=(9, 5.5))
    for r in rates:
        p = consistency_probability(r, constraints)
        ax.semilogy(constraints, p, label=f"conflict rate r = {r}")

    # Mark the quadratic constraint count for a 10-column, 12-row example.
    n, k = 10, 12
    c_quad = comb(n, 2) * k  # = 45 * 12 = 540
    ax.axvline(c_quad, color="black", linestyle="--", alpha=0.6)
    ax.text(c_quad + 8, 1e-20,
            f"C(n,2)·k = {c_quad}\n(n={n}, k={k})", fontsize=9)

    ax.set_xlabel("number of overlap constraints  C")
    ax.set_ylabel("P(consistent) = (1 - r)^C   (log scale)")
    ax.set_title("Exponential decay of database consistency probability")
    ax.set_ylim(1e-60, 2.0)
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("consistency_decay.png", dpi=150)
    print("saved consistency_decay.png")


if __name__ == "__main__":
    main()
