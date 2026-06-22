"""
The Boltzmann Bridge — Visualizations
=====================================

Standalone matplotlib script producing three figures:

  (A) The Vietoris-Rips filtration of a point cloud at growing scales, with the
      birth time (diamWeight) of edges shown as they appear.
  (B) The Nerve interleaving sandwich Cech(e) subset VR(2e) subset Cech(2e) on
      an equilateral triangle, drawing the covering balls.
  (C) The Euler characteristic of the full simplex pinned at 1 across n, next to
      the alternating binomial bars that cancel to 1.

Run:  python visualize.py   ->   writes boltzmann_bridge.png
"""

from __future__ import annotations

from itertools import combinations
from math import comb, sqrt
from typing import List, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import Circle

Point = Tuple[float, float]


def dist(a: Point, b: Point) -> float:
    return sqrt((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2)


def diam(face: List[Point]) -> float:
    return max((dist(x, y) for x in face for y in face), default=0.0)


def make_figure() -> None:
    fig = plt.figure(figsize=(15, 5))

    # ---- (A) VR filtration at growing scales -----------------------------
    pts: List[Point] = [(0, 0), (1, 0.1), (1.8, 0.9), (0.9, 1.6), (-0.1, 0.9)]
    axA = fig.add_subplot(1, 3, 1)
    eps = 1.1
    for i, j in combinations(range(len(pts)), 2):
        if dist(pts[i], pts[j]) <= eps:
            axA.plot([pts[i][0], pts[j][0]], [pts[i][1], pts[j][1]],
                     color="#3b6fb5", lw=2, alpha=0.7)
    xs, ys = zip(*pts)
    axA.scatter(xs, ys, s=80, color="#d1495b", zorder=3)
    axA.set_title(f"Vietoris-Rips complex at scale eps={eps}\n(edge born when diamWeight <= eps)")
    axA.set_aspect("equal")
    axA.grid(alpha=0.3)

    # ---- (B) Nerve sandwich ---------------------------------------------
    axB = fig.add_subplot(1, 3, 2)
    tri: List[Point] = [(0, 0), (1, 0), (0.5, sqrt(3) / 2)]
    e = 0.55
    # VR(2e) edges
    for i, j in combinations(range(3), 2):
        axB.plot([tri[i][0], tri[j][0]], [tri[i][1], tri[j][1]],
                 color="#3b6fb5", lw=2)
    # common ball at radius 2e (circumcenter)
    cx, cy = 0.5, sqrt(3) / 6
    axB.add_patch(Circle((cx, cy), 2 * e, fill=True, alpha=0.12,
                         color="#2a9d8f", label="Cech ball radius 2e"))
    axB.add_patch(Circle((cx, cy), 2 * e, fill=False, color="#2a9d8f", lw=1.5))
    xs, ys = zip(*tri)
    axB.scatter(xs, ys, s=90, color="#d1495b", zorder=3)
    axB.set_title("Nerve sandwich:\nCech(e) subset VR(2e) subset Cech(2e)")
    axB.set_aspect("equal")
    axB.grid(alpha=0.3)
    axB.legend(loc="upper right", fontsize=8)

    # ---- (C) Euler characteristic = 1 -----------------------------------
    axC = fig.add_subplot(1, 3, 3)
    n = 6
    ks = list(range(1, n + 1))
    terms = [(-1) ** (k - 1) * comb(n, k) for k in ks]
    colors = ["#2a9d8f" if t > 0 else "#d1495b" for t in terms]
    axC.bar(ks, terms, color=colors, alpha=0.8)
    chi = sum(terms)
    axC.axhline(0, color="black", lw=0.8)
    axC.set_title(f"Alternating f-vector of full simplex (n={n})\n"
                  f"sum = {chi}  (Euler characteristic = 1)")
    axC.set_xlabel("k (number of vertices)")
    axC.set_ylabel("(-1)^(k-1) C(n,k)")
    axC.grid(alpha=0.3, axis="y")

    fig.tight_layout()
    fig.savefig("boltzmann_bridge.png", dpi=130)
    print("Wrote boltzmann_bridge.png")


if __name__ == "__main__":
    make_figure()
