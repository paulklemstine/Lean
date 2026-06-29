"""
Visualization for the Korselt / multiplicative-order bridge.

Produces two figures:
  (A) A heatmap of the order spectrum: for several Carmichael numbers n, the
      distribution of element orders ord(a) in (Z/nZ)^x, all dividing n-1.
  (B) A scatter plot over composites n showing, per prime factor p, whether
      (p-1) | (n-1), highlighting how Carmichael numbers light up entirely.

Requires matplotlib and numpy.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List

import matplotlib.pyplot as plt
import numpy as np


def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def units_mod(n: int) -> List[int]:
    return [a for a in range(1, n) if gcd(a, n) == 1]


def element_order(a: int, n: int) -> int:
    k, cur = 1, a % n
    while cur != 1:
        cur = (cur * a) % n
        k += 1
    return k


def is_korselt(n: int) -> bool:
    f = factorize(n)
    if n <= 1 or f == {n: 1} or any(e > 1 for e in f.values()):
        return False
    return all((n - 1) % (p - 1) == 0 for p in f)


def plot_order_spectrum(numbers: List[int]) -> None:
    fig, axes = plt.subplots(1, len(numbers), figsize=(5 * len(numbers), 4))
    if len(numbers) == 1:
        axes = [axes]
    for ax, n in zip(axes, numbers):
        orders = [element_order(a, n) for a in units_mod(n)]
        # All orders must divide n-1 (the bridge, extended to all units).
        assert all((n - 1) % o == 0 for o in orders)
        ax.hist(orders, bins=range(1, max(orders) + 2), color="#3b6fb6",
                edgecolor="white")
        ax.set_title(f"n = {n} = {'·'.join(map(str, factorize(n)))}\n"
                     f"all orders divide n-1 = {n-1}")
        ax.set_xlabel("ord(a) in (Z/nZ)^x")
        ax.set_ylabel("count")
    fig.suptitle("Order spectrum of Carmichael numbers (every order | n-1)",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("order_spectrum.png", dpi=130)
    print("wrote order_spectrum.png")


def plot_divisibility_grid(limit: int = 2000) -> None:
    xs, ys, cs = [], [], []
    for n in range(3, limit):
        f = factorize(n)
        if f == {n: 1}:  # prime
            continue
        for p in f:
            xs.append(n)
            ys.append((p - 1))
            cs.append(1.0 if (n - 1) % (p - 1) == 0 else 0.0)
    fig, ax = plt.subplots(figsize=(10, 5))
    sc = ax.scatter(xs, ys, c=cs, cmap="coolwarm_r", s=6, alpha=0.6)
    for n in range(3, limit):
        if is_korselt(n):
            ax.axvline(n, color="green", alpha=0.25, lw=0.8)
    ax.set_xlabel("composite n")
    ax.set_ylabel("p - 1  (over prime factors p of n)")
    ax.set_title("Blue: (p-1) | (n-1).  Green verticals: Carmichael numbers "
                 "(all factors blue).")
    fig.colorbar(sc, label="(p-1) | (n-1) ?")
    fig.tight_layout()
    fig.savefig("divisibility_grid.png", dpi=130)
    print("wrote divisibility_grid.png")


if __name__ == "__main__":
    plot_order_spectrum([561, 1105, 1729])
    plot_divisibility_grid(2000)
