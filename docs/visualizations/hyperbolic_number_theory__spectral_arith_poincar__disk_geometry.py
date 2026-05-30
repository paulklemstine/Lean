"""
Visualization 2: The Poincaré Disk and Hyperbolic Distance

Illustrates:
1. The Poincaré disk with hyperbolic geodesics
2. The conformal factor λ(z) = 2/(1-|z|²) as a heatmap
3. Pseudo-hyperbolic distance contours
4. Möbius orbits showing how the group action generates lattice points
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(2, 2, figsize=(14, 14))

# Panel 1: Poincaré disk with geodesics
ax = axes[0, 0]
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')

# Draw some hyperbolic geodesics (circular arcs perpendicular to boundary)
for a in np.linspace(-0.8, 0.8, 9):
    # Vertical geodesic through (a, 0): this is a circular arc
    if abs(a) < 0.01:
        ax.plot([0, 0], [-1, 1], 'b-', alpha=0.3, linewidth=0.8)
    else:
        # Center of the geodesic circle: (1/a, 0), radius sqrt(1/a²-1)
        R = np.sqrt(1/a**2 - 1) if abs(a) < 1 else 1
        cx = 1/a
        t = np.linspace(-np.pi, np.pi, 500)
        gx = cx + R * np.cos(t)
        gy = R * np.sin(t)
        mask = gx**2 + gy**2 < 1
        gx_masked = np.where(mask, gx, np.nan)
        gy_masked = np.where(mask, gy, np.nan)
        ax.plot(gx_masked, gy_masked, 'b-', alpha=0.3, linewidth=0.8)

# Horizontal geodesics
for b in np.linspace(-0.8, 0.8, 9):
    if abs(b) < 0.01:
        ax.plot([-1, 1], [0, 0], 'r-', alpha=0.3, linewidth=0.8)
    else:
        R = np.sqrt(1/b**2 - 1) if abs(b) < 1 else 1
        cy = 1/b
        t = np.linspace(-np.pi, np.pi, 500)
        gx = R * np.cos(t)
        gy = cy + R * np.sin(t)
        mask = gx**2 + gy**2 < 1
        gx_masked = np.where(mask, gx, np.nan)
        gy_masked = np.where(mask, gy, np.nan)
        ax.plot(gx_masked, gy_masked, 'r-', alpha=0.3, linewidth=0.8)

ax.set_title('Poincaré Disk with Geodesic Grid', fontsize=13)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)

# Panel 2: Conformal factor heatmap
ax = axes[0, 1]
x = np.linspace(-0.99, 0.99, 400)
y = np.linspace(-0.99, 0.99, 400)
X, Y = np.meshgrid(x, y)
R2 = X**2 + Y**2
mask = R2 < 1

# λ(z) = 2/(1-|z|²)
Lambda = np.where(mask, 2.0 / (1.0 - R2), np.nan)

im = ax.imshow(Lambda, extent=[-1, 1, -1, 1], origin='lower',
               cmap='hot', vmin=2, vmax=20, aspect='equal')
ax.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)
plt.colorbar(im, ax=ax, label='λ(z) = 2/(1-|z|²)')
ax.set_title('Conformal Factor (proved λ ≥ 2)', fontsize=13)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)

# Panel 3: Pseudo-hyperbolic distance contours from origin
ax = axes[1, 0]
# ρ(0, z) = |z|, so the contours are just circles
rho_vals = np.where(mask, np.sqrt(R2), np.nan)
contour = ax.contourf(X, Y, rho_vals, levels=np.linspace(0, 0.99, 20),
                        cmap='viridis', extend='max')
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
plt.colorbar(contour, ax=ax, label='ρ(0, z)')
ax.set_aspect('equal')
ax.set_title('Pseudo-Hyperbolic Distance from Origin', fontsize=13)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.plot(0, 0, 'w*', markersize=15, markeredgecolor='k')

# Panel 4: Möbius orbits
ax = axes[1, 1]
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')

def mobius_map(a_re, a_im, z_re, z_im):
    """φ_a(z) = (a + z) / (1 + conj(a)*z)"""
    # numerator = a + z
    num_re = a_re + z_re
    num_im = a_im + z_im
    # conj(a)*z = (a_re - i*a_im)*(z_re + i*z_im)
    conj_a_z_re = a_re * z_re + a_im * z_im
    conj_a_z_im = a_re * z_im - a_im * z_re
    # denominator = 1 + conj(a)*z
    den_re = 1 + conj_a_z_re
    den_im = conj_a_z_im
    # division
    den_sq = den_re**2 + den_im**2
    if den_sq < 1e-12:
        return z_re, z_im
    result_re = (num_re * den_re + num_im * den_im) / den_sq
    result_im = (num_im * den_re - num_re * den_im) / den_sq
    return result_re, result_im

# Generate orbit of 0 under two generators
generators = [(0.5, 0.0), (0.0, 0.5), (-0.3, 0.4), (0.4, -0.3)]
colors = ['red', 'blue', 'green', 'orange']

orbit_points = [(0.0, 0.0)]
for gen_idx, (ga, gb) in enumerate(generators):
    # Apply generator and its inverse repeatedly
    current = [(0.0, 0.0)]
    for depth in range(6):
        new_points = []
        for z_re, z_im in current:
            w_re, w_im = mobius_map(ga, gb, z_re, z_im)
            if w_re**2 + w_im**2 < 0.999:
                new_points.append((w_re, w_im))
                orbit_points.append((w_re, w_im))
            # Also inverse
            w_re2, w_im2 = mobius_map(-ga, -gb, z_re, z_im)
            if w_re2**2 + w_im2**2 < 0.999:
                new_points.append((w_re2, w_im2))
                orbit_points.append((w_re2, w_im2))
        current = new_points

# Plot orbit points
xs = [p[0] for p in orbit_points]
ys = [p[1] for p in orbit_points]
ax.scatter(xs, ys, c='navy', s=8, alpha=0.6, zorder=5)
ax.plot(0, 0, 'r*', markersize=15, markeredgecolor='k', zorder=10)

# Mark generators
for (ga, gb), c in zip(generators, colors):
    ax.plot(ga, gb, 'o', color=c, markersize=10, markeredgecolor='k',
            zorder=10, label=f'gen ({ga},{gb})')

ax.set_title(f'Möbius Orbits ({len(orbit_points)} lattice points)', fontsize=13)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.legend(fontsize=8, loc='lower right')

plt.suptitle('Poincaré Disk: Geometry of Hyperbolic Number Theory',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_poincare_disk.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_poincare_disk.png")
