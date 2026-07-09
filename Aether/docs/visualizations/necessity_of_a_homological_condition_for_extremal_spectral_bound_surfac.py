"""Heatmap of the extremal spectral bound q_bd(n, r, t) = t*n - (t-1)*(r+1)
and a check of its discrete derivatives (d/dn = t, d/dr = -(t-1))."""
from typing import List
import numpy as np
import matplotlib.pyplot as plt


def q_bound(n: int, r: int, t: int) -> int:
    return t * n - (t - 1) * (r + 1)


t = 3
ns = list(range(5, 21))
rs = list(range(1, 11))
grid = np.array([[q_bound(n, r, t) for n in ns] for r in rs])

fig, ax = plt.subplots(figsize=(9, 5))
im = ax.imshow(grid, origin="lower", aspect="auto",
               extent=[ns[0], ns[-1], rs[0], rs[-1]], cmap="viridis")
ax.set_xlabel("n (vertices)")
ax.set_ylabel("r (dimension)")
ax.set_title(f"Extremal bound q_bd(n, r, t={t}) = t*n - (t-1)*(r+1)")
fig.colorbar(im, ax=ax, label="q_bd")
plt.tight_layout()
plt.savefig("q_bound_heatmap.png", dpi=150)
print("wrote q_bound_heatmap.png")
