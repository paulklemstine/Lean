"""Visualization: the Vietoris–Rips face-count staircase and the completion
threshold (diameter) for a small planar point cloud.

Generates a two-panel figure:
  (left)  the point cloud with its diametral pair highlighted;
  (right) the number of Rips faces as a function of the scale eps, a monotone
          staircase that saturates exactly at the diameter D = tropBirthSum.
"""

from __future__ import annotations

from itertools import combinations
from math import sqrt
from typing import List, Tuple

import matplotlib.pyplot as plt

Point = Tuple[float, float]


def euclidean(x: Point, y: Point) -> float:
    return sqrt((x[0] - y[0]) ** 2 + (x[1] - y[1]) ** 2)


def face_birth(face: Tuple[Point, ...]) -> float:
    if len(face) < 2:
        return 0.0
    return max(euclidean(p, q) for p, q in combinations(face, 2))


def num_rips_faces(points: List[Point], eps: float) -> int:
    n = len(points)
    return sum(
        1
        for k in range(1, n + 1)
        for face in combinations(points, k)
        if face_birth(face) <= eps
    )


def main() -> None:
    pts: List[Point] = [(0.0, 0.0), (1.0, 0.2), (0.3, 1.0), (1.2, 1.1), (0.6, 0.5)]
    # diameter and the realizing pair
    pairs = list(combinations(range(len(pts)), 2))
    i, j = max(pairs, key=lambda ij: euclidean(pts[ij[0]], pts[ij[1]]))
    D = euclidean(pts[i], pts[j])

    eps_grid = [0.01 * t for t in range(0, int(D * 120) + 20)]
    counts = [num_rips_faces(pts, e) for e in eps_grid]
    full = (1 << len(pts)) - 1

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))

    xs, ys = zip(*pts)
    ax1.scatter(xs, ys, s=80, zorder=3, color="#1f77b4")
    ax1.plot([pts[i][0], pts[j][0]], [pts[i][1], pts[j][1]],
             "r--", lw=2, label=f"diametral pair  D={D:.3f}")
    ax1.set_title("Point cloud and diametral pair")
    ax1.legend()
    ax1.set_aspect("equal")

    ax2.step(eps_grid, counts, where="post", color="#2ca02c", lw=2)
    ax2.axhline(full, ls=":", color="gray", label=f"full complex ({full} faces)")
    ax2.axvline(D, ls="--", color="red", label=f"threshold D={D:.3f}")
    ax2.set_xlabel("scale  eps")
    ax2.set_ylabel("number of Rips faces")
    ax2.set_title("Face count saturates exactly at the diameter")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("rips_threshold.png", dpi=150)
    print("Saved rips_threshold.png ; diameter =", round(D, 6))


if __name__ == "__main__":
    main()
