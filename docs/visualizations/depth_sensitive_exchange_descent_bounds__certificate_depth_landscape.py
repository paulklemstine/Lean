"""
Visualization: Certificate Depth Landscape
=============================================

A heatmap showing how the theoretical descent bound d^{d-k} varies
across dimension d and certificate depth k. The diagonal (k=d) is
the "linear regime" where certificate depth saturates dimension.

Visualizes the core insight: the complexity landscape has a dramatic
cliff — moving from k=1 to k=d reduces complexity from exponential
to linear.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# --- Panel 1: Heatmap of d^{d-k} ---
ax = axes[0]

d_max = 12
matrix = np.zeros((d_max, d_max))

for d in range(1, d_max + 1):
    for k in range(1, d + 1):
        matrix[d-1, k-1] = np.log10(max(d ** (d - k), 1))

# Mask invalid entries (k > d)
mask = np.zeros_like(matrix, dtype=bool)
for d in range(1, d_max + 1):
    for k in range(d + 1, d_max + 1):
        mask[d-1, k-1] = True

masked = np.ma.masked_array(matrix, mask)

cmap = plt.cm.RdYlGn_r.copy()
cmap.set_bad('white', alpha=0)

im = ax.imshow(masked, cmap=cmap, aspect='equal', origin='lower',
               vmin=0, vmax=np.max(matrix))

ax.set_xlabel('Certificate Depth k', fontsize=12)
ax.set_ylabel('Dimension d', fontsize=12)
ax.set_title('log₁₀(d^{d-k}): Complexity Landscape', fontsize=13, fontweight='bold')

ax.set_xticks(range(d_max))
ax.set_xticklabels(range(1, d_max + 1))
ax.set_yticks(range(d_max))
ax.set_yticklabels(range(1, d_max + 1))

# Add diagonal line for k = d
ax.plot(range(d_max), range(d_max), 'w--', linewidth=2, alpha=0.8)
ax.text(d_max - 3, d_max - 2, 'k = d\n(LINEAR)', color='white',
        fontsize=10, fontweight='bold', ha='center',
        bbox=dict(boxstyle='round', facecolor='black', alpha=0.5))

# Add text annotations for key values
for d in range(1, min(d_max + 1, 9)):
    for k in range(1, d + 1):
        val = d ** (d - k)
        if val <= 1e6:
            txt = f'{val:.0f}' if val < 1000 else f'{val:.0e}'
            ax.text(k-1, d-1, txt, ha='center', va='center',
                    fontsize=6, color='white' if matrix[d-1, k-1] > 3 else 'black')

plt.colorbar(im, ax=ax, label='log₁₀(complexity factor)', shrink=0.8)

# --- Panel 2: Cross-sections at fixed dimensions ---
ax = axes[1]

colors = plt.cm.viridis(np.linspace(0.2, 0.9, 6))

for idx, d in enumerate([4, 5, 6, 8, 10, 12]):
    ks = range(1, d + 1)
    bounds = [d ** (d - k) for k in ks]
    ax.semilogy(ks, bounds, 'o-', color=colors[idx], linewidth=2,
                markersize=7, label=f'd = {d}')

ax.axhline(y=1, color='red', linestyle='--', linewidth=2, alpha=0.7,
           label='LINEAR (d^0 = 1)')
ax.set_xlabel('Certificate Depth k', fontsize=12)
ax.set_ylabel('Complexity Factor d^{d-k} (log scale)', fontsize=12)
ax.set_title('Descent Complexity vs Certificate Depth', fontsize=13, fontweight='bold')
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3)

# Add annotation
ax.annotate('Deeper certificates →\nfaster descent',
            xy=(6, 10), fontsize=11, fontstyle='italic',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('depth_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: depth_landscape.png")
