"""Visualizations for *Stack-Sorting Depth*.

Generates two figures:
  1. ``depth_distribution.png`` -- the depth distribution of permutations of
     [1..n] for n = 3..7 as grouped bars (the "spectrum of difficulty").
  2. ``average_depth.png`` -- the average depth A(n) and the scaled value
     A(n)/n, illustrating the conjectured linear growth A(n) ~ (3/4) n.

Run with:  ``python3 visualize.py``  (requires matplotlib).
"""

from __future__ import annotations

from itertools import permutations
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def stack_sort(l: List[int]) -> List[int]:
    """One pass of West's stack-sorting map (stack head = top)."""
    out: List[int] = []
    s: List[int] = []
    for x in l:
        while s and s[0] < x:
            out.append(s.pop(0))
        s = [x] + s
    out.extend(s)
    return out


def depth(l: List[int]) -> int:
    cur, target, steps = list(l), sorted(l), 0
    while cur != target:
        cur = stack_sort(cur)
        steps += 1
    return steps


def distribution(n: int) -> Dict[int, int]:
    counts: Dict[int, int] = {}
    for p in permutations(range(1, n + 1)):
        d = depth(list(p))
        counts[d] = counts.get(d, 0) + 1
    return counts


def average_depth(n: int) -> float:
    ds = [depth(list(p)) for p in permutations(range(1, n + 1))]
    return sum(ds) / len(ds)


def plot_distributions(ns: List[int], path: str = "depth_distribution.png") -> None:
    fig, ax = plt.subplots(figsize=(9, 5))
    max_d = max(max(distribution(n)) for n in ns)
    width = 0.8 / len(ns)
    for i, n in enumerate(ns):
        dist = distribution(n)
        xs = list(range(max_d + 1))
        ys = [dist.get(t, 0) for t in xs]
        offs = [t + (i - len(ns) / 2) * width + width / 2 for t in xs]
        ax.bar(offs, ys, width=width, label=f"n = {n}")
    ax.set_xlabel("stack-sorting depth t")
    ax.set_ylabel("number of permutations")
    ax.set_title("Depth distribution of permutations of [1..n]")
    ax.set_xticks(list(range(max_d + 1)))
    ax.legend()
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    print(f"wrote {path}")


def plot_average(ns: List[int], path: str = "average_depth.png") -> None:
    avgs: List[Tuple[int, float]] = [(n, average_depth(n)) for n in ns]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))
    ax1.plot([n for n, _ in avgs], [a for _, a in avgs], "o-", color="tab:blue")
    ax1.set_xlabel("n")
    ax1.set_ylabel("A(n)")
    ax1.set_title("Average stack-sorting depth A(n)")
    ax2.plot([n for n, _ in avgs], [a / n for n, a in avgs], "s-",
             color="tab:green", label="A(n)/n")
    ax2.axhline(0.75, ls="--", color="tab:red", label="conjectured limit 3/4")
    ax2.set_xlabel("n")
    ax2.set_ylabel("A(n)/n")
    ax2.set_ylim(0, 0.8)
    ax2.set_title("Scaled average A(n)/n")
    ax2.legend()
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    print(f"wrote {path}")


if __name__ == "__main__":
    plot_distributions([3, 4, 5, 6, 7])
    plot_average([2, 3, 4, 5, 6, 7, 8])
