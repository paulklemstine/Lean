#!/usr/bin/env python3
"""
Visualization 1: Split Geometry Curvature Field

Visualizes the Gaussian curvature K(x,y) = sech²(x) - sech²(y) as a heatmap,
showing the elliptic (K > 0), flat (K = 0), and hyperbolic (K < 0) regions.
The phase boundaries along y = ±x are clearly visible as the zero contour.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

def sech(x):
    return 1.0 / np.cosh(x)

# Compute curvature field
x = np.linspace(-4, 4, 500)
y = np.linspace(-4, 4, 500)
X, Y = np.meshgrid(x, y)
K = sech(X)**2 - sech(Y)**2

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Curvature heatmap
ax = axes[0]
norm = mcolors.TwoSlopeNorm(vmin=-1, vcenter=0, vmax=1)
im = ax.pcolormesh(X, Y, K, cmap='RdBu_r', norm=norm, shading='auto')
ax.contour(X, Y, K, levels=[0], colors='black', linewidths=2)
ax.plot([-4, 4], [-4, 4], 'k--', linewidth=1, alpha=0.5, label='y = x')
ax.plot([-4, 4], [4, -4], 'k--', linewidth=1, alpha=0.5, label='y = -x')
ax.set_xlabel('x', fontsize=14)
ax.set_ylabel('y', fontsize=14)
ax.set_title('Split Geometry: Gaussian Curvature K(x,y)', fontsize=14)
ax.set_aspect('equal')
ax.legend(fontsize=11)
cbar = fig.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('K = sech²(x) − sech²(y)', fontsize=12)

# Annotate regions
ax.text(0, 2.5, 'ELLIPTIC\nK > 0', ha='center', va='center', 
        fontsize=13, fontweight='bold', color='darkblue',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax.text(0, -2.5, 'ELLIPTIC\nK > 0', ha='center', va='center',
        fontsize=13, fontweight='bold', color='darkblue',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax.text(2.5, 0, 'HYPERBOLIC\nK < 0', ha='center', va='center',
        fontsize=13, fontweight='bold', color='darkred',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax.text(-2.5, 0, 'HYPERBOLIC\nK < 0', ha='center', va='center',
        fontsize=13, fontweight='bold', color='darkred',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Right: Curvature along specific lines
ax2 = axes[1]
t = np.linspace(-4, 4, 500)

# Along x-axis (y=0)
K_xaxis = sech(t)**2 - sech(0)**2
ax2.plot(t, K_xaxis, 'r-', linewidth=2, label='K(t, 0) — x-axis')

# Along y-axis (x=0)
K_yaxis = sech(0)**2 - sech(t)**2
ax2.plot(t, K_yaxis, 'b-', linewidth=2, label='K(0, t) — y-axis')

# Along diagonal
K_diag = sech(t)**2 - sech(t)**2
ax2.plot(t, K_diag, 'k-', linewidth=2, label='K(t, t) — diagonal')

# Along line y = 2x
K_line = sech(t)**2 - sech(2*t)**2
ax2.plot(t, K_line, 'g-', linewidth=2, label='K(t, 2t)')

ax2.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
ax2.axhline(y=1, color='gray', linestyle=':', linewidth=0.5)
ax2.axhline(y=-1, color='gray', linestyle=':', linewidth=0.5)
ax2.set_xlabel('t', fontsize=14)
ax2.set_ylabel('K', fontsize=14)
ax2.set_title('Curvature Along Different Lines', fontsize=14)
ax2.set_ylim(-1.1, 1.1)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('curvature_field.png', dpi=150, bbox_inches='tight')
print("Saved curvature_field.png")
