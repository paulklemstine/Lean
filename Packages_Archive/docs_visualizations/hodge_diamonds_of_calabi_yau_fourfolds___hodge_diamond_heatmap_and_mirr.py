"""Heatmap of the 5x5 Calabi-Yau fourfold Hodge diamond and its mirror."""
from typing import Dict, Tuple
import numpy as np
import matplotlib.pyplot as plt


def diamond_grid(h11: int, h21: int, h31: int, h22: int) -> np.ndarray:
    table: Dict[Tuple[int, int], int] = {
        (0, 0): 1, (4, 4): 1, (0, 4): 1, (4, 0): 1,
        (1, 1): h11, (3, 3): h11, (3, 1): h31, (1, 3): h31,
        (2, 2): h22, (2, 1): h21, (1, 2): h21, (2, 3): h21, (3, 2): h21,
    }
    return np.array([[table.get((p, q), 0) for q in range(5)] for p in range(5)])


def main() -> None:
    h11, h21, h31 = 3, 2, 7
    h22 = 2 * (22 + 2 * h11 + 2 * h31 - h21)
    X = diamond_grid(h11, h21, h31, h22)
    Xm = diamond_grid(h31, h21, h11, h22)  # mirror: swap h11 <-> h31

    fig, axes = plt.subplots(1, 2, figsize=(11, 5))
    for ax, M, title in ((axes[0], X, "X"), (axes[1], Xm, "mirror X (h11<->h31)")):
        im = ax.imshow(M, cmap="viridis")
        for p in range(5):
            for q in range(5):
                ax.text(q, p, str(M[p, q]), ha="center", va="center",
                        color="white", fontsize=11)
        chi = sum((-1) ** (p + q) * M[p, q] for p in range(5) for q in range(5))
        ax.set_title(f"{title}\nchi = {chi}")
        ax.set_xlabel("q"); ax.set_ylabel("p")
        fig.colorbar(im, ax=ax, fraction=0.046)
    fig.suptitle("Calabi-Yau fourfold Hodge diamond and its mirror "
                 "(chi invariant)", fontsize=13)
    fig.tight_layout()
    fig.savefig("cy4_diamond_mirror.png", dpi=150)
    print("saved cy4_diamond_mirror.png")


if __name__ == "__main__":
    main()
