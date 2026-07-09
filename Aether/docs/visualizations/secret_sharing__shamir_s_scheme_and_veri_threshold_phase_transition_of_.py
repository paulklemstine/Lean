"""
Visualization: the threshold phase transition of Shamir secret sharing.

Left panel  -- shares as points on a degree-(t-1) curve over the reals, with the
               unique interpolating polynomial through any t of them and its
               y-intercept (the secret).
Right panel -- privacy below threshold: with only t-1 points, infinitely many
               degree-(t-1) curves pass through them, each hitting a DIFFERENT
               y-intercept, so the secret is completely undetermined.
"""

from __future__ import annotations

from typing import List, Sequence

import numpy as np
import matplotlib.pyplot as plt


def lagrange_value(xs: Sequence[float], ys: Sequence[float], z: float) -> float:
    """Evaluate the interpolating polynomial through (xs, ys) at z (over the reals)."""
    total = 0.0
    for i, xi in enumerate(xs):
        term = ys[i]
        for j, xj in enumerate(xs):
            if j != i:
                term *= (z - xj) / (xi - xj)
        total += term
    return total


def main() -> None:
    t = 3                       # threshold; sharing polynomial has degree t-1 = 2
    secret = 4.0
    coeffs = [secret, -1.2, 0.6]  # f(x) = 4 - 1.2 x + 0.6 x^2
    nodes = [1.0, 2.0, 3.0, 4.0]
    shares = [sum(c * x ** k for k, c in enumerate(coeffs)) for x in nodes]

    grid = np.linspace(-0.5, 4.5, 400)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # ---- Left: reconstruction with t points ------------------------------- #
    curve = [sum(c * x ** k for k, c in enumerate(coeffs)) for x in grid]
    ax1.plot(grid, curve, "b-", lw=2, label="secret polynomial f")
    ax1.scatter(nodes, shares, c="navy", s=70, zorder=5, label="shares")
    ax1.scatter([0], [secret], c="red", s=120, marker="*", zorder=6,
                label=f"secret f(0) = {secret}")
    ax1.axvline(0, color="grey", ls=":")
    ax1.set_title(f"Reconstruction: t = {t} shares pin down the secret")
    ax1.set_xlabel("evaluation point x")
    ax1.set_ylabel("share value f(x)")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # ---- Right: privacy with t-1 points ----------------------------------- #
    obs_x = nodes[:t - 1]            # only 2 points known
    obs_y = shares[:t - 1]
    ax2.scatter(obs_x, obs_y, c="navy", s=70, zorder=5,
                label=f"{t-1} observed shares")
    colors = plt.cm.viridis(np.linspace(0, 1, 7))
    for color, c0 in zip(colors, np.linspace(0, 8, 7)):
        xs = list(obs_x) + [0.0]
        ys = list(obs_y) + [c0]      # force the y-intercept to be c0
        yy = [lagrange_value(xs, ys, z) for z in grid]
        ax2.plot(grid, yy, color=color, lw=1.5, alpha=0.8)
        ax2.scatter([0], [c0], color=color, s=40, zorder=6)
    ax2.axvline(0, color="grey", ls=":")
    ax2.set_title(f"Privacy: t-1 = {t-1} shares fit every secret equally")
    ax2.set_xlabel("evaluation point x")
    ax2.set_ylabel("share value f(x)")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.suptitle("Shamir secret sharing: the threshold phase transition",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("threshold_phase_transition.png", dpi=140)
    print("Saved threshold_phase_transition.png")


if __name__ == "__main__":
    main()
