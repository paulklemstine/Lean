"""Visualization: the universality dichotomy on the circle.

Plots the orbit {n*alpha mod 1} for the irrational golden-ratio phase (which
fills the circle densely) versus the rational phase 4/5 (which visits only 5
points). Saves 'dichotomy.png'.
"""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt


def orbit_points(alpha: float, steps: int) -> np.ndarray:
    return np.array([(n * alpha) % 1.0 for n in range(steps)])


def main() -> None:
    phi = (1.0 + math.sqrt(5.0)) / 2.0
    steps = 400
    irr = orbit_points(phi % 1.0, steps)
    rat = orbit_points(4.0 / 5.0, steps)

    fig, axes = plt.subplots(1, 2, figsize=(11, 5.2),
                             subplot_kw={"projection": "polar"})
    for ax, pts, title, color in (
        (axes[0], irr, "phi (irrational): orbit dense", "#1f77b4"),
        (axes[1], rat, "4/5 (rational): 5 points, finite order", "#d62728"),
    ):
        theta = 2 * math.pi * pts
        radius = np.linspace(0.3, 1.0, len(pts))
        ax.scatter(theta, radius, s=10, c=color, alpha=0.7)
        ax.set_title(title, fontsize=11)
        ax.set_yticklabels([])
    fig.suptitle("Universality dichotomy: dense  <=>  irrational phase",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("dichotomy.png", dpi=130)
    print("wrote dichotomy.png")


if __name__ == "__main__":
    main()
