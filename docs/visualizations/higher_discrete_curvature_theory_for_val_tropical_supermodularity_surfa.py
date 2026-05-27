#!/usr/bin/env python3
"""
Visualization 3: Tropical Supermodularity Surface

Visualizes the energy landscape -log f for a 2D function, showing the
supermodularity structure that arises from mixed log-concavity.
The surface plot reveals the tropical convexity of the valuation.

Also plots the "supermodularity defect" heatmap showing where
the supermodular inequality is tight vs slack.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, exp
from mpl_toolkits.mplot3d import Axes3D


def make_mixed_lc_function(a=1.0, b=0.5, c=0.3):
    """Create a 2D function that is mixed log-concave.
    f(x,y) = exp(-a*x^2 - b*y^2 - c*x*y) with a*b > (c/2)^2."""
    def f(m):
        x, y = m[0], m[1]
        return exp(-a * x**2 - b * y**2 - c * x * y)
    return f


def neg_log(f, m):
    v = f(m)
    if v > 1e-15:
        return -log(v)
    return float('nan')


def supermodular_defect(f, m, i, j, n=2):
    """Compute g(m+ei+ej) + g(m) - g(m+ei) - g(m+ej) for g = -log f."""
    ei = tuple(1 if k == i else 0 for k in range(n))
    ej = tuple(1 if k == j else 0 for k in range(n))
    m_ij = tuple(a + b + c for a, b, c in zip(m, ei, ej))
    m_i = tuple(a + b for a, b in zip(m, ei))
    m_j = tuple(a + b for a, b in zip(m, ej))

    vals = [f(m), f(m_i), f(m_j), f(m_ij)]
    if any(v <= 1e-15 for v in vals):
        return float('nan')

    g = [-log(v) for v in vals]
    return g[3] + g[0] - g[1] - g[2]  # Should be >= 0 for supermodular


# Create figure with two subplots
fig = plt.figure(figsize=(16, 7))

# --- Left panel: Energy surface ---
ax1 = fig.add_subplot(121, projection='3d')

f = make_mixed_lc_function(a=0.8, b=0.6, c=0.4)

x_range = np.arange(0, 8)
y_range = np.arange(0, 8)
X, Y = np.meshgrid(x_range, y_range)
Z = np.zeros_like(X, dtype=float)

for i in range(len(x_range)):
    for j in range(len(y_range)):
        Z[j, i] = neg_log(f, (int(x_range[i]), int(y_range[j])))

surf = ax1.plot_surface(X, Y, Z, cmap='coolwarm', alpha=0.8,
                        edgecolor='black', linewidth=0.3)
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('y', fontsize=12)
ax1.set_zlabel('-log f(x,y)', fontsize=12)
ax1.set_title('Energy Landscape: -log f\n(Tropical Potential)', fontsize=14)
ax1.view_init(elev=25, azim=-60)

# --- Right panel: Supermodularity defect heatmap ---
ax2 = fig.add_subplot(122)

x_range2 = np.arange(0, 10)
y_range2 = np.arange(0, 10)
defect = np.zeros((len(y_range2), len(x_range2)))

for i, x in enumerate(x_range2):
    for j, y in enumerate(y_range2):
        defect[j, i] = supermodular_defect(f, (int(x), int(y)), 0, 1)

# Replace NaN with 0 for visualization
defect_clean = np.nan_to_num(defect, nan=0.0)

im = ax2.imshow(defect_clean, extent=[x_range2[0]-0.5, x_range2[-1]+0.5,
                                       y_range2[0]-0.5, y_range2[-1]+0.5],
                origin='lower', cmap='YlOrRd', aspect='equal',
                interpolation='nearest')

ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('y', fontsize=12)
ax2.set_title('Supermodularity Defect\n'
              r'$g(m+e_i+e_j) + g(m) - g(m+e_i) - g(m+e_j) \geq 0$',
              fontsize=14)

cbar = plt.colorbar(im, ax=ax2)
cbar.set_label('Defect (≥0 means supermodular)', fontsize=11)

# Add annotation about mixed log-concavity
min_defect = np.nanmin(defect)
ax2.text(0.02, 0.98,
         f'Min defect: {min_defect:.4f}\n'
         f'Supermodular: {"Yes ✓" if min_defect >= -1e-12 else "No ✗"}',
         transform=ax2.transAxes, va='top', fontsize=11,
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.suptitle('Tropical Convexity from Mixed Log-Concavity',
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('tropical_supermodularity.png', dpi=150, bbox_inches='tight')
print("Saved tropical_supermodularity.png")
