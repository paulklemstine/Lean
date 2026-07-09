"""
Visualization: the Fano plane S(2,3,7) and the pair-packing equality.

Renders the Fano plane (7 points, 7 lines, the seventh "line" drawn as the
incircle) and a bar chart contrasting m*C(r,2) with C(n,2) for several linear
hypergraphs, illustrating Theorem 1 (global tightness: equality <=> Steiner).

Requires matplotlib. Run:  python visualize_packing.py
"""

from __future__ import annotations

from math import comb, cos, pi, sin
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def fano_coordinates() -> Dict[int, Tuple[float, float]]:
    """Standard triangle layout: 3 corners, 3 edge-midpoints, 1 center."""
    corners = [(cos(pi / 2 + 2 * pi * k / 3), sin(pi / 2 + 2 * pi * k / 3))
               for k in range(3)]
    mids = [((corners[i][0] + corners[(i + 1) % 3][0]) / 2,
             (corners[i][1] + corners[(i + 1) % 3][1]) / 2) for i in range(3)]
    center = (0.0, 0.0)
    pts = corners + mids + [center]
    return {i: pts[i] for i in range(7)}


def draw_fano(ax: plt.Axes) -> None:
    coords = fano_coordinates()
    # Lines as point triples; the central circle is the "curved" line.
    lines = [(0, 3, 1), (1, 4, 2), (2, 5, 0), (0, 6, 4), (1, 6, 5), (2, 6, 3)]
    circle = (3, 4, 5)
    for a, b, c in lines:
        xs = [coords[a][0], coords[b][0], coords[c][0]]
        ys = [coords[a][1], coords[b][1], coords[c][1]]
        ax.plot(xs, ys, color="#3366cc", lw=2, zorder=1)
    cx = sum(coords[p][0] for p in circle) / 3
    cy = sum(coords[p][1] for p in circle) / 3
    rad = ((coords[3][0] - cx) ** 2 + (coords[3][1] - cy) ** 2) ** 0.5
    ax.add_patch(plt.Circle((cx, cy), rad, fill=False, color="#3366cc", lw=2))
    for i, (x, y) in coords.items():
        ax.scatter([x], [y], s=240, color="#cc3333", zorder=2)
        ax.annotate(str(i), (x, y), color="white", ha="center", va="center",
                    fontweight="bold", zorder=3)
    ax.set_title("Fano plane S(2,3,7): 7 points, 7 lines\n"
                 "every pair on exactly one line (tight)")
    ax.set_aspect("equal")
    ax.axis("off")


def draw_packing_bars(ax: plt.Axes) -> None:
    examples: List[Tuple[str, int, int, int]] = [
        ("Fano\nS(2,3,7)", 7, 3, 7),
        ("AG(2,3)\nS(2,3,9)", 9, 3, 12),
        ("two\ntriples", 7, 3, 2),
        ("S(2,3,13)", 13, 3, 26),
    ]
    labels = [e[0] for e in examples]
    used = [e[3] * comb(e[2], 2) for e in examples]
    avail = [comb(e[1], 2) for e in examples]
    x = range(len(examples))
    ax.bar([i - 0.2 for i in x], used, width=0.4, label="m*C(r,2) (pairs used)",
           color="#3366cc")
    ax.bar([i + 0.2 for i in x], avail, width=0.4, label="C(n,2) (pairs available)",
           color="#cc8833")
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels)
    ax.set_ylabel("number of pairs")
    ax.set_title("Theorem 1: equality (bars match) <=> Steiner system")
    ax.legend()


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(13, 6))
    draw_fano(axes[0])
    draw_packing_bars(axes[1])
    fig.tight_layout()
    fig.savefig("packing_visualization.png", dpi=150)
    print("Saved packing_visualization.png")


if __name__ == "__main__":
    main()
