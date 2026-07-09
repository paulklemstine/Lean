"""
Visualization: the alien odometer and its digit grid.

Renders, side by side:
  (1) a "wheel" diagram of a mixed-radix system showing each position's base, and
  (2) a grid of the factoradic digit lists for n = 0 .. (k+1)!-1, illustrating the
      bijection between Fin(prod bs) and valid digit lists.

Requires matplotlib. Saves 'alien_number_systems.png'.
"""

from __future__ import annotations

from math import prod
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def mdigits(bs: List[int], n: int) -> List[int]:
    out: List[int] = []
    for b in bs:
        out.append(n % b)
        n //= b
    return out


def main() -> None:
    bs = [2, 3, 4, 5]            # factorial base, capacity 5! = 120
    cap = prod(bs)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    # ---- (1) wheel sizes -------------------------------------------------
    ax1.bar(range(len(bs)), bs, color="#4C72B0", edgecolor="black")
    ax1.set_title("Alien odometer: each wheel has its own base")
    ax1.set_xlabel("position i (least significant first)")
    ax1.set_ylabel("base b_i")
    ax1.set_xticks(range(len(bs)))
    ax1.set_xticklabels([f"b{i}={b}" for i, b in enumerate(bs)])
    for i, b in enumerate(bs):
        ax1.text(i, b + 0.05, str(b), ha="center", va="bottom")
    ax1.text(0.5, 0.92, f"capacity = product = {cap} = 5!",
             transform=ax1.transAxes, ha="center", fontsize=11,
             bbox=dict(boxstyle="round", fc="#FFF3CD"))

    # ---- (2) factoradic digit grid --------------------------------------
    grid = np.array([mdigits(bs, n) for n in range(cap)])  # shape (cap, k)
    im = ax2.imshow(grid.T, aspect="auto", cmap="viridis", origin="lower")
    ax2.set_title("Factoradic digits of n = 0 .. 119 (the bijection)")
    ax2.set_xlabel("n")
    ax2.set_ylabel("digit position i")
    ax2.set_yticks(range(len(bs)))
    fig.colorbar(im, ax=ax2, label="digit value d_i")

    fig.tight_layout()
    fig.savefig("alien_number_systems.png", dpi=150)
    print("saved alien_number_systems.png")


if __name__ == "__main__":
    main()
