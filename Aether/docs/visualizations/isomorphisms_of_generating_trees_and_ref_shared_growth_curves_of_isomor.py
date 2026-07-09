"""Visualization: counting-sequence growth of two isomorphic generating trees.

Plots the level counts of two differently-labelled but intertwined trees on a
log scale, showing that the two curves coincide exactly (Equal-counts theorem).
"""

from __future__ import annotations

from typing import Callable
import matplotlib.pyplot as plt


def level_count(succ: Callable[[int], list[int]], root: int, k: int) -> int:
    level = [root]
    for _ in range(k):
        nxt: list[int] = []
        for a in level:
            nxt.extend(succ(a))
        level = nxt
    return len(level)


def succ1(a: int) -> list[int]:
    return list(range(2, a + 2))


def succ2(b: int) -> list[int]:
    return list(range(101, b + 2))


def main() -> None:
    depths = list(range(9))
    c1 = [level_count(succ1, 1, k) for k in depths]
    c2 = [level_count(succ2, 100, k) for k in depths]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(depths, c1, "o-", label="tree 1 (labels a >= 1)", linewidth=2)
    ax.semilogy(depths, c2, "s--", label="tree 2 (labels b >= 100)", linewidth=2)
    ax.set_xlabel("depth k")
    ax.set_ylabel("number of nodes  c_k  (log scale)")
    ax.set_title("Isomorphic generating trees share a counting sequence")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("growth.png", dpi=150)
    print("wrote growth.png; counts:", c1)


if __name__ == "__main__":
    main()
