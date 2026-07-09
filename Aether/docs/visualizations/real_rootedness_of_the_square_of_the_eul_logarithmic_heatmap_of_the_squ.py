"""Heatmap of the squared Eulerian triangle coefficients T(n,k) (requires matplotlib)."""
from functools import lru_cache
from typing import List
import matplotlib.pyplot as plt
import math

@lru_cache(maxsize=None)
def eulerian(n: int, k: int) -> int:
    if k < 0 or k >= max(n, 1):
        return 0
    if n == 0:
        return 1 if k == 0 else 0
    if k == 0:
        return 1
    return (k + 1) * eulerian(n - 1, k) + (n - k) * eulerian(n - 1, k - 1)

N = 12
grid = [[float("nan")] * (N - 1) for _ in range(N)]
for n in range(2, N):
    top = max(n, 1)
    for k in range(n - 1):
        val = sum(eulerian(n, j) * eulerian(j, k) for j in range(top))
        grid[n][k] = math.log10(val) if val > 0 else float("nan")

fig, ax = plt.subplots(figsize=(8, 6))
im = ax.imshow(grid, aspect="auto", origin="lower")
ax.set_xlabel("k"); ax.set_ylabel("n")
ax.set_title("log10 of squared-triangle coefficients T(n,k)")
fig.colorbar(im, ax=ax, label="log10 T(n,k)")
plt.tight_layout(); plt.savefig("squared_heatmap.png", dpi=150)
print("wrote squared_heatmap.png")
