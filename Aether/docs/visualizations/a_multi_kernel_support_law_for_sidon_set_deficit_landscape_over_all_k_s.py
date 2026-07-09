"""Heatmap of the deficit D(s) over sliding windows, showing Sidon sparsity."""
from __future__ import annotations
from itertools import combinations
from typing import List
import matplotlib.pyplot as plt
import numpy as np


def deficit(s: List[int]) -> int:
    e = list(set(s))
    k = len(e)
    ds = len({a - b for a in e for b in e})
    return (k * k - k + 1) - ds


def main() -> None:
    universe = list(range(0, 10))
    k = 4
    subsets = list(combinations(universe, k))
    defs = [deficit(list(t)) for t in subsets]
    grid_w = 40
    grid_h = (len(defs) + grid_w - 1) // grid_w
    grid = np.full((grid_h, grid_w), np.nan)
    for i, d in enumerate(defs):
        grid[i // grid_w, i % grid_w] = d
    plt.figure(figsize=(10, 4))
    plt.imshow(grid, aspect="auto", cmap="viridis")
    plt.colorbar(label="deficit D(s)  (0 = Sidon)")
    n_sidon = sum(1 for d in defs if d == 0)
    plt.title(f"Deficit over all {len(defs)} 4-subsets of {{0..9}}: "
              f"{n_sidon} are Sidon")
    plt.tight_layout()
    plt.savefig("deficit_heatmap.png", dpi=150)
    print(f"wrote deficit_heatmap.png ({n_sidon} Sidon subsets)")


if __name__ == "__main__":
    main()
