"""Visualize Fibonacci divisibility positions and the rank of apparition.

Produces a grid where cell (m, k) is shaded when m | F(k); the first shaded
cell in each row m sits at column alpha(m), and the whole row is an arithmetic
progression of step alpha(m) (the law of apparition made visible).
"""
import matplotlib.pyplot as plt
import numpy as np

def fib(k: int) -> int:
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a

M, K = 20, 40
grid = np.zeros((M, K))
for m in range(1, M + 1):
    for k in range(1, K + 1):
        if fib(k) % m == 0:
            grid[m - 1, k - 1] = 1

fig, ax = plt.subplots(figsize=(11, 6))
ax.imshow(grid, aspect="auto", cmap="viridis",
          extent=[1, K, M, 1], interpolation="nearest")
# mark alpha(m) (first hit) in each row
for m in range(1, M + 1):
    hits = [k for k in range(1, K + 1) if fib(k) % m == 0]
    if hits:
        ax.scatter([hits[0]], [m], color="red", s=18, zorder=3)
ax.set_xlabel("Fibonacci index k")
ax.set_ylabel("modulus m")
ax.set_title("m | F(k): appearances (red = rank of apparition alpha(m))")
plt.tight_layout()
plt.savefig("apparition_heatmap.png", dpi=150)
print("wrote apparition_heatmap.png")
