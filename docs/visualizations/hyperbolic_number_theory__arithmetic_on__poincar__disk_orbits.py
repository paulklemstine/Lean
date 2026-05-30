"""
Visualization 1: Poincaré Disk Orbits and Tessellation
=======================================================
Visualizes the orbit of the origin under iterated Möbius transformations,
showing how "hyperbolic integers" tile the Poincaré disk.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def mobius_map(a, theta, z):
    """Möbius disk automorphism."""
    phase = np.exp(1j * theta)
    return phase * (z - a) / (1 - np.conj(a) * z)


def generate_orbit(a, theta, n):
    """Generate orbit points."""
    pts = [0j]
    for _ in range(n - 1):
        pts.append(mobius_map(a, theta, pts[-1]))
    return np.array(pts)


def hyp_add(z, w):
    """Hyperbolic addition."""
    return (z + w) / (1 + np.conj(z) * w)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Single generator orbit
ax = axes[0]
a, theta = 0.4 + 0.1j, np.pi / 5
orbit = generate_orbit(a, theta, 200)

circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)
ax.scatter(orbit.real, orbit.imag, c=np.arange(len(orbit)),
           cmap='viridis', s=15, zorder=5)
ax.plot(orbit.real[:50], orbit.imag[:50], 'b-', alpha=0.3, linewidth=0.5)
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Orbit under Möbius Generator\n(Hyperbolic Integers)', fontsize=12)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.grid(True, alpha=0.3)

# Panel 2: Multiple generator orbits (tessellation seed)
ax = axes[1]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

generators = [
    (0.5 + 0j, 0),
    (0.3j, np.pi / 3),
    (-0.4 + 0.2j, np.pi / 6),
]
colors_gen = ['#e74c3c', '#3498db', '#2ecc71']
labels = ['Gen 1: a=0.5', 'Gen 2: a=0.3i', 'Gen 3: a=-0.4+0.2i']

for (a, theta), color, label in zip(generators, colors_gen, labels):
    orb = generate_orbit(a, theta, 100)
    ax.scatter(orb.real, orb.imag, c=color, s=10, alpha=0.7, label=label, zorder=5)

ax.scatter([0], [0], c='gold', s=100, marker='*', zorder=10, label='Origin')
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Multiple Generator Orbits\n(Hyperbolic Lattice Seeds)', fontsize=12)
ax.legend(fontsize=8, loc='lower right')
ax.grid(True, alpha=0.3)

# Panel 3: Hyperbolic addition grid
ax = axes[2]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Create a grid of hyperbolic sums
base_points = [0.3 * np.exp(2j * np.pi * k / 6) for k in range(6)]
grid_pts = []
for z in base_points:
    for w in base_points:
        s = hyp_add(z, w)
        grid_pts.append(s)
        # Second level
        for v in base_points[:3]:
            grid_pts.append(hyp_add(s, v))

grid_pts = np.array(grid_pts)
mask = np.abs(grid_pts) < 1
grid_pts = grid_pts[mask]

ax.scatter(grid_pts.real, grid_pts.imag, c='purple', s=5, alpha=0.5)
for z in base_points:
    ax.scatter([z.real], [z.imag], c='red', s=50, zorder=10)
ax.scatter([0], [0], c='gold', s=100, marker='*', zorder=10)
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Addition Grid\n(Gyrogroup Structure)', fontsize=12)
ax.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Number Theory: Arithmetic on the Poincaré Disk',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('poincare_disk_orbits.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: poincare_disk_orbits.png")
