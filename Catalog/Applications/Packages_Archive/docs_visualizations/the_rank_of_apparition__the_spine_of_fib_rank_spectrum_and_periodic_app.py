"""Visualization: rank of apparition and exact apparition density.

Left  : bar chart of rank(m) for m = 1..40.
Right : apparition indicator m | F_n (heatmap) showing the periodic stripes,
        the visual signature of the spine  m | F_n  <=>  rank(m) | n.
Requires matplotlib and numpy.
"""
import numpy as np
import matplotlib.pyplot as plt

def fib_rank(m: int) -> int:
    if m == 1:
        return 1
    a, b, k = 0, 1, 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k

M, N = 20, 60
ranks = [fib_rank(m) for m in range(1, 41)]

grid = np.zeros((M, N), dtype=int)
for mi, m in enumerate(range(1, M + 1)):
    r = fib_rank(m)
    for n in range(1, N + 1):
        grid[mi, n - 1] = 1 if n % r == 0 else 0   # spine: m | F_n iff r | n

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

ax1.bar(range(1, 41), ranks, color="#3b6fb6")
ax1.set_title("Rank of apparition rank(m)")
ax1.set_xlabel("modulus m")
ax1.set_ylabel("rank(m)")

ax2.imshow(grid, aspect="auto", cmap="magma", origin="lower",
           extent=[1, N, 1, M])
ax2.set_title("Apparition stripes:  m | F_n  (period = rank(m))")
ax2.set_xlabel("index n")
ax2.set_ylabel("modulus m")

plt.tight_layout()
plt.savefig("rank_of_apparition.png", dpi=140)
print("saved rank_of_apparition.png")
