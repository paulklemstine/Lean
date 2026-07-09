"""Visualizations for the discrete-cube isotropy model of Bourgain's slicing problem.

Produces two figures:
  1. A heatmap of the covariance kernel T(k,l)/2^n, showing it is the identity.
  2. A bar chart of E[<theta,x>^2] for a random unit theta across dimensions n,
     showing the dimension-free constant value 1.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import List, Tuple

import numpy as np
import matplotlib.pyplot as plt


def covariance_matrix(n: int) -> np.ndarray:
    """Normalized covariance matrix T(k,l)/2^n of the uniform measure on {-1,1}^n."""
    M = np.zeros((n, n))
    for bits in itertools.product((1, -1), repeat=n):
        x = np.array(bits, dtype=float)
        M += np.outer(x, x)
    return M / (2 ** n)


def expected_inner_sq(n: int, theta: List[float]) -> float:
    total = 0.0
    for bits in itertools.product((1, -1), repeat=n):
        s = sum(theta[k] * bits[k] for k in range(n))
        total += s * s
    return total / (2 ** n)


def unit(theta: List[float]) -> List[float]:
    norm = math.sqrt(sum(t * t for t in theta))
    return [t / norm for t in theta]


def make_figures() -> Tuple[plt.Figure, plt.Figure]:
    # Figure 1: covariance heatmap.
    n = 6
    M = covariance_matrix(n)
    fig1, ax1 = plt.subplots(figsize=(5, 4))
    im = ax1.imshow(M, cmap="viridis", vmin=0.0, vmax=1.0)
    ax1.set_title(f"Normalized covariance T/2^n  (n = {n}) = Identity")
    ax1.set_xlabel("coordinate l")
    ax1.set_ylabel("coordinate k")
    fig1.colorbar(im, ax=ax1)

    # Figure 2: dimension-free constant.
    rng = random.Random(20260626)
    ns = list(range(1, 13))
    vals = [expected_inner_sq(n, unit([rng.uniform(-1, 1) for _ in range(n)])) for n in ns]
    fig2, ax2 = plt.subplots(figsize=(6, 4))
    ax2.bar(ns, vals, color="#3b78b0")
    ax2.axhline(1.0, color="crimson", linestyle="--", label="predicted value 1")
    ax2.set_ylim(0, 1.4)
    ax2.set_title("E[<theta,x>^2] for a unit theta is 1 in every dimension")
    ax2.set_xlabel("dimension n")
    ax2.set_ylabel("E[<theta,x>^2]")
    ax2.legend()
    return fig1, fig2


def main() -> None:
    fig1, fig2 = make_figures()
    fig1.savefig("covariance_identity.png", dpi=150, bbox_inches="tight")
    fig2.savefig("dimension_free_constant.png", dpi=150, bbox_inches="tight")
    print("Saved covariance_identity.png and dimension_free_constant.png")


if __name__ == "__main__":
    main()
