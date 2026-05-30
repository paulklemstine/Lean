"""
Visualization: Poincaré Disk Lattice Orbits
=============================================

Visualizes the orbit of the origin under Möbius transformations
on the Poincaré disk, showing how "hyperbolic integers" tile
the hyperbolic plane. Points are colored by their generation depth.

This illustrates the core concept: arithmetic on curved space,
where the density of lattice points increases exponentially
near the boundary of the disk.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.collections import LineCollection


def moebius_transform(z, center, angle):
    """Apply Möbius transformation z ↦ e^{iθ} · (z - a) / (1 - ā·z)."""
    rotation = np.exp(1j * angle)
    return rotation * (z - center) / (1 - np.conj(center) * z)


def hyp_add(a, b):
    """Hyperbolic addition: (a + b) / (1 + a*b)."""
    return (a + b) / (1 + a * b)


def enumerate_orbit(generators, max_depth):
    """Enumerate orbit points by depth."""
    levels = [{0j}]
    all_points = {(0.0, 0.0)}
    tol = 1e-8

    for depth in range(1, max_depth + 1):
        new_points = set()
        for z in levels[depth - 1]:
            for center, angle in generators:
                w = moebius_transform(z, center, angle)
                key = (round(w.real / tol) * tol, round(w.imag / tol) * tol)
                if key not in all_points and abs(w) < 1 - tol:
                    all_points.add(key)
                    new_points.add(w)
        levels.append(new_points)

    return levels


# Generate orbit
generators = [
    (0.4 + 0j, 0.0),
    (0j + 0.4j, np.pi / 3),
    (-0.3 + 0.2j, np.pi / 2),
]

max_depth = 6
orbit = enumerate_orbit(generators, max_depth)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))

# --- Left panel: Orbit visualization ---
ax = axes[0]

# Draw the unit disk boundary
theta = np.linspace(0, 2 * np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.03, color='blue')

# Draw geodesic grid lines (arcs of circles orthogonal to boundary)
for r in [0.2, 0.4, 0.6, 0.8]:
    ax.plot(r * np.cos(theta), r * np.sin(theta), 'k-', alpha=0.08, linewidth=0.5)

# Color scheme
colors = plt.cm.viridis(np.linspace(0.1, 0.9, max_depth + 1))

# Plot orbit points
for depth, points in enumerate(orbit):
    if not points:
        continue
    xs = [z.real for z in points]
    ys = [z.imag for z in points]
    size = max(120 - depth * 15, 10)
    ax.scatter(xs, ys, c=[colors[depth]], s=size, zorder=5,
               edgecolors='white', linewidth=0.5,
               label=f'Depth {depth} ({len(points)} pts)')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Integers on the Poincaré Disk', fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=8, framealpha=0.9)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')

# Add annotation
ax.annotate('Origin\n(identity)', xy=(0, 0), xytext=(0.3, -0.7),
            fontsize=9, ha='center',
            arrowprops=dict(arrowstyle='->', color='gray'),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.8))

# --- Right panel: Counting function ---
ax2 = axes[1]

depths = list(range(max_depth + 1))
counts_per_depth = [len(orbit[d]) for d in depths]
cumulative = [sum(counts_per_depth[:d+1]) for d in depths]

# Exponential bound
k = len(generators)
exp_bound = [k**d for d in depths]
cumulative_bound = [sum(k**i for i in range(d+1)) for d in depths]

ax2.semilogy(depths, cumulative, 'bo-', linewidth=2, markersize=8,
             label='Actual count N(d)', zorder=5)
ax2.semilogy(depths, cumulative_bound, 'r--', linewidth=2,
             label=f'Bound: Σ {k}^i', alpha=0.7)

# Bar chart for per-depth counts
ax2_twin = ax2.twinx()
ax2_twin.bar(depths, counts_per_depth, alpha=0.2, color='green',
             label='Points at depth d')
ax2_twin.set_ylabel('Points at depth d', color='green', fontsize=11)
ax2_twin.tick_params(axis='y', labelcolor='green')

ax2.set_xlabel('Depth d', fontsize=12)
ax2.set_ylabel('Cumulative count N(d)', fontsize=12, color='blue')
ax2.tick_params(axis='y', labelcolor='blue')
ax2.set_title('Exponential Growth of Lattice Points', fontsize=14, fontweight='bold')
ax2.legend(loc='upper left', fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('poincare_lattice.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: poincare_lattice.png")
