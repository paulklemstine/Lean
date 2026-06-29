"""Visualization: entry points and the law of apparition for Fibonacci numbers.

Produces two panels:
  (left)  a scatter of entry(p) versus prime p, showing the irregular but
          bounded growth of the rank of apparition;
  (right) a divisibility heatmap: cell (m, k) is shaded when m | F(k), whose
          column structure visibly consists of arithmetic progressions of
          period entry(m) -- the law of apparition made visual.

Requires matplotlib and numpy.  Saves 'entry_point_visualization.png'.
"""

from __future__ import annotations

from math import gcd
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_entry(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0 % m, 1 % m
    for k in range(1, m * m + 2):
        a, b = b, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError("unreachable")


def primes_up_to(n: int) -> List[int]:
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel 1: entry(p) vs p
    ps = primes_up_to(120)
    es = [fib_entry(p) for p in ps]
    ax1.scatter(ps, es, c="crimson", s=22)
    ax1.plot(ps, ps, "k--", lw=0.8, label="entry = p")
    ax1.plot(ps, [p + 1 for p in ps], "b:", lw=0.8, label="entry = p+1")
    ax1.set_xlabel("prime p")
    ax1.set_ylabel("entry(p) = rank of apparition")
    ax1.set_title("Fibonacci entry point of primes")
    ax1.legend()

    # Panel 2: divisibility heatmap m | F(k)
    M, K = 24, 40
    grid = np.zeros((M, K))
    for m in range(1, M + 1):
        for k in range(1, K + 1):
            if fib(k) % m == 0:
                grid[m - 1, k - 1] = 1.0
    ax2.imshow(grid, aspect="auto", cmap="Greens", origin="lower",
               extent=(1, K, 1, M))
    ax2.set_xlabel("index k")
    ax2.set_ylabel("modulus m")
    ax2.set_title("m | F(k): periodic columns of period entry(m)")

    fig.suptitle("The entry-point invariant of the Fibonacci sequence", fontsize=13)
    fig.tight_layout()
    fig.savefig("entry_point_visualization.png", dpi=130)
    print("saved entry_point_visualization.png")


if __name__ == "__main__":
    main()
