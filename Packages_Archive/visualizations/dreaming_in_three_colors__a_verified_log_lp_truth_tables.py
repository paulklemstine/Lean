"""Visualization: heatmaps of the LP connectives (neg, conj=min, disj=max)
and the designated set, on the chain ff < bb < tt.

Standalone: run `python _assets_viz_truth_tables.py` to produce
`lp_truth_tables.png`.
"""
from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np

VALUES: List[str] = ["ff", "bb", "tt"]  # chain order: 0 < 1 < 2


def neg(i: int) -> int:
    return {0: 2, 1: 1, 2: 0}[i]


def conj(i: int, j: int) -> int:
    return min(i, j)


def disj(i: int, j: int) -> int:
    return max(i, j)


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(13, 4))

    # conj = min
    conj_grid = np.array([[conj(i, j) for j in range(3)] for i in range(3)])
    disj_grid = np.array([[disj(i, j) for j in range(3)] for i in range(3)])

    for ax, grid, title in (
        (axes[0], conj_grid, "conj  (= min)"),
        (axes[1], disj_grid, "disj  (= max)"),
    ):
        ax.imshow(grid, cmap="viridis", vmin=0, vmax=2)
        ax.set_xticks(range(3))
        ax.set_yticks(range(3))
        ax.set_xticklabels(VALUES)
        ax.set_yticklabels(VALUES)
        ax.set_title(title)
        for i in range(3):
            for j in range(3):
                ax.text(j, i, VALUES[grid[i, j]], ha="center", va="center",
                        color="white", fontsize=14, fontweight="bold")

    # negation + designation bar
    ax = axes[2]
    neg_vals = [neg(i) for i in range(3)]
    desig = [0, 1, 1]  # ff undesignated, bb/tt designated
    ax.bar(range(3), [1, 1, 1], color=["#d62728" if d == 0 else "#2ca02c" for d in desig])
    for i in range(3):
        ax.text(i, 0.5, f"{VALUES[i]}\n¬={VALUES[neg_vals[i]]}",
                ha="center", va="center", color="white", fontsize=13, fontweight="bold")
    ax.set_xticks(range(3))
    ax.set_xticklabels(VALUES)
    ax.set_yticks([])
    ax.set_title("negation & designation\n(green = designated)")

    fig.suptitle("LP connectives on the chain  ff < bb < tt", fontsize=15)
    fig.tight_layout()
    fig.savefig("lp_truth_tables.png", dpi=150)
    print("wrote lp_truth_tables.png")


if __name__ == "__main__":
    main()
