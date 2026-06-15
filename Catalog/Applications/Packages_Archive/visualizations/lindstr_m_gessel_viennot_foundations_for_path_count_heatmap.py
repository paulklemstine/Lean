import numpy as np
import matplotlib.pyplot as plt
from math import comb

M = N = 8
grid = np.array([[comb(m + n, n) for n in range(N + 1)] for m in range(M + 1)])

fig, ax = plt.subplots(figsize=(7, 6))
im = ax.imshow(np.log10(grid), origin="lower", cmap="viridis")
for m in range(M + 1):
    for n in range(N + 1):
        ax.text(n, m, str(grid[m, n]), ha="center", va="center",
                color="white", fontsize=7)
ax.set_xlabel("n (North steps)")
ax.set_ylabel("m (East steps)")
ax.set_title("pathCount(m,n) = C(m+n, n)  (color = log10 count)")
fig.colorbar(im, ax=ax, label="log10 path count")
plt.tight_layout()
plt.savefig("path_count_heatmap.png", dpi=150)
print("wrote path_count_heatmap.png")
