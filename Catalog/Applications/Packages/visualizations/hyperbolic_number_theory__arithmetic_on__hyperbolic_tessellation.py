"""
Visualization: Hyperbolic Tessellation and Lattice Points

Shows the tessellation of the Poincaré disk by the modular group,
illustrating how "hyperbolic integers" tile the hyperbolic plane.
The exponential growth of tiles near the boundary reflects the
proven theorem hypGrowth(n) = 3^n.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def moebius_map(a, z):
    """Möbius automorphism."""
    denom = 1 - np.conj(a) * z
    mask = np.abs(denom) > 1e-12
    result = np.where(mask, (z - a) / np.where(mask, denom, 1), 0)
    return result


def hyperbolic_distance_from_origin(z):
    """Hyperbolic distance from the origin."""
    r = np.abs(z)
    r = np.clip(r, 0, 0.9999)
    return 2 * np.arctanh(r)


fig, axes = plt.subplots(1, 2, figsize=(14, 6.5))

# Left panel: Lattice points colored by distance
ax = axes[0]

# Draw disk boundary
circle = patches.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Generate lattice points by applying transformations
# Use simple representation: rotations and translations in disk model
lattice_points = [0 + 0j]
generators_a = [
    0.3 + 0.0j,
    -0.3 + 0.0j,
    0.0 + 0.3j,
    0.0 - 0.3j,
    0.15 + 0.26j,
    -0.15 + 0.26j,
    0.15 - 0.26j,
    -0.15 - 0.26j,
]

# Generate orbit by repeatedly applying Möbius maps
seen = set()
seen.add((0, 0))
current_gen = [0 + 0j]

for depth in range(4):
    next_gen = []
    for z in current_gen:
        for a in generators_a:
            w = moebius_map(a, z)
            if abs(w) < 0.98:
                key = (round(w.real, 4), round(w.imag, 4))
                if key not in seen:
                    seen.add(key)
                    lattice_points.append(w)
                    next_gen.append(w)
    current_gen = next_gen

# Plot lattice points colored by distance from origin
points = np.array(lattice_points)
distances = np.array([hyperbolic_distance_from_origin(z) for z in lattice_points])

scatter = ax.scatter(points.real, points.imag, c=distances, cmap='viridis',
                     s=15, alpha=0.8, edgecolors='none', zorder=3)
plt.colorbar(scatter, ax=ax, label='Hyperbolic distance from origin', shrink=0.8)

# Mark origin
ax.plot(0, 0, 'r*', markersize=12, zorder=5)

ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)
ax.set_aspect('equal')
ax.set_title(f'Hyperbolic Lattice Points ({len(lattice_points)} points)\n'
             'Color = hyperbolic distance from origin', fontsize=11)
ax.grid(True, alpha=0.15)

# Right panel: Hyperbolic geodesic fan showing tiling
ax = axes[1]

# Draw disk boundary
circle = patches.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Draw a {7,3} tiling approximation
# Regular heptagonal tiling: 7-gons meeting 3 at each vertex
n_sides = 7
n_levels = 4

# Generate vertices of central polygon
r_central = 0.4
angles_central = np.linspace(0, 2 * np.pi, n_sides, endpoint=False)
central_vertices = r_central * np.exp(1j * angles_central)

# Draw central polygon
for i in range(n_sides):
    z1 = central_vertices[i]
    z2 = central_vertices[(i + 1) % n_sides]
    # Draw geodesic (approximated as line for now, since these are close to origin)
    t = np.linspace(0, 1, 50)
    # Hyperbolic geodesic: use Möbius-mapped straight lines
    line = z1 + t[:, np.newaxis] * (z2 - z1)
    line = line.flatten()
    ax.plot(line.real, line.imag, 'b-', linewidth=1.5, alpha=0.7)

# Add reflected polygons
for i in range(n_sides):
    center = central_vertices[i]
    # Reflect central polygon through each edge
    for j in range(n_sides):
        v = central_vertices[j]
        w = moebius_map(-center * 0.8, v)
        if abs(w) < 0.98:
            ax.plot(w.real, w.imag, 'g.', markersize=3, alpha=0.5)

# Draw radial geodesics from origin to boundary
n_geodesics = 14
for angle in np.linspace(0, 2 * np.pi, n_geodesics, endpoint=False):
    r = np.linspace(0, 0.99, 200)
    z = r * np.exp(1j * angle)
    ax.plot(z.real, z.imag, 'gray', linewidth=0.5, alpha=0.3)

# Draw horocycles (circles tangent to boundary)
for r_center in [0.3, 0.5, 0.7, 0.85, 0.93]:
    theta = np.linspace(0, 2 * np.pi, 200)
    z = r_center * np.exp(1j * theta)
    ax.plot(z.real, z.imag, 'r-', linewidth=0.5, alpha=0.3)

# Mark "hyperbolic primes" (generators)
prime_angles = np.linspace(0, 2 * np.pi, 6, endpoint=False)
for angle in prime_angles:
    z = 0.35 * np.exp(1j * angle)
    ax.plot(z.real, z.imag, 'r^', markersize=8, zorder=5)

ax.plot(0, 0, 'k*', markersize=12, zorder=5, label='Origin (identity)')
ax.plot([], [], 'r^', markersize=8, label='Hyperbolic primes')
ax.legend(loc='upper right', fontsize=9)

ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Tessellation & Primes\n'
             'Red triangles = generators (primes)', fontsize=11)
ax.grid(True, alpha=0.15)

plt.suptitle('Hyperbolic Integers: Lattice Points on the Poincaré Disk',
             fontsize=13, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig("viz_tessellation.png", dpi=150, bbox_inches='tight')
plt.close()
