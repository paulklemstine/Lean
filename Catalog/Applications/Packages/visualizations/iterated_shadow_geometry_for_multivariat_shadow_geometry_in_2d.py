"""
Visualization: Shadow Geometry in 2D

Visualizes the k-th shadow of a 2D support set as a lattice diagram,
showing how the "downward shadow" expands and contracts.

Uses only matplotlib and numpy, no local imports.
"""

import matplotlib.pyplot as plt
import numpy as np


# ---- Inline helper functions ----

def mass(tau):
    return sum(tau)

def multi_indices_of_mass(n, k):
    if n == 0:
        return [()] if k == 0 else []
    if n == 1:
        return [(k,)]
    result = []
    for first in range(k, -1, -1):
        for rest in multi_indices_of_mass(n - 1, k - first):
            result.append((first,) + rest)
    return result

def leq(tau, alpha):
    return all(t <= a for t, a in zip(tau, alpha))

def sub(alpha, tau):
    return tuple(max(a - t, 0) for a, t in zip(alpha, tau))

def kth_shadow(S, k):
    if not S:
        return set()
    n = len(next(iter(S)))
    result = set()
    taus = multi_indices_of_mass(n, k)
    for alpha in S:
        for tau in taus:
            if leq(tau, alpha):
                result.add(sub(alpha, tau))
    return result


# ---- Main visualization ----

# Support set in 2 variables
S = {(4, 2), (2, 4), (3, 3)}

max_deg = max(mass(a) for a in S)
n_shadows = max_deg + 1

fig, axes = plt.subplots(2, 4, figsize=(20, 10))
fig.suptitle('Shadow Geometry: 2D Lattice Shadows of S = {(4,2), (2,4), (3,3)}', 
             fontsize=16, fontweight='bold')

# Color map for different shadow depths
cmap = plt.cm.viridis

for idx in range(min(8, n_shadows)):
    ax = axes[idx // 4, idx % 4]
    shadow = kth_shadow(S, idx)
    
    # Draw lattice grid
    grid_max = max_deg + 1
    for x in range(grid_max):
        for y in range(grid_max):
            ax.plot(x, y, '.', color='#e0e0e0', markersize=3)
    
    # Highlight shadow points
    if shadow:
        xs = [p[0] for p in shadow]
        ys = [p[1] for p in shadow]
        ax.scatter(xs, ys, c=[cmap(idx / max(n_shadows - 1, 1))], 
                   s=100, zorder=5, edgecolors='black', linewidth=0.5)
    
    # Mark original support
    if idx == 0:
        for p in S:
            ax.scatter(p[0], p[1], c='red', s=150, marker='*', zorder=6)
    
    ax.set_title(f'Shadow_{idx}(S)\n|Shadow| = {len(shadow)}', fontsize=11)
    ax.set_xlim(-0.5, grid_max - 0.5)
    ax.set_ylim(-0.5, grid_max - 0.5)
    ax.set_aspect('equal')
    ax.set_xlabel('x exponent')
    ax.set_ylabel('y exponent')
    ax.grid(True, alpha=0.15)

# Remove unused subplots
for idx in range(n_shadows, 8):
    axes[idx // 4, idx % 4].set_visible(False)

plt.tight_layout()
plt.savefig('shadow_geometry_2d.png', dpi=150, bbox_inches='tight')
print("Saved shadow_geometry_2d.png")
