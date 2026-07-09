"""Visualization: convergence of exponential-polynomial approximation and the
depth gap between the two monomial representations.

Generates 'eml_density_depth.png' with two panels:
  (left)  sup-norm approximation error vs. number of exponential features,
          illustrating eml_approx_unitCube (error -> 0);
  (right) representation depth vs. monomial degree, illustrating
          eml_depth_compression (constant 3 vs. linear n).
"""
from __future__ import annotations

import itertools
import math
from typing import List, Tuple

import numpy as np
import matplotlib.pyplot as plt


def target(X: np.ndarray) -> np.ndarray:
    return np.sin(3.0 * X[:, 0]) * (X[:, 1] ** 2) + np.cos(2.0 * X[:, 0] * X[:, 1])


def fit_error(max_degree: int, grid: int = 15) -> Tuple[int, float]:
    axis = np.linspace(0.0, 1.0, grid)
    X = np.array(list(itertools.product(axis, repeat=2)), dtype=float)
    y = target(X)
    idx = [k for k in itertools.product(range(max_degree + 1), repeat=2) if sum(k) <= max_degree]
    Phi = np.exp(X @ np.asarray(idx, dtype=float).T)
    c, *_ = np.linalg.lstsq(Phi, y, rcond=None)
    return len(idx), float(np.max(np.abs(Phi @ c - y)))


def main() -> None:
    degrees = list(range(1, 8))
    counts, errors = [], []
    for d in degrees:
        c, e = fit_error(d)
        counts.append(c)
        errors.append(e)

    ns = list(range(1, 33))
    depth_naive = ns
    depth_explog = [3 for _ in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.semilogy(counts, errors, "o-", color="#1f77b4")
    ax1.set_xlabel("number of exponential features  |S|")
    ax1.set_ylabel("sup-norm error on the cube")
    ax1.set_title("Density: uniform error -> 0")
    ax1.grid(True, which="both", alpha=0.3)

    ax2.plot(ns, depth_naive, "o-", label="naive product (depth n)", color="#d62728")
    ax2.plot(ns, depth_explog, "s-", label="exp/log (depth 3)", color="#2ca02c")
    ax2.set_xlabel("monomial degree  n")
    ax2.set_ylabel("representation depth")
    ax2.set_title("Depth compression: 3 vs. n")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("eml_density_depth.png", dpi=150)
    print("wrote eml_density_depth.png")


if __name__ == "__main__":
    main()
