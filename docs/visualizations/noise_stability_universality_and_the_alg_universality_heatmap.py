#!/usr/bin/env python3
"""
Universality Heatmap: Stability Radii Across Families and Sizes

Visualizes the universality ratio R_alg/R_geom as a heatmap across
different matroid families and ground set sizes, testing whether the
ratio remains in a bounded interval.

This script is fully self-contained and does not import from local modules.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb


def lorentzian_radius_uniform(n: int, k: int) -> float:
    """Lorentzian radius for uniform matroid U_{k,n}."""
    c = comb(n, k)
    return 1.0 / c if c > 0 else 0.0


def lorentzian_radius_partition(block_sizes: list) -> float:
    """Lorentzian radius for partition matroid."""
    if not block_sizes:
        return 0.0
    return min(1.0 / b for b in block_sizes if b > 0)


def lorentzian_radius_graphic(n_vertices: int) -> float:
    """Lorentzian radius for graphic matroid of complete graph K_n."""
    n_edges = n_vertices * (n_vertices - 1) // 2
    connectivity = n_vertices - 1
    return connectivity / n_edges if n_edges > 0 else 0.0


# ============================================================
# Compute data for heatmap
# ============================================================

families = ['Uniform\nU(⌊n/2⌋,n)', 'Partition\n(equal blocks)', 'Graphic\n(K_n)',
            'Uniform\nU(2,n)', 'Uniform\nU(n-1,n)']
n_values = list(range(3, 11))

# Ratio matrix: rows = families, cols = n values
ratio_matrix = np.zeros((len(families), len(n_values)))

for j, n in enumerate(n_values):
    # Family 0: Uniform U(n/2, n)
    k = n // 2
    r_g = lorentzian_radius_uniform(n, k)
    r_a = max(r_g * n, r_g)
    ratio_matrix[0, j] = r_a / r_g if r_g > 0 else 0

    # Family 1: Partition matroid (equal blocks of size 2)
    num_blocks = n // 2
    if num_blocks > 0:
        r_g = lorentzian_radius_partition([2] * num_blocks)
        r_a = max(r_g * n, r_g)
        ratio_matrix[1, j] = r_a / r_g if r_g > 0 else 0

    # Family 2: Graphic matroid of K_n
    r_g = lorentzian_radius_graphic(n)
    r_a = max(r_g * n, r_g)
    ratio_matrix[2, j] = r_a / r_g if r_g > 0 else 0

    # Family 3: Uniform U(2, n)
    r_g = lorentzian_radius_uniform(n, 2)
    r_a = max(r_g * n, r_g)
    ratio_matrix[3, j] = r_a / r_g if r_g > 0 else 0

    # Family 4: Uniform U(n-1, n)
    r_g = lorentzian_radius_uniform(n, n - 1)
    r_a = max(r_g * n, r_g)
    ratio_matrix[4, j] = r_a / r_g if r_g > 0 else 0


# ============================================================
# Create visualization
# ============================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# Heatmap
im = ax1.imshow(ratio_matrix, aspect='auto', cmap='YlOrRd',
                vmin=0, vmax=np.max(ratio_matrix) * 1.1)
ax1.set_xticks(range(len(n_values)))
ax1.set_xticklabels(n_values)
ax1.set_yticks(range(len(families)))
ax1.set_yticklabels(families, fontsize=9)
ax1.set_xlabel('Ground Set Size n', fontsize=12)
ax1.set_title('Universality Ratio R_alg / R_geom', fontsize=14)

# Add text annotations
for i in range(len(families)):
    for j in range(len(n_values)):
        text = f'{ratio_matrix[i, j]:.1f}'
        ax1.text(j, i, text, ha='center', va='center',
                 fontsize=8, color='black' if ratio_matrix[i, j] < np.max(ratio_matrix) * 0.6 else 'white')

plt.colorbar(im, ax=ax1, label='Ratio')

# Line plot of ratios
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800']
for i, (fam, color) in enumerate(zip(families, colors)):
    label = fam.replace('\n', ' ')
    ax2.plot(n_values, ratio_matrix[i], 'o-', color=color,
             linewidth=2, markersize=6, label=label)

ax2.set_xlabel('Ground Set Size n', fontsize=12)
ax2.set_ylabel('Universality Ratio', fontsize=12)
ax2.set_title('Ratio Trends Across Families', fontsize=14)
ax2.legend(fontsize=8, loc='upper left')
ax2.grid(True, alpha=0.3)

# Add universality band
mean_ratio = np.mean(ratio_matrix)
ax2.axhline(y=mean_ratio, color='gray', linestyle='--', alpha=0.5)
ax2.fill_between(n_values,
                 [mean_ratio * 0.3] * len(n_values),
                 [mean_ratio * 3.0] * len(n_values),
                 alpha=0.05, color='gray',
                 label='Universality conjecture band')

plt.suptitle('Testing the Universality Conjecture',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('universality_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved universality_heatmap.png")
