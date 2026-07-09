"""
Visualization: moment polytopes and their barycenters.

Draws the moment polygons of P^2 (balanced triangle) and the one-point blow-up of
P^2 (off-balance quadrilateral), marking the origin and each barycenter, so the
balanced/obstructed dichotomy is visible at a glance.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Tuple

import matplotlib.pyplot as plt


def barycenter(points: List[Tuple[float, float]]) -> Tuple[float, float]:
    n = len(points)
    return (sum(p[0] for p in points) / n, sum(p[1] for p in points) / n)


def draw(ax, points: List[Tuple[float, float]], title: str) -> None:
    xs = [p[0] for p in points] + [points[0][0]]
    ys = [p[1] for p in points] + [points[0][1]]
    ax.plot(xs, ys, "-o", color="#2b6cb0", lw=2, label="polytope")
    ax.fill(xs, ys, color="#bee3f8", alpha=0.5)
    bx, by = barycenter(points)
    balanced = abs(bx) < 1e-9 and abs(by) < 1e-9
    ax.scatter([0], [0], color="black", zorder=5, label="origin")
    ax.scatter([bx], [by], color="#c53030" if not balanced else "#2f855a",
               marker="*", s=220, zorder=6,
               label=f"barycenter ({'off-origin' if not balanced else 'origin'})")
    ax.axhline(0, color="gray", lw=0.5)
    ax.axvline(0, color="gray", lw=0.5)
    ax.set_aspect("equal")
    ax.set_title(title + ("\nK-STABLE (KE exists)" if balanced
                          else "\nOBSTRUCTED (no KE metric)"))
    ax.legend(loc="upper right", fontsize=8)


def main() -> None:
    p2 = [(-1.0, -1.0), (1.0, 0.0), (0.0, 1.0)]
    blow = [(-1.0, -1.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]
    fig, axes = plt.subplots(1, 2, figsize=(11, 5))
    draw(axes[0], p2, "Moment polytope of $\\mathbb{P}^2$")
    draw(axes[1], blow, "Blow-up of $\\mathbb{P}^2$ at a point")
    fig.suptitle("The shape decides: barycenter at the origin $\\iff$ "
                 "Kähler–Einstein metric exists", fontsize=12)
    fig.tight_layout()
    fig.savefig("moment_polytopes.png", dpi=150)
    print("saved moment_polytopes.png")


if __name__ == "__main__":
    main()
