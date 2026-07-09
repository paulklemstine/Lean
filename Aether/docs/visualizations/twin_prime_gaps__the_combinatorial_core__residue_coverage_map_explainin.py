"""
Visualization: residue-coverage map showing why admissibility is a finite check.

Generates `admissibility_map.png`: for an admissible tuple H, a grid whose rows
are the primes p <= |H| and whose columns are residue classes 0..p-1; a cell is
shaded if class r is HIT by some h in H. Each row of an admissible tuple leaves
at least one blank cell (the missing residue from `exists_missing_residue`).
Compares the admissible {0,2,6,8,12} with the inadmissible {0,2,4}.
"""

from __future__ import annotations

import matplotlib.pyplot as plt
import numpy as np


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def primes_upto(limit: int) -> list[int]:
    return [p for p in range(2, limit + 1) if is_prime(p)]


def coverage_grid(H: list[int]) -> tuple[list[int], np.ndarray]:
    k = len(set(H))
    ps = primes_upto(k)
    width = max(ps) if ps else 1
    grid = np.full((len(ps), width), np.nan)
    for i, p in enumerate(ps):
        hit = {h % p for h in H}
        for r in range(p):
            grid[i, r] = 1.0 if r in hit else 0.0
    return ps, grid


def main() -> None:
    examples = {"admissible {0,2,6,8,12}": [0, 2, 6, 8, 12],
                "inadmissible {0,2,4}": [0, 2, 4]}
    fig, axes = plt.subplots(1, 2, figsize=(12, 4))
    for ax, (title, H) in zip(axes, examples.items()):
        ps, grid = coverage_grid(H)
        ax.imshow(grid, aspect="auto", cmap="RdYlGn_r", vmin=0, vmax=1)
        ax.set_yticks(range(len(ps)))
        ax.set_yticklabels([f"p={p}" for p in ps])
        ax.set_xlabel("residue class r")
        ax.set_title(title)
        for i, p in enumerate(ps):
            for r in range(grid.shape[1]):
                if np.isnan(grid[i, r]):
                    ax.add_patch(plt.Rectangle((r - 0.5, i - 0.5), 1, 1,
                                               color="lightgray"))
    fig.suptitle("Residue coverage: a blank (green) cell per row = admissible")
    fig.tight_layout()
    fig.savefig("admissibility_map.png", dpi=140)
    print("wrote admissibility_map.png")


if __name__ == "__main__":
    main()
