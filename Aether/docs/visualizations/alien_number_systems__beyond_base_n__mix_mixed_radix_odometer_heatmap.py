"""Visualize the crowning bijection: residues <-> valid digit lists.

Renders, for a chosen alien base list, every integer 0..capacity-1 as a column
of its mixed-radix digits, producing an odometer-style heatmap that shows the
carry structure of a variable-base system. Requires matplotlib + numpy.
"""
from typing import List
import numpy as np
import matplotlib.pyplot as plt


def mdigits(bases: List[int], n: int) -> List[int]:
    out: List[int] = []
    for b in bases:
        out.append(n % b)
        n //= b
    return out


def main() -> None:
    bases = [2, 3, 4, 5]  # factorial bases, capacity 120 = 5!
    cap = 1
    for b in bases:
        cap *= b
    grid = np.array([mdigits(bases, n) for n in range(cap)]).T  # rows = positions
    fig, ax = plt.subplots(figsize=(12, 3))
    im = ax.imshow(grid, aspect="auto", cmap="viridis", interpolation="nearest")
    ax.set_yticks(range(len(bases)))
    ax.set_yticklabels([f"pos {i} (base {b})" for i, b in enumerate(bases)])
    ax.set_xlabel("integer n  (0 .. capacity-1)")
    ax.set_title(f"Mixed-radix odometer for bases {bases}  (capacity {cap} = 5!)")
    fig.colorbar(im, ax=ax, label="digit value")
    fig.tight_layout()
    fig.savefig("alien_odometer.png", dpi=150)
    print("wrote alien_odometer.png")


if __name__ == "__main__":
    main()
