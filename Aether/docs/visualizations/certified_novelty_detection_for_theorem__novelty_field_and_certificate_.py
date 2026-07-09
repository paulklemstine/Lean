"""Visualize novelty as a distance-to-catalog field and its 1-Lipschitz contours.

Renders the novelty function novelty(C, x) over a 2D grid for a small catalog,
overlaying the catalog points (novelty = 0) and the eps-certified region (novelty
>= eps). Requires matplotlib and numpy.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    catalog = np.array([[1.0, 1.0], [4.0, 2.0], [2.5, 4.5], [5.0, 5.0]])
    eps = 0.8
    xs = np.linspace(0, 6, 400)
    ys = np.linspace(0, 6, 400)
    gx, gy = np.meshgrid(xs, ys)
    grid = np.stack([gx.ravel(), gy.ravel()], axis=1)

    # novelty(C, x) = min over catalog of Euclidean distance
    d = np.sqrt(((grid[:, None, :] - catalog[None, :, :]) ** 2).sum(-1))
    nov = d.min(axis=1).reshape(gx.shape)

    fig, ax = plt.subplots(figsize=(7, 6))
    im = ax.contourf(gx, gy, nov, levels=25, cmap="viridis")
    ax.contour(gx, gy, nov, levels=[eps], colors="white", linewidths=2)
    ax.scatter(catalog[:, 0], catalog[:, 1], c="red", s=80,
               edgecolors="white", zorder=5, label="catalog (novelty = 0)")
    ax.set_title(f"Novelty field; white contour = eps-certificate boundary (eps={eps})")
    ax.set_xlabel("embedding dim 1")
    ax.set_ylabel("embedding dim 2")
    ax.legend(loc="upper left")
    fig.colorbar(im, ax=ax, label="novelty(C, x)")
    fig.tight_layout()
    fig.savefig("novelty_field.png", dpi=150)
    print("wrote novelty_field.png")


if __name__ == "__main__":
    main()
