"""Visualize the quantitative distinguisher bound advantage >= delta - eps.

Generates a heatmap of the guaranteed lower bound on distinguishing advantage
as a function of property density (delta) and leak probability (eps), the two
parameters of the approximate-distinguisher theorem of the natural proofs barrier.
"""
from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def guaranteed_advantage(delta: float, eps: float) -> float:
    """Lower bound on advantage: max(delta - eps, 0)."""
    return max(delta - eps, 0.0)


def main() -> None:
    resolution: int = 200
    deltas: np.ndarray = np.linspace(0.0, 1.0, resolution)
    epss: np.ndarray = np.linspace(0.0, 1.0, resolution)
    grid: np.ndarray = np.zeros((resolution, resolution))
    for i, eps in enumerate(epss):
        for j, delta in enumerate(deltas):
            grid[i, j] = guaranteed_advantage(float(delta), float(eps))

    fig, ax = plt.subplots(figsize=(7, 6))
    im = ax.imshow(grid, origin="lower", extent=(0, 1, 0, 1),
                   aspect="auto", cmap="viridis")
    ax.plot([0, 1], [0, 1], "w--", lw=1.5, label="delta = eps (advantage = 0)")
    ax.set_xlabel("property density  delta = randomProb(P)")
    ax.set_ylabel("leak probability  eps  >=  pseudoProb(P, g)")
    ax.set_title("Guaranteed distinguishing advantage  >=  delta - eps")
    cbar = fig.colorbar(im, ax=ax)
    cbar.set_label("advantage lower bound")
    ax.legend(loc="lower right")
    fig.tight_layout()
    fig.savefig("advantage_heatmap.png", dpi=150)
    print("wrote advantage_heatmap.png")


if __name__ == "__main__":
    main()
