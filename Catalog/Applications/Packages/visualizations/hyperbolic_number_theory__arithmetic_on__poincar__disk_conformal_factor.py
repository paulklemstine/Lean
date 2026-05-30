#!/usr/bin/env python3
"""
Visualization: Poincaré Disk Conformal Factor

Heatmap showing the conformal factor λ(z) = 2/(1 - |z|²) across the
Poincaré disk. This factor describes how much the hyperbolic metric
stretches distances compared to the Euclidean metric.

Key proved properties visualized:
- λ(0) = 2 (minimum at the center)
- λ(z) ≥ 2 everywhere (proved in Lean as poincareConformal_ge_two)
- λ(z) → ∞ as |z| → 1 (distances diverge near the boundary)
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


# Create grid
resolution = 500
x = np.linspace(-1, 1, resolution)
y = np.linspace(-1, 1, resolution)
X, Y = np.meshgrid(x, y)
R2 = X**2 + Y**2

# Compute conformal factor (only inside disk)
mask = R2 < 0.999
Lambda = np.full_like(R2, np.nan)
Lambda[mask] = 2.0 / (1.0 - R2[mask])

# Plot
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap
ax1 = axes[0]
im = ax1.imshow(Lambda, extent=[-1, 1, -1, 1], origin='lower',
                cmap='inferno', norm=LogNorm(vmin=2, vmax=200),
                interpolation='bilinear')

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)

# Mark origin
ax1.plot(0, 0, 'co', markersize=8, label='Origin: λ = 2')

ax1.set_xlim(-1.1, 1.1)
ax1.set_ylim(-1.1, 1.1)
ax1.set_aspect('equal')
ax1.set_title('Conformal Factor λ(z) = 2/(1 - |z|²)', fontsize=13, fontweight='bold')
ax1.set_xlabel('Re(z)', fontsize=11)
ax1.set_ylabel('Im(z)', fontsize=11)
ax1.legend(fontsize=10)

cbar = plt.colorbar(im, ax=ax1, shrink=0.8)
cbar.set_label('λ(z)', fontsize=11)

# Radial profile
ax2 = axes[1]
r_vals = np.linspace(0, 0.999, 500)
lambda_vals = 2.0 / (1.0 - r_vals**2)

ax2.semilogy(r_vals, lambda_vals, 'b-', linewidth=2, label='λ(r) = 2/(1-r²)')
ax2.axhline(y=2, color='red', linestyle='--', alpha=0.7, label='λ = 2 (minimum)')
ax2.fill_between(r_vals, 2, lambda_vals, alpha=0.1, color='blue')

ax2.set_xlabel('Euclidean distance from origin (r)', fontsize=11)
ax2.set_ylabel('Conformal factor λ(r)', fontsize=11)
ax2.set_title('Radial Profile: λ ≥ 2 Everywhere', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_xlim(0, 1)
ax2.set_ylim(1.5, 500)
ax2.grid(True, alpha=0.3)

# Annotate key points
ax2.annotate('Flat (Euclidean-like)',
             xy=(0.1, 2.02), fontsize=9, color='green',
             arrowprops=dict(arrowstyle='->', color='green'),
             xytext=(0.2, 5))
ax2.annotate('Highly curved\n(near boundary)',
             xy=(0.95, 40), fontsize=9, color='red',
             arrowprops=dict(arrowstyle='->', color='red'),
             xytext=(0.6, 100))

plt.tight_layout()
plt.savefig('viz_conformal_factor.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_conformal_factor.png")
