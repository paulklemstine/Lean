#!/usr/bin/env python3
"""
Visualization 3: Conformal Factor and Hyperbolic Metric

Shows how the Poincaré disk metric stretches near the boundary,
and visualizes the pseudo-hyperbolic distance between points.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Conformal factor heatmap
ax1 = axes[0]
x = np.linspace(-0.99, 0.99, 400)
y = np.linspace(-0.99, 0.99, 400)
X, Y = np.meshgrid(x, y)
R2 = X**2 + Y**2
mask = R2 < 1

# Conformal factor: λ(z) = 2/(1-|z|²)
conf_factor = np.where(mask, 2 / (1 - R2), np.nan)

im = ax1.pcolormesh(X, Y, conf_factor, cmap='inferno', norm=LogNorm(vmin=2, vmax=200),
                    shading='auto')
# Draw unit circle
theta = np.linspace(0, 2 * np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)
ax1.set_aspect('equal')
ax1.set_title('Conformal Factor λ(z) = 2/(1-|z|²)\n'
              'Diverges at boundary → infinite area', fontsize=11)
ax1.set_xlabel('x')
ax1.set_ylabel('y')
plt.colorbar(im, ax=ax1, label='λ(z)', shrink=0.8)

# Panel 2: Conformal factor along radius
ax2 = axes[1]
r = np.linspace(0, 0.999, 500)
lam = 2 / (1 - r**2)

ax2.semilogy(r, lam, 'b-', linewidth=2)
ax2.axhline(y=2, color='red', linestyle='--', alpha=0.5, label='λ(0) = 2 (minimum)')
ax2.fill_between(r, 2, lam, alpha=0.1, color='blue')
ax2.set_xlabel('Radius r = |z|', fontsize=12)
ax2.set_ylabel('Conformal factor λ(r)', fontsize=12)
ax2.set_title('Conformal Factor vs. Radius\n'
              'Proven: λ(r) ≥ 2 for all r ∈ [0,1)', fontsize=11)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 1)

# Panel 3: Pseudo-hyperbolic distance from origin
ax3 = axes[2]

def pseudo_hyp_dist_sq(px, py, qx, qy):
    num = (px - qx)**2 + (py - qy)**2
    den = (1 - px*qx - py*qy)**2 + (px*qy - py*qx)**2
    return num / den if den > 0 else 0

# Distance from a fixed point (0.3, 0.2)
px, py = 0.3, 0.2
dist = np.zeros_like(X)
for i in range(X.shape[0]):
    for j in range(X.shape[1]):
        if mask[i, j]:
            dist[i, j] = pseudo_hyp_dist_sq(px, py, X[i, j], Y[i, j])
        else:
            dist[i, j] = np.nan

# Use arctanh for actual hyperbolic distance
hyp_dist = np.where(mask & (dist < 1), 2 * np.arctanh(np.sqrt(np.maximum(dist, 0))), np.nan)

im3 = ax3.pcolormesh(X, Y, hyp_dist, cmap='viridis', shading='auto',
                     vmin=0, vmax=5)
ax3.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)
ax3.plot(px, py, 'r*', markersize=15, zorder=10)
ax3.annotate(f'({px}, {py})', (px, py), textcoords="offset points",
             xytext=(10, 10), color='white', fontsize=10, fontweight='bold')
ax3.set_aspect('equal')
ax3.set_title(f'Hyperbolic Distance from ({px}, {py})\n'
              f'd(z,w) = 2·arctanh(√δ(z,w))', fontsize=11)
ax3.set_xlabel('x')
ax3.set_ylabel('y')
plt.colorbar(im3, ax=ax3, label='Hyperbolic distance', shrink=0.8)

plt.suptitle('The Poincaré Disk: Geometry of Curved Space',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('conformal_factor.png', dpi=150, bbox_inches='tight')
plt.close()
print("Generated conformal factor visualization")
