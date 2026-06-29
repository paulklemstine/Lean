"""Visualization: packing-isolating sets on a path and the C5 obstruction.

Renders (a) the path P_12 with the aligned set {1,4,7,10} highlighted and each
closed neighborhood shaded, and (b) the 5-cycle C5 showing that any single vertex
leaves two vertices and an edge uncovered. Requires matplotlib.
"""
from typing import List, Set, Tuple
import matplotlib.pyplot as plt
import numpy as np


def path_packing(n: int) -> Set[int]:
    return {i for i in range(n) if i % 3 == 1}


def draw_path(ax: plt.Axes, n: int) -> None:
    s = path_packing(n)
    xs = list(range(n))
    ax.plot(xs, [0] * n, color="0.7", zorder=1)
    for i in xs:
        sel = i in s
        ax.scatter([i], [0], s=420 if sel else 220,
                   color="#d62728" if sel else "#1f77b4",
                   edgecolor="black", zorder=3)
        ax.annotate(str(i), (i, 0), color="white", ha="center", va="center",
                    fontsize=8, zorder=4)
        if sel:
            ax.add_patch(plt.Rectangle((i - 1.4, -0.45), 2.8, 0.9, alpha=0.12,
                                       color="#d62728", zorder=0))
    ax.set_title(f"P_{n}: aligned packing-isolating set {sorted(s)}")
    ax.set_ylim(-1.2, 1.2)
    ax.axis("off")


def draw_c5(ax: plt.Axes) -> None:
    n = 5
    ang = np.linspace(np.pi / 2, np.pi / 2 + 2 * np.pi, n, endpoint=False)
    pts = np.column_stack([np.cos(ang), np.sin(ang)])
    for i in range(n):
        j = (i + 1) % n
        ax.plot([pts[i, 0], pts[j, 0]], [pts[i, 1], pts[j, 1]],
                color="0.6", zorder=1)
    covered = {0, 1, 4}  # N[0] in C5
    for i in range(n):
        c = "#2ca02c" if i in covered else "#888888"
        if i == 0:
            c = "#d62728"
        ax.scatter([pts[i, 0]], [pts[i, 1]], s=420, color=c,
                   edgecolor="black", zorder=3)
        ax.annotate(str(i), pts[i], ha="center", va="center", color="white",
                    fontsize=9, zorder=4)
    ax.set_title("C5: guard at 0 (red) reaches {0,1,4} (green);\n"
                 "2,3 and edge {2,3} stay uncovered")
    ax.set_aspect("equal")
    ax.axis("off")


def main() -> None:
    fig, axes = plt.subplots(2, 1, figsize=(9, 7))
    draw_path(axes[0], 12)
    draw_c5(axes[1])
    fig.tight_layout()
    fig.savefig("packing_isolation_visualization.png", dpi=150)
    print("Saved packing_isolation_visualization.png")


if __name__ == "__main__":
    main()
