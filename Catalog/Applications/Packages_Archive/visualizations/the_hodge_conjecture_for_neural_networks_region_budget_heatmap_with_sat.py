"""Heatmap of the region budget regionBound(m,n) and its 2^m saturation."""
import numpy as np
import matplotlib.pyplot as plt
from math import comb

def region_bound(m: int, n: int) -> int:
    return sum(comb(m, i) for i in range(0, n + 1))

M, N = 12, 12
grid = np.array([[region_bound(m, n) for n in range(N + 1)]
                 for m in range(M + 1)], dtype=float)

fig, ax = plt.subplots(figsize=(7, 6))
im = ax.imshow(np.log2(grid + 1), origin="lower", cmap="viridis", aspect="auto")
ax.plot(range(M + 1), range(M + 1), "r--", lw=2, label="saturation line n = m")
ax.set_xlabel("ambient dimension n")
ax.set_ylabel("number of neurons m")
ax.set_title("Region budget regionBound(m,n) = sum_{i<=n} C(m,i)  (log2 scale)")
ax.legend(loc="lower right")
fig.colorbar(im, ax=ax, label="log2(1 + regionBound)")
plt.tight_layout()
plt.savefig("region_budget_heatmap.png", dpi=150)
print("saved region_budget_heatmap.png")
