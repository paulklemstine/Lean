"""Heatmap of v2(R_m - 1) laid out on a 28-column grid (period-28 structure)."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def perrin(n_max: int) -> list[int]:
    R = [3, 0, 2]
    for i in range(3, n_max + 1):
        R.append(R[i - 2] + R[i - 3])
    return R


def v2(x: int) -> int:
    x = abs(x); k = 0
    while x % 2 == 0:
        x //= 2; k += 1
    return k


def main() -> None:
    rows = 30
    R = perrin(rows * 28)
    grid = np.zeros((rows, 28))
    for m in range(1, rows * 28):
        grid[m // 28, m % 28] = v2(R[m] - 1)
    plt.figure(figsize=(11, 6))
    plt.imshow(grid, aspect="auto", cmap="viridis")
    plt.colorbar(label=r"$\nu_2(R_m - 1)$")
    plt.xlabel("m mod 28"); plt.ylabel("row = floor(m / 28)")
    plt.title("Period-28 structure: columns 10, 19, 26 are the bright anomalies")
    plt.tight_layout(); plt.savefig("perrin_valuation_heatmap.png", dpi=150)


if __name__ == "__main__":
    main()
