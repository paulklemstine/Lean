#!/usr/bin/env python3
"""
Visualization: Jacobian Determinant Heatmap for Keller Maps

This script visualizes how the Jacobian determinant of a polynomial map
varies across a 2D domain. For Keller maps, the determinant is constant
(the heatmap should be uniform). For non-Keller maps, the determinant
varies, revealing the geometric structure of the map.

Uses matplotlib to produce a static PNG.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def poly_eval_2d(poly, x, y):
    """Evaluate a 2D polynomial at (x, y)."""
    val = 0.0
    for (ex, ey), c in poly.items():
        val += c * (x ** ex) * (y ** ey)
    return val


def jacobian_det_2d(F1, F2, x, y):
    """Compute Jacobian determinant for 2D map at (x,y)."""
    # ∂F1/∂x
    dF1dx = sum(c * ex * x**(ex-1) * y**ey for (ex, ey), c in F1.items() if ex > 0)
    # ∂F1/∂y
    dF1dy = sum(c * x**ex * ey * y**(ey-1) for (ex, ey), c in F1.items() if ey > 0)
    # ∂F2/∂x
    dF2dx = sum(c * ex * x**(ex-1) * y**ey for (ex, ey), c in F2.items() if ex > 0)
    # ∂F2/∂y
    dF2dy = sum(c * x**ex * ey * y**(ey-1) for (ex, ey), c in F2.items() if ey > 0)
    return dF1dx * dF2dy - dF1dy * dF2dx


# Define maps
# Map 1: Keller map F(x,y) = (x + y³, y) — det(JF) = 1 everywhere
keller_F1 = {(1, 0): 1.0, (0, 3): 1.0}
keller_F2 = {(0, 1): 1.0}

# Map 2: Non-Keller map F(x,y) = (x + xy², y + x²y) — det varies
nonkeller_F1 = {(1, 0): 1.0, (1, 2): 1.0}
nonkeller_F2 = {(0, 1): 1.0, (2, 1): 1.0}

# Map 3: Another Keller (Drużkowski) F(x,y) = (x + (x+y)³, y) — not actually Keller
druz_F1 = {(1, 0): 1.0, (3, 0): 1.0, (2, 1): 3.0, (1, 2): 3.0, (0, 3): 1.0}
druz_F2 = {(0, 1): 1.0}

# Grid
grid_size = 200
x_range = np.linspace(-1.5, 1.5, grid_size)
y_range = np.linspace(-1.5, 1.5, grid_size)
X, Y = np.meshgrid(x_range, y_range)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

maps = [
    ("Keller Map\nF = (x + y³, y)\ndet(JF) = 1", keller_F1, keller_F2),
    ("Non-Keller Map\nF = (x + xy², y + x²y)", nonkeller_F1, nonkeller_F2),
    ("Drużkowski-type\nF = (x + (x+y)³, y)", druz_F1, druz_F2),
]

for ax, (title, F1, F2) in zip(axes, maps):
    Z = np.zeros_like(X)
    for i in range(grid_size):
        for j in range(grid_size):
            Z[i, j] = jacobian_det_2d(F1, F2, X[i, j], Y[i, j])
    
    vmin, vmax = max(Z.min(), -5), min(Z.max(), 5)
    im = ax.imshow(Z, extent=[-1.5, 1.5, -1.5, 1.5], origin='lower',
                   cmap='RdBu_r', vmin=vmin, vmax=vmax, aspect='equal')
    ax.set_title(title, fontsize=11)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    plt.colorbar(im, ax=ax, label='det(JF)')

plt.suptitle('Jacobian Determinant Landscapes\nKeller maps have constant determinant; non-Keller maps show variation',
             fontsize=13, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('jacobian_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved jacobian_heatmap.png")
