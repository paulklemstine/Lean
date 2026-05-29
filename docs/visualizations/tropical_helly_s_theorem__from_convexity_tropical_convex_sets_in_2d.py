#!/usr/bin/env python3
"""
Visualization: Tropical Convex Sets in 2D

Visualizes tropical convex sets (intersections of tropical halfspaces)
in ℝ², showing their characteristic angular, crystalline structure.
Compares tropical and classical convex sets side by side.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.colors import LinearSegmentedColormap


def in_tropical_halfspace(x, y, a, b):
    """Check if (x, y) ∈ H(a, b) = {z | max(a_0+z_0, a_1+z_1) >= b}."""
    return np.maximum(a[0] + x, a[1] + y) >= b


def tropical_combination_2d(x1, y1, x2, y2, s, t):
    """Tropical combination of two 2D points."""
    return np.maximum(s + x1, t + x2), np.maximum(s + y1, t + y2)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Grid
grid_res = 500
xx = np.linspace(-4, 6, grid_res)
yy = np.linspace(-4, 6, grid_res)
X, Y = np.meshgrid(xx, yy)

# --- Panel 1: Single tropical halfspace ---
ax = axes[0]
a1 = np.array([1.0, -0.5])
b1 = 2.0
mask = in_tropical_halfspace(X, Y, a1, b1)

cmap1 = LinearSegmentedColormap.from_list('trop', ['#fff5f0', '#e41a1c'])
ax.contourf(X, Y, mask.astype(float), levels=[0.5, 1.5], colors=['#fdd49e'], alpha=0.7)
ax.contour(X, Y, mask.astype(float), levels=[0.5], colors=['#e41a1c'], linewidths=2)
ax.set_title('Tropical Halfspace\n$\\max(1+x, -0.5+y) \\geq 2$', fontsize=12)
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.set_xlim(-4, 6)
ax.set_ylim(-4, 6)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 2: Intersection of 3 tropical halfspaces ---
ax = axes[1]
halfspaces = [
    (np.array([1.0, 0.0]), 1.0),
    (np.array([0.0, 1.0]), 0.5),
    (np.array([-0.5, 0.5]), -0.5),
]

mask_all = np.ones_like(X, dtype=bool)
colors_hs = ['#e41a1c', '#377eb8', '#4daf4a']

for i, (a, b) in enumerate(halfspaces):
    mask_i = in_tropical_halfspace(X, Y, a, b)
    ax.contour(X, Y, mask_i.astype(float), levels=[0.5], colors=[colors_hs[i]], 
               linewidths=1.5, linestyles='--', alpha=0.6)
    mask_all &= mask_i

ax.contourf(X, Y, mask_all.astype(float), levels=[0.5, 1.5], colors=['#b2df8a'], alpha=0.8)
ax.contour(X, Y, mask_all.astype(float), levels=[0.5], colors=['#33a02c'], linewidths=2.5)

# Mark the Farkas witness point
A = np.array([h[0] for h in halfspaces])
b_vec = np.array([h[1] for h in halfspaces])
x_farkas = np.array([np.max(b_vec - A[:, i]) for i in range(2)])
ax.plot(x_farkas[0], x_farkas[1], 'k*', markersize=15, zorder=5, label='Farkas point')

ax.set_title('Intersection of 3\nTropical Halfspaces', fontsize=12)
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.set_xlim(-4, 6)
ax.set_ylim(-4, 6)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(loc='upper left', fontsize=9)

# --- Panel 3: Tropical convex hull of 3 points ---
ax = axes[2]
points = np.array([[0, 0], [4, 1], [1, 4]], dtype=float)

# Generate tropical convex hull by sampling combinations
hull_x, hull_y = [], []
for i in range(len(points)):
    for j in range(len(points)):
        for s in np.linspace(-5, 0, 100):
            zx, zy = tropical_combination_2d(
                points[i, 0], points[i, 1],
                points[j, 0], points[j, 1],
                s, 0.0
            )
            hull_x.append(zx)
            hull_y.append(zy)
            zx, zy = tropical_combination_2d(
                points[i, 0], points[i, 1],
                points[j, 0], points[j, 1],
                0.0, s
            )
            hull_x.append(zx)
            hull_y.append(zy)

hull_x = np.array(hull_x)
hull_y = np.array(hull_y)

# Plot hull as scatter (density shows the hull shape)
ax.scatter(hull_x, hull_y, c='#fdd49e', s=1, alpha=0.3, zorder=1)

# Plot generators
for i, p in enumerate(points):
    ax.plot(p[0], p[1], 'o', color=colors_hs[i], markersize=10, zorder=5, 
            label=f'$p_{i+1}$ = ({p[0]:.0f}, {p[1]:.0f})')

# Tropical segments between pairs
for i in range(len(points)):
    for j in range(i+1, len(points)):
        seg_x, seg_y = [], []
        for s in np.linspace(-5, 0, 200):
            zx, zy = tropical_combination_2d(
                points[i, 0], points[i, 1],
                points[j, 0], points[j, 1],
                s, 0.0
            )
            seg_x.append(zx)
            seg_y.append(zy)
            zx, zy = tropical_combination_2d(
                points[i, 0], points[i, 1],
                points[j, 0], points[j, 1],
                0.0, s
            )
            seg_x.append(zx)
            seg_y.append(zy)
        ax.plot(seg_x, seg_y, '.', markersize=2, color='#ff7f00', alpha=0.5, zorder=2)

ax.set_title('Tropical Convex Hull\nof 3 Points', fontsize=12)
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.set_xlim(-2, 6)
ax.set_ylim(-2, 6)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(loc='upper left', fontsize=8)

plt.tight_layout()
plt.savefig('tropical_convexity.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: tropical_convexity.png")
