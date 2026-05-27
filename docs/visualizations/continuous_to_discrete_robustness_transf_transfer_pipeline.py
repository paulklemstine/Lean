#!/usr/bin/env python3
"""
Visualization: The Certified Transfer Pipeline

Illustrates the complete pipeline from continuous density to certified
mixing time, showing each transformation step and its error contribution.

Panels:
1. Continuous Gaussian density (heatmap)
2. Discretized grid weights (heatmap on grid cells)
3. Cell-by-cell error map
4. Mixing time bounds across grid spacings
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.special import erf
from matplotlib.patches import Rectangle
from matplotlib.collections import PatchCollection

def gaussian_2d(x, y, sigma=1.0):
    return np.exp(-(x**2 + y**2) / (2*sigma**2)) / (2*np.pi*sigma**2)

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Continuous density
ax = axes[0, 0]
x = np.linspace(-3, 3, 200)
y = np.linspace(-3, 3, 200)
X, Y = np.meshgrid(x, y)
Z = gaussian_2d(X, Y)
im = ax.contourf(X, Y, Z, levels=30, cmap='viridis')
plt.colorbar(im, ax=ax, label='Density')
ax.set_title('Continuous Gaussian Density', fontsize=13, fontweight='bold')
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.set_aspect('equal')

# Panel 2: Discretized grid
ax = axes[0, 1]
h = 0.5
R = 3.0
sigma = 1.0
n_cells = int(np.ceil(2*R/h))
edges = np.linspace(-R, -R + n_cells*h, n_cells+1)
centers = (edges[:-1] + edges[1:]) / 2

cdf_vals = 0.5 * (1 + erf(edges / (sigma*np.sqrt(2))))
cell_1d = np.diff(cdf_vals)
cell_2d = np.outer(cell_1d, cell_1d)

im2 = ax.pcolormesh(edges, edges, cell_2d.T, cmap='viridis', shading='flat')
plt.colorbar(im2, ax=ax, label='Cell mass')
ax.set_title(f'Grid Discretization ($h={h}$)', fontsize=13, fontweight='bold')
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.set_aspect('equal')

# Panel 3: Error map
ax = axes[1, 0]
density_1d = np.exp(-centers**2 / (2*sigma**2)) / (np.sqrt(2*np.pi)*sigma)
point_1d = density_1d * h
cell_norm = cell_2d / np.sum(cell_2d)
point_2d_norm = np.outer(point_1d, point_1d)
point_2d_norm = point_2d_norm / np.sum(point_2d_norm)

error_map = np.abs(point_2d_norm - cell_norm)
im3 = ax.pcolormesh(edges, edges, error_map.T, cmap='hot', shading='flat')
plt.colorbar(im3, ax=ax, label='|Point - Cell| error')
ax.set_title('Cellwise Discretization Error', fontsize=13, fontweight='bold')
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.set_aspect('equal')

# Panel 4: Mixing time bounds
ax = axes[1, 1]
h_range = np.linspace(0.05, 2.0, 100)
psi = 1.0 / np.sqrt(2*np.pi)
eta = 0.01

mix_times = []
gaps = []
for hh in h_range:
    nc = int(np.ceil(2*5.0/hh))
    e = np.linspace(-5, -5+nc*hh, nc+1)
    c = (e[:-1] + e[1:]) / 2
    cv = 0.5*(1+erf(e/(sigma*np.sqrt(2))))
    ci = np.diff(cv)
    d1 = np.exp(-c**2/(2*sigma**2)) / (np.sqrt(2*np.pi)*sigma)
    p1 = d1 * hh
    cn = np.outer(ci, ci).flatten()
    pn = np.outer(p1, p1).flatten()
    cn = cn / np.sum(cn)
    pn = pn / np.sum(pn)
    cd = np.sum(np.abs(pn - cn))
    N = nc**2
    gap = max(0, psi - 2*cd)
    gaps.append(gap)
    if gap > 0:
        mix_times.append((1/gap) * np.log(N/eta))
    else:
        mix_times.append(np.nan)

ax.semilogy(h_range, mix_times, 'b-', linewidth=2, label='Certified $t_{\\rm mix}$')
ax2 = ax.twinx()
ax2.plot(h_range, gaps, 'r--', linewidth=1.5, alpha=0.7, label='Gap LB')
ax2.axhline(y=psi, color='r', linestyle=':', alpha=0.5)
ax2.set_ylabel('Certified gap', color='r', fontsize=11)
ax2.tick_params(axis='y', labelcolor='r')

ax.set_xlabel('Grid spacing $h$', fontsize=12)
ax.set_ylabel('Mixing time bound', color='b', fontsize=11)
ax.tick_params(axis='y', labelcolor='b')
ax.set_title('Certified Mixing Time vs Grid Spacing', fontsize=13, fontweight='bold')
ax.legend(loc='upper left', fontsize=10)
ax2.legend(loc='upper right', fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Continuous-to-Discrete Robustness Transfer Pipeline',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('pipeline_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
