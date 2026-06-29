"""Visualization: a 'divisibility grid' of small primes against Fibonacci indices,
highlighting entry points and the exceptional index n = 12.

Renders a heatmap where cell (p, n) is shaded if p | F_n, with each prime's entry
point marked. Saves to fib_entry_points.png. Requires matplotlib + numpy."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def fib_mod(n: int, p: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, (a + b) % p
    return a


def entry_point(p: int) -> int:
    a, b, k = 0, 1, 1
    while True:
        if b % p == 0:
            return k
        a, b = b, (a + b) % p
        k += 1


def main() -> None:
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    N = 30
    grid = np.zeros((len(primes), N))
    for i, p in enumerate(primes):
        for n in range(1, N + 1):
            grid[i, n - 1] = 1.0 if fib_mod(n, p) == 0 else 0.0

    fig, ax = plt.subplots(figsize=(12, 5))
    ax.imshow(grid, aspect="auto", cmap="Blues",
              extent=[0.5, N + 0.5, len(primes) - 0.5, -0.5])
    for i, p in enumerate(primes):
        e = entry_point(p)
        ax.scatter([e], [i], s=80, facecolors="none", edgecolors="red", linewidths=2)
    ax.axvline(12, color="orange", linestyle="--", linewidth=2, label="n = 12 (exception)")
    ax.set_yticks(range(len(primes)))
    ax.set_yticklabels([f"p={p}" for p in primes])
    ax.set_xticks(range(1, N + 1))
    ax.set_xlabel("Fibonacci index n")
    ax.set_title("p | F_n  (shaded);  red circle = entry point a(p)")
    ax.legend(loc="upper right")
    fig.tight_layout()
    fig.savefig("fib_entry_points.png", dpi=140)
    print("saved fib_entry_points.png")


if __name__ == "__main__":
    main()
