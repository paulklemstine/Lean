"""
Visualization: the curvature landscape of three-voter elections.

Renders two figures using matplotlib:
  (1) A bar chart of the fraction of FLAT profiles for n=3 as k grows.
  (2) The Condorcet-paradox tournament as a directed triangle (the unit of
      holonomy), contrasted with a flat transitive tournament.

Run:  python visualize_curvature.py
"""
from __future__ import annotations
from itertools import permutations, product
from typing import List, Tuple
import matplotlib.pyplot as plt
import numpy as np

StrictRanking = Tuple[int, ...]


def all_rankings(n: int) -> List[StrictRanking]:
    out = []
    for p in permutations(range(n)):
        rank = [0] * n
        for pos, alt in enumerate(p):
            rank[alt] = pos
        out.append(tuple(rank))
    return out


def beats(profile, a: int, b: int) -> bool:
    s_ab = sum(1 for r in profile if r[a] < r[b])
    s_ba = sum(1 for r in profile if r[b] < r[a])
    return s_ab > s_ba


def curvature(profile, n: int) -> int:
    return sum(
        1 for a, b, c in product(range(n), repeat=3)
        if beats(profile, a, b) and beats(profile, b, c) and beats(profile, c, a)
    )


def flat_fraction(n: int, k: int) -> float:
    rankings = all_rankings(n)
    flat = total = 0
    for prof in product(rankings, repeat=k):
        total += 1
        if curvature(list(prof), n) == 0:
            flat += 1
    return flat / total


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ks = [1, 3, 5]
    fracs = [100 * flat_fraction(3, k) for k in ks]
    ax1.bar([str(k) for k in ks], fracs, color="#39d98a")
    ax1.set_title("Fraction of FLAT profiles (n = 3)")
    ax1.set_xlabel("number of voters k (odd)")
    ax1.set_ylabel("% flat (curvature 0)")
    ax1.set_ylim(80, 101)
    for x, f in zip(range(len(ks)), fracs):
        ax1.text(x, f + 0.3, f"{f:.1f}%", ha="center")

    # draw the paradox triangle
    ang = np.array([90, 210, 330]) * np.pi / 180
    pts = np.c_[np.cos(ang), np.sin(ang)]
    labels = ["A", "B", "C"]
    ax2.set_title("Condorcet paradox: a holonomy loop (curvature 3)")
    for (i, j) in [(0, 1), (1, 2), (2, 0)]:
        ax2.annotate("", xy=pts[j], xytext=pts[i],
                     arrowprops=dict(arrowstyle="-|>", color="#ff6b8a", lw=3))
    for p, lab in zip(pts, labels):
        ax2.scatter(*p, s=900, color="#1c2440", zorder=3, edgecolors="#7aa2ff")
        ax2.text(*p, lab, ha="center", va="center", color="white",
                 fontsize=16, zorder=4)
    ax2.set_xlim(-1.6, 1.6)
    ax2.set_ylim(-1.6, 1.4)
    ax2.axis("off")

    plt.tight_layout()
    plt.savefig("curvature_landscape.png", dpi=140)
    print("saved curvature_landscape.png")


if __name__ == "__main__":
    main()
