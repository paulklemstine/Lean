"""Visualisation: the gainability threshold q <= n across moduli and class counts.

Produces a heatmap whose (n, q) cell is shaded by whether a parallel class with q
balance classes is Z/n-gainable (q <= n), overlaid with the (n+1)K2 minor boundary
q = n+1. Requires matplotlib and numpy.
"""
from typing import Tuple
import numpy as np
import matplotlib.pyplot as plt

def gainability_grid(max_n: int = 12, max_q: int = 14) -> Tuple[np.ndarray, np.ndarray]:
    ns = np.arange(2, max_n + 1)
    qs = np.arange(1, max_q + 1)
    grid = np.zeros((len(qs), len(ns)), dtype=float)
    for i, q in enumerate(qs):
        for j, n in enumerate(ns):
            grid[i, j] = 1.0 if q <= n else 0.0  # digon_gainable_iff_card
    return grid, ns

def main() -> None:
    grid, ns = gainability_grid()
    qs = np.arange(1, grid.shape[0] + 1)
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.imshow(grid, origin="lower", aspect="auto", cmap="Greens",
              extent=[ns[0] - 0.5, ns[-1] + 0.5, qs[0] - 0.5, qs[-1] + 0.5])
    # (n+1)K2 minor boundary: q = n+1
    ax.plot(ns, ns + 1, "r--", lw=2, label="(n+1)K2 minor boundary  q = n+1")
    ax.set_xlabel("modulus n  (gain group Z/n)")
    ax.set_ylabel("number of balance classes q")
    ax.set_title("Parallel-class gainability: green = gainable (q <= n)")
    ax.legend(loc="upper left")
    fig.tight_layout()
    fig.savefig("gainability_threshold.png", dpi=150)
    print("wrote gainability_threshold.png")

if __name__ == "__main__":
    main()
