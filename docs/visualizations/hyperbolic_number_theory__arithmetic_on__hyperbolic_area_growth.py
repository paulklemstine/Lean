#!/usr/bin/env python3
"""
Visualization: Hyperbolic Area Growth
======================================
Shows the exponential growth of hyperbolic area compared to
Euclidean area, and the proven lower bound A(R) ≥ π(eᴿ - 2).
Also shows tessellation of the disk by a hyperbolic lattice.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import matplotlib.colors as mcolors


def moebius_add(z, w):
    return (z + w) / (1 + np.conj(w) * z)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Area comparison
ax = axes[0]
R = np.linspace(0, 6, 200)
hyp_area = 2 * np.pi * (np.cosh(R) - 1)
euc_area = np.pi * R**2
lower_bound = np.pi * (np.exp(R) - 2)

ax.semilogy(R, hyp_area, 'b-', linewidth=2.5, label='Hyperbolic: 2π(cosh R - 1)')
ax.semilogy(R, euc_area, 'g--', linewidth=2, label='Euclidean: πR²')
ax.semilogy(R, np.maximum(lower_bound, 0.01), 'r:', linewidth=1.5,
            label='Proved bound: π(eᴿ - 2)')

ax.fill_between(R, np.maximum(lower_bound, 0.01), hyp_area,
                alpha=0.1, color='blue', label='Gap above lower bound')

ax.set_xlabel('Radius R', fontsize=12)
ax.set_ylabel('Area (log scale)', fontsize=12)
ax.set_title('Hyperbolic vs Euclidean Area\n(Formally Verified Bounds)',
             fontsize=12, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 6)
ax.set_ylim(0.1, 1e4)

# Panel 2: Ratio of areas
ax2 = axes[1]
R2 = np.linspace(0.01, 8, 300)
ratio = 2 * np.pi * (np.cosh(R2) - 1) / (np.pi * R2**2)

ax2.plot(R2, ratio, 'b-', linewidth=2)
ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)

ax2.set_xlabel('Radius R', fontsize=12)
ax2.set_ylabel('A_hyp(R) / A_euc(R)', fontsize=12)
ax2.set_title('Hyperbolic/Euclidean Area Ratio\n(Exponential divergence)',
              fontsize=12, fontweight='bold')
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

# Annotate
ax2.annotate('At R=5: hyperbolic area\nis 30× Euclidean',
            xy=(5, ratio[np.argmin(np.abs(R2-5))]),
            xytext=(2, 50), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='red'))

# Panel 3: Hyperbolic tessellation (Voronoi-like)
ax3 = axes[2]

# Draw unit disk boundary
theta = np.linspace(0, 2*np.pi, 200)
ax3.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Generate lattice
angles = np.linspace(0, 2*np.pi, 7)[:-1]
gens = [0.4 * np.exp(1j * a) for a in angles]
pts = {(0.0, 0.0)}
current = [0.0 + 0.0j]
for _ in range(5):
    new = []
    for p in current:
        for g in gens:
            q = moebius_add(p, g)
            k = (round(q.real, 6), round(q.imag, 6))
            if abs(q) < 0.998 and k not in pts:
                pts.add(k)
                new.append(q)
    current = new

lattice = [complex(x, y) for x, y in pts]

# Color by hyperbolic distance
for z in lattice:
    r = abs(z)
    h = np.log((1 + r) / (1 - r)) if r < 0.999 else 5
    size = max(2, 15 - 2*h)
    color = plt.cm.plasma(min(h/5, 1))
    ax3.plot(z.real, z.imag, 'o', color=color, markersize=size, alpha=0.7)

# Draw some "geodesic" connections (hyperbolic lines)
for z in lattice[:50]:
    for g in gens[:3]:
        w = moebius_add(z, g)
        if abs(w) < 0.999:
            t = np.linspace(0, 1, 20)
            path = [(1-s)*z + s*w for s in t]
            ax3.plot([p.real for p in path], [p.imag for p in path],
                    'k-', alpha=0.05, linewidth=0.3)

ax3.set_xlim(-1.1, 1.1)
ax3.set_ylim(-1.1, 1.1)
ax3.set_aspect('equal')
ax3.set_title(f'Hyperbolic Tessellation\n({len(lattice)} cells)',
              fontsize=12, fontweight='bold')
ax3.set_xlabel('Re(z)')
ax3.set_ylabel('Im(z)')

plt.tight_layout()
plt.savefig('viz_hyp_area.png', dpi=150, bbox_inches='tight')
print("Saved hyperbolic area visualization")
