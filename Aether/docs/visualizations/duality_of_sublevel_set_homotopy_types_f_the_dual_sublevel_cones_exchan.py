"""Visualization: the dual sublevel cones and their exchange under L.

Renders {f <= c} and {f_dual <= c} for f = |x|/(|x|+|y|) and its dual, side by
side, showing that the coordinate swap L(x,y) = (y,x) reflects one onto the
other across the diagonal y = x. Saves 'sublevel_duality.png'.
"""

from __future__ import annotations

from typing import Tuple

import numpy as np
import matplotlib.pyplot as plt

Point = Tuple[float, float]


def f(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    denom = np.abs(x) + np.abs(y)
    return np.divide(np.abs(x), denom, out=np.full_like(denom, np.nan),
                     where=denom > 0)


def f_dual(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    denom = np.abs(x) + np.abs(y)
    return np.divide(np.abs(y), denom, out=np.full_like(denom, np.nan),
                     where=denom > 0)


def main() -> None:
    c = 0.5
    lin = np.linspace(-2.0, 2.0, 801)
    X, Y = np.meshgrid(lin, lin)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    axes[0].contourf(X, Y, (f(X, Y) <= c).astype(float),
                     levels=[0.5, 1.5], colors=["#3b82f6"])
    axes[0].set_title(r"$\{f \leq 1/2\} = \{|x| \leq |y|\}$")

    axes[1].contourf(X, Y, (f_dual(X, Y) <= c).astype(float),
                     levels=[0.5, 1.5], colors=["#ef4444"])
    axes[1].set_title(r"$\{f^\circ \leq 1/2\} = \{|y| \leq |x|\}$")

    axes[2].contourf(X, Y, (f(X, Y) <= c).astype(float),
                     levels=[0.5, 1.5], colors=["#3b82f6"], alpha=0.5)
    axes[2].contourf(X, Y, (f_dual(X, Y) <= c).astype(float),
                     levels=[0.5, 1.5], colors=["#ef4444"], alpha=0.5)
    axes[2].plot(lin, lin, "k--", lw=1)
    axes[2].set_title(r"$L(x,y)=(y,x)$ reflects one onto the other")

    for ax in axes:
        ax.set_aspect("equal")
        ax.set_xlim(-2, 2)
        ax.set_ylim(-2, 2)
        ax.axhline(0, color="gray", lw=0.5)
        ax.axvline(0, color="gray", lw=0.5)

    fig.suptitle("Polarity duality of RC sublevel cones", fontsize=14)
    fig.tight_layout()
    fig.savefig("sublevel_duality.png", dpi=150)
    print("wrote sublevel_duality.png")


if __name__ == "__main__":
    main()
