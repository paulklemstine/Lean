"""Visualization: the novelty-region filtration and the score field.

Draws the novelty score as a contour field around a reference set, and overlays
the boundaries of the novelty regions {x : eps < noveltyScore(S, x)} for a
sequence of thresholds, illustrating the decreasing (nested) filtration.
Requires matplotlib and numpy.
"""
from __future__ import annotations
from math import sqrt
from typing import List, Tuple

import numpy as np
import matplotlib.pyplot as plt

Point = Tuple[float, float]


def novelty_score(S: List[Point], x: float, y: float) -> float:
    return min(sqrt((x - sx) ** 2 + (y - sy) ** 2) for sx, sy in S)


def main() -> None:
    S: List[Point] = [(-2.0, -1.0), (2.0, -1.0), (0.0, 2.0)]
    xs = np.linspace(-6, 6, 400)
    ys = np.linspace(-6, 6, 400)
    X, Y = np.meshgrid(xs, ys)
    Z = np.vectorize(lambda a, b: novelty_score(S, a, b))(X, Y)

    fig, ax = plt.subplots(figsize=(7, 6))
    cf = ax.contourf(X, Y, Z, levels=30, cmap="viridis")
    fig.colorbar(cf, ax=ax, label="novelty score = infDist(x, S)")
    cs = ax.contour(X, Y, Z, levels=[1, 2, 3, 4], colors="white", linewidths=1.4)
    ax.clabel(cs, fmt=lambda v: f"region eps={v:g}")
    sx, sy = zip(*S)
    ax.scatter(sx, sy, c="red", s=80, edgecolors="black", zorder=5,
               label="known points S")
    ax.set_title("Novelty score field and nested novelty regions (filtration)")
    ax.set_aspect("equal")
    ax.legend(loc="upper right")
    plt.tight_layout()
    plt.savefig("novelty_filtration.png", dpi=150)
    print("wrote novelty_filtration.png")


if __name__ == "__main__":
    main()
