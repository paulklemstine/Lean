"""
Visualization: Compression Ratio Heatmap for Certificate Complexity

Shows how the ratio (actual leaves / ambient leaves) varies with
matroid parameters n (ground set size) and r (rank) for the uniform matroid.
For uniform matroids, every (r-2)-subset is independent, so the ratio is
always 1.0. But for restricted matroids (bases using only k < n variables),
the compression ratio C(k,r-2)/C(n,r-2) drops dramatically.

This heatmap shows the compression ratio for a matroid whose bases use
only k=8 active variables, embedded in ground sets of various sizes n,
for different ranks r. The plot reveals how support geometry compresses
the certificate complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# Parameters
k_active = 8  # number of active variables
n_values = list(range(8, 31))  # ground set sizes
r_values = list(range(3, 9))   # ranks

# Compute compression ratios
ratios = np.zeros((len(r_values), len(n_values)))

for i, r in enumerate(r_values):
    for j, n in enumerate(n_values):
        if r - 2 > min(k_active, n) or r > n:
            ratios[i, j] = np.nan
        else:
            ambient = comb(n, r - 2)
            compressed = comb(min(k_active, n), r - 2)
            ratios[i, j] = compressed / ambient if ambient > 0 else 1.0

# Create figure
fig, ax = plt.subplots(figsize=(12, 6))

# Plot heatmap
im = ax.imshow(ratios, aspect='auto', cmap='RdYlGn',
               vmin=0, vmax=1,
               extent=[n_values[0]-0.5, n_values[-1]+0.5,
                       r_values[-1]+0.5, r_values[0]-0.5])

# Labels
ax.set_xlabel('Ground Set Size n', fontsize=13)
ax.set_ylabel('Rank r', fontsize=13)
ax.set_title(f'Certificate Compression Ratio: C({k_active}, r−2) / C(n, r−2)\n'
             f'Active Variables k = {k_active}', fontsize=14)

# Colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Compression Ratio (actual / ambient)', fontsize=11)

# Annotate cells with values
for i, r in enumerate(r_values):
    for j, n in enumerate(n_values):
        if not np.isnan(ratios[i, j]):
            color = 'white' if ratios[i, j] < 0.3 else 'black'
            ax.text(n, r, f'{ratios[i,j]:.2f}',
                    ha='center', va='center', fontsize=7, color=color)

# Set ticks
ax.set_xticks(n_values[::2])
ax.set_yticks(r_values)

plt.tight_layout()
plt.savefig('viz_compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_compression_heatmap.png")
