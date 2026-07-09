"""Visualization: the diagonal staircase height function and its L1-mass
envelope on an m x n grid. Renders the staircase surface f(i,j)=i+j as a 3D
bar/surface plot and annotates the total mass equal to triBound(m,n).

Requires matplotlib. Run: python _viz_staircase.py
"""
from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def tri_bound(m: int, n: int) -> int:
    return n * (m * (m - 1) // 2) + m * (n * (n - 1) // 2)


def main(m: int = 8, n: int = 6) -> None:
    xs = np.arange(m)
    ys = np.arange(n)
    grid_i, grid_j = np.meshgrid(xs, ys, indexing="ij")
    heights = grid_i + grid_j  # staircase f(i,j) = i + j

    fig = plt.figure(figsize=(10, 5))

    ax1 = fig.add_subplot(1, 2, 1, projection="3d")
    ax1.plot_surface(grid_i, grid_j, heights, cmap="viridis", edgecolor="k", lw=0.3)
    ax1.set_title("Diagonal staircase  f(i,j) = i + j")
    ax1.set_xlabel("row i")
    ax1.set_ylabel("col j")
    ax1.set_zlabel("height")

    ax2 = fig.add_subplot(1, 2, 2)
    im = ax2.imshow(heights.T, origin="lower", cmap="viridis")
    for i in range(m):
        for j in range(n):
            ax2.text(i, j, str(heights[i, j]), ha="center", va="center", color="w")
    ax2.set_title(f"|f| = i+j heatmap\ntotal mass = triBound({m},{n}) = {tri_bound(m, n)}")
    ax2.set_xlabel("row i")
    ax2.set_ylabel("col j")
    fig.colorbar(im, ax=ax2, shrink=0.8)

    fig.tight_layout()
    fig.savefig("staircase_envelope.png", dpi=140)
    print("saved staircase_envelope.png; total mass =", tri_bound(m, n))


if __name__ == "__main__":
    main()
