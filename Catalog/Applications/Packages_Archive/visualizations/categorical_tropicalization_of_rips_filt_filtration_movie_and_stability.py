"""Visualization: Rips filtration movie + stability of the interleaving distance.

Generates two figures:
  (1) the Vietoris-Rips graph at several scales (the "movie of shapes");
  (2) the optimal interleaving shift vs. sup-distance under random perturbations,
      confirming interleavingDist <= ||d - d'||_inf (points on/under diagonal).

Requires: matplotlib, numpy.  Run: python visualization.py
"""
from __future__ import annotations
from itertools import combinations, product
from typing import Dict, List, Tuple
import numpy as np
import matplotlib.pyplot as plt

Edge = Tuple[int, int]


def dist_matrix(pts: np.ndarray) -> Dict[Edge, float]:
    d: Dict[Edge, float] = {}
    n = len(pts)
    for i, j in product(range(n), range(n)):
        d[(i, j)] = float(np.linalg.norm(pts[i] - pts[j]))
    return d


def rips_edges(d: Dict[Edge, float], n: int, t: float) -> List[Edge]:
    return [(i, j) for i, j in combinations(range(n), 2) if d[(i, j)] <= t]


def fig_filtration(pts: np.ndarray, scales: List[float]) -> None:
    d = dist_matrix(pts)
    n = len(pts)
    fig, axes = plt.subplots(1, len(scales), figsize=(4 * len(scales), 4))
    for ax, t in zip(axes, scales):
        for (i, j) in rips_edges(d, n, t):
            ax.plot([pts[i, 0], pts[j, 0]], [pts[i, 1], pts[j, 1]],
                    color="steelblue", lw=1.5, zorder=1)
        ax.scatter(pts[:, 0], pts[:, 1], color="crimson", s=60, zorder=2)
        ax.set_title(f"Rips graph at scale t = {t:.2f}")
        ax.set_aspect("equal"); ax.axis("off")
    fig.suptitle("The movie of shapes: a Vietoris-Rips filtration", fontsize=14)
    fig.tight_layout()
    fig.savefig("filtration_movie.png", dpi=140)


def optimal_shift(d: Dict[Edge, float], d2: Dict[Edge, float], n: int,
                  scales: List[float], grid: List[float]) -> float:
    for eps in grid:
        ok = True
        for t in scales:
            A = set(rips_edges(d, n, t)); B = set(rips_edges(d2, n, t + eps))
            C = set(rips_edges(d2, n, t)); D = set(rips_edges(d, n, t + eps))
            if not (A <= B and C <= D):
                ok = False; break
        if ok:
            return eps
    return float("inf")


def fig_stability(seed: int = 0) -> None:
    rng = np.random.default_rng(seed)
    base = rng.uniform(0, 3, size=(6, 2))
    d = dist_matrix(base)
    scales = list(np.linspace(0, 4, 25))
    grid = list(np.linspace(0, 2, 41))
    sups, shifts = [], []
    for _ in range(40):
        noise = rng.uniform(0, 0.8)
        pert = base + rng.uniform(-noise, noise, size=base.shape)
        d2 = dist_matrix(pert)
        sup = max(abs(d[k] - d2[k]) for k in d)
        sh = optimal_shift(d, d2, len(base), scales, grid)
        sups.append(sup); shifts.append(sh)
    fig, ax = plt.subplots(figsize=(6, 6))
    lim = max(max(sups), max(shifts)) * 1.1
    ax.plot([0, lim], [0, lim], "k--", label="y = x (stability bound)")
    ax.scatter(sups, shifts, color="darkorange", s=40, alpha=0.8,
               label="(||d-d'||_inf, interleaving shift)")
    ax.set_xlabel("sup-distance  ||d - d'||_inf")
    ax.set_ylabel("optimal interleaving shift")
    ax.set_title("Stability: interleaving distance <= sup-distance")
    ax.legend(); ax.set_aspect("equal")
    fig.tight_layout(); fig.savefig("stability_scatter.png", dpi=140)


if __name__ == "__main__":
    pts = np.array([[0, 0], [1, 0.2], [2, 0], [2.2, 1], [1, 1.3], [0.1, 1]],
                   dtype=float)
    fig_filtration(pts, [0.8, 1.2, 1.6, 2.2])
    fig_stability()
    print("Wrote filtration_movie.png and stability_scatter.png")
