"""Render the space-time diagram of an additive CA over F_p as a fractal image.

Produces a PNG of the Sierpinski-type pattern generated from a single seed,
colouring each cell by its field value 0..p-1.  Requires matplotlib + numpy.
"""
from __future__ import annotations
from math import comb
from typing import List
import numpy as np
import matplotlib.pyplot as plt


def spacetime_matrix(p: int, steps: int) -> np.ndarray:
    """Row n holds C(n,k) mod p at column k (the time-n CA state)."""
    grid = np.zeros((steps, 2 * steps - 1), dtype=int)
    center = steps - 1
    for n in range(steps):
        for k in range(n + 1):
            grid[n, center + (2 * k - n)] = comb(n, k) % p
    return grid


def render(p: int = 2, steps: int = 256) -> None:
    grid = spacetime_matrix(p, steps)
    plt.figure(figsize=(8, 8))
    cmap = "binary" if p == 2 else "viridis"
    plt.imshow(grid, cmap=cmap, interpolation="nearest")
    plt.title(f"Additive CA space-time diagram over F_{p}\n"
              f"(Pascal's triangle mod {p}; powers of {p} give 2-cell rows)")
    plt.xlabel("space  (site = column - center)")
    plt.ylabel("time  n")
    plt.colorbar(label="cell value mod p")
    plt.tight_layout()
    plt.savefig(f"additive_ca_p{p}_fractal.png", dpi=150)
    print(f"wrote additive_ca_p{p}_fractal.png")


if __name__ == "__main__":
    render(2, 256)   # the classic Sierpinski triangle
    render(3, 243)   # the F_3 analogue (243 = 3^5)
