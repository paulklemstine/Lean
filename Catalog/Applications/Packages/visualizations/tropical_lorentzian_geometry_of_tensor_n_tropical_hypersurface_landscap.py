#!/usr/bin/env python3
"""
Visualization 1: Tropical Hypersurface of Boundary Measurement Data

Visualizes the tropical hypersurface — the locus where two or more boundary
sectors compete as the dominant configuration — for a 2D boundary measurement
polynomial. Each colored region shows which monomial "wins" (has minimum
tropical weight), and the black lines show the tropical hypersurface where
transitions between dominant sectors occur.

This directly illustrates Theorems 2-3: tropical hypersurface points are
exactly the parameter loci where competing boundary sectors tie for minimum cost.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap


def weight_eval(coeff, x0, x1, m):
    """Tropical affine evaluation: c(m) + m[0]*x0 + m[1]*x1."""
    return coeff[m] + m[0] * x0 + m[1] * x1


def compute_dominant_sector(support, coeff, x0, x1):
    """Find the dominant sector (minimizer) at (x0, x1)."""
    best_idx = 0
    best_val = weight_eval(coeff, x0, x1, support[0])
    for i, m in enumerate(support[1:], 1):
        val = weight_eval(coeff, x0, x1, m)
        if val < best_val:
            best_idx, best_val = i, val
    return best_idx, best_val


def compute_tropical_gap(support, coeff, x0, x1):
    """Compute the gap between 1st and 2nd smallest weights."""
    weights = sorted(weight_eval(coeff, x0, x1, m) for m in support)
    return weights[1] - weights[0] if len(weights) >= 2 else float('inf')


# Define boundary measurement data
support = [(0, 0), (2, 0), (0, 2), (1, 1), (3, 0), (0, 3)]
coeff = {
    (0, 0): 0.0,
    (2, 0): 1.5,
    (0, 2): 1.2,
    (1, 1): 0.8,
    (3, 0): 3.0,
    (0, 3): 2.8,
}

# Create grid
grid_size = 500
x_range = np.linspace(-4, 4, grid_size)
y_range = np.linspace(-4, 4, grid_size)
X, Y = np.meshgrid(x_range, y_range)

# Compute dominant sector and gap at each point
sector_map = np.zeros((grid_size, grid_size), dtype=int)
gap_map = np.zeros((grid_size, grid_size))

for i in range(grid_size):
    for j in range(grid_size):
        idx, _ = compute_dominant_sector(support, coeff, X[i, j], Y[i, j])
        sector_map[i, j] = idx
        gap_map[i, j] = compute_tropical_gap(support, coeff, X[i, j], Y[i, j])

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Dominant sectors with tropical hypersurface
ax1 = axes[0]
colors = ['#E74C3C', '#3498DB', '#2ECC71', '#F39C12', '#9B59B6', '#1ABC9C']
cmap = ListedColormap(colors[:len(support)])
im1 = ax1.pcolormesh(X, Y, sector_map, cmap=cmap, shading='auto', alpha=0.7)

# Overlay hypersurface as contour at gap ≈ 0
ax1.contour(X, Y, gap_map, levels=[0.01], colors='black', linewidths=2)

ax1.set_xlabel('Tropical parameter x₁', fontsize=12)
ax1.set_ylabel('Tropical parameter x₂', fontsize=12)
ax1.set_title('Dominant Boundary Sectors\n& Tropical Hypersurface', fontsize=13, fontweight='bold')

# Add legend for sectors
for idx, m in enumerate(support):
    ax1.plot([], [], 's', color=colors[idx], markersize=10, label=f'm = {m}')
ax1.legend(loc='upper right', fontsize=9, title='Sector')

# Right panel: Tropical gap heatmap
ax2 = axes[1]
im2 = ax2.pcolormesh(X, Y, np.log10(gap_map + 1e-15), cmap='magma_r', 
                      shading='auto', vmin=-2, vmax=2)
plt.colorbar(im2, ax=ax2, label='log₁₀(tropical gap)')
ax2.contour(X, Y, gap_map, levels=[0.01], colors='white', linewidths=1.5, 
            linestyles='dashed')

ax2.set_xlabel('Tropical parameter x₁', fontsize=12)
ax2.set_ylabel('Tropical parameter x₂', fontsize=12)
ax2.set_title('Tropical Gap (Separation Strength)\nDark = Competing Sectors', 
              fontsize=13, fontweight='bold')

plt.suptitle('Tropical Hypersurface of Tensor Network Boundary Measurement Data',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tropical_hypersurface.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved tropical_hypersurface.png")
print(f"Support size: {len(support)}")
print(f"Number of distinct dominant sectors: {len(set(sector_map.flatten()))}")
print(f"Minimum gap observed: {gap_map.min():.6f}")
