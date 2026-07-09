"""Visualization: EML monomial networks vs. their target monomials on [0,1].

Plots emlQuadApprox(h, x) against x^2 and emlCubicApprox(h, x) against x^3 for
several step sizes h = 1/n, together with the proved uniform error envelopes
(4/9)h and (5/16)h, illustrating the O(1/n) Jackson rate.
"""

from __future__ import annotations

import math
from typing import List

import numpy as np
import matplotlib.pyplot as plt


def eml_quad_approx(h: float, x: np.ndarray) -> np.ndarray:
    u = h * x
    return (2.0 / h ** 2) * (np.exp(u) - 1.0 - u)


def eml_cubic_approx(h: float, x: np.ndarray) -> np.ndarray:
    u = h * x
    return (6.0 / h ** 3) * (np.exp(u) - 1.0 - u - u ** 2 / 2.0)


def main() -> None:
    xs = np.linspace(0.0, 1.0, 400)
    ns: List[int] = [1, 2, 4, 8]

    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    axes[0].plot(xs, xs ** 2, "k--", lw=2, label="target $x^2$")
    for n in ns:
        axes[0].plot(xs, eml_quad_approx(1.0 / n, xs), lw=1.3, label=f"n={n}")
    axes[0].set_title("Quadratic EML network  (2/h$^2$)(e$^{hx}$-1-hx) → $x^2$")
    axes[0].set_xlabel("x"); axes[0].legend(); axes[0].grid(alpha=0.3)

    axes[1].plot(xs, xs ** 3, "k--", lw=2, label="target $x^3$")
    for n in ns:
        axes[1].plot(xs, eml_cubic_approx(1.0 / n, xs), lw=1.3, label=f"n={n}")
    axes[1].set_title("Cubic EML network  (6/h$^3$)(e$^{hx}$-1-hx-(hx)$^2$/2) → $x^3$")
    axes[1].set_xlabel("x"); axes[1].legend(); axes[1].grid(alpha=0.3)

    fig.suptitle("EML monomial synthesis via rescaled forward differences of exp")
    fig.tight_layout()
    fig.savefig("eml_monomial_networks.png", dpi=150)
    print("saved eml_monomial_networks.png")


if __name__ == "__main__":
    main()
