"""Visualization: Brenier monotone matching vs. a crossing matching.

Plots source points x (top line) and target points y (bottom line) and draws the
matching edges for the sorted (Brenier-optimal) coupling and for a crossing
coupling, annotating each panel with its total quadratic cost. Requires matplotlib.
"""

from __future__ import annotations

from typing import List, Sequence

import matplotlib.pyplot as plt


def quadratic_match_cost(x: Sequence[float], y: Sequence[float],
                         sigma: Sequence[int]) -> float:
    return sum((x[i] - y[sigma[i]]) ** 2 for i in range(len(x)))


def draw_matching(ax: "plt.Axes", x: Sequence[float], y: Sequence[float],
                  sigma: Sequence[int], title: str) -> None:
    ax.scatter(x, [1] * len(x), s=120, color="#2563eb", zorder=3, label="source x")
    ax.scatter(y, [0] * len(y), s=120, color="#dc2626", zorder=3, label="target y")
    for i in range(len(x)):
        ax.plot([x[i], y[sigma[i]]], [1, 0], color="#475569", lw=2, alpha=0.7)
    cost = quadratic_match_cost(x, y, sigma)
    ax.set_title(f"{title}\nquadratic cost = {cost:.3f}")
    ax.set_ylim(-0.4, 1.4)
    ax.set_yticks([0, 1])
    ax.set_yticklabels(["targets", "sources"])
    ax.legend(loc="upper right", fontsize=8)


def main() -> None:
    x: List[float] = [0.1, 0.4, 0.6, 0.9]
    y: List[float] = [0.2, 0.5, 0.8, 1.3]  # both sorted => monovary
    n = len(x)
    identity = list(range(n))          # Brenier-optimal monotone matching
    crossing = list(reversed(range(n)))  # deliberately crossing matching

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4))
    draw_matching(ax1, x, y, identity, "Monotone (Brenier-optimal) matching")
    draw_matching(ax2, x, y, crossing, "Crossing matching")
    fig.suptitle("Quadratic cost: non-crossing transport is cheapest", fontsize=13)
    fig.tight_layout()
    fig.savefig("brenier_matching.png", dpi=150)
    print("saved brenier_matching.png")


if __name__ == "__main__":
    main()
