"""
Visualization: the forest density staircase approaching the 1 and 3/2 thresholds.

Plots the exact tree edge densities rho(n) = (n-1)/n for growing n, showing the
monotone climb toward the limiting density 1 (a supremum never attained) and the
comfortable margin below the structural threshold 3/2.

Requires matplotlib.  Run:  python _viz.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import List

import matplotlib.pyplot as plt


def tree_densities(max_n: int) -> List[float]:
    """Exact tree densities (n-1)/n for n = 1..max_n, returned as floats."""
    return [float(Fraction(max(n - 1, 0), n)) for n in range(1, max_n + 1)]


def main() -> None:
    max_n = 40
    ns = list(range(1, max_n + 1))
    rho = tree_densities(max_n)

    fig, ax = plt.subplots(figsize=(9, 5.5))
    ax.step(ns, rho, where="mid", color="#2a6f97", linewidth=2,
            label=r"tree density $\rho(n)=(n-1)/n$")
    ax.scatter(ns, rho, color="#2a6f97", s=18, zorder=3)

    ax.axhline(1.0, color="#e07a5f", linestyle="--", linewidth=1.6,
               label=r"limiting density $1$ (supremum, never attained)")
    ax.axhline(1.5, color="#3d405b", linestyle=":", linewidth=1.6,
               label=r"structural threshold $3/2$")

    ax.fill_between(ns, 1.0, 1.5, color="#f2cc8f", alpha=0.25,
                    label=r"forbidden density band $[1,\,3/2)$ for forests")

    ax.set_xlabel("number of vertices $n$")
    ax.set_ylabel("edge density")
    ax.set_title("Forests stay strictly below density 1 — and far below 3/2")
    ax.set_ylim(0, 1.6)
    ax.legend(loc="lower right", fontsize=9)
    ax.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("forest_density_staircase.png", dpi=150)
    print("saved forest_density_staircase.png")


if __name__ == "__main__":
    main()
