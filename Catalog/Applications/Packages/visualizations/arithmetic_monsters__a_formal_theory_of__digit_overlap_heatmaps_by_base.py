#!/usr/bin/env python3
"""
Visualization: Digit-Disjointness Heatmap

Visualizes the digit-disjointness adjacency matrix for small numbers
across multiple bases, revealing the base-2 → base-3 phase transition.
Each pixel (i,j) is colored by digit overlap: darker = more overlap,
white = digit-disjoint (overlap = 0).
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def digits_base(n, b):
    if n == 0 or b < 2:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def digit_overlap(m, n, b):
    bm = Counter(digits_base(m, b))
    bn = Counter(digits_base(n, b))
    return sum(min(bm.get(d, 0), bn.get(d, 0)) for d in range(b))


N = 40
bases = [2, 3, 5, 10]

fig, axes = plt.subplots(1, 4, figsize=(16, 4))
fig.suptitle("Digit Overlap Matrices by Base\n(White = digit-disjoint, dark = high overlap)",
             fontsize=13, fontweight='bold')

for idx, b in enumerate(bases):
    mat = np.zeros((N, N))
    for i in range(1, N + 1):
        for j in range(1, N + 1):
            mat[i-1, j-1] = digit_overlap(i, j, b)

    ax = axes[idx]
    im = ax.imshow(mat, cmap='YlOrRd', origin='lower', aspect='equal',
                   extent=[1, N, 1, N])
    ax.set_title(f"Base {b}", fontsize=12)
    ax.set_xlabel("n")
    if idx == 0:
        ax.set_ylabel("m")

    # Mark diagonal
    ax.plot([1, N], [1, N], 'k--', alpha=0.3, linewidth=0.5)

    plt.colorbar(im, ax=ax, shrink=0.8, label="Overlap")

plt.tight_layout()
plt.savefig("viz_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")
