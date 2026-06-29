"""
Visualization: a point cloud, its Vietoris-Rips complex (filled triangles), and
the filtration drawn as a sequence of growing complexes as eps increases.

Generates 'clique_complex_panels.png'. Requires matplotlib + numpy.
"""
from __future__ import annotations
from itertools import combinations
from typing import List, Tuple
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon


def is_clique(edges: set, s: Tuple[int, ...]) -> bool:
    return all(frozenset((u, v)) in edges for u, v in combinations(s, 2))


def triangles(n: int, edges: set) -> List[Tuple[int, int, int]]:
    return [t for t in combinations(range(n), 3) if is_clique(edges, t)]


def vr_edges(pts: np.ndarray, eps: float) -> set:
    n = len(pts)
    return {frozenset((u, v)) for u, v in combinations(range(n), 2)
            if np.linalg.norm(pts[u] - pts[v]) <= eps}


def draw(ax, pts: np.ndarray, eps: float) -> None:
    n = len(pts)
    E = vr_edges(pts, eps)
    for t in triangles(n, E):
        ax.add_patch(Polygon(pts[list(t)], closed=True, alpha=0.25, color="#4C72B0"))
    for e in E:
        a, b = tuple(e)
        ax.plot([pts[a, 0], pts[b, 0]], [pts[a, 1], pts[b, 1]],
                color="#2A4D69", lw=2, zorder=2)
    ax.scatter(pts[:, 0], pts[:, 1], s=120, color="#C44E52", zorder=3)
    ax.set_title(f"VR complex, eps = {eps:.2f}", fontsize=11)
    ax.set_aspect("equal")
    ax.axis("off")


def main() -> None:
    rng = np.random.default_rng(7)
    pts = rng.uniform(0, 4, size=(8, 2))
    scales = [0.8, 1.4, 2.0, 3.5]
    fig, axes = plt.subplots(1, len(scales), figsize=(4 * len(scales), 4))
    for ax, eps in zip(axes, scales):
        draw(ax, pts, eps)
    fig.suptitle("Vietoris-Rips filtration: edges then triangles fill in as eps grows",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("clique_complex_panels.png", dpi=150)
    print("wrote clique_complex_panels.png")


if __name__ == "__main__":
    main()
