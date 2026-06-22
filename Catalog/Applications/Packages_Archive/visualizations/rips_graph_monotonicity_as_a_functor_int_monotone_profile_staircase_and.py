"""Visualize the monotone edge-count profile as a staircase, alongside the
growing Rips graph at several scales. Requires matplotlib."""
import math
from itertools import combinations
from typing import List, Tuple

import matplotlib.pyplot as plt

Point = Tuple[float, float]


def edge_count(points: List[Point], r: float) -> int:
    return sum(1 for a, b in combinations(points, 2)
               if math.dist(a, b) <= r)


def main() -> None:
    k = 8
    pts: List[Point] = [(5 * math.cos(2 * math.pi * i / k),
                         5 * math.sin(2 * math.pi * i / k)) for i in range(k)]
    thresholds = list(range(0, 13))
    profile = [edge_count(pts, float(r)) for r in thresholds]
    cap = k * (k - 1) // 2

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: the monotone staircase.
    ax1.step(thresholds, profile, where="post", lw=2, color="#1f77b4")
    ax1.axhline(cap, ls="--", color="gray", label=f"upper bound n(n-1)/2 = {cap}")
    ax1.set_xlabel("threshold r")
    ax1.set_ylabel("edge count  profile(r)")
    ax1.set_title("Monotone edge-count profile (a tropical valuation)")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # Right: the Rips graph at scale r = 4.
    r = 4.0
    ax2.scatter([p[0] for p in pts], [p[1] for p in pts], color="#d62728", zorder=3)
    for a, b in combinations(pts, 2):
        if math.dist(a, b) <= r:
            ax2.plot([a[0], b[0]], [a[1], b[1]], color="#1f77b4", alpha=0.6)
    ax2.set_title(f"Rips graph at scale r = {r:.0f}")
    ax2.set_aspect("equal")
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("rips_profile.png", dpi=150)
    print("saved rips_profile.png")


if __name__ == "__main__":
    main()
