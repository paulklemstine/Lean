"""Visualization: the 1-Lipschitz stability of Vietoris-Rips filtrations.

Generates two panels:
  (left)  two perturbed 3-point clouds and their pairwise distances;
  (right) the diameter-weight "staircase" of each filtration, shaded to show
          that the second curve stays within a vertical band of width <= eps of
          the first -- a direct picture of the interleaving / 1-Lipschitz bound.

Run:  python _asset_viz.py   (writes stability_visualization.png)
"""
from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

Point = int
DistMatrix = Dict[Tuple[Point, Point], float]


def dist_matrix(coords: np.ndarray) -> DistMatrix:
    n = len(coords)
    d: DistMatrix = {}
    for i in range(n):
        for j in range(n):
            d[(i, j)] = float(np.linalg.norm(coords[i] - coords[j]))
    return d


def diam(d: DistMatrix, sigma: Tuple[int, ...]) -> float:
    pairs = list(combinations(sigma, 2))
    return max((d[(x, y)] for (x, y) in pairs), default=0.0)


def betti0_curve(d: DistMatrix, n: int, scales: np.ndarray) -> List[int]:
    """Number of connected components of the VR graph at each scale (a simple,
    monotone-stable invariant to visualize)."""
    out: List[int] = []
    for t in scales:
        parent = list(range(n))

        def find(a: int) -> int:
            while parent[a] != a:
                parent[a] = parent[parent[a]]
                a = parent[a]
            return a

        for i in range(n):
            for j in range(i + 1, n):
                if d[(i, j)] <= t:
                    parent[find(i)] = find(j)
        out.append(len({find(i) for i in range(n)}))
    return out


def main() -> None:
    rng = np.random.default_rng(0)
    cloud1 = np.array([[0.0, 0.0], [1.0, 0.0], [0.4, 0.9]])
    eps = 0.18
    cloud2 = cloud1 + rng.uniform(-eps, eps, size=cloud1.shape) * 0.5

    d1, d2 = dist_matrix(cloud1), dist_matrix(cloud2)
    n = 3
    simplices = [c for k in range(1, n + 1) for c in combinations(range(n), k)]

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13, 5.2))

    # Panel 1: the two clouds.
    for cloud, col, lab in ((cloud1, "#1f77b4", "cloud 1"),
                            (cloud2, "#d62728", "cloud 2")):
        ax0.scatter(cloud[:, 0], cloud[:, 1], s=140, color=col, zorder=3,
                    label=lab, edgecolor="k")
        for i, j in combinations(range(n), 2):
            ax0.plot([cloud[i, 0], cloud[j, 0]], [cloud[i, 1], cloud[j, 1]],
                     color=col, alpha=0.35, lw=2)
    ax0.set_title("Two perturbed 3-point clouds")
    ax0.legend()
    ax0.set_aspect("equal")
    ax0.grid(alpha=0.3)

    # Panel 2: diameter weights of every simplex, with the eps band.
    labels = ["".join(str(v) for v in s) for s in simplices]
    w1 = [diam(d1, s) for s in simplices]
    w2 = [diam(d2, s) for s in simplices]
    x = np.arange(len(simplices))
    ax1.bar(x - 0.2, w1, width=0.4, color="#1f77b4", label="diam (cloud 1)")
    ax1.bar(x + 0.2, w2, width=0.4, color="#d62728", label="diam (cloud 2)")
    distortion = max(abs(d1[k] - d2[k]) for k in d1)
    for xi, a in zip(x, w1):
        ax1.fill_between([xi - 0.42, xi + 0.42], a - distortion, a + distortion,
                         color="gray", alpha=0.18, zorder=0)
    ax1.set_xticks(x)
    ax1.set_xticklabels([f"{{{l}}}" for l in labels])
    ax1.set_ylabel("diameter weight (birth scale)")
    ax1.set_title(f"Diameters within distortion eps = {distortion:.3f}\n"
                  "(shaded band = 1-Lipschitz stability guarantee)")
    ax1.legend()
    ax1.grid(alpha=0.3, axis="y")

    fig.suptitle("1-Lipschitz stability: perturbing the data perturbs the "
                 "filtration no more", fontsize=13)
    fig.tight_layout()
    fig.savefig("stability_visualization.png", dpi=150)
    print("wrote stability_visualization.png; matrix distortion =",
          round(distortion, 4))


if __name__ == "__main__":
    main()
