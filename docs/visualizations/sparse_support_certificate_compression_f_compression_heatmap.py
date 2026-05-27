"""
Visualization: Compression Ratio Heatmap for Uniform Matroids

Visualizes the ratio of actual quadratic leaves to ambient leaf count
for uniform matroids U_{r,n} across different values of r and n.
For uniform matroids, every (r-2)-subset is independent, so the ratio
is always 1.0 — this serves as the baseline against which sparse
matroids show compression.

The heatmap shows C(n, r-2) values, illustrating how certification
complexity grows with n and r.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# Parameters
n_values = list(range(4, 16))
r_values = list(range(3, 10))

# Compute leaf counts
data = np.zeros((len(r_values), len(n_values)))
for i, r in enumerate(r_values):
    for j, n in enumerate(n_values):
        if r <= n:
            data[i, j] = comb(n, r - 2)
        else:
            data[i, j] = 0

# Create heatmap
fig, ax = plt.subplots(figsize=(12, 7))
im = ax.imshow(data, cmap='YlOrRd', aspect='auto', interpolation='nearest')

# Labels
ax.set_xticks(range(len(n_values)))
ax.set_xticklabels(n_values)
ax.set_yticks(range(len(r_values)))
ax.set_yticklabels(r_values)
ax.set_xlabel('Ground Set Size (n)', fontsize=13)
ax.set_ylabel('Rank (r)', fontsize=13)
ax.set_title('Quadratic Leaf Count C(n, r−2) for Uniform Matroids\n'
             '(Baseline for Support Compression)', fontsize=14)

# Add text annotations
for i in range(len(r_values)):
    for j in range(len(n_values)):
        val = int(data[i, j])
        if val > 0:
            color = 'white' if val > data.max() * 0.6 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=8, color=color, fontweight='bold')

plt.colorbar(im, ax=ax, label='Number of Quadratic Leaves')
plt.tight_layout()
plt.savefig('viz_compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_compression_heatmap.png")
