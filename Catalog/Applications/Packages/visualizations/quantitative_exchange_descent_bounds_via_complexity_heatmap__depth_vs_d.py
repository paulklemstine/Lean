"""
Visualization 3: Heatmap of Complexity Bounds — Depth vs Dimension

Shows the log of the theoretical complexity bound log₁₀(d^(d-k) · D)
as a heatmap over (dimension d, depth k) with D=10. The diagonal k=d
shows the linear regime (green), while k=0 shows the generic exponential
regime (red).

This visualization encapsulates the entire theory in a single image:
certificate depth controls the color of the complexity landscape.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

D = 10  # Fixed diameter
d_max = 15

# Build the complexity matrix
d_values = np.arange(2, d_max + 1)
k_values = np.arange(0, d_max + 1)

# Complexity: d^(d-k) * D (use log10 for visualization)
complexity = np.full((len(k_values), len(d_values)), np.nan)
for i, k in enumerate(k_values):
    for j, d in enumerate(d_values):
        if k <= d:
            val = (d - k) * np.log10(d) + np.log10(D)
            complexity[i, j] = val

fig, ax = plt.subplots(figsize=(12, 8))

# Custom colormap: green (fast) to red (slow)
cmap = plt.cm.RdYlGn_r
masked = np.ma.array(complexity, mask=np.isnan(complexity))

im = ax.pcolormesh(d_values - 0.5, k_values - 0.5, masked,
                   cmap=cmap, shading='auto')
cbar = plt.colorbar(im, ax=ax, label='log₁₀(Complexity Bound)', pad=0.02)

# Draw the diagonal k=d line
ax.plot(d_values, d_values, 'w--', linewidth=2.5, label='k = d (linear regime)')
ax.plot(d_values, np.ones_like(d_values), 'w:', linewidth=1.5, label='k = 1 (generic)')

# Annotations
ax.annotate('LINEAR\nREGIME', xy=(d_max - 2, d_max - 2),
            fontsize=12, fontweight='bold', color='white', ha='center',
            bbox=dict(boxstyle='round', facecolor='green', alpha=0.7))
ax.annotate('EXPONENTIAL\nREGIME', xy=(d_max - 2, 2),
            fontsize=12, fontweight='bold', color='white', ha='center',
            bbox=dict(boxstyle='round', facecolor='red', alpha=0.7))

ax.set_xlabel('Dimension d', fontsize=14)
ax.set_ylabel('Certificate Depth k', fontsize=14)
ax.set_title('Complexity Landscape: Certificate Depth vs Dimension\n'
             f'Bound = d^(d-k) · D,  D={D}', fontsize=15, fontweight='bold')
ax.legend(loc='upper left', fontsize=11,
          facecolor='white', framealpha=0.9)
ax.set_xlim(d_values[0] - 0.5, d_values[-1] + 0.5)
ax.set_ylim(k_values[0] - 0.5, k_values[-1] + 0.5)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('viz_heatmap_depth_dim.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap_depth_dim.png")
