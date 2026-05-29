#!/usr/bin/env python3
"""
Visualization: Formula Complexity Landscape

Visualizes how formula complexity grows as boolean operations are composed,
showing the relationship between atom count, negation count, and total
complexity via the decomposition theorem: complexity = 2*atoms - 1 + negations.

Uses matplotlib to create a heatmap of complexity values.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Create complexity landscape
max_atoms = 15
max_negs = 10

atoms = np.arange(1, max_atoms + 1)
negs = np.arange(0, max_negs + 1)
A, N = np.meshgrid(atoms, negs)

# Complexity decomposition: complexity = 2*atomCount - 1 + negCount
C = 2 * A - 1 + N

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap of complexity
im = axes[0].imshow(C, origin='lower', aspect='auto',
                     extent=[0.5, max_atoms + 0.5, -0.5, max_negs + 0.5],
                     cmap='YlOrRd')
axes[0].set_xlabel('Atom Count', fontsize=12)
axes[0].set_ylabel('Negation Count', fontsize=12)
axes[0].set_title('Formula Complexity Landscape\n(complexity = 2·atoms − 1 + negations)',
                   fontsize=13, fontweight='bold')
cbar = plt.colorbar(im, ax=axes[0])
cbar.set_label('Total Complexity', fontsize=11)

# Add contour lines
contours = axes[0].contour(A, N, C, levels=range(3, 35, 4),
                            colors='black', alpha=0.3, linewidths=0.5)
axes[0].clabel(contours, inline=True, fontsize=8, fmt='%d')

# Formula tree count growth
def formula_tree_count(n, d):
    if d == 0:
        return 1
    sub = formula_tree_count(n, d - 1)
    return n + 2 * sub * sub + sub

depths = range(0, 7)
for n_atoms in [1, 2, 3, 5]:
    counts = [formula_tree_count(n_atoms, d) for d in depths]
    axes[1].semilogy(list(depths), counts, 'o-', label=f'{n_atoms} atom types',
                      linewidth=2, markersize=6)

axes[1].set_xlabel('Maximum Depth', fontsize=12)
axes[1].set_ylabel('Formula Count (log scale)', fontsize=12)
axes[1].set_title('Formula Tree Enumeration\n(Logic ↔ Combinatorics Bridge)',
                   fontsize=13, fontweight='bold')
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_complexity.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity.png")
