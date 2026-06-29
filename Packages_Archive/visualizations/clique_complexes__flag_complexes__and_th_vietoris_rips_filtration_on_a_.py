"""
viz_filtration.py — Visualize the Vietoris-Rips filtration on a 2D point cloud.

Generates a row of panels, one per scale epsilon, showing how edges and filled
triangles (2-faces) of the clique complex appear and accumulate as epsilon grows
(Theorem 5.1: the complexes are nested). Requires matplotlib + numpy.

Run:  python viz_filtration.py   ->  writes  vr_filtration.png
"""

from __future__ import annotations

from itertools import combinations
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Polygon


def vr_faces(points: np.ndarray, eps: float) -> Tuple[List[Tuple[int, int]],
                                                      List[Tuple[int, int, int]]]:
    """Return (edges, triangles) of the Vietoris-Rips complex at scale eps."""
    n = len(points)
    dist = np.linalg.norm(points[:, None, :] - points[None, :, :], axis=-1)
    edges = [(i, j) for i, j in combinations(range(n), 2) if dist[i, j] <= eps]
    eset = set(edges)
    triangles = [
        (i, j, k)
        for i, j, k in combinations(range(n), 3)
        if (i, j) in eset and (j, k) in eset and (i, k) in eset
    ]
    return edges, triangles


def main() -> None:
    rng = np.random.default_rng(7)
    # Points roughly on a circle (so a loop is born then filled in).
    theta = np.linspace(0, 2 * np.pi, 9, endpoint=False)
    pts = np.c_[np.cos(theta), np.sin(theta)] + 0.05 * rng.standard_normal((9, 2))

    scales = [0.5, 0.8, 1.2, 2.0]
    fig, axes = plt.subplots(1, len(scales), figsize=(4 * len(scales), 4))
    for ax, eps in zip(axes, scales):
        edges, tris = vr_faces(pts, eps)
        for (i, j, k) in tris:
            ax.add_patch(Polygon(pts[[i, j, k]], closed=True,
                                 facecolor="#4c72b0", alpha=0.25, edgecolor="none"))
        for (i, j) in edges:
            ax.plot(pts[[i, j], 0], pts[[i, j], 1], color="#dd8452", lw=1.3, zorder=2)
        ax.scatter(pts[:, 0], pts[:, 1], color="#2a2a2a", zorder=3, s=30)
        ax.set_title(f"eps = {eps}\n{len(edges)} edges, {len(tris)} triangles")
        ax.set_aspect("equal")
        ax.axis("off")
    fig.suptitle("Vietoris-Rips filtration: complexes grow monotonically with eps",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("vr_filtration.png", dpi=150)
    print("wrote vr_filtration.png")


if __name__ == "__main__":
    main()
