"""Visualization: density convergence and linear generator-complexity growth.

Generates a two-panel figure. Left panel overlays a continuous target with its
exponential-monomial least-squares approximations for increasing numbers of
monomials (witnessing density of span{e^{kx}}). Right panel plots the exact
generator size 2k+2 (the bound K(e^{(k+1)x}) <= 2k+2) against k.

Requires matplotlib and numpy.
"""

from __future__ import annotations

from math import exp, cos, pi
from typing import Callable, List

import numpy as np
import matplotlib.pyplot as plt


def fit_coeffs(target: Callable[[float], float], a: float, b: float,
               k_max: int, m: int = 300) -> np.ndarray:
    xs = np.linspace(a, b, m)
    ys = np.array([target(float(x)) for x in xs])
    A = np.column_stack([np.exp(k * xs) for k in range(k_max + 1)])
    coeffs, *_ = np.linalg.lstsq(A, ys, rcond=None)
    return coeffs


def evaluate(coeffs: np.ndarray, xs: np.ndarray) -> np.ndarray:
    return sum(coeffs[k] * np.exp(k * xs) for k in range(len(coeffs)))


def main() -> None:
    a, b = 0.0, 1.0
    target = lambda x: cos(3 * pi * x)
    xs = np.linspace(a, b, 400)
    truth = np.array([target(float(x)) for x in xs])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(xs, truth, "k-", lw=2.5, label="target  cos(3πx)")
    for k_max in (2, 4, 6, 10):
        coeffs = fit_coeffs(target, a, b, k_max)
        ax1.plot(xs, evaluate(coeffs, xs), "--", lw=1.5,
                 label=f"{k_max + 1} monomials")
    ax1.set_title("Density: exponential-monomial approximation")
    ax1.set_xlabel("x")
    ax1.set_ylabel("value")
    ax1.legend(fontsize=8)
    ax1.grid(alpha=0.3)

    ks = list(range(0, 13))
    sizes = [2 * k + 2 for k in ks]
    ax2.plot(ks, sizes, "o-", color="crimson", lw=2)
    ax2.set_title(r"Complexity bound  $K(e^{(k+1)x}) \leq 2k+2$")
    ax2.set_xlabel("frequency index k")
    ax2.set_ylabel("term size  =  2k + 2")
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("eml_density_complexity.png", dpi=140)
    print("wrote eml_density_complexity.png")


if __name__ == "__main__":
    main()
