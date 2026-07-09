"""Visualization: a complete set of n-1 mutually orthogonal Italian squares.

Renders the affine squares S_a(i, j) = a*i + j over Z/nZ (n prime) as a row
of colored grids, and a superimposed Graeco-Latin square for the first two,
illustrating that every ordered pair of symbols occurs exactly once.

Requires matplotlib. Run:  python visualize.py
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np

Square = List[List[int]]


def affine_square(a: int, n: int) -> Square:
    """S_a(i, j) = (a*i + j) mod n over Z/nZ."""
    return [[(a * i + j) % n for j in range(n)] for i in range(n)]


def plot_mols(n: int = 5) -> None:
    slopes = [a for a in range(n) if a != 0]            # n - 1 nonzero slopes
    squares = [affine_square(a, n) for a in slopes]

    fig, axes = plt.subplots(1, len(squares) + 1,
                             figsize=(3 * (len(squares) + 1), 3))

    for ax, a, sq in zip(axes[:-1], slopes, squares):
        ax.imshow(np.array(sq), cmap="viridis")
        for i in range(n):
            for j in range(n):
                ax.text(j, i, str(sq[i][j]), ha="center", va="center",
                        color="white", fontsize=10)
        ax.set_title(f"$S_{a}(i,j)={a}i+j$")
        ax.set_xticks([]); ax.set_yticks([])

    # Superposition of the first two squares: a Graeco-Latin square.
    a0, a1 = squares[0], squares[1]
    ax = axes[-1]
    combo = np.array([[a0[i][j] * n + a1[i][j] for j in range(n)]
                      for i in range(n)])
    ax.imshow(combo, cmap="twilight")
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f"{a0[i][j]},{a1[i][j]}", ha="center", va="center",
                    color="white", fontsize=8)
    ax.set_title("Superposition: all pairs once")
    ax.set_xticks([]); ax.set_yticks([])

    fig.suptitle(f"A complete set of {n - 1} mutually orthogonal "
                 f"Italian squares of order {n}", fontsize=13)
    fig.tight_layout()
    fig.savefig("mols_visualization.png", dpi=150)
    print("Saved mols_visualization.png")


if __name__ == "__main__":
    plot_mols(5)
