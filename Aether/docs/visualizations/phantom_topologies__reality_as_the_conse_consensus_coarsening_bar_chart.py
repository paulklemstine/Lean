"""Visualization 2: consensus coarsens as observers are added.

Bar chart of the number of agreed-open sets versus the number of observers,
demonstrating the order-reversing law of the consensus operation.
"""
from __future__ import annotations

from itertools import chain, combinations
from typing import Callable, FrozenSet, Iterable, List

import matplotlib.pyplot as plt


def powerset(elements: Iterable[int]) -> List[FrozenSet[int]]:
    items = list(elements)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(items, r) for r in range(len(items) + 1))]


def topo(ground: Iterable[int], pred: Callable[[FrozenSet[int]], bool]):
    return frozenset(U for U in powerset(ground) if pred(U))


def main() -> None:
    ground = frozenset({1, 2, 3})
    observers = [
        topo(ground, lambda U: (1 not in U) or (2 in U)),
        topo(ground, lambda U: (2 not in U) or (3 in U)),
        topo(ground, lambda U: (3 not in U) or (1 in U)),
    ]
    counts = []
    running = observers[0]
    for k, t in enumerate(observers, start=1):
        running = running & t if k > 1 else t
        counts.append(len(running))

    fig, ax = plt.subplots(figsize=(7, 4.5))
    xs = list(range(1, len(counts) + 1))
    ax.bar(xs, counts, color="indianred", alpha=0.8)
    for x, c in zip(xs, counts):
        ax.text(x, c + 0.05, str(c), ha="center", fontsize=12)
    ax.axhline(2 ** len(ground), ls="--", color="gray",
               label=f"discrete ({2 ** len(ground)} opens)")
    ax.set_xlabel("number of observers in consensus")
    ax.set_ylabel("number of agreed-open sets")
    ax.set_title("Measurement coarsens: consensus is order-reversing")
    ax.set_xticks(xs)
    ax.legend()
    plt.tight_layout()
    plt.savefig("phantom_coarsening.png", dpi=150)
    print("saved phantom_coarsening.png")


if __name__ == "__main__":
    main()
