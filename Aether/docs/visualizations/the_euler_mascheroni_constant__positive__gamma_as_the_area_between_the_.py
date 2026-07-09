"""Visualization: gamma as the area between the staircase 1/floor(x) and 1/x.

Generates a figure showing, on [1, N+1], the descending step function
1/floor(x) sitting above the smooth hyperbola 1/x. The shaded region between
them has total area gamma = 0.5772156649..., the Euler-Mascheroni constant.

Run:  python3 _viz_staircase.py   (saves euler_mascheroni_staircase.png)
"""

from __future__ import annotations

import math

import numpy as np
import matplotlib.pyplot as plt


def main(num_windows: int = 8) -> None:
    fig, ax = plt.subplots(figsize=(10, 6))

    # Smooth hyperbola 1/x.
    xs = np.linspace(1.0, num_windows + 1, 2000)
    ax.plot(xs, 1.0 / xs, color="#c0392b", lw=2.2, label=r"$y = 1/x$", zorder=3)

    # Staircase 1/floor(x) and shaded slivers.
    for k in range(num_windows):
        left, right = k + 1, k + 2
        height = 1.0 / (k + 1)
        ax.hlines(height, left, right, color="#2c3e50", lw=2.0, zorder=3)
        xx = np.linspace(left, right, 200)
        ax.fill_between(xx, 1.0 / xx, height, color="#3498db", alpha=0.45, zorder=2)

    ax.plot([], [], color="#2c3e50", lw=2.0, label=r"$y = 1/\lfloor x \rfloor$")
    ax.fill_between([], [], color="#3498db", alpha=0.45,
                    label=r"area $= \gamma = 0.57721566\ldots$")

    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.set_title("The Euler--Mascheroni constant as area between staircase and hyperbola")
    ax.set_xlim(1, num_windows + 1)
    ax.set_ylim(0, 1.05)
    ax.legend(loc="upper right", framealpha=0.95)
    ax.grid(alpha=0.25)

    fig.tight_layout()
    fig.savefig("euler_mascheroni_staircase.png", dpi=150)
    print("saved euler_mascheroni_staircase.png")


if __name__ == "__main__":
    main()
