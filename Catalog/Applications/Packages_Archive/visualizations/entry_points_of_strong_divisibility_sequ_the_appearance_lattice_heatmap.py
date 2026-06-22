"""
Appearance Lattice Heatmap for Strong Divisibility Sequences
============================================================

Visualizes the divisibility bridge  p | a(n) <=> z(p) | n  as a heatmap:
rows are small primes, columns are indices n, a cell is lit when p | a(n).
The first lit cell in each row is the entry point z(p) (primitive divisor),
outlined in gold; the periodic lit cells thereafter are exactly the multiples
of z(p), making the arithmetic-progression structure visually obvious.

Requires: matplotlib, numpy.  Run:  python3 _viz_heatmap.py
"""
from __future__ import annotations
from math import gcd
from typing import Callable, List
import numpy as np
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne2(n: int) -> int:
    return 2 ** n - 1


def entry_point(a: Callable[[int], int], p: int, limit: int) -> int:
    for k in range(1, limit + 1):
        if a(k) % p == 0:
            return k
    return 0


def build_matrix(a: Callable[[int], int], primes: List[int], N: int) -> np.ndarray:
    M = np.zeros((len(primes), N), dtype=float)
    for i, p in enumerate(primes):
        for n in range(1, N + 1):
            M[i, n - 1] = 1.0 if a(n) % p == 0 else 0.0
    return M


def plot(a: Callable[[int], int], primes: List[int], N: int, title: str, ax) -> None:
    M = build_matrix(a, primes, N)
    ax.imshow(M, aspect="auto", cmap="GnBu", interpolation="nearest")
    for i, p in enumerate(primes):
        z = entry_point(a, p, N)
        if z:
            ax.add_patch(plt.Rectangle((z - 1.5, i - 0.5), 1, 1,
                         fill=False, edgecolor="gold", lw=2.2))
    ax.set_yticks(range(len(primes)))
    ax.set_yticklabels([f"p={p} (z={entry_point(a,p,N)})" for p in primes])
    ax.set_xlabel("index n")
    ax.set_title(title)


def main() -> None:
    fig, axes = plt.subplots(2, 1, figsize=(12, 7))
    plot(fib, [2, 3, 5, 7, 11, 13, 17], 60, "Fibonacci F(n): p | F(n) (gold = entry point)", axes[0])
    plot(mersenne2, [3, 5, 7, 11, 13, 17, 31], 60,
         "Mersenne 2^n - 1: p | 2^n - 1 (gold = entry point)", axes[1])
    fig.suptitle("The appearance lattice: divisibility is periodic with period z(p)", fontsize=13)
    fig.tight_layout()
    fig.savefig("appearance_lattice.png", dpi=130)
    print("Saved appearance_lattice.png")


if __name__ == "__main__":
    main()
