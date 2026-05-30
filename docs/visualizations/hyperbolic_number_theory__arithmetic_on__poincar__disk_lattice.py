"""
Visualization 1: Poincaré Disk Lattice Points
==============================================
Visualizes hyperbolic integers as orbit points in the Poincaré disk,
showing how Möbius transformations tessellate the disk with exponentially
many points that crowd toward the boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def moebius_map(a, z):
    """Möbius automorphism φ_a(z) = (a - z) / (1 - conj(a) * z)"""
    return (a - z) / (1 - np.conj(a) * z)


def enumerate_lattice(generators, max_depth):
    """Enumerate hyperbolic integers by BFS on the Cayley graph."""
    points = {0: (0 + 0j, 0)}  # position → (complex_value, depth)
    current_level = [0 + 0j]
    all_points = [(0 + 0j, 0)]

    for depth in range(1, max_depth + 1):
        next_level = []
        for z in current_level:
            for g in generators:
                w = moebius_map(g, z)
                # Use discretization to avoid duplicates
                key = round(w.real, 8) + 1j * round(w.imag, 8)
                if key not in points:
                    points[key] = (w, depth)
                    next_level.append(w)
                    all_points.append((w, depth))
        current_level = next_level

    return all_points


# Generate lattice with 2 generators at angle π/3 apart
r = 0.6  # generator radius
gen1 = r * np.exp(1j * 0)
gen2 = r * np.exp(1j * np.pi / 3)
gen3 = r * np.exp(1j * 2 * np.pi / 3)
generators = [gen1, gen2, gen3]

lattice = enumerate_lattice(generators, max_depth=5)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))

# Left panel: Lattice points colored by depth
ax1 = axes[0]
theta = np.linspace(0, 2 * np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax1.set_xlim(-1.15, 1.15)
ax1.set_ylim(-1.15, 1.15)
ax1.set_aspect('equal')

cmap = plt.cm.viridis
max_depth = max(d for _, d in lattice)
for z, depth in lattice:
    color = cmap(depth / max(max_depth, 1))
    size = max(50 - depth * 8, 3)
    ax1.plot(z.real, z.imag, 'o', color=color, markersize=size ** 0.5 * 2,
             markeredgecolor='black', markeredgewidth=0.3, alpha=0.8)

# Mark generators
for i, g in enumerate(generators):
    ax1.plot(g.real, g.imag, 'r*', markersize=12, markeredgecolor='black', markeredgewidth=0.5)
ax1.plot(0, 0, 'ko', markersize=8)

ax1.set_title('Hyperbolic Integers on the Poincaré Disk\n(orbit of 0 under 3 Möbius generators)',
              fontsize=13, fontweight='bold')
ax1.set_xlabel('Re(z)')
ax1.set_ylabel('Im(z)')

# Add colorbar
sm = plt.cm.ScalarMappable(cmap=cmap, norm=plt.Normalize(0, max_depth))
sm.set_array([])
cbar = plt.colorbar(sm, ax=ax1, shrink=0.8)
cbar.set_label('Word length (depth)')

# Right panel: Growth comparison
ax2 = axes[1]
ns = np.arange(0, 12)
flat_growth = 2 * ns + 1
hyp_growth_2 = [sum(2**i for i in range(n+1)) for n in ns]
hyp_growth_3 = [sum(3**i for i in range(n+1)) for n in ns]

ax2.semilogy(ns, flat_growth, 'b-o', linewidth=2, markersize=8, label='ℤ (flat): 2n+1')
ax2.semilogy(ns, hyp_growth_2, 'r-s', linewidth=2, markersize=8, label='ℤ_H (k=2): Σ2ⁱ')
ax2.semilogy(ns, hyp_growth_3, 'g-^', linewidth=2, markersize=8, label='ℤ_H (k=3): Σ3ⁱ')

ax2.set_xlabel('Radius n', fontsize=12)
ax2.set_ylabel('Number of lattice points (log scale)', fontsize=12)
ax2.set_title('Exponential Growth:\nFlat vs Hyperbolic Arithmetic', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, 11.5)

plt.tight_layout()
plt.savefig('poincare_lattice.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved poincare_lattice.png")
