"""Standalone visualization: eigenvalues of the unbalanced vs. unsigned 4-cycle,
and the spectral radius against the max-degree bound. Requires matplotlib."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt


def main() -> None:
    unbalanced = [-math.sqrt(2), -math.sqrt(2), math.sqrt(2), math.sqrt(2)]
    unsigned = [-2.0, 0.0, 0.0, 2.0]
    delta = 2.0

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))

    # Eigenvalue scatter on the real line.
    ax1.axhline(0, color="0.8", lw=1)
    ax1.scatter(unsigned, [1] * 4, s=90, color="#c0392b", label="unsigned $C_4$", zorder=3)
    ax1.scatter(unbalanced, [0] * 4, s=90, color="#2471a3", label="unbalanced $C_4$", zorder=3)
    for x in (-delta, delta):
        ax1.axvline(x, color="0.6", ls="--", lw=1)
    ax1.set_yticks([0, 1])
    ax1.set_yticklabels(["signed", "unsigned"])
    ax1.set_xlabel("eigenvalue")
    ax1.set_title("Spectra of the 4-cycle")
    ax1.legend(loc="upper center")

    # Spectral radius bar chart vs. degree bound.
    labels = ["unsigned\n$\rho=2$", "unbalanced\n$\rho=\sqrt2$"]
    vals = [2.0, math.sqrt(2)]
    bars = ax2.bar(labels, vals, color=["#c0392b", "#2471a3"])
    ax2.axhline(delta, color="k", ls="--", lw=1.2, label=r"degree bound $\Delta=2$")
    for b, v in zip(bars, vals):
        ax2.text(b.get_x() + b.get_width() / 2, v + 0.03, f"{v:.3f}", ha="center")
    ax2.set_ylim(0, 2.4)
    ax2.set_ylabel("spectral radius")
    ax2.set_title("Signing suppresses the spectral radius")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("spectral_radius.png", dpi=150)
    print("saved spectral_radius.png")


if __name__ == "__main__":
    main()
