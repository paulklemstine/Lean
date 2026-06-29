"""
Visualization: the linear ceiling 2k+1 versus the actual maximum neighbourhood-type
count measured on parallel-chain posets of width k.  Produces 'twinwidth_bound.png'.
"""
from __future__ import annotations

from typing import Callable, List, Sequence

import matplotlib.pyplot as plt

Leq = Callable[[int, int], bool]


def lt(leq: Leq, a: int, b: int) -> bool:
    return a != b and leq(a, b)


def pos_type(leq: Leq, x: int, c: int) -> str:
    if x == c:
        return "Eq"
    if lt(leq, c, x):
        return "Above"
    if lt(leq, x, c):
        return "Below"
    return "Incomp"


def transition_count(seq: Sequence[str]) -> int:
    p = [s for s in seq if s != "Eq"]
    return sum(1 for i in range(len(p) - 1) if p[i] != p[i + 1])


def nbhd_count(leq: Leq, x: int, cover: Sequence[Sequence[int]]) -> int:
    return 1 + sum(transition_count([pos_type(leq, x, c) for c in ch]) for ch in cover)


def parallel(k: int, length: int):
    elements = list(range(k * length))

    def leq(a: int, b: int) -> bool:
        ca, pa = divmod(a, length)
        cb, pb = divmod(b, length)
        return ca == cb and pa <= pb

    cover = [[c * length + p for p in range(length)] for c in range(k)]
    return elements, leq, cover


def main() -> None:
    ks: List[int] = list(range(1, 11))
    bound = [2 * k + 1 for k in ks]
    actual: List[int] = []
    for k in ks:
        elements, leq, cover = parallel(k, length=9)
        actual.append(max(nbhd_count(leq, x, cover) for x in elements))

    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.plot(ks, bound, "o-", label="2k+1 ceiling (nbhdTypeCount_le)")
    ax.plot(ks, actual, "s--", label="measured max neighbourhood-type count")
    ax.fill_between(ks, actual, bound, alpha=0.1)
    ax.set_xlabel("width k (number of chains)")
    ax.set_ylabel("red neighbourhood types per element")
    ax.set_title("Linear ceiling on red neighbourhood types of bounded-width posets")
    ax.legend()
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("twinwidth_bound.png", dpi=150)
    print("wrote twinwidth_bound.png")


if __name__ == "__main__":
    main()
