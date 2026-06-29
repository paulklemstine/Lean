"""Visualization: a tropical line is the corner locus of min(a+X, b+Y, c).

Renders the three regions where each monomial wins, plus the Y-shaped corner
locus (tropical line). Requires matplotlib and numpy.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def tropical_line_plot(a: float = 0.0, b: float = 0.0, c: float = 0.0,
                       lim: float = 6.0, res: int = 600) -> None:
    xs = np.linspace(-lim, lim, res)
    ys = np.linspace(-lim, lim, res)
    X, Y = np.meshgrid(xs, ys)
    f0 = a + X            # monomial in x
    f1 = b + Y            # monomial in y
    f2 = c + 0*X          # constant monomial
    winner = np.argmin(np.stack([f0, f1, f2]), axis=0)

    plt.figure(figsize=(7, 7))
    plt.contourf(X, Y, winner, levels=[-0.5,0.5,1.5,2.5],
                 colors=["#cde7ff", "#ffe2c4", "#d6f5d6"], alpha=0.8)
    # corner locus: where the min is attained twice (region boundaries).
    M = np.min(np.stack([f0, f1, f2]), axis=0)
    twice = ((np.isclose(f0, M, atol=8*lim/res)).astype(int)
             + (np.isclose(f1, M, atol=8*lim/res)).astype(int)
             + (np.isclose(f2, M, atol=8*lim/res)).astype(int)) >= 2
    plt.contour(X, Y, twice.astype(float), levels=[0.5], colors="black", linewidths=2)
    plt.title("Tropical line: corner locus of min(a+X, b+Y, c)")
    plt.xlabel("X"); plt.ylabel("Y")
    plt.gca().set_aspect("equal")
    plt.tight_layout()
    plt.savefig("tropical_line.png", dpi=130)
    print("Saved tropical_line.png")

if __name__ == "__main__":
    tropical_line_plot(a=0.0, b=0.0, c=0.0)
