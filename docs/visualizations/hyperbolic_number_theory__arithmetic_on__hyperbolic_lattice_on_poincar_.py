#!/usr/bin/env python3
"""
Visualization: Hyperbolic Lattice on the Poincaré Disk
======================================================
Visualizes the orbit of the origin under iterated Möbius additions,
showing how lattice points fill the hyperbolic plane with exponentially
increasing density near the boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def moebius_add(z, w):
    """Möbius addition: (z + w) / (1 + conj(w) * z)."""
    return (z + w) / (1 + np.conj(w) * z)


def generate_lattice(generators, depth=6, max_pts=3000):
    """Generate lattice by iterated Möbius addition."""
    pts = {(0.0, 0.0)}
    current = [0.0 + 0.0j]
    for _ in range(depth):
        if len(pts) >= max_pts:
            break
        new = []
        for p in current:
            for g in generators:
                q = moebius_add(p, g)
                k = (round(q.real, 7), round(q.imag, 7))
                if abs(q) < 0.9999 and k not in pts:
                    pts.add(k)
                    new.append(q)
                    if len(pts) >= max_pts:
                        break
            if len(pts) >= max_pts:
                break
        current = new
    return [complex(x, y) for x, y in pts]


# Generate lattice with 6 generators (hexagonal-like pattern)
angles = np.linspace(0, 2*np.pi, 7)[:-1]
gens = [0.35 * np.exp(1j * a) for a in angles]
lattice = generate_lattice(gens, depth=7, max_pts=2000)

# Compute hyperbolic distances from origin
dists = []
for z in lattice:
    r = abs(z)
    if r < 0.9999:
        dists.append(np.log((1 + r) / (1 - r)))
    else:
        dists.append(10.0)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Poincaré disk with lattice points
ax = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

xs = [z.real for z in lattice]
ys = [z.imag for z in lattice]
colors = dists

sc = ax.scatter(xs, ys, c=colors, cmap='viridis', s=8, alpha=0.7,
                edgecolors='none', vmin=0, vmax=5)
ax.scatter([0], [0], c='red', s=50, zorder=5, marker='*', label='Origin')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title(f'Hyperbolic Lattice on the Poincaré Disk\n({len(lattice)} points)',
             fontsize=13, fontweight='bold')
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
plt.colorbar(sc, ax=ax, label='Hyperbolic distance from origin')
ax.legend(loc='upper right', fontsize=9)

# Draw hyperbolic circles (Euclidean circles in disk model)
for R_hyp in [1.0, 2.0, 3.0, 4.0]:
    r_euc = np.tanh(R_hyp / 2)
    circ = plt.Circle((0, 0), r_euc, fill=False, color='gray',
                       linewidth=0.5, linestyle='--', alpha=0.5)
    ax.add_patch(circ)

# Right: Lattice counting function vs hyperbolic area
ax2 = axes[1]
R_values = np.linspace(0.1, 6, 50)
N_values = []
A_values = []
for R in R_values:
    N = sum(1 for d in dists if d <= R)
    N_values.append(N)
    A_values.append(2 * np.pi * (np.cosh(R) - 1))

ax2.semilogy(R_values, N_values, 'b-', linewidth=2, label='N(R) = lattice count')
ax2.semilogy(R_values, A_values, 'r--', linewidth=2, label='A(R) = 2π(cosh R - 1)')
ax2.semilogy(R_values, np.pi * (np.exp(R_values) - 2), 'g:',
             linewidth=1.5, label='π(eᴿ - 2) lower bound')

ax2.set_xlabel('Hyperbolic radius R', fontsize=12)
ax2.set_ylabel('Count / Area', fontsize=12)
ax2.set_title('Lattice Point Counting\nvs Hyperbolic Area', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(1, None)

plt.tight_layout()
plt.savefig('viz_poincare_lattice.png', dpi=150, bbox_inches='tight')
print(f"Saved visualization with {len(lattice)} lattice points")
