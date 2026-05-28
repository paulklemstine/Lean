"""
Visualization: Compression Ratio Heatmap

Visualizes the compression ratio (actual leaves / ambient bound) as a
heatmap across different values of n (ground set size) and number of
bases. Shows how support sparsity controls certification complexity.

The key insight: as the number of bases decreases relative to the
maximum (uniform matroid), the compression ratio drops dramatically,
demonstrating that support geometry compresses certification.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb
import random

random.seed(42)

def count_leaves(bases, n, r):
    """Count independent (r-2)-sets."""
    k = r - 2
    if k < 0:
        return 0
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= b for b in bases):
            count += 1
    return count

# Parameters
r = 4  # Fixed rank
n_values = list(range(6, 13))  # Ground set sizes
num_bases_fracs = [0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 1.0]

# Compute compression ratios
ratios = np.zeros((len(num_bases_fracs), len(n_values)))

for j, n in enumerate(n_values):
    max_bases = comb(n, r)
    all_bases = list(combinations(range(n), r))
    ambient = comb(n, r - 2)

    for i, frac in enumerate(num_bases_fracs):
        num_b = max(1, int(frac * max_bases))
        # Sample bases
        chosen = random.sample(all_bases, min(num_b, len(all_bases)))
        bases = {frozenset(c) for c in chosen}
        leaves = count_leaves(bases, n, r)
        ratios[i, j] = leaves / ambient if ambient > 0 else 0

# Plot
fig, ax = plt.subplots(figsize=(10, 7))

im = ax.imshow(ratios, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)
ax.set_xticks(range(len(n_values)))
ax.set_xticklabels(n_values, fontsize=12)
ax.set_yticks(range(len(num_bases_fracs)))
ax.set_yticklabels([f"{f:.0%}" for f in num_bases_fracs], fontsize=12)

ax.set_xlabel('Ground Set Size (n)', fontsize=14)
ax.set_ylabel('Fraction of Maximum Bases', fontsize=14)
ax.set_title(f'Certificate Compression Ratio (rank r={r})\n'
             f'Ratio = Actual Leaves / Ambient C(n, r−2)', fontsize=15)

# Add text annotations
for i in range(len(num_bases_fracs)):
    for j in range(len(n_values)):
        text = f'{ratios[i, j]:.2f}'
        color = 'white' if ratios[i, j] > 0.6 else 'black'
        ax.text(j, i, text, ha='center', va='center',
                fontsize=10, color=color, fontweight='bold')

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Compression Ratio', fontsize=13)

plt.tight_layout()
plt.savefig('compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved compression_heatmap.png")
