"""Visualization: Calabi-Yau fourfold Hodge diamond and its mirror.
Renders the diamond as a heatmap alongside its mirror (h11 <-> h31 swap),
and plots the Euler characteristic across a family, highlighting mirror
invariance. Requires matplotlib + numpy.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def diamond_grid(h11: int, h21: int, h31: int, h22: int) -> np.ndarray:
    g = np.zeros((5, 5), dtype=int)
    for (p, q), v in {
        (0, 0): 1, (4, 4): 1, (0, 4): 1, (4, 0): 1,
        (1, 1): h11, (3, 3): h11, (3, 1): h31, (1, 3): h31,
        (2, 2): h22, (2, 1): h21, (1, 2): h21, (2, 3): h21, (3, 2): h21,
    }.items():
        g[p, q] = v
    return g


def euler_char(h11: int, h21: int, h31: int, h22: int) -> int:
    return 4 + 2 * h11 + 2 * h31 + h22 - 4 * h21


def main() -> None:
    h11, h21, h31, h22 = 5, 7, 11, 100
    G = diamond_grid(h11, h21, h31, h22)
    Gm = diamond_grid(h31, h21, h11, h22)  # mirror: swap h11<->h31

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    for ax, grid, title in (
        (axes[0], G, f"Diamond X  (chi={euler_char(h11,h21,h31,h22)})"),
        (axes[1], Gm, f"Mirror X  (chi={euler_char(h31,h21,h11,h22)})"),
    ):
        im = ax.imshow(grid, cmap="viridis")
        for p in range(5):
            for q in range(5):
                ax.text(q, p, str(grid[p, q]), ha="center", va="center",
                        color="white", fontsize=11)
        ax.set_title(title)
        ax.set_xlabel("q"); ax.set_ylabel("p")
        fig.colorbar(im, ax=ax, fraction=0.046)

    hs = np.arange(0, 30)
    chi = [euler_char(h, h21, 40 - h, h22) for h in hs]  # h11+h31 fixed
    axes[2].plot(hs, chi, "o-")
    axes[2].set_title("chi invariant under h11<->h31 (h11+h31 fixed)")
    axes[2].set_xlabel("h11 (with h31 = 40 - h11)")
    axes[2].set_ylabel("chi")
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("cy4_diamond.png", dpi=140)
    print("saved cy4_diamond.png")


if __name__ == "__main__":
    main()
