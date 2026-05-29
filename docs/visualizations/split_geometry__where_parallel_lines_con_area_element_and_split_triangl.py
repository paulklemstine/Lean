#!/usr/bin/env python3
"""
Visualization 3: Area Element and Split Triangle

Shows the area distortion of the split metric (cosh(x)/cosh(y)) and
demonstrates a split triangle with vertices in all three phase regions.
The area element shows how regions with large |x| are stretched
while regions with large |y| are compressed.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection

# Compute area element field
x = np.linspace(-4, 4, 400)
y = np.linspace(-4, 4, 400)
X, Y = np.meshgrid(x, y)
AE = np.cosh(X) / np.cosh(Y)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Area element heatmap
ax = axes[0]
im = ax.pcolormesh(X, Y, np.log10(AE), cmap='magma', shading='auto',
                   vmin=-1.5, vmax=1.5)
ax.contour(X, Y, AE, levels=[1], colors='white', linewidths=2, linestyles='--')
ax.contour(X, Y, np.abs(Y) - np.abs(X), levels=[0], colors='cyan', 
           linewidths=1.5, linestyles='--')

# Split triangle
v1 = (0.5, 2.5)   # elliptic
v2 = (1.5, 1.5)   # flat boundary
v3 = (3.0, 0.5)   # hyperbolic
triangle = Polygon([v1, v2, v3], fill=False, edgecolor='lime', 
                   linewidth=3, linestyle='-')
ax.add_patch(triangle)

ax.plot(*v1, 'o', color='blue', markersize=12, zorder=5, label='Elliptic vertex')
ax.plot(*v2, 's', color='white', markersize=10, zorder=5, label='Flat vertex')
ax.plot(*v3, '^', color='red', markersize=12, zorder=5, label='Hyperbolic vertex')

ax.set_xlabel('x', fontsize=14)
ax.set_ylabel('y', fontsize=14)
ax.set_title('Area Element log₁₀(cosh(x)/cosh(y))\nwith Split Triangle', fontsize=14)
ax.set_aspect('equal')
ax.legend(fontsize=10, loc='lower right')
cbar = fig.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('log₁₀(area element)', fontsize=12)

# Right: Cross-sections of area element
ax2 = axes[1]
t = np.linspace(-4, 4, 500)

# Along x-axis
ae_xaxis = np.cosh(t) / np.cosh(0)
ax2.plot(t, ae_xaxis, 'r-', linewidth=2, label='cosh(t)/cosh(0) = cosh(t) — along y=0')

# Along y-axis
ae_yaxis = np.cosh(0) / np.cosh(t)
ax2.plot(t, ae_yaxis, 'b-', linewidth=2, label='cosh(0)/cosh(t) = sech(t) — along x=0')

# Along diagonal
ae_diag = np.cosh(t) / np.cosh(t)
ax2.plot(t, ae_diag, 'k-', linewidth=2, label='cosh(t)/cosh(t) = 1 — along y=x')

# Along y = 2t
ae_slope = np.cosh(t) / np.cosh(2*t)
ax2.plot(t, ae_slope, 'g-', linewidth=2, label='cosh(t)/cosh(2t) — along y=2x')

ax2.axhline(y=1, color='gray', linestyle=':', linewidth=0.5)
ax2.set_xlabel('t', fontsize=14)
ax2.set_ylabel('Area element', fontsize=14)
ax2.set_title('Area Distortion Along Different Lines', fontsize=14)
ax2.set_ylim(0, 5)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Annotate the key insight
ax2.annotate('Area grows exponentially\nalong x-axis', 
             xy=(3, np.cosh(3)), xytext=(1.5, 4),
             fontsize=10, color='red',
             arrowprops=dict(arrowstyle='->', color='red'))
ax2.annotate('Area shrinks exponentially\nalong y-axis',
             xy=(3, 1/np.cosh(3)), xytext=(1.5, 1.5),
             fontsize=10, color='blue',
             arrowprops=dict(arrowstyle='->', color='blue'))

plt.tight_layout()
plt.savefig('area_element.png', dpi=150, bbox_inches='tight')
print("Saved area_element.png")
