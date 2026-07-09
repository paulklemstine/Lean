"""Visualization: the tight ceiling-logarithm complexity of binary search.

Plots, for every interval gap g, the worst-case number of bisection steps
against clog2(g) = ceil(log2 g) and against the (failing) floor logarithm,
illustrating that the worst case equals the ceiling logarithm exactly.
Requires matplotlib. Run: python visualization_complexity.py
"""
from __future__ import annotations
import math
from typing import Callable, List
import matplotlib.pyplot as plt


def clog2(g: int) -> int:
    if g <= 1:
        return 0
    return clog2((g + 1) // 2) + 1


def bsearch_steps(p: Callable[[int], bool], lo: int, hi: int) -> int:
    steps = 0
    while lo + 1 < hi:
        mid = (lo + hi) // 2
        steps += 1
        if p(mid):
            hi = mid
        else:
            lo = mid
    return steps


def worst_steps(g: int) -> int:
    best = 0
    for t in range(1, g + 1):
        p = lambda i, t=t: i >= t
        best = max(best, bsearch_steps(p, 0, g))
    return best


def main() -> None:
    gaps: List[int] = list(range(1, 65))
    worst = [worst_steps(g) for g in gaps]
    ceil_log = [clog2(g) for g in gaps]
    floor_log = [math.floor(math.log2(g)) for g in gaps]

    plt.figure(figsize=(10, 6))
    plt.step(gaps, ceil_log, where="post", label="clog2(g) = ceil(log2 g)  (proved bound)", linewidth=2)
    plt.plot(gaps, worst, "o", markersize=4, label="worst-case bisection steps")
    plt.step(gaps, floor_log, where="post", linestyle="--",
             label="floor(log2 g)  (fails as upper bound)")
    plt.xlabel("interval gap  g = hi - lo")
    plt.ylabel("number of comparisons")
    plt.title("Binary search worst case equals the ceiling logarithm (tight)")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("binary_search_complexity.png", dpi=150)
    print("Saved binary_search_complexity.png")


if __name__ == "__main__":
    main()
