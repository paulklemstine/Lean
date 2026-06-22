"""
Visualization: the commutator-scaling factor u^{-2} across roots of unity.

For Jones operators at weights u = exp(2*pi*i/k), the commutator of two gates is
the commutator of the underlying generators scaled by u^{-2}. This script plots
the points u^{-2} = exp(-4*pi*i/k) on the unit circle for k = 3..12, making
visually clear that the scaling factor is always a UNIT (|u^{-2}| = 1) and hence
can never destroy non-commutativity.

Self-contained: standard library + matplotlib.
Run:  python3 _viz.py   (writes commutator_scaling.png)
"""

from __future__ import annotations

import cmath
from typing import List

import matplotlib.pyplot as plt


def scaling_factors(ks: List[int]) -> List[complex]:
    """The commutator-scaling factor u^{-2} for u = exp(2*pi*i/k)."""
    return [cmath.exp(-4j * cmath.pi / k) for k in ks]


def main() -> None:
    ks = list(range(3, 13))
    factors = scaling_factors(ks)

    fig, ax = plt.subplots(figsize=(6, 6))

    # Unit circle.
    circle = plt.Circle((0, 0), 1.0, fill=False, color="0.7", linestyle="--")
    ax.add_artist(circle)

    xs = [f.real for f in factors]
    ys = [f.imag for f in factors]
    ax.scatter(xs, ys, c=ks, cmap="viridis", s=120, zorder=3)

    for k, f in zip(ks, factors):
        label = f"k={k}" + ("  (Fibonacci)" if k == 5 else "")
        ax.annotate(label, (f.real, f.imag), textcoords="offset points",
                    xytext=(8, 4), fontsize=8)

    ax.axhline(0, color="0.85", lw=0.8)
    ax.axvline(0, color="0.85", lw=0.8)
    ax.set_aspect("equal")
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_title(r"Commutator scaling factor $u^{-2}=e^{-4\pi i/k}$ on the unit circle"
                 "\n(|u^{-2}|=1 always: a unit can never destroy non-commutativity)")
    ax.set_xlabel("Re")
    ax.set_ylabel("Im")
    fig.tight_layout()
    fig.savefig("commutator_scaling.png", dpi=150)
    print("wrote commutator_scaling.png")


if __name__ == "__main__":
    main()
