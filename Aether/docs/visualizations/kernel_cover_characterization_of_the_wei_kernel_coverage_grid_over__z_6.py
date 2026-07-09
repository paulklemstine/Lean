"""Visualize which points of (Z/m)^2 are covered by kernels as the weight
set grows, for the multiplication weight sets over Z/m."""
from itertools import product
import matplotlib.pyplot as plt

def covered(x, m, weights):
    allowed = [0] + list(weights)
    choices = [c for c in product(allowed, repeat=len(x)) if any(ci != 0 for ci in c)]
    return any(sum(ci * xi for ci, xi in zip(c, x)) % m == 0 for c in choices)

m = 6
weight_sets = [[1], [1, 5], [1, 2, 3, 4, 5]]
fig, axes = plt.subplots(1, len(weight_sets), figsize=(12, 4))
for ax, W in zip(axes, weight_sets):
    grid = [[1 if covered((a, b), m, W) else 0 for b in range(m)] for a in range(m)]
    ax.imshow(grid, cmap="Greens", vmin=0, vmax=1, origin="lower")
    ax.set_title(f"weights {set(W)}\ncovered fraction "
                 f"{sum(sum(r) for r in grid)}/{m*m}")
    ax.set_xlabel("second coordinate"); ax.set_ylabel("first coordinate")
fig.suptitle("Kernel coverage of (Z/6)^2 as the weight set enlarges")
plt.tight_layout(); plt.savefig("coverage_grid.png", dpi=150)
print("wrote coverage_grid.png")
