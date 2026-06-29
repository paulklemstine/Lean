"""
visualize_rademacher.py — Visualize the empirical Rademacher complexity of the
symmetric pair {f, -f} as a function of the vector f, and the exact closed-form
identity emp_rad({f,-f}) = (1/m)(1/2^m) sum_sigma |radSum(f,sigma)|.

Generates two panels:
  (left)  emp_rad({f,-f}) over a 2D slice f = (x, y) with m = 2.
  (right) distribution of radSum(f, sigma) over all sign vectors for a fixed f,
          illustrating the zero-mean (Thm 4.1) and absolute-value absorption.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import itertools
from typing import Iterable, Sequence, Tuple

import numpy as np
import matplotlib.pyplot as plt


def all_sign_vectors(m: int) -> Iterable[Tuple[bool, ...]]:
    return itertools.product([False, True], repeat=m)


def rad_sum(f: Sequence[float], sigma: Sequence[bool]) -> float:
    return sum((1.0 if s else -1.0) * fi for s, fi in zip(sigma, f))


def emp_rad_symmetric_pair(f: Sequence[float]) -> float:
    m = len(f)
    total = sum(abs(rad_sum(f, s)) for s in all_sign_vectors(m))
    return (1.0 / m) * (1.0 / (2.0 ** m)) * total


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel 1: heatmap of emp_rad({f,-f}) for f = (x, y), m = 2.
    xs = np.linspace(-2, 2, 121)
    ys = np.linspace(-2, 2, 121)
    Z = np.empty((len(ys), len(xs)))
    for j, y in enumerate(ys):
        for i, x in enumerate(xs):
            Z[j, i] = emp_rad_symmetric_pair((x, y))
    im = ax1.contourf(xs, ys, Z, levels=30, cmap="viridis")
    ax1.set_title("emp_rad({f, -f}),  f = (x, y),  m = 2")
    ax1.set_xlabel("x = f(0)")
    ax1.set_ylabel("y = f(1)")
    fig.colorbar(im, ax=ax1, label="empirical Rademacher complexity")

    # Panel 2: radSum values over all sign vectors for a fixed f (m = 4).
    f = [1.0, -2.0, 0.5, 1.5]
    sigmas = list(all_sign_vectors(len(f)))
    vals = [rad_sum(f, s) for s in sigmas]
    ax2.bar(range(len(vals)), vals, color="steelblue")
    ax2.axhline(0.0, color="black", lw=1)
    ax2.set_title(f"radSum(f, sigma) over all 2^{len(f)} sign vectors\n"
                  f"(mean = {np.mean(vals):.2e}, illustrating Thm 4.1)")
    ax2.set_xlabel("sign vector index")
    ax2.set_ylabel("radSum(f, sigma)")

    fig.tight_layout()
    fig.savefig("rademacher_visualization.png", dpi=150)
    print("Saved rademacher_visualization.png")


if __name__ == "__main__":
    main()
