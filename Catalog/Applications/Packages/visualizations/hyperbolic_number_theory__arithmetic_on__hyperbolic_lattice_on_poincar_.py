#!/usr/bin/env python3
"""
Visualization 1: Hyperbolic Lattice on the Poincaré Disk

Visualizes the orbit of the origin under hyperbolic translations,
showing the tessellation structure. Hyperbolic primes are highlighted
in red, composites in blue, demonstrating the "number theory on
curved space" concept.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def hyp_add(a: complex, b: complex) -> complex:
    denom = 1 + a.conjugate() * b
    if abs(denom) < 1e-15:
        return a
    return (a + b) / denom


def mobius_map(a: complex, z: complex) -> complex:
    denom = 1 - a.conjugate() * z
    if abs(denom) < 1e-15:
        return a
    return (a - z) / denom


def generate_lattice(generators, depth=5):
    orbit = [0.0 + 0.0j]
    seen = {(0, 0)}

    def _key(z):
        return (round(z.real, 3), round(z.imag, 3))

    frontier = [0.0 + 0.0j]
    for _ in range(depth):
        new_frontier = []
        for z in frontier:
            for g in generators:
                for s in [1, -1]:
                    try:
                        w = hyp_add(complex(s) * g, z)
                        if abs(w) < 0.995:
                            k = _key(w)
                            if k not in seen:
                                seen.add(k)
                                orbit.append(w)
                                new_frontier.append(w)
                    except (ValueError, ZeroDivisionError):
                        pass
        frontier = new_frontier
    orbit.sort(key=lambda z: abs(z))
    return orbit


def is_hyp_prime(lattice, n):
    if abs(lattice[n]) < 1e-10:
        return False
    for i in range(n):
        if abs(lattice[i]) < 1e-10:
            continue
        for j in range(n):
            if abs(lattice[j]) < 1e-10:
                continue
            try:
                s = hyp_add(lattice[i], lattice[j])
                if abs(s - lattice[n]) < 0.008:
                    return False
            except (ValueError, ZeroDivisionError):
                pass
    return True


# Generate lattice
gens = [
    0.12 + 0.0j,
    0.0 + 0.12j,
    0.12 * np.exp(1j * np.pi / 3),
    0.12 * np.exp(1j * 2 * np.pi / 3),
    0.12 * np.exp(1j * 4 * np.pi / 3),
    0.12 * np.exp(1j * 5 * np.pi / 3),
]
lattice = generate_lattice(gens, depth=4)

# Classify primes vs composites
N = min(len(lattice), 60)
prime_pts = []
comp_pts = []
for i in range(N):
    if abs(lattice[i]) < 1e-10:
        continue
    if is_hyp_prime(lattice, i):
        prime_pts.append(lattice[i])
    else:
        comp_pts.append(lattice[i])

# Plot
fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw disk boundary
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Draw hyperbolic geodesics (arcs) connecting nearby points
for i, p1 in enumerate(lattice[:N]):
    for j, p2 in enumerate(lattice[:N]):
        if i < j and abs(p1 - p2) < 0.3:
            # Draw straight line (approximate geodesic for nearby points)
            ax.plot([p1.real, p2.real], [p1.imag, p2.imag],
                    'gray', alpha=0.15, linewidth=0.5)

# Plot composites
if comp_pts:
    ax.scatter([z.real for z in comp_pts], [z.imag for z in comp_pts],
               c='royalblue', s=40, zorder=5, label=f'Composite ({len(comp_pts)})',
               edgecolors='navy', linewidth=0.5)

# Plot primes
if prime_pts:
    ax.scatter([z.real for z in prime_pts], [z.imag for z in prime_pts],
               c='crimson', s=80, marker='*', zorder=6,
               label=f'Hyperbolic Prime ({len(prime_pts)})',
               edgecolors='darkred', linewidth=0.5)

# Plot origin
ax.scatter([0], [0], c='gold', s=100, marker='o', zorder=7,
           edgecolors='black', linewidth=1.5, label='Origin')

# Draw concentric hyperbolic circles (actually circles in disk model)
for r_hyp in [0.3, 0.6, 0.9]:
    r_disk = np.tanh(r_hyp)
    circle_h = plt.Circle((0, 0), r_disk, fill=False, color='green',
                           linewidth=0.8, linestyle='--', alpha=0.4)
    ax.add_patch(circle_h)
    ax.text(r_disk + 0.02, 0.02, f'd={r_hyp:.1f}', fontsize=8, color='green')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.legend(loc='upper right', fontsize=11)
ax.set_title('Hyperbolic Lattice on the Poincaré Disk\n'
             'Primes (★) vs Composites (●) — Number Theory on Curved Space',
             fontsize=14, fontweight='bold')
ax.set_xlabel('Re(z)', fontsize=12)
ax.set_ylabel('Im(z)', fontsize=12)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_poincare_lattice.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_poincare_lattice.png")
