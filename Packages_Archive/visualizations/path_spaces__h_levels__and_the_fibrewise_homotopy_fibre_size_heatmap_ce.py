"""Visualization: fiber-size heatmap certifying the fibrewise equivalence
criterion (Theorem 5.1).  For a sweep of candidate maps f : Z_n -> Z_n we plot,
for each target b, the size |HFiber f b|.  A row that is all-ones (every fiber a
singleton => contractible) certifies a bijection; any 0 or >=2 entry exhibits a
non-equivalence."""
from typing import Callable, List
import numpy as np
import matplotlib.pyplot as plt


def fiber_sizes(f: Callable[[int], int], n: int) -> List[int]:
    return [sum(1 for a in range(n) if f(a) == b) for b in range(n)]


def main() -> None:
    n = 6
    maps = {
        "identity (equiv)":      lambda a: a,
        "shift +1 (equiv)":      lambda a: (a + 1) % n,
        "double mod n":          lambda a: (2 * a) % n,
        "square mod n":          lambda a: (a * a) % n,
        "constant 0":            lambda a: 0,
    }
    grid = np.array([fiber_sizes(f, n) for f in maps.values()])
    fig, ax = plt.subplots(figsize=(7, 3.5))
    im = ax.imshow(grid, cmap="viridis", vmin=0, vmax=grid.max())
    ax.set_xticks(range(n)); ax.set_xticklabels([f"b={b}" for b in range(n)])
    ax.set_yticks(range(len(maps))); ax.set_yticklabels(list(maps.keys()))
    for i in range(grid.shape[0]):
        for j in range(grid.shape[1]):
            ax.text(j, i, str(grid[i, j]), ha="center", va="center",
                    color="white" if grid[i, j] < grid.max()/2 else "black")
    ax.set_title("|HFiber f b|  (all 1s  =>  bijection,  by Theorem 5.1)")
    fig.colorbar(im, label="fiber size")
    fig.tight_layout()
    fig.savefig("fiber_heatmap.png", dpi=130)
    print("wrote fiber_heatmap.png")


if __name__ == "__main__":
    main()
