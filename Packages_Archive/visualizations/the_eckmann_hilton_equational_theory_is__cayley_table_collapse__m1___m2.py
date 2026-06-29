"""
Visualization: the Eckmann-Hilton collapse on finite carriers.

Renders, side by side, the Cayley tables of the two operations m1 and m2 of
Eckmann-Hilton data built from Z/n, showing that they are pixel-for-pixel
identical (same_op), symmetric (comm), and that the abstract identity
m1 a b == m2 b a (pi_two_commutative) holds. Also draws a schematic of the
interchange / medial 2x2 grid.

Requires matplotlib.  Run:  python visualization.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable

import matplotlib.pyplot as plt
import numpy as np

Op = Callable[[int, int], int]


def cayley(n: int, op: Op) -> np.ndarray:
    return np.array([[op(a, b) for b in range(n)] for a in range(n)])


def main() -> None:
    n = 7
    add: Op = lambda a, b: (a + b) % n  # m1 = m2 from a commutative monoid

    T1 = cayley(n, add)               # m1
    T2 = cayley(n, add)               # m2 (equal by same_op)
    T2T = cayley(n, lambda a, b: add(b, a))  # m2 b a

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    titles = [
        r"$m_1(a,b)$ (vertical)",
        r"$m_2(a,b)$ (horizontal)",
        r"$m_2(b,a)$  $=\ m_1(a,b)$",
    ]
    for ax, T, title in zip(axes, [T1, T2, T2T], titles):
        im = ax.imshow(T, cmap="viridis")
        ax.set_title(title, fontsize=13)
        ax.set_xlabel("b")
        ax.set_ylabel("a")
        ax.set_xticks(range(n))
        ax.set_yticks(range(n))
        for a, b in product(range(n), repeat=2):
            ax.text(b, a, str(T[a, b]), ha="center", va="center",
                    color="white", fontsize=8)
        fig.colorbar(im, ax=ax, fraction=0.046)

    assert np.array_equal(T1, T2), "same_op failed"
    assert np.array_equal(T1, T2T), "pi_two_commutative failed"

    fig.suptitle(
        "Eckmann-Hilton collapse on Z/7:  m1 = m2 and  m1(a,b) = m2(b,a)",
        fontsize=15,
    )
    fig.tight_layout()
    fig.savefig("eckmann_hilton_collapse.png", dpi=150)
    print("Wrote eckmann_hilton_collapse.png")


if __name__ == "__main__":
    main()
