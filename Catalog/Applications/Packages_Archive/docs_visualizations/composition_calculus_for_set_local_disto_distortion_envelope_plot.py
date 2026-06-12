"""
Visualization: how the certified Hausdorff-dimension envelope of a composition
pipeline widens as Holder exponents move away from 1 (bi-Lipschitz), and how
exponents multiply along a chain of stages.

Generates two panels:
  (left)  envelope width vs Holder exponent r for an n-stage pipeline,
  (right) cumulative forward exponent product along a fixed pipeline.

Self-contained; requires matplotlib + numpy.
"""

from __future__ import annotations

import math

import matplotlib.pyplot as plt
import numpy as np


def envelope(base_dim: float, r_forward_product: float,
             r_inverse_product: float) -> tuple[float, float]:
    """Certified [lo, hi] for dimH of the image (Theorem 4.2)."""
    return base_dim * r_inverse_product, base_dim / r_forward_product


def main() -> None:
    base_dim = math.log(3) / math.log(2)  # Sierpinski triangle ~1.585

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # ---- Panel 1: envelope vs exponent, for several pipeline lengths ----
    rs = np.linspace(0.4, 1.0, 200)
    for n in (1, 2, 3):
        los, his = [], []
        for r in rs:
            R = r ** n  # all stages share exponent r; product is r^n
            lo, hi = envelope(base_dim, R, R)
            los.append(lo)
            his.append(hi)
        ax1.fill_between(rs, los, his, alpha=0.25, label=f"{n}-stage pipeline")
    ax1.axhline(base_dim, color="black", ls="--", lw=1, label="dimH s (invariant)")
    ax1.set_xlabel("Holder exponent r (per stage)")
    ax1.set_ylabel("certified dimension envelope")
    ax1.set_title("Envelope pinches to dimH s as r -> 1")
    ax1.legend()
    ax1.set_ylim(0, 6)

    # ---- Panel 2: multiplicativity of exponents along a chain ----
    stage_exponents = [0.9, 0.8, 0.95, 0.7, 0.85]
    cum = np.cumprod([1.0] + stage_exponents)
    ax2.plot(range(len(cum)), cum, "o-", color="crimson")
    for i, val in enumerate(cum):
        ax2.annotate(f"{val:.3f}", (i, val), textcoords="offset points",
                     xytext=(0, 8), ha="center", fontsize=8)
    ax2.set_xlabel("number of stages composed")
    ax2.set_ylabel("cumulative forward exponent product")
    ax2.set_title("Holder exponents MULTIPLY along the chain")
    ax2.set_ylim(0, 1.05)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Composition calculus for Hausdorff-dimension distortion",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("distortion_envelope.png", dpi=150)
    print("Saved distortion_envelope.png")


if __name__ == "__main__":
    main()
