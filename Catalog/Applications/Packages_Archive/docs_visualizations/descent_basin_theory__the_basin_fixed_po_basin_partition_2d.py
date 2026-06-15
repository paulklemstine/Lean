"""
visualize_basins.py — Visualize the basin partition of a 2D descent system.

Builds a descent system on an m x n grid whose dynamics flow downhill on a
fixed integer "height" landscape (a discrete gradient descent that steps to the
lowest-energy Moore neighbor, with ties broken deterministically). Fixed points
are the local minima; basins are the fibers of the limit map. The figure shows:

  * left  : the integer height landscape;
  * right : the basin partition, each basin in its own color, local minima marked.

This is a direct visual instance of the Basin Fixed Point Theorem: the number of
distinct colors (basins) equals the number of marked local minima (fixed points).

Run:  python visualize_basins.py
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import numpy as np
import matplotlib.pyplot as plt

Cell = Tuple[int, int]


def make_landscape(m: int, n: int, seed: int = 7) -> np.ndarray:
    """A smooth-ish integer height field with several local minima."""
    rng = np.random.default_rng(seed)
    xs = np.linspace(0, 3 * np.pi, n)
    ys = np.linspace(0, 3 * np.pi, m)
    gx, gy = np.meshgrid(xs, ys)
    field = (np.sin(gx) * np.cos(gy) + 0.6 * np.sin(2 * gx + 1.0)
             + 0.6 * np.cos(2 * gy + 0.5))
    field = field + 0.15 * rng.standard_normal((m, n))
    # quantize to integers (Lyapunov energy must be N-valued)
    q = np.round((field - field.min()) * 6).astype(int)
    return q


def step(height: np.ndarray, c: Cell) -> Cell:
    """Move to the strictly-lower Moore neighbor of minimal height; else stay.

    Only strictly-lower neighbors are candidates, so energy strictly decreases on
    every genuine move (the strict descent law); ties among candidates are broken
    by lexicographic order, which cannot create cycles since height keeps falling.
    """
    m, n = height.shape
    i, j = c
    best: Cell = c
    best_h = int(height[i, j])
    for di in (-1, 0, 1):
        for dj in (-1, 0, 1):
            if di == 0 and dj == 0:
                continue
            ni, nj = i + di, j + dj
            if 0 <= ni < m and 0 <= nj < n:
                h = int(height[ni, nj])
                if h < int(height[i, j]):  # candidate must be strictly lower
                    if h < best_h or (h == best_h and (ni, nj) < best):
                        best, best_h = (ni, nj), h
    return best


def limit_point(height: np.ndarray, c: Cell) -> Cell:
    """Iterate step until a fixed point (local min) is reached."""
    seen = set()
    while c not in seen:
        seen.add(c)
        nxt = step(height, c)
        if nxt == c:
            return c
        c = nxt
    return c


def compute_basins(height: np.ndarray) -> Tuple[np.ndarray, List[Cell]]:
    """Return a label grid (basin id per cell) and the list of local minima."""
    m, n = height.shape
    minima: List[Cell] = []
    for i in range(m):
        for j in range(n):
            if step(height, (i, j)) == (i, j):
                minima.append((i, j))
    idx: Dict[Cell, int] = {mn: k for k, mn in enumerate(minima)}
    labels = np.zeros((m, n), dtype=int)
    for i in range(m):
        for j in range(n):
            labels[i, j] = idx[limit_point(height, (i, j))]
    return labels, minima


def main() -> None:
    m, n = 30, 40
    height = make_landscape(m, n)
    labels, minima = compute_basins(height)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    im1 = ax1.imshow(height, cmap="terrain")
    ax1.set_title("Integer height landscape (energy)")
    fig.colorbar(im1, ax=ax1, fraction=0.046, pad=0.04)

    ax2.imshow(labels, cmap="tab20")
    ys, xs = zip(*minima)
    ax2.scatter(xs, ys, c="black", s=40, marker="x", label="local minima (fixed pts)")
    ax2.set_title(f"Basin partition: {len(minima)} basins = {len(minima)} fixed points")
    ax2.legend(loc="upper right")

    fig.suptitle("Basin Fixed Point Theorem in 2D: #basins = #fixed points",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("basins.png", dpi=130)
    print(f"Saved basins.png  (#basins = #fixed points = {len(minima)})")


if __name__ == "__main__":
    main()
