"""Visualize the search dimension D(b,k)=log(k)/log(b) as a heatmap and
the subcritical decay of the success fraction (k/b)^d. Requires matplotlib."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

def search_dimension(b: int, k: int) -> float:
    return math.log(k) / math.log(b)

# Heatmap of D over (b, k)
bs = list(range(2, 21))
grid = np.full((20, len(bs)), np.nan)
for j, b in enumerate(bs):
    for k in range(1, b + 1):
        grid[k - 1, j] = search_dimension(b, k)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
im = ax1.imshow(grid, origin="lower", aspect="auto",
                extent=[2, 20, 1, 20], cmap="viridis")
ax1.set_xlabel("branching factor b")
ax1.set_ylabel("survivors k")
ax1.set_title("Search dimension D(b,k) = log(k)/log(b)")
fig.colorbar(im, ax=ax1, label="D")

# Subcritical decay curves
ds = np.arange(0, 16)
for (b, k) in [(5, 2), (5, 3), (5, 4), (10, 7)]:
    frac = (k / b) ** ds
    ax2.semilogy(ds, frac, marker="o",
                 label=f"b={b}, k={k}, D={search_dimension(b,k):.2f}")
ax2.set_xlabel("search depth d")
ax2.set_ylabel("success fraction (k/b)^d  (log scale)")
ax2.set_title("Subcritical exponential decay")
ax2.legend()
ax2.grid(True, which="both", alpha=0.3)

plt.tight_layout()
plt.savefig("fractal_proof_search.png", dpi=150)
print("saved fractal_proof_search.png")
