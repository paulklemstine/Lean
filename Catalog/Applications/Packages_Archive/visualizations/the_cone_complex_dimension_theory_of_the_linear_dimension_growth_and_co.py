"""
visualize.py -- Visualizations of the tropical moduli space M_g^trop dimension theory.

Produces two figures:
  1. The linear growth of dim M_g^trop = 3g - 3 and max vertices 2g - 2.
  2. The growth in the number of legal combinatorial types per genus.

Self-contained: enumerates types directly.
"""

from __future__ import annotations

from typing import Iterator

import matplotlib.pyplot as plt


def legal_types(g: int) -> Iterator[tuple[int, int, int, int]]:
    """Yield legal invariant vectors (v0, vp, e, w) of genus g."""
    for v0 in range(0, 2 * g + 1):
        for vp in range(0, 2 * g + 1):
            for e in range(0, 3 * g + 1):
                for w in range(0, g + 1):
                    v = v0 + vp
                    if (g + v == e + 1 + w
                            and 3 * v <= 2 * w + 2 * e
                            and v <= e + 1
                            and vp <= w):
                        yield (v0, vp, e, w)


def main() -> None:
    genera = list(range(2, 11))
    dim = [3 * g - 3 for g in genera]
    maxv = [2 * g - 2 for g in genera]
    counts = [sum(1 for _ in legal_types(g)) for g in genera]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(genera, dim, "o-", label="dim M_g^trop = 3g - 3", color="#c0392b")
    ax1.plot(genera, maxv, "s-", label="max vertices = 2g - 2", color="#2980b9")
    ax1.set_xlabel("genus g")
    ax1.set_ylabel("dimension / vertices")
    ax1.set_title("Dimension theory of M_g^trop")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2.bar(genera, counts, color="#27ae60", alpha=0.8)
    ax2.set_xlabel("genus g")
    ax2.set_ylabel("number of legal combinatorial types")
    ax2.set_title("Finiteness of the cone complex")
    ax2.grid(True, axis="y", alpha=0.3)

    fig.tight_layout()
    fig.savefig("tropical_moduli_dimension.png", dpi=150)
    print("saved tropical_moduli_dimension.png")


if __name__ == "__main__":
    main()
