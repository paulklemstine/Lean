"""
Visualization: the flat single-cell symbol histogram of Latin squares.

For order n in {3, 4, 5} we enumerate all Latin squares and, for the corner cell
(0, 0), plot how many squares carry each symbol there. The exact one-cell
uniformity theorem predicts every bar has height N/n, i.e. a perfectly flat
histogram. The predicted level N/n is overlaid as a dashed line.
"""

from __future__ import annotations

from itertools import permutations
from typing import List, Tuple

import matplotlib.pyplot as plt

Square = Tuple[Tuple[int, ...], ...]


def enumerate_latin_squares(n: int) -> List[Square]:
    rows_all: List[Tuple[int, ...]] = list(permutations(range(n)))
    result: List[Square] = []
    current: List[Tuple[int, ...]] = []

    def compatible(row: Tuple[int, ...]) -> bool:
        return all(placed[c] != row[c] for placed in current for c in range(n))

    def backtrack(depth: int) -> None:
        if depth == n:
            result.append(tuple(current))
            return
        for row in rows_all:
            if compatible(row):
                current.append(row)
                backtrack(depth + 1)
                current.pop()

    backtrack(0)
    return result


def main() -> None:
    orders = [3, 4, 5]
    fig, axes = plt.subplots(1, len(orders), figsize=(13, 4))
    for ax, n in zip(axes, orders):
        squares = enumerate_latin_squares(n)
        N = len(squares)
        counts = [sum(1 for L in squares if L[0][0] == s) for s in range(n)]
        ax.bar(range(n), counts, color="#3b7dd8", edgecolor="black")
        ax.axhline(N / n, color="crimson", linestyle="--",
                   label=f"N/n = {N}/{n} = {N // n}")
        ax.set_title(f"order n = {n}  (N = {N})")
        ax.set_xlabel("symbol in cell (0,0)")
        ax.set_ylabel("number of Latin squares")
        ax.set_xticks(range(n))
        ax.legend()
    fig.suptitle("Exact one-cell uniformity: each symbol occupies the corner "
                 "in exactly N/n squares", fontsize=12)
    fig.tight_layout()
    fig.savefig("one_cell_uniformity.png", dpi=130)
    print("saved one_cell_uniformity.png")


if __name__ == "__main__":
    main()
