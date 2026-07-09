"""Edge-Density Landscape Around the 3/2 Threshold.

Plots edge density |E|/|V| for forests, paths, and cycles against the 3/2
threshold and the density-1 floor, illustrating that both the forest class and the
maximum-degree-<=2 class stay strictly below 3/2 (cycles sit exactly on 1).
"""
from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def path_density(n: int) -> float:
    return (n - 1) / n if n > 0 else 0.0  # P_n: |E| = n - 1


def cycle_density(n: int) -> float:
    return 1.0  # C_n: |E| = n  =>  density exactly 1


def star_forest_density(n: int) -> float:
    # A star K_{1,n-1} is a tree on n vertices: |E| = n - 1.
    return (n - 1) / n if n > 0 else 0.0


def main() -> None:
    sizes: List[int] = list(range(3, 31))
    paths = [path_density(n) for n in sizes]
    cycles = [cycle_density(n) for n in sizes]
    stars = [star_forest_density(n) for n in sizes]

    plt.figure(figsize=(9, 5.5))
    plt.axhline(1.5, color="crimson", ls="--", lw=2, label="threshold 3/2")
    plt.axhline(1.0, color="gray", ls=":", lw=1.5, label="density floor 1")
    plt.plot(sizes, cycles, "o-", color="#1f77b4", label="cycles C_n (max deg 2)")
    plt.plot(sizes, paths, "s-", color="#2ca02c", label="paths P_n (forest)")
    plt.plot(sizes, stars, "^-", color="#9467bd", label="stars K_{1,n-1} (tree)")

    plt.fill_between(sizes, 0, 1.5, color="green", alpha=0.05)
    plt.text(20, 1.55, "no minor-closed witness here yet", color="crimson")
    plt.xlabel("number of vertices |V|")
    plt.ylabel("edge density  |E| / |V|")
    plt.title("Sparse minor-closed witnesses below the 3/2 density threshold")
    plt.ylim(0, 1.7)
    plt.legend(loc="lower right")
    plt.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("density_landscape.png", dpi=150)
    print("Saved density_landscape.png")


if __name__ == "__main__":
    main()
