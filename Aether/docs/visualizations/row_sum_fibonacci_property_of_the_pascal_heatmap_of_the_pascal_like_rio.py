"""Visualization: the Pascal-like Riordan array and its Fibonacci row sums.

Renders a heatmap of the array t[n,k] = C(n+k, 2k) with each row annotated by
its row sum, which equals the odd-indexed Fibonacci number fib(2n+1).
Requires matplotlib and numpy.
"""

from math import comb

import matplotlib.pyplot as plt
import numpy as np


def fib(m: int) -> int:
    a, b = 0, 1
    for _ in range(m):
        a, b = b, a + b
    return a


def plot_riordan_array(n_max: int = 9) -> None:
    grid = np.full((n_max + 1, n_max + 1), np.nan)
    for n in range(n_max + 1):
        for k in range(n + 1):
            grid[n, k] = comb(n + k, 2 * k)

    fig, ax = plt.subplots(figsize=(9, 7))
    masked = np.ma.masked_invalid(grid)
    im = ax.imshow(np.log1p(masked), cmap="viridis", origin="upper")

    for n in range(n_max + 1):
        for k in range(n + 1):
            ax.text(k, n, str(int(grid[n, k])), ha="center", va="center",
                    color="white", fontsize=8)
        rs = sum(comb(n + k, 2 * k) for k in range(n + 1))
        ax.text(n_max + 0.7, n, f"= {rs} = fib({2*n+1})",
                ha="left", va="center", fontsize=9, color="black")

    ax.set_title("Riordan array  t[n,k] = C(n+k, 2k)\n"
                 "row sums are odd-indexed Fibonacci numbers fib(2n+1)")
    ax.set_xlabel("column k")
    ax.set_ylabel("row n")
    ax.set_xlim(-0.5, n_max + 4)
    fig.colorbar(im, ax=ax, label="log(1 + entry)")
    plt.tight_layout()
    plt.savefig("riordan_array_heatmap.png", dpi=150)
    print("saved riordan_array_heatmap.png")


if __name__ == "__main__":
    plot_riordan_array()
