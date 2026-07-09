"""Visualization: the normalized average depth D_n/n against n, with the
conjectured limiting density lambda = (3/5)(7 - 8 ln 2) drawn as a horizontal
asymptote. Shows the slow sub-linear approach predicted by the tightness
conjecture."""
from __future__ import annotations
from itertools import permutations
from math import log
from typing import List
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


def avg_depth(n: int) -> float:
    ds = [depth(list(p)) for p in permutations(range(1, n + 1))]
    return sum(ds) / len(ds)


if __name__ == "__main__":
    lam = (3 / 5) * (7 - 8 * log(2))
    ns = list(range(2, 9))
    ratios = [avg_depth(n) / n for n in ns]
    plt.figure(figsize=(8, 5))
    plt.plot(ns, ratios, "o-", label="D_n / n (exact enumeration)")
    plt.axhline(lam, color="crimson", ls="--",
                label=f"lambda = (3/5)(7-8 ln2) ~ {lam:.4f}")
    plt.axhline(0.6243299885, color="gray", ls=":",
                label="Golomb-Dickman G ~ 0.6243")
    plt.xlabel("n")
    plt.ylabel("normalized average stack-sorting depth")
    plt.title("Average stack-sorting depth density and Defant's constant")
    plt.legend()
    plt.tight_layout()
    plt.savefig("stacksort_depth_ratio.png", dpi=150)
    print("wrote stacksort_depth_ratio.png")
