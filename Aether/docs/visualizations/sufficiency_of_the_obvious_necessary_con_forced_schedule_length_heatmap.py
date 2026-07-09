"""Heatmap of the forced schedule length N = 2n(n-1)/sum(m) over a grid of
two-table profiles (m1, m2). Requires matplotlib and numpy."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def make(nmax: int = 12) -> None:
    grid = np.full((nmax, nmax), np.nan)
    for m1 in range(2, nmax):
        for m2 in range(2, nmax):
            n = m1 + m2
            total = 2 * n * (n - 1)
            if total % (m1 + m2) == 0:
                grid[m1, m2] = total // (m1 + m2)
    plt.imshow(grid, origin="lower", cmap="viridis")
    plt.colorbar(label="forced nights N")
    plt.xlabel("m2"); plt.ylabel("m1")
    plt.title("Forced schedule length for two round tables (s = 0)")
    plt.tight_layout(); plt.savefig("nights_heatmap.png", dpi=150)
    print("wrote nights_heatmap.png")


if __name__ == "__main__":
    make()
