"""Visualization: the iterated tent map and the exponentially steep ramp.

Generates a figure showing tent^[k] for k = 1..4 (the exponential growth in the
number of oscillations) plus a zoom on the first 2^-k ramp that defeats any
gently-sloped shallow approximant.  Requires matplotlib + numpy.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def relu(x: np.ndarray) -> np.ndarray:
    return np.maximum(x, 0.0)


def tent(x: np.ndarray) -> np.ndarray:
    return 1.0 - relu(2.0 * x - 1.0) - relu(1.0 - 2.0 * x)


def tent_iterate(x: np.ndarray, k: int) -> np.ndarray:
    for _ in range(k):
        x = tent(x)
    return x


def main() -> None:
    xs = np.linspace(0.0, 1.0, 200_001)
    fig, axes = plt.subplots(2, 2, figsize=(11, 8))

    for ax, k in zip(axes.ravel(), [1, 2, 3, 6]):
        ax.plot(xs, tent_iterate(xs, k), lw=0.8, color="#1f77b4")
        ax.set_title(f"tent^[{k}]  ({2 ** (k - 1)} peaks, Lipschitz = {2 ** k})")
        ax.set_xlim(0, 1)
        ax.set_ylim(-0.05, 1.05)
        ax.set_xlabel("x")
        ax.set_ylabel("output")
        # highlight the steep first ramp from (0,0) to (2^-k, 1)
        ax.plot([0, 2.0 ** (-k)], [0, 1], "r--", lw=1.5,
                label=f"ramp width 2^-{k}")
        ax.legend(loc="upper right", fontsize=8)

    fig.suptitle(
        "Iterated tent map: bounded in [0,1], exponential oscillation, "
        "slope 2^k", fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("tent_depth_separation.png", dpi=150)
    print("Saved tent_depth_separation.png")


if __name__ == "__main__":
    main()
