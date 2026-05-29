#!/usr/bin/env python3
"""
Visualization: Constraint Density Heatmap
==========================================

Visualizes how the constraint density (ratio of compatibility constraints
to total pieces) varies with puzzle grid dimensions. The density approaches
2 as both dimensions grow, which is the theoretical maximum proven in
our Lean formalization.

Key insight: The constraint density determines puzzle difficulty.
Near the theoretical limit of 2, almost every piece placement is
constrained by its neighbors, making the puzzle maximally difficult.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

def total_constraints(m: int, n: int) -> int:
    """Number of compatibility constraints in an m×n puzzle."""
    h_constraints = m * max(0, n - 1)
    v_constraints = max(0, m - 1) * n
    return h_constraints + v_constraints

def constraint_density(m: int, n: int) -> float:
    """Constraint density: constraints per piece."""
    pieces = m * n
    if pieces == 0:
        return 0
    return total_constraints(m, n) / pieces

# Generate data
max_size = 25
ms = np.arange(1, max_size + 1)
ns = np.arange(1, max_size + 1)
density_grid = np.zeros((max_size, max_size))

for i, m in enumerate(ms):
    for j, n in enumerate(ns):
        density_grid[i, j] = constraint_density(m, n)

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Subplot 1: Heatmap
im = ax1.imshow(density_grid, origin='lower', extent=[1, max_size, 1, max_size],
                cmap='YlOrRd', vmin=0, vmax=2, aspect='auto')
ax1.set_xlabel('Columns (n)', fontsize=12)
ax1.set_ylabel('Rows (m)', fontsize=12)
ax1.set_title('Constraint Density of m×n Jigsaw Puzzles', fontsize=14)
cbar = plt.colorbar(im, ax=ax1, label='Constraints per piece')

# Add contour lines
contours = ax1.contour(np.arange(1, max_size + 1), np.arange(1, max_size + 1),
                       density_grid, levels=[1.0, 1.5, 1.8, 1.9, 1.95],
                       colors='black', linewidths=0.5)
ax1.clabel(contours, inline=True, fontsize=8, fmt='%.2f')

# Subplot 2: Diagonal cross-section (n×n puzzles)
n_vals = np.arange(1, 51)
densities = [constraint_density(n, n) for n in n_vals]
theoretical_limit = 2.0

ax2.plot(n_vals, densities, 'b-', linewidth=2, label='Actual density')
ax2.axhline(y=theoretical_limit, color='r', linestyle='--', linewidth=1.5,
            label=f'Theoretical limit = {theoretical_limit}')
ax2.fill_between(n_vals, densities, theoretical_limit, alpha=0.1, color='blue')
ax2.set_xlabel('Grid size n (for n×n puzzle)', fontsize=12)
ax2.set_ylabel('Constraint density', fontsize=12)
ax2.set_title('Constraint Density Approaches 2', fontsize=14)
ax2.legend(fontsize=11)
ax2.set_ylim(0, 2.2)
ax2.grid(True, alpha=0.3)

# Annotate key points
for n_val in [2, 5, 10, 20]:
    d = constraint_density(n_val, n_val)
    ax2.annotate(f'n={n_val}: {d:.3f}',
                xy=(n_val, d), xytext=(n_val + 3, d - 0.15),
                arrowprops=dict(arrowstyle='->', color='gray'),
                fontsize=9)

plt.tight_layout()
plt.savefig('constraint_density.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved constraint_density.png")
