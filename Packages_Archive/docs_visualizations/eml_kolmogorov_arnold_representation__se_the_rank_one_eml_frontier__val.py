"""Visualization of the rank-one EML frontier.

Generates a figure with three panels:
  (1) the value-table heatmaps of x*y (separable, rank-one) and x+y (not),
  (2) the cross-multiplicative defect heat signature distinguishing them,
  (3) the boundary obstruction: exp/log form vs polynomial form along y=1.

Run with:  python visualize.py   (saves eml_rank_one_frontier.png)
"""

from __future__ import annotations

import math
from typing import Callable

import numpy as np
import matplotlib.pyplot as plt


def cross_mul_field(f: Callable[[float, float], float],
                    xs: np.ndarray, ys: np.ndarray) -> np.ndarray:
    """Local cross-multiplicative defect using neighbouring grid points."""
    nx, ny = len(xs), len(ys)
    field = np.zeros((nx - 1, ny - 1))
    for i in range(nx - 1):
        for j in range(ny - 1):
            lhs = f(xs[i], ys[j]) * f(xs[i + 1], ys[j + 1])
            rhs = f(xs[i], ys[j + 1]) * f(xs[i + 1], ys[j])
            field[i, j] = abs(lhs - rhs)
    return field


def main() -> None:
    xs = np.linspace(0.2, 3.0, 60)
    ys = np.linspace(0.2, 3.0, 60)
    XX, YY = np.meshgrid(xs, ys, indexing="ij")

    fig, axes = plt.subplots(1, 3, figsize=(16, 4.5))

    # Panel 1: value tables
    prod = XX * YY
    summ = XX + YY
    im0 = axes[0].imshow(prod, origin="lower", extent=[0.2, 3, 0.2, 3],
                         cmap="viridis", aspect="auto")
    axes[0].set_title("Product x*y  (rank-one EML)")
    axes[0].set_xlabel("x"); axes[0].set_ylabel("y")
    fig.colorbar(im0, ax=axes[0])

    # Panel 2: cross-mul defect for the sum (nonzero => not rank-one)
    field = cross_mul_field(lambda a, b: a + b, xs, ys)
    im1 = axes[1].imshow(field, origin="lower", extent=[0.2, 3, 0.2, 3],
                         cmap="magma", aspect="auto")
    axes[1].set_title("Cross-mul defect of x+y  (> 0: NOT rank-one)")
    axes[1].set_xlabel("x"); axes[1].set_ylabel("y")
    fig.colorbar(im1, ax=axes[1])

    # Panel 3: boundary obstruction along y = 1
    t = np.linspace(0.0, 2.0, 400)

    def safe_log(v: float) -> float:
        return math.log(v) if v > 0 else 0.0

    eml = np.array([math.exp(safe_log(x) + safe_log(1.0)) for x in t])
    poly = np.array([0.25 * (x + 1) ** 2 - 0.25 * (x - 1) ** 2 for x in t])
    truth = t * 1.0
    axes[2].plot(t, truth, "k-", lw=2, label="true x*1")
    axes[2].plot(t, poly, "g--", lw=2, label="polarization (global)")
    axes[2].plot(t, eml, "r:", lw=2.5, label="exp(log x + log 1), log 0:=0")
    axes[2].scatter([0.0], [1.0], color="red", zorder=5)
    axes[2].annotate("wrong value 1 at x=0", (0.0, 1.0),
                     textcoords="offset points", xytext=(40, -10), color="red")
    axes[2].set_title("Boundary obstruction along y = 1")
    axes[2].set_xlabel("x"); axes[2].set_ylabel("value")
    axes[2].legend()

    fig.suptitle("The rank-one EML frontier: separability, its test, and the boundary",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("eml_rank_one_frontier.png", dpi=140)
    print("saved eml_rank_one_frontier.png")


if __name__ == "__main__":
    main()
