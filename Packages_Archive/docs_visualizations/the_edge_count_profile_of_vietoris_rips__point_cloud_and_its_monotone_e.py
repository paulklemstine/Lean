"""
visualize_profile.py — Plot the Rips edge-count profile as a monotone staircase.

Generates a figure with two panels:
  (left)  a point cloud with the Rips edges drawn at a chosen scale;
  (right) the edge-count profile E(r), a nondecreasing staircase, annotated with
          the complete-graph ceiling C(n,2) and the chosen scale.

Requires matplotlib.  Run:  python3 visualize_profile.py
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt

Point = Tuple[float, float]


def dist(a: Point, b: Point) -> float:
    return math.hypot(a[0] - b[0], a[1] - b[1])


def rips_edges(points: Sequence[Point], r: float) -> List[Tuple[int, int]]:
    n = len(points)
    return [(i, j) for i in range(n) for j in range(i + 1, n)
            if dist(points[i], points[j]) <= r]


def profile(points: Sequence[Point], rs: Sequence[float]) -> List[int]:
    return [len(rips_edges(points, r)) for r in rs]


def main() -> None:
    pts: List[Point] = [(math.cos(2 * math.pi * k / 10), math.sin(2 * math.pi * k / 10))
                        for k in range(10)]
    n = len(pts)
    ceiling = n * (n - 1) // 2
    r_show = 1.0
    rs = [i / 100.0 for i in range(0, 251)]
    ys = profile(pts, rs)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 5))

    # Left: point cloud + edges at r_show
    for (i, j) in rips_edges(pts, r_show):
        ax1.plot([pts[i][0], pts[j][0]], [pts[i][1], pts[j][1]],
                 color="#4cc9f0", lw=1.3, alpha=0.7, zorder=1)
    xs, ysc = zip(*pts)
    ax1.scatter(xs, ysc, color="#6ea8fe", s=60, zorder=2)
    ax1.set_title(f"Rips graph at scale r = {r_show}")
    ax1.set_aspect("equal")
    ax1.set_xticks([]); ax1.set_yticks([])

    # Right: profile staircase
    ax2.plot(rs, ys, color="#4cc9f0", lw=2.2, label="E(r)")
    ax2.axhline(ceiling, color="#f4a261", ls="--", lw=1.3,
                label=f"ceiling C(n,2) = {ceiling}")
    ax2.axvline(r_show, color="#6ea8fe", ls=":", lw=1.3, label=f"r = {r_show}")
    ax2.set_xlabel("scale r")
    ax2.set_ylabel("edge count E(r)")
    ax2.set_title("Edge-count profile (monotone staircase)")
    ax2.legend(loc="lower right", fontsize=9)
    ax2.grid(alpha=0.2)

    fig.suptitle("Vietoris–Rips edge-count profile of 10 points on a circle",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("rips_profile.png", dpi=150)
    print("Saved rips_profile.png")


if __name__ == "__main__":
    main()
