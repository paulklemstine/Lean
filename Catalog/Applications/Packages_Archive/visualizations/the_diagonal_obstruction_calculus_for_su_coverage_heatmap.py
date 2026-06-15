"""Visualization: residue-sum coverage density across moduli and term counts.

Generates a heatmap of |R_{n,s}(m)| / m (fraction of residues reachable as a
sum of s n-th powers) -- bright cells are obstruction-free, dark cells obstruct.
Saves to 'coverage_heatmap.png'.
"""
from __future__ import annotations
import matplotlib.pyplot as plt
import numpy as np


def residue_sums(n: int, s: int, m: int) -> set[int]:
    powers = {pow(x, n, m) for x in range(m)}
    reachable: set[int] = {0}
    for _ in range(s):
        reachable = {(r + p) % m for r in reachable for p in powers}
    return reachable


def main() -> None:
    n = 3                       # cubes
    moduli = list(range(2, 31))
    term_counts = list(range(1, 9))
    grid = np.zeros((len(term_counts), len(moduli)))
    for i, s in enumerate(term_counts):
        for j, m in enumerate(moduli):
            grid[i, j] = len(residue_sums(n, s, m)) / m

    fig, ax = plt.subplots(figsize=(11, 5))
    im = ax.imshow(grid, aspect="auto", origin="lower", cmap="viridis",
                   vmin=0, vmax=1)
    ax.set_xticks(range(len(moduli)))
    ax.set_xticklabels(moduli)
    ax.set_yticks(range(len(term_counts)))
    ax.set_yticklabels(term_counts)
    ax.set_xlabel("modulus m")
    ax.set_ylabel("number of terms s")
    ax.set_title(f"Coverage |R_{{n,s}}(m)|/m for n={n} (cubes): "
                 f"dark = local obstruction present")
    fig.colorbar(im, ax=ax, label="fraction of residues reachable")
    fig.tight_layout()
    fig.savefig("coverage_heatmap.png", dpi=150)
    print("saved coverage_heatmap.png")


if __name__ == "__main__":
    main()
