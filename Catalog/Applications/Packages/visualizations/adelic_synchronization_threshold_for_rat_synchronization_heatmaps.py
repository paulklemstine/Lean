"""
Visualization 1: Synchronization Heatmap

Visualizes the pairwise agreement matrix of orbit invariants across primes
for different parameters c. Exceptional (preperiodic) parameters show
dense agreement blocks; generic parameters show sparse, disordered patterns.

This is the core visual evidence for the adelic synchronization thesis.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from collections import Counter


def quad_map_mod(x, c, p):
    return (x * x + c) % p

def find_preperiod_and_period(c, p):
    seen = {}
    x = 0
    for i in range(p + 2):
        if x in seen:
            return seen[x], i - seen[x]
        seen[x] = i
        x = quad_map_mod(x, c, p)
    return p, 1

def sieve(n):
    if n < 2:
        return []
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n**0.5) + 1):
        if s[i]:
            for j in range(i*i, n + 1, i):
                s[j] = False
    return [i for i in range(2, n + 1) if s[i]]


primes = [p for p in sieve(200) if p > 2][:40]
n_p = len(primes)

params = [0, -1, -2, 3, 7, 42]
titles = [
    "c = 0 (fixed point)",
    "c = −1 (period 2)",
    "c = −2 (preperiod 1)",
    "c = 3 (generic)",
    "c = 7 (generic)",
    "c = 42 (generic)",
]

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle("Adelic Synchronization Heatmaps\nPairwise agreement of orbit invariants across primes",
             fontsize=14, fontweight='bold')

for idx, (c, title) in enumerate(zip(params, titles)):
    ax = axes[idx // 3][idx % 3]
    invariants = [find_preperiod_and_period(c, p) for p in primes]

    # Build agreement matrix
    matrix = np.zeros((n_p, n_p))
    for i in range(n_p):
        for j in range(n_p):
            matrix[i][j] = 1 if invariants[i] == invariants[j] else 0

    score = int(matrix.sum())
    ratio = score / (n_p * n_p)

    cmap = mcolors.ListedColormap(['#f0f0f0', '#2166ac'])
    ax.imshow(matrix, cmap=cmap, interpolation='nearest', aspect='equal')
    ax.set_title(f"{title}\nSync ratio: {ratio:.3f}", fontsize=10)
    ax.set_xlabel("Prime index")
    ax.set_ylabel("Prime index")
    ax.set_xticks([])
    ax.set_yticks([])

plt.tight_layout()
plt.savefig("sync_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved sync_heatmap.png")
