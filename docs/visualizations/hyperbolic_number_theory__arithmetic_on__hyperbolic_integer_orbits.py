#!/usr/bin/env python3
"""
Visualization 1: Hyperbolic Integer Orbits on the Poincaré Disk

Shows the orbit of the origin under iterated Möbius maps for different
generators, illustrating how hyperbolic integers are distributed in the disk.
The unit circle boundary represents "infinity" in hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def moebius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def compute_orbit(a, N, start=0.0):
    orbit = [complex(start)]
    for _ in range(N):
        orbit.append(moebius_map(a, orbit[-1]))
    return np.array(orbit)


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

generators = [
    ((3 - np.sqrt(5)) / 2, "Golden Generator\na = (3−√5)/2 ≈ 0.382"),
    (0.3 + 0.2j, "Complex Generator\na = 0.3 + 0.2i"),
    (0.5 * np.exp(1j * np.pi / 5), "Spiral Generator\na = 0.5·e^{iπ/5}"),
]

for ax, (a, title) in zip(axes, generators):
    N = 100
    orbit = compute_orbit(a, N)
    
    # Draw unit circle
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)
    
    # Draw orbit path
    ax.plot(orbit.real, orbit.imag, '-', color='#2196F3', alpha=0.3, linewidth=0.5)
    
    # Color by index
    colors = plt.cm.viridis(np.linspace(0, 1, N + 1))
    
    # Mark points
    for i, z in enumerate(orbit):
        is_prime = i in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
                         53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
        size = 30 if is_prime else 8
        marker = '*' if is_prime else 'o'
        ax.scatter(z.real, z.imag, c=[colors[i]], s=size, marker=marker,
                   edgecolors='none', zorder=3)
    
    # Mark origin
    ax.scatter(0, 0, c='red', s=50, marker='o', zorder=5, edgecolors='black')
    
    # Mark generator
    ax.scatter((-a).real, (-a).imag, c='green', s=80, marker='D', zorder=5,
               edgecolors='black', label='z₁ = −a')
    
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=11)
    ax.grid(True, alpha=0.2)

# Legend
axes[0].scatter([], [], c='red', s=50, marker='o', label='Origin (z₀)')
axes[0].scatter([], [], c='green', s=80, marker='D', label='z₁ = −a')
axes[0].scatter([], [], c='gold', s=30, marker='*', label='Prime index')
axes[0].scatter([], [], c='gray', s=8, marker='o', label='Composite index')
axes[0].legend(loc='lower left', fontsize=8)

fig.suptitle('Hyperbolic Integers on the Poincaré Disk', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_orbit.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_orbit.png")
