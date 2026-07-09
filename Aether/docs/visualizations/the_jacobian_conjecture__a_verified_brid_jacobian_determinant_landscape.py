"""Visualization: Jacobian determinant landscapes — constant vs. non-constant.

Generates a 1x3 panel of heatmaps over the (x, y) plane:
  * Triangular automorphism F=(x+y^2, y):       det(JF) = 1            (flat)
  * Druzkowski cubic-linear F=(x+y^3, y):        det(JF) = 1            (flat)
  * Symmetric candidate F=(x+y^2, y+x^2):        det(JF) = 1 - 4xy      (varies)

The flat panels are genuine Jacobian-Conjecture candidates; the varying panel
fails the hypothesis. Saves 'jacobian_landscapes.png'.
"""
from typing import Callable
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    grid = np.linspace(-2.0, 2.0, 400)
    X, Y = np.meshgrid(grid, grid)

    panels = [
        ("Triangular  F=(x+y^2, y)\ndet(JF) = 1", np.ones_like(X)),
        ("Druzkowski  F=(x+y^3, y)\ndet(JF) = 1", np.ones_like(X)),
        ("Symmetric  F=(x+y^2, y+x^2)\ndet(JF) = 1 - 4xy", 1.0 - 4.0 * X * Y),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.6))
    for ax, (title, Z) in zip(axes, panels):
        im = ax.pcolormesh(X, Y, Z, shading="auto", cmap="coolwarm",
                           vmin=-8, vmax=8)
        ax.set_title(title, fontsize=11)
        ax.set_xlabel("x")
        ax.set_ylabel("y")
        ax.contour(X, Y, Z, levels=[0.0], colors="black", linewidths=1.2)
        fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    fig.suptitle("Jacobian determinant landscapes: candidates are flat, "
                 "naive guesses are not", fontsize=13)
    fig.tight_layout()
    fig.savefig("jacobian_landscapes.png", dpi=150)
    print("wrote jacobian_landscapes.png")


if __name__ == "__main__":
    main()
