"""Visualization: the toroidal slope-2 n-queens solution and the threshold landscape.

Generates two figures with matplotlib:
  (1) the board for n=13 with the slope-2 line x |-> (2x mod 13), shading the
      diagonals to show that no two queens share a row, column, or diagonal;
  (2) a bar chart of the three density constants 0.2 (proved Hall repair),
      0.216 (conjectured threshold), and 1/3 (greedy reachability ceiling).
"""

from __future__ import annotations

from math import gcd
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def diag_graph(n: int, b: int) -> List[Tuple[int, int]]:
    """Slope-2 toroidal solution { (x, (2x + b) mod n) }."""
    return [(x, (2 * x + b) % n) for x in range(n)]


def plot_board(n: int = 13, b: int = 0) -> None:
    assert gcd(n, 6) == 1, "slope-2 line is a solution only when gcd(n,6)=1"
    queens = diag_graph(n, b)
    fig, ax = plt.subplots(figsize=(6, 6))
    board = np.indices((n, n)).sum(axis=0) % 2
    ax.imshow(board, cmap="binary", alpha=0.15, origin="lower")
    rs, cs = zip(*queens)
    ax.scatter(cs, rs, s=320, marker="*", color="crimson", zorder=3,
               edgecolors="black", linewidths=0.5)
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel("column")
    ax.set_ylabel("row")
    ax.set_title(f"Toroidal slope-2 solution: n={n}, queen at (x, 2x+{b} mod {n})")
    ax.grid(True, color="gray", linewidth=0.3)
    fig.tight_layout()
    fig.savefig("nqueens_board.png", dpi=150)
    print("wrote nqueens_board.png")


def plot_threshold_landscape() -> None:
    labels = ["Proved Hall repair\n1/5 = 0.200",
              "Conjectured threshold\n27/125 = 0.216",
              "Reachability ceiling\n1/3 = 0.333"]
    values = [1 / 5, 27 / 125, 1 / 3]
    colors = ["#2a9d8f", "#e9c46a", "#e76f51"]
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.bar(labels, values, color=colors, edgecolor="black")
    for i, v in enumerate(values):
        ax.text(i, v + 0.005, f"{v:.3f}", ha="center", fontweight="bold")
    ax.set_ylabel("density  qc(n)/n")
    ax.set_ylim(0, 0.40)
    ax.set_title("The n-queens completion threshold landscape")
    fig.tight_layout()
    fig.savefig("nqueens_threshold.png", dpi=150)
    print("wrote nqueens_threshold.png")


if __name__ == "__main__":
    plot_board()
    plot_threshold_landscape()
