"""
Visualization: Möbius Transformation Dynamics and Involution

Demonstrates the theorem moebius_inverse: φ_{-a}(φ_a(z)) = z.
Shows how Möbius transformations create fractal-like orbit structures
on the Poincaré disk, connecting hyperbolic geometry to dynamics.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

# --- Self-contained helpers ---

def moebius_map(a, z):
    """Möbius transformation φ_a(z) = (z - a) / (1 - conj(a) * z)."""
    return (z - a) / (1 - np.conj(a) * z)

def pseudo_hyp_dist(z, w):
    """Pseudo-hyperbolic distance."""
    return abs(moebius_map(w, z))

def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5)+1):
        if n % i == 0: return False
    return True

# --- Create figure ---
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Inverse property demonstration
ax = axes[0]
ax.set_aspect('equal')
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)

circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

a = 0.4 + 0.25j
test_points = [
    0.1 + 0.3j, -0.3 + 0.5j, 0.6 - 0.2j,
    -0.5 - 0.3j, 0.2 + 0.7j, -0.1 - 0.6j
]

colors = plt.cm.Set1(np.linspace(0, 1, len(test_points)))

for i, z in enumerate(test_points):
    w = moebius_map(a, z)           # φ_a(z)
    z_back = moebius_map(-a, w)     # φ_{-a}(φ_a(z)) = z

    # Draw z → w → z_back
    ax.plot(z.real, z.imag, 'o', color=colors[i], markersize=10, zorder=5)
    ax.plot(w.real, w.imag, 's', color=colors[i], markersize=8, zorder=5, alpha=0.6)

    # Arrow z → w
    ax.annotate('', xy=(w.real, w.imag), xytext=(z.real, z.imag),
                arrowprops=dict(arrowstyle='->', color=colors[i], lw=1.5, alpha=0.7))

    # Arrow w → z_back (should go back to z)
    ax.annotate('', xy=(z_back.real, z_back.imag), xytext=(w.real, w.imag),
                arrowprops=dict(arrowstyle='->', color=colors[i], lw=1.5,
                               linestyle='dashed', alpha=0.5))

    error = abs(z_back - z)
    ax.annotate(f'ε={error:.1e}', xy=(z.real, z.imag),
                fontsize=6, ha='left', va='bottom')

ax.plot(a.real, a.imag, 'g^', markersize=12, label=f'a = {a}', zorder=10)
ax.set_title('Möbius Inverse Property\nφ_{-a}(φ_a(z)) = z',
             fontsize=13, fontweight='bold')
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.legend(loc='upper left', fontsize=9)

# Panel 2: Orbit spiral structure
ax2 = axes[1]
ax2.set_aspect('equal')
ax2.set_xlim(-1.15, 1.15)
ax2.set_ylim(-1.15, 1.15)

circle2 = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax2.add_patch(circle2)

# Apply iterated Möbius maps to trace orbits
a_orbit = 0.3 + 0.15j
start_points = [
    0.1 + 0.1j, -0.2 + 0.1j, 0.05 - 0.15j
]
orbit_colors = ['blue', 'red', 'green']

for sp, color in zip(start_points, orbit_colors):
    orbit = [sp]
    z = sp
    for step in range(30):
        z = moebius_map(a_orbit, z)
        if abs(z) > 0.999:
            break
        orbit.append(z)

    xs = [p.real for p in orbit]
    ys = [p.imag for p in orbit]
    ax2.plot(xs, ys, '-', color=color, alpha=0.5, linewidth=1)
    ax2.plot(xs, ys, 'o', color=color, markersize=3, alpha=0.7)
    ax2.plot(xs[0], ys[0], 'o', color=color, markersize=8, zorder=5)

ax2.set_title('Orbit Structure under Iterated φ_a\n(spiraling dynamics)',
              fontsize=13, fontweight='bold')
ax2.set_xlabel('Re(z)')
ax2.set_ylabel('Im(z)')

# Panel 3: Distance preservation heatmap
ax3 = axes[2]

# Create a grid and compute pseudo-hyperbolic distances
n_grid = 50
x = np.linspace(-0.9, 0.9, n_grid)
y = np.linspace(-0.9, 0.9, n_grid)
X, Y = np.meshgrid(x, y)
Z = X + 1j * Y

# Only keep disk interior
mask = np.abs(Z) < 0.95

# Compute distance from 0.3+0.2j before and after Möbius transform
ref = 0.3 + 0.2j
a_dist = 0.4 + 0.1j

dist_before = np.full_like(X, np.nan)
dist_after = np.full_like(X, np.nan)

for i in range(n_grid):
    for j in range(n_grid):
        z = Z[i, j]
        if abs(z) < 0.95:
            d1 = pseudo_hyp_dist(z, ref)
            # Transform both points
            z_t = moebius_map(a_dist, z)
            ref_t = moebius_map(a_dist, ref)
            d2 = pseudo_hyp_dist(z_t, ref_t)
            dist_before[i, j] = d1
            dist_after[i, j] = d2

# Plot difference (should be near zero everywhere — isometry)
diff = np.abs(dist_after - dist_before)
diff[~mask] = np.nan

im = ax3.pcolormesh(X, Y, diff, cmap='hot_r', vmin=0, vmax=0.01,
                     shading='auto')
circle3 = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax3.add_patch(circle3)
ax3.set_aspect('equal')
plt.colorbar(im, ax=ax3, label='|ρ_before - ρ_after|')

ax3.set_title('Distance Preservation\n(Möbius maps are isometries)',
              fontsize=13, fontweight='bold')
ax3.set_xlabel('Re(z)')
ax3.set_ylabel('Im(z)')

plt.suptitle('Möbius Transformation Dynamics on the Poincaré Disk',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_moebius_dynamics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_moebius_dynamics.png")
