#!/usr/bin/env python3
"""
Visualization: Mixed Directional Log-Concavity Heatmap

Visualizes the coefficient function of a complete homogeneous polynomial
on a 2D degree slice, showing how mixed log-concavity creates a
"smooth dome" shape that forces rectangle closure of the support.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import factorial, comb

def multinomial(m):
    total = sum(m)
    result = factorial(total)
    for mi in m:
        result //= factorial(mi)
    return result

# Parameters
d = 8  # degree
n = 3  # variables (we'll plot 2D slice fixing x3 = d - x1 - x2)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Multinomial coefficients as heatmap
ax = axes[0]
grid = np.zeros((d+1, d+1))
for a in range(d+1):
    for b in range(d+1-a):
        c = d - a - b
        grid[a, b] = multinomial((a, b, c))

im = ax.imshow(np.log1p(grid), cmap='YlOrRd', origin='lower', aspect='equal')
ax.set_title(f'log(1 + multinomial) on degree-{d} slice', fontsize=11)
ax.set_xlabel('$m_1$')
ax.set_ylabel('$m_2$')
plt.colorbar(im, ax=ax, shrink=0.8)

# Plot 2: Mixed DLC ratio f(m+ei+ej)*f(m) / (f(m+ei)*f(m+ej))
ax = axes[1]
ratio_grid = np.full((d+1, d+1), np.nan)
for a in range(d-1):
    for b in range(d-1-a):
        c = d - a - b
        if c >= 2:
            f_m = multinomial((a, b, c))
            f_mij = multinomial((a+1, b+1, c-2))
            f_mi = multinomial((a+1, b, c-1))
            f_mj = multinomial((a, b+1, c-1))
            if f_mi * f_mj > 0:
                ratio_grid[a, b] = (f_mij * f_m) / (f_mi * f_mj)

im2 = ax.imshow(ratio_grid, cmap='RdYlGn_r', origin='lower', aspect='equal',
                vmin=0, vmax=1.1)
ax.set_title('Mixed DLC ratio (≤1 = satisfied)', fontsize=11)
ax.set_xlabel('$m_1$')
ax.set_ylabel('$m_2$')
plt.colorbar(im2, ax=ax, shrink=0.8)

# Plot 3: -log f (tropical values) showing convexity
ax = axes[2]
trop_grid = np.full((d+1, d+1), np.nan)
for a in range(d+1):
    for b in range(d+1-a):
        c = d - a - b
        val = multinomial((a, b, c))
        if val > 0:
            trop_grid[a, b] = -np.log(val)

im3 = ax.imshow(trop_grid, cmap='viridis', origin='lower', aspect='equal')
ax.set_title('$-\\log f$ (tropical shadow)', fontsize=11)
ax.set_xlabel('$m_1$')
ax.set_ylabel('$m_2$')
plt.colorbar(im3, ax=ax, shrink=0.8)

fig.suptitle('Multivariate Log-Concavity on Degree-8 Slice of $h_8(x_1, x_2, x_3)$',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('heatmap_logconcavity.png', dpi=150, bbox_inches='tight')
print("Saved heatmap_logconcavity.png")
