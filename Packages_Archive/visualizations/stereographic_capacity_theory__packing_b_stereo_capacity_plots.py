"""Visualization: the S^2 distortion bound and the conformal factor.

Generates two side-by-side plots:
  (left)  conformal factor lambda(x) = 2/(1+t^2) as a function of t = ||x||,
          showing lambda <= 2 with equality at the origin;
  (right) the S^2 distortion bound 8/(cos^2 r (1-cos r)) over r in (0, pi/2).

Saves to stereo_capacity_plots.png.
"""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt


def stereo_factor_radial(t: np.ndarray) -> np.ndarray:
    return 2.0 / (1.0 + t ** 2)


def stereo_bound_s2_closed(r: np.ndarray) -> np.ndarray:
    return 8.0 / (np.cos(r) ** 2 * (1.0 - np.cos(r)))


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    t = np.linspace(0.0, 6.0, 400)
    ax1.plot(t, stereo_factor_radial(t), color="navy", lw=2)
    ax1.axhline(2.0, ls="--", color="gray", label="upper bound 2")
    ax1.scatter([0.0], [2.0], color="crimson", zorder=5, label="maximum at origin")
    ax1.set_title("Conformal factor  lambda = 2/(1+||x||^2)")
    ax1.set_xlabel("||x||")
    ax1.set_ylabel("lambda")
    ax1.legend()
    ax1.grid(alpha=0.3)

    r = np.linspace(0.05, math.pi / 2 - 0.05, 400)
    ax2.plot(r, stereo_bound_s2_closed(r), color="darkgreen", lw=2)
    ax2.set_yscale("log")
    ax2.set_title("S^2 distortion bound  8/(cos^2 r (1-cos r))")
    ax2.set_xlabel("geodesic radius r")
    ax2.set_ylabel("bound (log scale)")
    ax2.grid(alpha=0.3, which="both")

    fig.tight_layout()
    fig.savefig("stereo_capacity_plots.png", dpi=150)
    print("Saved stereo_capacity_plots.png")


if __name__ == "__main__":
    main()
