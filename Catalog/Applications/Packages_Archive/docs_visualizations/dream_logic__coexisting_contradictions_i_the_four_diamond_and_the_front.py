"""
Visualization: The FOUR diamond bilattice and the topological frontier.

Renders two panels:
  (left)  the truth-order "diamond" of Belnap's FOUR with gluts/gaps highlighted;
  (right) the closed interval [0,1] on the real line with its contradiction set
          (frontier) {0,1} marked as coexisting "in-and-out" points.

Run:  python _viz.py    (saves dream_logic.png)
"""

from __future__ import annotations

from typing import Dict, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


def draw_diamond(ax: plt.Axes) -> None:
    pos: Dict[str, Tuple[float, float]] = {
        "false": (0.0, 0.0),
        "both": (-1.0, 1.0),
        "neither": (1.0, 1.0),
        "true": (0.0, 2.0),
    }
    edges = [("false", "both"), ("false", "neither"),
             ("both", "true"), ("neither", "true")]
    for a, b in edges:
        ax.plot([pos[a][0], pos[b][0]], [pos[a][1], pos[b][1]],
                color="#888", lw=1.5, zorder=1)
    colors = {"true": "#2e7d32", "false": "#c62828",
              "both": "#6a1b9a", "neither": "#1565c0"}
    labels = {"true": "true", "false": "false",
              "both": "both\n(glut)", "neither": "neither\n(gap)"}
    for name, (x, y) in pos.items():
        ax.scatter([x], [y], s=2600, color=colors[name], zorder=2,
                   edgecolors="black", linewidths=1.2)
        ax.text(x, y, labels[name], ha="center", va="center",
                color="white", fontsize=10, fontweight="bold", zorder=3)
    ax.set_title("Belnap FOUR: the truth-order diamond\n"
                 "negation fixes both & neither", fontsize=11)
    ax.set_xlim(-2, 2)
    ax.set_ylim(-0.6, 2.6)
    ax.axis("off")


def draw_frontier(ax: plt.Axes) -> None:
    ax.hlines(0, -1.0, 2.0, color="#bbb", lw=1)
    # closed interval [0,1]
    ax.hlines(0, 0.0, 1.0, color="#1565c0", lw=6, zorder=1)
    # frontier / contradiction set {0,1}
    for xpt in (0.0, 1.0):
        ax.scatter([xpt], [0], s=240, color="#6a1b9a",
                   edgecolors="black", zorder=3)
        ax.annotate(f"x = {xpt:g}\nboth (glut)\nfrontier point",
                    xy=(xpt, 0), xytext=(xpt, 0.5 if xpt == 0 else -0.6),
                    ha="center", fontsize=9, color="#6a1b9a",
                    arrowprops=dict(arrowstyle="->", color="#6a1b9a"))
    ax.text(0.5, 0.18, "A = [0,1] (closed)", ha="center",
            color="#1565c0", fontsize=10, fontweight="bold")
    ax.text(-0.6, 0.0, "outside", ha="center", va="bottom",
            color="#c62828", fontsize=9)
    ax.text(1.6, 0.0, "outside", ha="center", va="bottom",
            color="#c62828", fontsize=9)
    ax.set_title("contradiction([0,1]) = frontier([0,1]) = {0, 1}\n"
                 "each frontier point is in A AND closure(complement)",
                 fontsize=11)
    ax.set_xlim(-1.1, 2.1)
    ax.set_ylim(-1.0, 1.0)
    ax.axis("off")


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    draw_diamond(ax1)
    draw_frontier(ax2)
    fig.suptitle("Dream Logic: gluts in algebra = boundary points in geometry",
                 fontsize=13, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("dream_logic.png", dpi=140)
    print("saved dream_logic.png")


if __name__ == "__main__":
    main()
