#!/usr/bin/env python3
"""
Oracle Bootstrap: Julia Set in the Complex Plane
=================================================

The bootstrap map f(z) = 3z² - 2z³ extended to complex numbers
creates a stunning fractal Julia set — the boundary between the
basins of attraction of the two superattractors (0 and 1).

This boundary is the "cosmic web" — the fractal structure separating
regions of void (→ 0) from regions of condensation (→ 1).

Run: python julia_set_fractal.py
Outputs: julia_set.png, julia_set_zoom.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

def compute_julia(xmin, xmax, ymin, ymax, width, height, max_iter=200):
    """Compute the Julia set of f(z) = 3z² - 2z³.

    Color by which attractor the orbit converges to:
    - Basin of 0 (Void): cool colors
    - Basin of 1 (Attractor): warm colors
    - Basin boundary (Julia set): black/fractal edge

    Returns: convergence array, basin array
    """
    x = np.linspace(xmin, xmax, width)
    y = np.linspace(ymin, ymax, height)
    X, Y = np.meshgrid(x, y)
    Z = X + 1j * Y

    # Track convergence
    converge_count = np.full(Z.shape, max_iter, dtype=float)
    basin = np.zeros(Z.shape, dtype=int)  # 0=undetermined, 1=void, 2=attractor
    active = np.ones(Z.shape, dtype=bool)

    Z_current = Z.copy()

    for i in range(max_iter):
        # f(z) = 3z² - 2z³
        Z_new = 3 * Z_current**2 - 2 * Z_current**3

        # Check convergence to 0
        converged_to_0 = active & (np.abs(Z_new) < 1e-6)
        converge_count[converged_to_0] = i
        basin[converged_to_0] = 1
        active[converged_to_0] = False

        # Check convergence to 1
        converged_to_1 = active & (np.abs(Z_new - 1) < 1e-6)
        converge_count[converged_to_1] = i
        basin[converged_to_1] = 2
        active[converged_to_1] = False

        # Check divergence
        diverged = active & (np.abs(Z_new) > 100)
        converge_count[diverged] = i
        active[diverged] = False

        Z_current[active] = Z_new[active]

    return converge_count, basin

# ══════════════════════════════════════════════════════
# Full Julia set view
# ══════════════════════════════════════════════════════
print("Computing full Julia set...")
W, H = 800, 800
conv, basin = compute_julia(-0.5, 1.5, -1.0, 1.0, W, H, max_iter=150)

# Create custom colormap
fig, ax = plt.subplots(1, 1, figsize=(14, 14))

# Color scheme: blue=void basin, red=attractor basin, smooth by convergence speed
image = np.zeros((H, W, 3))

# Void basin (blue-cyan)
void_mask = basin == 1
speed_void = conv[void_mask] / 150
image[void_mask, 0] = 0.0  # R
image[void_mask, 1] = 0.1 + 0.5 * (1 - speed_void)  # G
image[void_mask, 2] = 0.2 + 0.8 * (1 - speed_void)  # B

# Attractor basin (red-orange)
attr_mask = basin == 2
speed_attr = conv[attr_mask] / 150
image[attr_mask, 0] = 0.3 + 0.7 * (1 - speed_attr)  # R
image[attr_mask, 1] = 0.05 + 0.3 * (1 - speed_attr)  # G
image[attr_mask, 2] = 0.0  # B

# Boundary / non-converged (dark)
boundary = (basin == 0)
image[boundary] = [0.02, 0.02, 0.05]

ax.imshow(image, extent=[-0.5, 1.5, -1.0, 1.0], origin='lower', aspect='equal')

# Mark fixed points
ax.plot(0, 0, 'o', color='cyan', markersize=10, markeredgecolor='white', markeredgewidth=2, zorder=10)
ax.plot(1, 0, 'o', color='orange', markersize=10, markeredgecolor='white', markeredgewidth=2, zorder=10)
ax.plot(0.5, 0, 'o', color='white', markersize=8, markeredgecolor='black', markeredgewidth=2, zorder=10)

ax.annotate('Void\nAttractor', xy=(0, 0), xytext=(-0.3, 0.3),
           color='cyan', fontsize=12, fontweight='bold',
           arrowprops=dict(arrowstyle='->', color='cyan', lw=2))
ax.annotate('Great\nAttractor', xy=(1, 0), xytext=(1.2, 0.3),
           color='orange', fontsize=12, fontweight='bold',
           arrowprops=dict(arrowstyle='->', color='orange', lw=2))
ax.annotate('Great\nRepeller', xy=(0.5, 0), xytext=(0.5, -0.5),
           color='white', fontsize=12, fontweight='bold', ha='center',
           arrowprops=dict(arrowstyle='->', color='white', lw=2))

ax.set_xlabel('Re(z)', fontsize=14, color='white')
ax.set_ylabel('Im(z)', fontsize=14, color='white')
ax.set_title('Julia Set of f(z) = 3z² − 2z³: The Cosmic Web\n'
             'Blue = Void Basin (→ 0)  |  Red = Attractor Basin (→ 1)  |  Black = Fractal Boundary',
             fontsize=14, fontweight='bold', color='white', pad=20)
ax.tick_params(colors='gray')
fig.patch.set_facecolor('black')
ax.set_facecolor('black')

plt.savefig('/workspace/request-project/core/Oracle/CosmicBootstrap/demos/julia_set.png',
            dpi=150, bbox_inches='tight', facecolor='black')
plt.close()
print("✓ Generated: julia_set.png")

# ══════════════════════════════════════════════════════
# Zoomed view near the repeller
# ══════════════════════════════════════════════════════
print("Computing zoomed Julia set near repeller...")
conv_z, basin_z = compute_julia(0.35, 0.65, -0.15, 0.15, 800, 400, max_iter=200)

fig, ax = plt.subplots(figsize=(16, 8))
image_z = np.zeros((400, 800, 3))

void_mask = basin_z == 1
speed_void = conv_z[void_mask] / 200
image_z[void_mask, 0] = 0.0
image_z[void_mask, 1] = 0.1 + 0.6 * (1 - speed_void)
image_z[void_mask, 2] = 0.2 + 0.8 * (1 - speed_void)

attr_mask = basin_z == 2
speed_attr = conv_z[attr_mask] / 200
image_z[attr_mask, 0] = 0.3 + 0.7 * (1 - speed_attr)
image_z[attr_mask, 1] = 0.05 + 0.3 * (1 - speed_attr)
image_z[attr_mask, 2] = 0.0

boundary = basin_z == 0
image_z[boundary] = [0.02, 0.02, 0.05]

ax.imshow(image_z, extent=[0.35, 0.65, -0.15, 0.15], origin='lower', aspect='equal')
ax.plot(0.5, 0, 'o', color='white', markersize=8, markeredgecolor='black', markeredgewidth=2, zorder=10)

ax.set_xlabel('Re(z)', fontsize=14, color='white')
ax.set_ylabel('Im(z)', fontsize=14, color='white')
ax.set_title('Zoomed: Fractal Basin Boundary Near the Great Repeller (z = ½)\n'
             'The cosmic web at the unstable equilibrium — infinite complexity at the divide',
             fontsize=13, fontweight='bold', color='white', pad=15)
ax.tick_params(colors='gray')
fig.patch.set_facecolor('black')
ax.set_facecolor('black')

plt.savefig('/workspace/request-project/core/Oracle/CosmicBootstrap/demos/julia_set_zoom.png',
            dpi=150, bbox_inches='tight', facecolor='black')
plt.close()
print("✓ Generated: julia_set_zoom.png")
