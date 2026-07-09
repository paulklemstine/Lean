"""Visualization: T_0(A,B,C0) as a heatmap over pairs (A,B) for a fixed C0,
showing the diagonal structure induced on a sunflower-free family."""
from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List
import matplotlib.pyplot as plt
import numpy as np

Set = FrozenSet[int]


def coord_factor(a: int, b: int, c: int) -> int:
    return (1 - (a * b + b * c + c * a)) % 3


def T0(a: Set, b: Set, c: Set, n: int) -> int:
    v = 1
    for i in range(n):
        v = (v * coord_factor(int(i in a), int(i in b), int(i in c))) % 3
    return v


def is_sunflower(a: Set, b: Set, c: Set) -> bool:
    if a == b or a == c or b == c:
        return False
    return (a & b) == (a & c) == (b & c)


def greedy_family(n: int, k: int) -> List[Set]:
    fam: List[Set] = []
    for combo in combinations(range(n), k):
        s = frozenset(combo)
        if not any(is_sunflower(x, y, s) for x, y in combinations(fam, 2)):
            fam.append(s)
    return fam


def main() -> None:
    n, k = 6, 3
    fam = greedy_family(n, k)
    m = len(fam)
    # Fix C = the first family member; show T0(A,B,C) as A,B range over the family.
    c0 = fam[0]
    grid = np.array([[T0(fam[i], fam[j], c0, n) for j in range(m)] for i in range(m)])

    fig, ax = plt.subplots(figsize=(6, 5))
    im = ax.imshow(grid, cmap="viridis")
    ax.set_title(f"T_0(A,B,C0) over a sunflower-free family (n={n}, k={k})")
    ax.set_xlabel("index of B")
    ax.set_ylabel("index of A")
    fig.colorbar(im, ax=ax, label="value in F_3")
    fig.tight_layout()
    fig.savefig("tensor_heatmap.png", dpi=150)
    print("wrote tensor_heatmap.png; family size", m)


if __name__ == "__main__":
    main()
