#!/usr/bin/env python3
"""
Visualization: Well-Founded Overlap Decomposition

Shows how critical pair counts grow with the size bound, and how the
overlap decomposition structure ensures that larger overlaps decompose
into smaller ones via the well-founded ordering.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Critical pair count vs size bound ---
ax1 = axes[0]
sizes = np.arange(1, 21)
# Simulated critical pair counts for different systems
cp_sort = np.array([0, 1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3])
cp_map = np.array([0, 0, 0, 1, 2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4])
cp_arith = np.array([0, 0, 1, 2, 4, 6, 8, 10, 12, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15])

ax1.plot(sizes, cp_sort, 'o-', color='#2196F3', label='Sorting (3 rules)', linewidth=2, markersize=4)
ax1.plot(sizes, cp_map, 's-', color='#F44336', label='Map fusion (2 rules)', linewidth=2, markersize=4)
ax1.plot(sizes, cp_arith, '^-', color='#4CAF50', label='Arithmetic (5 rules)', linewidth=2, markersize=4)

ax1.set_xlabel('Size bound N', fontsize=12)
ax1.set_ylabel('Number of critical pairs', fontsize=12)
ax1.set_title('Critical Pairs Stabilize\n(Well-Foundedness)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Add annotation for stabilization
ax1.axhline(y=15, color='#4CAF50', linestyle=':', alpha=0.5)
ax1.annotate('Stabilization\npoint', xy=(12, 15), xytext=(15, 12),
            fontsize=9, ha='center',
            arrowprops=dict(arrowstyle='->', color='#333'))

# --- Panel 2: Overlap complexity heatmap ---
ax2 = axes[1]
k_vals = np.arange(1, 8)
M_vals = np.arange(1, 8)
K, M = np.meshgrid(k_vals, M_vals)
bounds = K**2 * M**2

im = ax2.imshow(bounds, cmap='YlOrRd', origin='lower',
                extent=[0.5, 7.5, 0.5, 7.5], aspect='auto')
ax2.set_xlabel('Number of rules (k)', fontsize=12)
ax2.set_ylabel('Max LHS size (M)', fontsize=12)
ax2.set_title('Critical Pair Bound\n(k² · M²)', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax2, label='Bound', shrink=0.8)

# Add contour lines
ax2.contour(K, M, bounds, levels=[10, 50, 100, 500, 1000],
           colors='white', linewidths=0.8, linestyles='dashed')

# --- Panel 3: Well-founded decomposition tree ---
ax3 = axes[2]
ax3.set_xlim(-1, 9)
ax3.set_ylim(-1, 7)
ax3.axis('off')
ax3.set_title('Overlap Decomposition\n(Well-Founded Tree)', fontsize=13, fontweight='bold')

# Draw a tree showing how large overlaps decompose
tree_nodes = [
    (4, 6, "N=7", '#F44336', 14),
    (2, 4, "N=4", '#FF9800', 12),
    (6, 4, "N=5", '#FF9800', 12),
    (1, 2, "N=2", '#4CAF50', 10),
    (3, 2, "N=3", '#4CAF50', 10),
    (5, 2, "N=3", '#4CAF50', 10),
    (7, 2, "N=1", '#2196F3', 10),
    (0.5, 0, "✓", '#81C784', 14),
    (1.5, 0, "✓", '#81C784', 14),
    (2.5, 0, "✓", '#81C784', 14),
    (3.5, 0, "✓", '#81C784', 14),
    (5, 0, "✓", '#81C784', 14),
    (7, 0, "✓", '#81C784', 14),
]

for x, y, label, color, fs in tree_nodes:
    ax3.add_patch(plt.Circle((x, y), 0.4, facecolor=color, edgecolor='#333',
                            linewidth=1.5, alpha=0.8))
    ax3.text(x, y, label, ha='center', va='center', fontsize=fs-4,
            fontweight='bold', color='white')

# Edges
edges = [
    (4, 6, 2, 4), (4, 6, 6, 4),
    (2, 4, 1, 2), (2, 4, 3, 2),
    (6, 4, 5, 2), (6, 4, 7, 2),
    (1, 2, 0.5, 0), (1, 2, 1.5, 0),
    (3, 2, 2.5, 0), (3, 2, 3.5, 0),
    (5, 2, 5, 0),
    (7, 2, 7, 0),
]

for x1, y1, x2, y2 in edges:
    dx, dy = x2 - x1, y2 - y1
    length = np.sqrt(dx**2 + dy**2)
    ux, uy = dx/length, dy/length
    ax3.annotate('', xy=(x2 - ux*0.4, y2 + 0.4),
                xytext=(x1 + ux*0.4, y1 - 0.4),
                arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

ax3.text(4, -0.8, 'Each overlap decomposes into\nstrictly smaller overlaps',
        ha='center', fontsize=9, style='italic')

plt.tight_layout()
plt.savefig('overlap_decomposition.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved overlap_decomposition.png")
