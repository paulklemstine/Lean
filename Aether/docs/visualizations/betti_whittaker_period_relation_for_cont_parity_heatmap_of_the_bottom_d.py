"""Visualize the parity of the bottom degree b(n, r1, r2) as a heatmap,
highlighting where the contragredient period sign flips (eps(disc) = -1)."""
from typing import List
import matplotlib.pyplot as plt
import numpy as np

def bottom_degree(n: int, r1: int, r2: int) -> int:
    return r1 * ((n // 2) * ((n + 1) // 2)) + r2 * (n * (n - 1) // 2)

def main() -> None:
    ns: List[int] = list(range(1, 13))
    fields = [("Q", 1, 0), ("real quad", 2, 0), ("Q(i)", 0, 1), ("mixed", 1, 1)]
    grid = np.zeros((len(fields), len(ns)))
    for i, (_, r1, r2) in enumerate(fields):
        for j, n in enumerate(ns):
            grid[i, j] = bottom_degree(n, r1, r2) % 2
    fig, ax = plt.subplots(figsize=(10, 4))
    ax.imshow(grid, aspect="auto", cmap="coolwarm")
    ax.set_xticks(range(len(ns)))
    ax.set_xticklabels([f"GL({n})" for n in ns], rotation=45)
    ax.set_yticks(range(len(fields)))
    ax.set_yticklabels([f"{name} (r1={r1},r2={r2})" for name, r1, r2 in fields])
    ax.set_title("Parity of bottom degree b  (red = odd: period sign flips when eps(disc)=-1)")
    for i in range(len(fields)):
        for j, n in enumerate(ns):
            b = bottom_degree(n, fields[i][1], fields[i][2])
            ax.text(j, i, str(b), ha="center", va="center", fontsize=8)
    plt.tight_layout()
    plt.savefig("bottom_degree_parity.png", dpi=150)
    print("saved bottom_degree_parity.png")

if __name__ == "__main__":
    main()
