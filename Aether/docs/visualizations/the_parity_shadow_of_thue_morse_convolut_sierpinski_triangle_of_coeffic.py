"""Render the Sierpinski (Pascal mod 2) pattern that governs t_{m+1}(n) parity."""
from math import comb
import numpy as np
import matplotlib.pyplot as plt


def pascal_mod2(rows: int) -> np.ndarray:
    grid = np.zeros((rows, rows), dtype=int)
    for N in range(rows):
        for r in range(N + 1):
            grid[N, r] = comb(N, r) % 2
    return grid


def main() -> None:
    rows = 128
    grid = pascal_mod2(rows)
    plt.figure(figsize=(6, 6))
    plt.imshow(grid, cmap="binary", interpolation="nearest")
    plt.title("Parity of C(N, r): the Sierpinski triangle\n"
              "(t_{m+1}(n) mod 2 = C(n+m, m) mod 2)")
    plt.xlabel("r = m")
    plt.ylabel("N = n + m")
    plt.tight_layout()
    plt.savefig("sierpinski_parity.png", dpi=150)
    print("saved sierpinski_parity.png")


if __name__ == "__main__":
    main()
