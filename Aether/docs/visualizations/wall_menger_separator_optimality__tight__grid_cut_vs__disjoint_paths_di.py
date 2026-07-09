"""Visualize the column separator and the disjoint row paths of a grid."""
from typing import List, Tuple
import matplotlib.pyplot as plt

Vertex = Tuple[int, int]


def visualize(m: int = 3, n: int = 7, c: int = 3) -> None:
    fig, ax = plt.subplots(figsize=(1.1 * (n + 1), 1.1 * (m + 1)))

    # grid edges
    for i in range(m + 1):
        for j in range(n + 1):
            if j < n:
                ax.plot([j, j + 1], [i, i], color="0.8", lw=1, zorder=1)
            if i < m:
                ax.plot([j, j], [i, i + 1], color="0.8", lw=1, zorder=1)

    # disjoint row paths (the maximum packing)
    for i in range(m + 1):
        ax.plot(range(n + 1), [i] * (n + 1), color="#1f77b4", lw=3,
                solid_capstyle="round", zorder=2,
                label="disjoint row paths" if i == 0 else None)

    # column separator (the minimum cut)
    ax.scatter([c] * (m + 1), range(m + 1), s=220, color="#d62728",
               zorder=4, label=f"column separator (size {m + 1})")

    # left / right regions
    ax.scatter([0] * (m + 1), range(m + 1), s=90, color="#2ca02c",
               zorder=3, label="A (left column)")
    ax.scatter([n] * (m + 1), range(m + 1), s=90, color="#9467bd",
               zorder=3, label="B (right column)")

    ax.set_title(f"Grid {m + 1}x{n + 1}: min-cut = max-disjoint-paths = {m + 1}")
    ax.set_aspect("equal")
    ax.axis("off")
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.05), ncol=2)
    plt.tight_layout()
    plt.savefig("wall_menger_grid.png", dpi=150, bbox_inches="tight")
    print("saved wall_menger_grid.png")


if __name__ == "__main__":
    visualize()
