#!/usr/bin/env python3
"""
Visualization: Derivative Tree Structure and Branch Explosion

Illustrates how the derivative tree of a polynomial grows when
degree increases. Shows:
1. Tree structure at different depths
2. Branch count growth (polynomial vs exponential)
3. Binary multiindex structure (SAT correspondence)
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import matplotlib.patches as mpatches


fig, axes = plt.subplots(2, 2, figsize=(16, 12))

# ---- Plot 1: Leaf count growth curves ----
ax = axes[0, 0]
n_values = [3, 5, 8, 12]
d_range = range(2, 16)

for n in n_values:
    leaves = []
    for d in d_range:
        k = d - 2
        try:
            count = math.comb(n + k - 1, k)
        except (ValueError, OverflowError):
            count = float('inf')
        leaves.append(min(count, 1e15))
    ax.semilogy(list(d_range), leaves, 'o-', linewidth=2, markersize=4, label=f'n = {n}')

# Add reference lines
d_ref = list(d_range)
ax.semilogy(d_ref, [2**(d-2) for d in d_ref], 'k--', alpha=0.5, linewidth=1, label='2^(d-2)')
ax.set_xlabel('Degree d', fontsize=12)
ax.set_ylabel('Number of quadratic leaves', fontsize=12)
ax.set_title('Leaf Count Growth by Degree', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(1, 1e12)

# ---- Plot 2: Binary vs total multiindices ----
ax = axes[0, 1]
n = 10
d_range2 = range(0, n + 1)
total_counts = [math.comb(n + d - 1, d) for d in d_range2]
binary_counts = [math.comb(n, d) for d in d_range2]

ax.bar([d - 0.2 for d in d_range2], total_counts, width=0.35, color='steelblue',
       label='All multiindices', alpha=0.8)
ax.bar([d + 0.2 for d in d_range2], binary_counts, width=0.35, color='coral',
       label='Binary multiindices', alpha=0.8)
ax.set_xlabel('Weight d', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Multiindex Counts (n = {n} variables)', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3, axis='y')

# ---- Plot 3: Central binomial coefficient vs 2^k ----
ax = axes[1, 0]
k_range = range(0, 16)
central = [math.comb(2*k, k) for k in k_range]
two_pow = [2**k for k in k_range]
four_pow_over = [4**k / (2*k + 1) for k in k_range]

ax.semilogy(list(k_range), central, 'ro-', linewidth=2, markersize=6,
            label='C(2k, k)', zorder=3)
ax.semilogy(list(k_range), two_pow, 'bs--', linewidth=1.5, markersize=5,
            label='2^k (proved lower bound)')
ax.semilogy(list(k_range), four_pow_over, 'g^--', linewidth=1.5, markersize=5,
            label='4^k / (2k+1)')

ax.fill_between(list(k_range), two_pow, central, alpha=0.15, color='red',
                label='Gap (factor ≈ C(2k,k)/2^k)')
ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Central Binomial Coefficient: C(2k,k) ≥ 2^k', fontsize=13)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

# ---- Plot 4: Phase diagram ----
ax = axes[1, 1]

# Create regions
n_grid = np.arange(2, 35)
d_grid = np.arange(2, 35)
N, D = np.meshgrid(n_grid, d_grid)

# Classify regions
# 0 = polynomial (d fixed or d << n)
# 1 = transitional
# 2 = exponential (d ~ n/2 or more)
region = np.zeros_like(N, dtype=float)
for i in range(len(d_grid)):
    for j in range(len(n_grid)):
        d, n = d_grid[i], n_grid[j]
        k = d - 2
        if k <= 0:
            region[i, j] = 0
        elif k <= max(2, math.log2(n + 1) + 1):
            region[i, j] = 0.3  # polynomial
        elif k <= n // 3:
            region[i, j] = 0.6  # transitional
        elif k <= n:
            region[i, j] = 1.0  # exponential
        else:
            region[i, j] = 0.8  # super-exponential but fewer leaves due to saturation

colors = ['#2ecc71', '#f1c40f', '#e67e22', '#e74c3c']
cmap = mcolors.LinearSegmentedColormap.from_list('regime', 
    [(0, '#2ecc71'), (0.35, '#f1c40f'), (0.65, '#e67e22'), (1.0, '#e74c3c')])

im = ax.contourf(N, D, region, levels=20, cmap=cmap, alpha=0.7)
ax.plot(n_grid, np.log2(n_grid) + 4, 'g-', linewidth=2.5, label='d = log₂(n) + 4 (poly)')
ax.plot(n_grid, n_grid / 3 + 2, 'y-', linewidth=2.5, label='d = n/3 + 2 (transition)')
ax.plot(n_grid, n_grid / 2 + 2, 'r-', linewidth=2.5, label='d = n/2 + 2 (exponential)')

ax.set_xlabel('Number of variables (n)', fontsize=12)
ax.set_ylabel('Degree (d)', fontsize=12)
ax.set_title('Complexity Phase Diagram', fontsize=13)
ax.legend(fontsize=9, loc='upper left')

# Add text annotations
ax.text(25, 8, 'POLYNOMIAL\n(tractable)', fontsize=10, ha='center',
        color='darkgreen', fontweight='bold')
ax.text(10, 22, 'EXPONENTIAL\n(barrier)', fontsize=10, ha='center',
        color='darkred', fontweight='bold')

plt.tight_layout()
plt.savefig('derivative_tree_analysis.png', dpi=150, bbox_inches='tight')
print("Saved derivative_tree_analysis.png")
