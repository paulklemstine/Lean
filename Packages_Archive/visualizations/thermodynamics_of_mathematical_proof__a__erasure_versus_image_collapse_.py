"""Visualization: erasure vs image-collapse for a step on a fixed register.

Plots the bits erased by a step on a 2**n-state register as a function of how
many distinct outputs (image size) it retains, illustrating erased = n - log2(k).
"""

from __future__ import annotations

from math import log2

import matplotlib.pyplot as plt


def erased(n_bits: int, image_size: int) -> float:
    return n_bits - log2(image_size)


def main() -> None:
    n_bits = 8
    domain = 2 ** n_bits
    ks = list(range(1, domain + 1))
    ys = [erased(n_bits, k) for k in ks]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ks, ys, color="crimson", lw=2)
    ax.fill_between(ks, ys, alpha=0.15, color="crimson")
    ax.axhline(0.0, color="black", lw=0.8)
    ax.set_xscale("log", base=2)
    ax.set_xlabel("distinct outputs retained  |image f|")
    ax.set_ylabel("bits erased")
    ax.set_title(f"Erasure of a step on a {domain}-state register (n = {n_bits})")
    ax.annotate("injective: 0 erased", xy=(domain, 0), xytext=(domain / 8, 1.5),
                arrowprops=dict(arrowstyle="->"))
    ax.annotate("constant: n erased", xy=(1, n_bits), xytext=(4, n_bits - 2),
                arrowprops=dict(arrowstyle="->"))
    fig.tight_layout()
    fig.savefig("erasure_vs_image.png", dpi=150)
    print("wrote erasure_vs_image.png")


if __name__ == "__main__":
    main()
