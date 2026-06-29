"""
Visualization: the appearance lattice of the Fibonacci rank of apparition.

Produces two panels:
  (left)  a heatmap of divisibility  [ m | F(k) ]  over a grid of moduli m and
          indices k, exposing the perfectly periodic columns of period entry(m)
          predicted by the law of apparition;
  (right) a scatter of entry(m) vs m with the join-law decomposition
          entry(m) = lcm over prime powers highlighted.

Requires: matplotlib, numpy.  Run:  python visualization.py
"""
from __future__ import annotations
from math import gcd, lcm
from typing import Dict, Optional
import numpy as np
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def entry_point(m: int, limit: int = 4000) -> Optional[int]:
    if m == 0:
        return None
    for k in range(1, limit + 1):
        if fib(k) % m == 0:
            return k
    return None


def factorize(n: int) -> Dict[int, int]:
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def main() -> None:
    M, K = 24, 48
    grid = np.zeros((M, K))
    for m in range(1, M + 1):
        for k in range(1, K + 1):
            grid[m - 1, k - 1] = 1.0 if fib(k) % m == 0 else 0.0

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    ax1.imshow(grid, aspect="auto", origin="lower",
               extent=[1, K, 1, M], cmap="Blues")
    ax1.set_title("Divisibility heatmap:  m | F(k)\n(periodic columns of period entry(m))")
    ax1.set_xlabel("index k")
    ax1.set_ylabel("modulus m")

    ms = list(range(2, 41))
    es = [entry_point(m) for m in ms]
    composite = [m for m in ms if len(factorize(m)) > 1]
    ax2.plot(ms, es, "o-", color="#888", label="entry(m)")
    ax2.scatter(composite, [entry_point(m) for m in composite],
                color="crimson", zorder=5,
                label="composite m: entry = lcm of prime-power entries")
    ax2.set_title("Rank of apparition entry(m)\nand its join-law decomposition")
    ax2.set_xlabel("modulus m")
    ax2.set_ylabel("entry(m)")
    ax2.legend()

    plt.tight_layout()
    plt.savefig("rank_of_apparition.png", dpi=150)
    print("Saved rank_of_apparition.png")


if __name__ == "__main__":
    main()
