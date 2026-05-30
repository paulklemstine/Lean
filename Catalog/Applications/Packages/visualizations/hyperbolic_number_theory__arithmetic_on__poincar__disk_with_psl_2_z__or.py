"""
Visualization 1: The Poincaré Disk with Möbius Transform Orbits
================================================================

Visualizes the PSL(2,Z) orbit on the Poincaré disk, showing how
the modular group tessellates hyperbolic space. Hyperbolic primes
are highlighted as the closest orbit points to the origin.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def normSq(z):
    return z.real**2 + z.imag**2


def cayley_transform(z):
    return (z - 1j) / (z + 1j)


def generate_psl2z_orbit(max_depth=6):
    visited = set()
    orbit = []
    
    def add_point(z_uhp):
        if z_uhp.imag <= 0:
            return
        w = cayley_transform(z_uhp)
        key = (round(w.real, 10), round(w.imag, 10))
        if key not in visited:
            visited.add(key)
            orbit.append(w)
    
    current = {1j}
    add_point(1j)
    
    for _ in range(max_depth):
        next_level = set()
        for z in current:
            if abs(z) > 1e-15:
                s_z = -1.0 / z
                if s_z.imag > 1e-10:
                    add_point(s_z)
                    next_level.add(s_z)
            t_z = z + 1
            if t_z.imag > 1e-10:
                add_point(t_z)
                next_level.add(t_z)
            ti_z = z - 1
            if ti_z.imag > 1e-10:
                add_point(ti_z)
                next_level.add(ti_z)
        current = next_level
    
    return orbit


# Generate orbit
orbit = generate_psl2z_orbit(max_depth=7)

# Sort by distance from origin
orbit_sorted = sorted(orbit, key=lambda z: normSq(z))

# Classify: primes (closest), composites (rest)
n_primes = min(6, len(orbit_sorted))
primes = orbit_sorted[:n_primes]
composites = orbit_sorted[n_primes:]

fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw the unit disk boundary
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Draw hyperbolic geodesics (arcs of circles perpendicular to the boundary)
# Draw a few decorative geodesics
for angle in np.linspace(0, np.pi, 6):
    t = np.linspace(-0.98, 0.98, 200)
    x = t * np.cos(angle)
    y = t * np.sin(angle)
    mask = x**2 + y**2 < 0.99
    ax.plot(x[mask], y[mask], color='#e0e0e0', linewidth=0.5, zorder=1)

# Plot composite lattice points
if composites:
    cx = [z.real for z in composites]
    cy = [z.imag for z in composites]
    ax.scatter(cx, cy, s=8, c='steelblue', alpha=0.6, zorder=3, label='Lattice points')

# Plot hyperbolic primes
if primes:
    px = [z.real for z in primes]
    py = [z.imag for z in primes]
    ax.scatter(px, py, s=80, c='crimson', marker='*', zorder=4, 
               label='Hyperbolic primes', edgecolors='darkred', linewidths=0.5)

# Mark the origin
ax.plot(0, 0, 'ko', markersize=8, zorder=5)
ax.annotate('O', (0.02, 0.03), fontsize=12, fontweight='bold')

# Annotations
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title(f'Poincaré Disk: PSL(2,ℤ) Orbit ({len(orbit)} points)\n'
             f'Hyperbolic Primes shown as red stars', fontsize=14)
ax.legend(loc='upper right', fontsize=11)
ax.set_xlabel('Re(z)', fontsize=12)
ax.set_ylabel('Im(z)', fontsize=12)

# Add grid circles for reference
for r in [0.25, 0.5, 0.75]:
    circle_r = plt.Circle((0, 0), r, fill=False, color='#d0d0d0', 
                           linewidth=0.5, linestyle='--')
    ax.add_patch(circle_r)

plt.tight_layout()
plt.savefig('viz_poincare_disk.png', dpi=150, bbox_inches='tight')
print(f"Saved visualization with {len(orbit)} orbit points and {n_primes} primes")
