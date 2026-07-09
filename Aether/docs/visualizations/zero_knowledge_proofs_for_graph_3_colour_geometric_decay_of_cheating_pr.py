"""Visualization: soundness-error decay under sequential repetition.

Plots the k-round cheating acceptance probability (1 - 1/m)^k for several edge
counts m, on a logarithmic y-axis, illustrating geometric decay to zero.
"""
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    ks = np.arange(0, 120)
    fig, ax = plt.subplots(figsize=(8, 5))
    for m in (5, 20, 100):
        p = 1.0 - 1.0 / m
        ax.semilogy(ks, p ** ks, label=f"|E| = {m}  (p = {p:.3f})")
    ax.axhline(1e-9, color="grey", ls="--", lw=1, label="target error 1e-9")
    ax.set_xlabel("number of rounds k")
    ax.set_ylabel("cheating acceptance probability  p^k")
    ax.set_title("Soundness amplification: geometric decay of cheating probability")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("soundness_decay.png", dpi=150)
    print("wrote soundness_decay.png")


if __name__ == "__main__":
    main()
