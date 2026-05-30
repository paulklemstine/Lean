#!/usr/bin/env python3
"""
Visualization 1: Poincaré Disk Lattice and Hyperbolic Primes

Visualizes the hyperbolic integer lattice on the Poincaré disk model,
color-coding points by depth and highlighting hyperbolic primes.
The unit circle boundary represents infinity in hyperbolic space.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def mobius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def hyp_norm(z):
    r = abs(z)
    if r >= 1:
        return float('inf')
    if r < 1e-15:
        return 0.0
    return np.log((1 + r) / (1 - r)) / 2


def generate_lattice(generators, depth=5):
    points = {0j}
    depths = {0j: 0}
    frontier = {0j}
    for d in range(1, depth + 1):
        new_frontier = set()
        for z in frontier:
            for g in generators:
                w = mobius_map(g, z)
                if abs(w) < 0.9999:
                    w_key = round(w.real, 9) + 1j * round(w.imag, 9)
                    if w_key not in points:
                        points.add(w_key)
                        depths[w_key] = d
                        new_frontier.add(w_key)
        frontier = new_frontier
        if not frontier:
            break
    return list(points), depths


def is_prime(z, generators):
    if abs(z) < 1e-10:
        return False
    for g1 in generators:
        for g2 in generators:
            if abs(mobius_map(g1, g2) - z) < 1e-7:
                return False
    return True


# Generate the lattice
generators = [0.5, 0.35j, -0.3 + 0.25j, 0.2 - 0.35j]
points, depths = generate_lattice(generators, depth=5)

fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))

# Left panel: lattice colored by depth
ax1 = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax1.add_patch(circle)

max_depth = max(depths.values()) if depths else 1
cmap = plt.cm.viridis
for z in sorted(points, key=lambda p: depths.get(p, 0)):
    d = depths.get(z, 0)
    color = cmap(d / max_depth)
    size = 40 if d == 0 else max(8, 30 - 4 * d)
    ax1.scatter(z.real, z.imag, c=[color], s=size, zorder=3, edgecolors='white',
                linewidth=0.3)

# Mark origin
ax1.scatter(0, 0, c='red', s=100, zorder=5, marker='*', edgecolors='black')
# Mark generators
for g in generators:
    ax1.scatter(g.real, g.imag, c='orange', s=60, zorder=4, marker='D',
                edgecolors='black', linewidth=1)

ax1.set_xlim(-1.15, 1.15)
ax1.set_ylim(-1.15, 1.15)
ax1.set_aspect('equal')
ax1.set_title('Hyperbolic Integer Lattice on the Poincaré Disk', fontsize=13, fontweight='bold')
ax1.set_xlabel('Re(z)')
ax1.set_ylabel('Im(z)')
ax1.grid(True, alpha=0.2)

legend_elements = [
    mpatches.Patch(color='red', label='Origin (0)'),
    mpatches.Patch(color='orange', label='Generators'),
    mpatches.Patch(color=cmap(0.0), label='Depth 0'),
    mpatches.Patch(color=cmap(0.5), label=f'Depth {max_depth//2}'),
    mpatches.Patch(color=cmap(1.0), label=f'Depth {max_depth}'),
]
ax1.legend(handles=legend_elements, loc='lower right', fontsize=9)

# Right panel: primes highlighted
ax2 = axes[1]
circle2 = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax2.add_patch(circle2)

primes = [z for z in points if is_prime(z, generators)]
composites = [z for z in points if not is_prime(z, generators) and abs(z) > 1e-10]

for z in composites:
    ax2.scatter(z.real, z.imag, c='lightblue', s=15, zorder=2, alpha=0.6)
for z in primes:
    hn = hyp_norm(z)
    ax2.scatter(z.real, z.imag, c='crimson', s=25, zorder=3, edgecolors='darkred',
                linewidth=0.5)
ax2.scatter(0, 0, c='gold', s=100, zorder=5, marker='*', edgecolors='black')

ax2.set_xlim(-1.15, 1.15)
ax2.set_ylim(-1.15, 1.15)
ax2.set_aspect('equal')
ax2.set_title('Hyperbolic Primes (red) vs Composites (blue)', fontsize=13, fontweight='bold')
ax2.set_xlabel('Re(z)')
ax2.set_ylabel('Im(z)')
ax2.grid(True, alpha=0.2)
ax2.text(0.02, -1.08, f'{len(primes)} primes / {len(points)} total points',
         fontsize=10, color='crimson')

plt.tight_layout()
plt.savefig('viz_poincare_lattice.png', dpi=150, bbox_inches='tight')
print(f"Saved visualization with {len(points)} points, {len(primes)} primes")
