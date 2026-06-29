"""
Visualization: the provability staircase of NatGL.

Renders the membership matrix M[k, m] = 1 iff  m ∈ natBox^k(∅) = Iio k,
producing the lower-triangular 'staircase' that is the geometric signature of
the theorem  □^k(∅) = {0, 1, ..., k-1}.  Each new iteration of the provability
box admits exactly one more world, and no row ever fills completely -- the
visual form of 'a strictly increasing chain of consistency strengths that never
reaches ⊤'.
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np


def nat_box(s: frozenset[int], n: int) -> frozenset[int]:
    return frozenset(m for m in range(n) if all(j in s for j in range(m)))


def iterate_membership(n: int) -> np.ndarray:
    """Row k = indicator of natBox^k(∅) over worlds {0,...,n-1}."""
    rows: List[List[int]] = []
    cur: frozenset[int] = frozenset()
    for _ in range(n + 1):
        rows.append([1 if m in cur else 0 for m in range(n)])
        cur = nat_box(cur, n)
    return np.array(rows)


def main() -> None:
    n = 14
    mat = iterate_membership(n)

    fig, ax = plt.subplots(figsize=(8, 7))
    ax.imshow(mat, cmap="Blues", aspect="auto")
    ax.set_xlabel("world  m")
    ax.set_ylabel("iteration  k   (□^k ⊥)")
    ax.set_title("Provability staircase:  □^k(∅) = {0,…,k−1}")
    ax.set_xticks(range(n))
    ax.set_yticks(range(n + 1))
    # grid lines
    ax.set_xticks(np.arange(-0.5, n, 1), minor=True)
    ax.set_yticks(np.arange(-0.5, n + 1, 1), minor=True)
    ax.grid(which="minor", color="white", linewidth=1.0)
    fig.tight_layout()
    fig.savefig("provability_staircase.png", dpi=150)
    print("wrote provability_staircase.png")


if __name__ == "__main__":
    main()
