"""Visualization: depth acts as a low-pass filter on the Hodge spectrum.

Plots the per-mode amplitude (1 - t*lam)^L versus depth L for the harmonic
mode (lam=0) and several non-harmonic eigenvalues, and marks the critical
depth L_c at which the spectral-gap mode falls below a tolerance eps.
"""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    mu: float = 2.0          # spectral gap (smallest nonzero eigenvalue)
    lam_max: float = 4.0
    t: float = 1.0 / lam_max # normalized step
    eps: float = 1e-3
    Lc: int = max(0, math.ceil(math.log(eps) / math.log(1 - t * mu)))

    depths = np.arange(0, 40)
    fig, ax = plt.subplots(figsize=(8, 5))
    for lam, label in [(0.0, "harmonic (lam=0)"),
                       (mu, f"gap mode (lam={mu})"),
                       (3.0, "lam=3"),
                       (lam_max, f"lam_max={lam_max}")]:
        amp = (1 - t * lam) ** depths
        ax.plot(depths, amp, marker="o", ms=3, label=label)

    ax.axhline(eps, color="gray", ls="--", lw=1, label=f"eps={eps}")
    ax.axvline(Lc, color="red", ls=":", lw=1.5, label=f"L_c={Lc}")
    ax.set_yscale("log")
    ax.set_xlabel("depth L")
    ax.set_ylabel("mode amplitude  (1 - t*lam)^L")
    ax.set_title("Depth as a low-pass filter on the Hodge spectrum")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("hodge_depth_filter.png", dpi=150)
    print("wrote hodge_depth_filter.png ; L_c =", Lc)


if __name__ == "__main__":
    main()
