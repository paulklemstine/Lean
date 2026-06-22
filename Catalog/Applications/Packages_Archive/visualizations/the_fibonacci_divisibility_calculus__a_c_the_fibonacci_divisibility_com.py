"""Visualize the Fibonacci divisibility lattice as a heatmap.

Cell (m, n) is shaded if F(m) divides F(n). By Theorem 3.3 (for m >= 3) this is
exactly the multiples-of-m pattern, so the picture is a clean comb of vertical
stripes -- the value divisibility lattice is a faithful image of the index one.
"""
from functools import lru_cache

import numpy as np
import matplotlib.pyplot as plt


@lru_cache(maxsize=None)
def fib(n: int) -> int:
    if n < 2:
        return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def main(N: int = 30) -> None:
    grid = np.zeros((N, N), dtype=float)
    for m in range(1, N + 1):
        for n in range(1, N + 1):
            fm = fib(m)
            grid[m - 1, n - 1] = 1.0 if (fm != 0 and fib(n) % fm == 0) else 0.0
    plt.figure(figsize=(8, 8))
    plt.imshow(grid, origin="lower", extent=[1, N, 1, N], cmap="viridis")
    plt.xlabel("n  (value index)")
    plt.ylabel("m  (divisor index)")
    plt.title("F(m) | F(n):  the divisibility comb (Theorem 3.3)")
    plt.colorbar(label="1 = F(m) divides F(n)")
    plt.tight_layout()
    plt.savefig("fib_divisibility_lattice.png", dpi=150)
    print("wrote fib_divisibility_lattice.png")


if __name__ == "__main__":
    main()
