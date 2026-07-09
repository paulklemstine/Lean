"""
Visualization: the affine gainability threshold for contrabalanced bundles k*K_2.

Produces a heatmap over (prime p, edge count k) showing whether k*K_2 is
Z/p-gainable (k <= p, the affine line A^1(Z/p)) versus the matroid-representability
threshold k <= p+1 (the projective line P^1(GF(p))), highlighting the gap of one.

Run:  python visualize_threshold.py    (saves zp_gain_threshold.png)
"""
from typing import List
import matplotlib.pyplot as plt
import numpy as np

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    return all(n % d for d in range(2, int(n ** 0.5) + 1))

primes: List[int] = [p for p in range(2, 14) if is_prime(p)]
ks: List[int] = list(range(1, 16))

grid = np.zeros((len(primes), len(ks)))
for r, p in enumerate(primes):
    for c, k in enumerate(ks):
        if k <= p:
            grid[r, c] = 2.0      # gain-realisable (affine)
        elif k <= p + 1:
            grid[r, c] = 1.0      # matroid-only (the +1 gap, point at infinity)
        else:
            grid[r, c] = 0.0      # neither

fig, ax = plt.subplots(figsize=(9, 5))
cmap = plt.get_cmap("YlGnBu")
im = ax.imshow(grid, aspect="auto", cmap=cmap, origin="lower")
ax.set_xticks(range(len(ks)))
ax.set_xticklabels(ks)
ax.set_yticks(range(len(primes)))
ax.set_yticklabels(primes)
ax.set_xlabel("k  (number of parallel edges in k*K_2)")
ax.set_ylabel("prime p  (gain group Z/p)")
ax.set_title("Gainability vs. representability thresholds for k*K_2\n"
             "2 = gain-realisable (k<=p), 1 = matroid-only gap (k=p+1), 0 = neither")
cbar = fig.colorbar(im, ticks=[0, 1, 2])
cbar.ax.set_yticklabels(["neither", "gap (k=p+1)", "gainable (k<=p)"])
plt.tight_layout()
plt.savefig("zp_gain_threshold.png", dpi=150)
print("saved zp_gain_threshold.png")
