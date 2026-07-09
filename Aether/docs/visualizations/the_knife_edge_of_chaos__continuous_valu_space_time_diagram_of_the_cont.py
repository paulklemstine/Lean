"""
Space-time diagram of the symmetric three-point continuous CA across the phase
transition. For several diffusion coefficients `a`, evolve a localized seed and
render the resulting space-time field, contrasting the laminar regime inside
[0, 1/2] with the explosive instability outside it.

Requires: numpy, matplotlib.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def evolve(a: float, width: int, steps: int, seed: str = "spike") -> np.ndarray:
    """Evolve a configuration of `width` cells (periodic) for `steps` steps.

    Returns a (steps+1, width) array of the space-time field.
    """
    c = np.zeros(width, dtype=float)
    if seed == "spike":
        c[width // 2] = 1.0
    elif seed == "noise":
        rng = np.random.default_rng(0)
        c = rng.standard_normal(width) * 0.01
    field = np.empty((steps + 1, width), dtype=float)
    field[0] = c
    for t in range(steps):
        c = a * np.roll(c, 1) + (1.0 - 2.0 * a) * c + a * np.roll(c, -1)
        field[t + 1] = c
    return field


def main() -> None:
    width, steps = 201, 120
    coeffs = [0.1, 0.25, 0.5, 0.65]  # last one is unstable (> 1/2)
    fig, axes = plt.subplots(1, len(coeffs), figsize=(4 * len(coeffs), 5))
    for ax, a in zip(axes, coeffs):
        # use the noise seed so the alternating mode is excited
        field = evolve(a, width, steps, seed="noise")
        # symmetric color scale clipped for visibility
        vmax = np.percentile(np.abs(field), 99) + 1e-12
        ax.imshow(field, cmap="RdBu_r", vmin=-vmax, vmax=vmax,
                  aspect="auto", interpolation="nearest")
        regime = "laminar" if 0.0 <= a <= 0.5 else "UNSTABLE"
        ax.set_title(f"a = {a}  ({regime})\n|1-4a| = {abs(1 - 4 * a):.2f}")
        ax.set_xlabel("position x")
        ax.set_ylabel("time t (down)")
    fig.suptitle("Continuous CA space-time across the threshold a = 1/2",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("spacetime.png", dpi=130)
    print("wrote spacetime.png")


if __name__ == "__main__":
    main()
