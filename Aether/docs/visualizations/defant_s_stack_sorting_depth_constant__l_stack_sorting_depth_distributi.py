"""Visualization: stacked depth histograms of S_n for n = 3..7, showing how the
mass of permutations spreads across increasing stack-sorting depths."""
from __future__ import annotations
from itertools import permutations
from typing import Dict, List
import matplotlib.pyplot as plt


def stack_sort(seq: List[int]) -> List[int]:
    stack: List[int] = []
    out: List[int] = []
    for x in seq:
        i = 0
        while i < len(stack) and stack[i] < x:
            i += 1
        out.extend(stack[:i])
        stack = [x] + stack[i:]
    out.extend(stack)
    return out


def depth(seq: List[int]) -> int:
    target, cur, c = sorted(seq), list(seq), 0
    for _ in range(len(seq) + 1):
        if cur == target:
            return c
        cur, c = stack_sort(cur), c + 1
    return c


if __name__ == "__main__":
    fig, ax = plt.subplots(figsize=(9, 5))
    for n in range(3, 8):
        counts: Dict[int, int] = {}
        for p in permutations(range(1, n + 1)):
            d = depth(list(p))
            counts[d] = counts.get(d, 0) + 1
        ts = sorted(counts)
        ax.plot(ts, [counts[t] for t in ts], "o-", label=f"n={n}")
    ax.set_xlabel("stack-sorting depth t")
    ax.set_ylabel("number of permutations")
    ax.set_yscale("log")
    ax.set_title("Depth distribution of S_n")
    ax.legend()
    fig.tight_layout()
    fig.savefig("stacksort_histogram.png", dpi=150)
    print("wrote stacksort_histogram.png")
