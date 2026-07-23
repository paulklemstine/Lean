"""
Visualization: error-decay curves and activation shapes for single-feature
universal approximation. Requires matplotlib and numpy.

Produces two panels:
  (1) the four canonical activations (all strictly increasing) plus the even
      Gaussian, illustrating injectivity vs non-injectivity;
  (2) log-scale uniform approximation error vs polynomial degree, showing
      geometric-style decay for injective activations and stagnation for the
      Gaussian.
"""

from __future__ import annotations

import math
from typing import Callable, List

import numpy as np
import matplotlib.pyplot as plt


def sigmoid(x: float) -> float:
    return 1.0 / (1.0 + math.exp(-x))


def softplus(x: float) -> float:
    return math.log1p(math.exp(-abs(x))) + max(x, 0.0)


def gaussian(x: float) -> float:
    return math.exp(-x * x)


def fit_and_error(act: Callable[[float], float], target: Callable[[float], float],
                  a: float, b: float, degree: int) -> float:
    xs = np.linspace(a, b, 400)
    u = np.array([act(float(x)) for x in xs])
    P = np.vstack([u ** k for k in range(degree + 1)]).T
    y = np.array([target(float(x)) for x in xs])
    coeffs, *_ = np.linalg.lstsq(P, y, rcond=None)
    xt = np.linspace(a, b, 2000)
    ut = np.array([act(float(x)) for x in xt])
    Pt = np.vstack([ut ** k for k in range(degree + 1)]).T
    pred = Pt @ coeffs
    yt = np.array([target(float(x)) for x in xt])
    return float(np.max(np.abs(pred - yt)))


def main() -> None:
    a, b = -2.0, 2.0
    target = lambda x: math.sin(3.0 * x) + 0.5 * x * math.cos(x)
    acts = {"sigmoid": sigmoid, "softplus": softplus,
            "tanh": math.tanh, "arctan": math.atan, "gaussian": gaussian}

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    grid = np.linspace(-3, 3, 400)
    for name, act in acts.items():
        ax1.plot(grid, [act(float(x)) for x in grid],
                 lw=2, ls="--" if name == "gaussian" else "-", label=name)
    ax1.set_title("Activations: injective (monotone) vs non-injective (Gaussian)")
    ax1.set_xlabel("x"); ax1.set_ylabel("sigma(x)"); ax1.legend(); ax1.grid(alpha=0.3)

    degrees = list(range(1, 15))
    for name, act in acts.items():
        errs = [fit_and_error(act, target, a, b, d) for d in degrees]
        ax2.semilogy(degrees, errs, marker="o",
                     ls="--" if name == "gaussian" else "-", label=name)
    ax2.set_title("Uniform approximation error vs polynomial degree")
    ax2.set_xlabel("polynomial degree d"); ax2.set_ylabel("sup-norm error (log)")
    ax2.legend(); ax2.grid(alpha=0.3, which="both")

    fig.tight_layout()
    fig.savefig("single_feature_approximation.png", dpi=150)
    print("saved single_feature_approximation.png")


if __name__ == "__main__":
    main()
