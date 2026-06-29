"""
Visualization: the q/4 decryption-correctness noise budget.

Plots the centered decryption value mu*(q/2)+e as the error e sweeps across
[-q/2, q/2] for both message bits, shading the correct-decoding bands and the
critical thresholds at +/- q/4. Demonstrates the verified theorems
regev_rounding_bit0 / regev_rounding_bit1: decoding is correct exactly inside
the |e| < q/4 window. Requires matplotlib.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def centered(value: np.ndarray, q: float) -> np.ndarray:
    """Map values to the representative in (-q/2, q/2]."""
    return ((value + q / 2.0) % q) - q / 2.0


def main() -> None:
    q: float = 256.0
    e = np.linspace(-q / 2.0, q / 2.0, 2000)

    fig, ax = plt.subplots(figsize=(9, 5))
    # Bit 0 encodes at 0; bit 1 encodes at q/2.
    ax.plot(e, centered(0.0 + e, q), label="encoded bit 0:  0 + e", lw=2)
    ax.plot(e, centered(q / 2.0 + e, q), label="encoded bit 1:  q/2 + e", lw=2)

    # Correct-decoding band for bit 0: |centered| < q/4.
    ax.axhspan(-q / 4.0, q / 4.0, color="tab:blue", alpha=0.12,
               label="decodes to 0  (|.| < q/4)")
    ax.axhline(q / 4.0, color="crimson", ls="--", lw=1.2)
    ax.axhline(-q / 4.0, color="crimson", ls="--", lw=1.2)
    ax.axvspan(-q / 4.0, q / 4.0, color="tab:green", alpha=0.10,
               label="safe error window |e| < q/4")

    ax.set_title("LWE / Regev decryption noise budget  (q = 256)")
    ax.set_xlabel("error  e")
    ax.set_ylabel("centered decoded value")
    ax.legend(loc="upper left", fontsize=8)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("noise_budget.png", dpi=150)
    print("wrote noise_budget.png")


if __name__ == "__main__":
    main()
