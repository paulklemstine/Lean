"""Visualization: residue heat map of P-positions across granularities.

For each granularity m on the vertical axis and position r on the horizontal
axis, mark whether r is a misere P-position, revealing the family of parallel
diagonal stripes r ≡ 1 (mod m+1). Requires matplotlib."""
import matplotlib.pyplot as plt
import numpy as np


def main():
    R, M = 40, 10
    grid = np.zeros((M, R + 1))
    for m in range(1, M + 1):
        for r in range(R + 1):
            grid[m - 1, r] = 1 if r % (m + 1) == 1 else 0
    plt.figure(figsize=(12, 5))
    plt.imshow(grid, aspect="auto", cmap="magma", origin="lower",
               extent=[0, R, 1, M])
    plt.xlabel("position r")
    plt.ylabel("granularity m")
    plt.title("Misere P-positions: r ≡ 1 (mod m+1)")
    plt.colorbar(label="P-position (1) / N-position (0)")
    plt.savefig("escalation_heatmap.png", dpi=120, bbox_inches="tight")
    print("saved escalation_heatmap.png")


if __name__ == "__main__":
    main()
