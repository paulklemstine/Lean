"""Visualization: the annealed free energy crossing for random k-SAT.

Plots E[Z] = 2^n (1 - 2^-k)^m on a log scale against the clause count m, for
several clause widths k, marking the freezing point E[Z] = 1 where an
unsatisfiable formula becomes forced. Requires matplotlib.
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def annealed(n: int, k: int, m: int) -> float:
    """E[Z] = 2^n (1 - 2^-k)^m."""
    return (2 ** n) * (1.0 - 2.0 ** (-k)) ** m


def main() -> None:
    n: int = 50
    ks: List[int] = [2, 3, 4, 5]
    fig, ax = plt.subplots(figsize=(8, 5))
    for k in ks:
        ms = list(range(0, int(3 * n * (2 ** k) * math.log(2)) + 1,
                         max(1, n // 25)))
        ez = [annealed(n, k, m) for m in ms]
        alphas = [m / n for m in ms]
        ax.plot(alphas, ez, label=f"k = {k}")
    ax.axhline(1.0, color="black", linestyle="--", linewidth=1,
               label="freezing point  E[Z] = 1")
    ax.set_yscale("log")
    ax.set_xlabel("clause density  alpha = m / n")
    ax.set_ylabel("annealed first moment  E[Z]")
    ax.set_title(f"First-moment freezing of random k-SAT  (n = {n})")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("threshold_crossing.png", dpi=150)
    print("Wrote threshold_crossing.png")


if __name__ == "__main__":
    main()
