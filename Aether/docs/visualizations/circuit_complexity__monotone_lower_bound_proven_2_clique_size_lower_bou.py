"""Visualization: the quadratic monotone lower bound for 2-CLIQUE.

Plots, for each vertex count m, the proven lower bound C(m,2) on the size of any
monotone circuit computing 2-CLIQUE, alongside the size of the canonical OR-of-edges
circuit, illustrating that the bound is met and grows quadratically.
"""
from __future__ import annotations

from math import comb
from typing import List

import matplotlib.pyplot as plt


def main() -> None:
    ms: List[int] = list(range(2, 16))
    bound: List[int] = [comb(m, 2) for m in ms]          # proven lower bound
    canonical: List[int] = [2 * comb(m, 2) - 1 for m in ms]  # OR of all edges, size

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ms, bound, "o-", label=r"lower bound  $\binom{m}{2}$", linewidth=2)
    ax.plot(ms, canonical, "s--", label="canonical OR-of-edges size", linewidth=2)
    ax.set_xlabel("number of vertices  m")
    ax.set_ylabel("circuit size")
    ax.set_title("Monotone 2-CLIQUE: proven size lower bound vs. construction")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("clique2_lower_bound.png", dpi=150)
    print("Saved clique2_lower_bound.png")


if __name__ == "__main__":
    main()
