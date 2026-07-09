"""Visualization: the partition function p(n) = number of conjugacy classes
of S_n, plotted against its Hardy-Ramanujan asymptotic.  Saves a PNG."""
from __future__ import annotations
import math
from typing import List
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def partition_count(n: int) -> int:
    # Euler pentagonal recurrence for p(n).
    p: List[int] = [1] + [0] * n
    for total in range(1, n + 1):
        k, s = 1, 0
        while True:
            g1 = k * (3 * k - 1) // 2
            g2 = k * (3 * k + 1) // 2
            if g1 > total and g2 > total:
                break
            sign = -1 if k % 2 == 0 else 1
            if g1 <= total:
                s += sign * p[total - g1]
            if g2 <= total:
                s += sign * p[total - g2]
            k += 1
        p[total] = s
    return p[n]


def hardy_ramanujan(n: int) -> float:
    return math.exp(math.pi * math.sqrt(2 * n / 3)) / (4 * n * math.sqrt(3))


def main() -> None:
    ns = list(range(1, 41))
    exact = [partition_count(n) for n in ns]
    approx = [hardy_ramanujan(n) for n in ns]
    fig, ax = plt.subplots(figsize=(9, 5.5))
    ax.semilogy(ns, exact, "o-", label="p(n) = #conjugacy classes of $S_n$")
    ax.semilogy(ns, approx, "--", label="Hardy-Ramanujan asymptotic")
    for n in (3, 4, 5):
        ax.annotate(f"$S_{{{n}}}$: {partition_count(n)}",
                    (n, partition_count(n)),
                    textcoords="offset points", xytext=(6, 8))
    ax.set_xlabel("n")
    ax.set_ylabel("number of conjugacy classes of $S_n$  (log scale)")
    ax.set_title("Conjugacy classes of $S_n$ are counted by the partition function")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("partition_growth.png", dpi=150)
    print("saved partition_growth.png")


if __name__ == "__main__":
    main()
