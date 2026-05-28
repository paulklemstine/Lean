"""
Visualization: Compression Ratio Across Parameters

Shows how the compression ratio (shadow size / naive enumeration size)
varies as the number of variables and degree change. This illustrates
that the compression theorem provides increasingly strong savings for
larger problems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from math import comb


def degree_shadow_matroid(n, r, k):
    """Compute shadow size for the uniform matroid U_{r,n} at degree k."""
    return comb(n, k)


fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# ─── Panel 1: Shadow size vs naive size ───
ax = axes[0]

ns = list(range(4, 16))
for r in [3, 4, 5]:
    shadow_sizes = []
    naive_sizes = []
    for n in ns:
        if r > n:
            shadow_sizes.append(None)
            naive_sizes.append(None)
            continue
        k = r - 2
        shadow = comb(n, k)
        naive = comb(n + k - 1, k)
        shadow_sizes.append(shadow)
        naive_sizes.append(naive)
    
    valid_n = [n for n, s in zip(ns, shadow_sizes) if s is not None]
    valid_shadow = [s for s in shadow_sizes if s is not None]
    valid_naive = [s for s in naive_sizes if s is not None]
    
    ax.plot(valid_n, valid_naive, 'o--', alpha=0.5, markersize=4,
            label=f'Naive (r={r})')
    ax.plot(valid_n, valid_shadow, 's-', markersize=5,
            label=f'Shadow (r={r})')

ax.set_xlabel('Number of variables (n)', fontsize=11)
ax.set_ylabel('Number of derivative checks', fontsize=11)
ax.set_title('Naive vs Shadow Complexity', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# ─── Panel 2: Compression ratio ───
ax = axes[1]

for r in [3, 4, 5, 6]:
    ratios = []
    valid_n = []
    for n in range(r, 20):
        k = r - 2
        shadow = comb(n, k)
        naive = comb(n + k - 1, k)
        ratios.append(shadow / naive if naive > 0 else 1.0)
        valid_n.append(n)
    
    ax.plot(valid_n, ratios, 'o-', markersize=4, label=f'r={r}')

ax.set_xlabel('Number of variables (n)', fontsize=11)
ax.set_ylabel('Compression ratio (shadow / naive)', fontsize=11)
ax.set_title('Compression Ratio for Uniform Matroids', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(0, 1.05)
ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
ax.grid(True, alpha=0.3)

fig.suptitle('M-Convex Compression: Scaling Analysis',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_compression_ratio.png', dpi=150, bbox_inches='tight')
print("Saved viz_compression_ratio.png")
