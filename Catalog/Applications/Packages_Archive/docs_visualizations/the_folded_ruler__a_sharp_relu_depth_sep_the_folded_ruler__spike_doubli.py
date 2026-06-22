"""Visualization: the tent map and its iterates as an exponentially folding comb.

Generates a figure with (a) tent^[k] for k = 1..4 showing the doubling of spikes,
and (b) the exponential growth of the Lipschitz constant vs depth (log scale).
Requires matplotlib + numpy:  pip install matplotlib numpy
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def tent(x: np.ndarray) -> np.ndarray:
    return 1.0 - np.abs(2.0 * x - 1.0)


def tent_iterate(k: int, x: np.ndarray) -> np.ndarray:
    t = x.copy()
    for _ in range(k):
        t = tent(t)
    return t


def main() -> None:
    fig, axes = plt.subplots(2, 3, figsize=(15, 8))
    xs = np.linspace(0.0, 1.0, 20001)
    for k, ax in zip(range(1, 6), axes.flat):
        ax.plot(xs, tent_iterate(k, xs), lw=0.8, color="#2a6f97")
        ax.axhline(0.5, color="crimson", ls="--", lw=0.7, alpha=0.6)
        ax.set_title(f"tent^[{k}]  ({2**k} spikes, Lipschitz 2^{k}={2**k})")
        ax.set_xlim(0, 1); ax.set_ylim(-0.05, 1.05)
        ax.set_xlabel("x"); ax.set_ylabel("output")

    ax = axes.flat[5]
    ks = np.arange(0, 16)
    ax.semilogy(ks, 2.0 ** ks, "o-", color="#d62828")
    ax.set_title("Lipschitz constant 2^k vs depth k")
    ax.set_xlabel("depth k"); ax.set_ylabel("2^k (log scale)")
    ax.grid(True, which="both", alpha=0.3)

    fig.suptitle("Depth folds the ruler: bounded range, exponential slope",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("tent_depth_separation.png", dpi=150)
    print("wrote tent_depth_separation.png")


if __name__ == "__main__":
    main()
