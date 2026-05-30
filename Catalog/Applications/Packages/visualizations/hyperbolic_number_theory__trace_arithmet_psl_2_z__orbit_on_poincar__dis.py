"""
Visualization 1: SL₂(ℤ) Orbit on the Poincaré Disk

This script visualizes the orbit of a point under the modular group PSL(2,ℤ)
acting on the Poincaré disk model of the hyperbolic plane. The orbit points
form the "hyperbolic integers" — the central object of our study.

The coloring indicates hyperbolic distance from the origin, showing how
hyperbolic space expands exponentially near the boundary.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import math
from collections import deque


def cayley_to_disk(z):
    """Map upper half-plane to Poincaré disk: w = (z-i)/(z+i)."""
    i = complex(0, 1)
    if abs(z + i) < 1e-15:
        return None
    return (z - i) / (z + i)


def hyp_dist_from_origin(w):
    """Hyperbolic distance from origin in the disk model."""
    r = abs(w)
    if r >= 1:
        return float('inf')
    return 2 * math.atanh(r)


def sl2z_orbit(max_depth=6, base=complex(0, 1)):
    """Compute orbit of base under PSL(2,ℤ) generators S and T."""
    seen = set()
    points = []
    queue = deque([(base, 0)])
    
    while queue:
        z, d = queue.popleft()
        key = (round(z.real, 6), round(z.imag, 6))
        if key in seen or z.imag <= 0.01:
            continue
        seen.add(key)
        
        w = cayley_to_disk(z)
        if w and abs(w) < 0.999:
            points.append(w)
        
        if d < max_depth:
            if abs(z) > 0.01:
                queue.append((-1/z, d+1))
            queue.append((z+1, d+1))
            queue.append((z-1, d+1))
    
    return points


# Generate orbit
orbit = sl2z_orbit(max_depth=7)

fig, ax = plt.subplots(1, 1, figsize=(10, 10), dpi=150)

# Draw the unit circle (boundary of hyperbolic space)
circle = patches.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Draw geodesic circles (horocycles) for reference
for r in [0.3, 0.5, 0.7, 0.9]:
    ref_circle = patches.Circle((0, 0), r, fill=False, color='gray',
                                 linewidth=0.3, linestyle='--', alpha=0.5)
    ax.add_patch(ref_circle)

# Color points by hyperbolic distance
xs = [p.real for p in orbit]
ys = [p.imag for p in orbit]
dists = [hyp_dist_from_origin(p) for p in orbit]

scatter = ax.scatter(xs, ys, c=dists, cmap='plasma', s=15, alpha=0.8,
                     edgecolors='none', vmin=0, vmax=max(dists) * 0.8)

# Mark the origin
ax.plot(0, 0, 'r*', markersize=15, zorder=5, label='Origin')

plt.colorbar(scatter, ax=ax, label='Hyperbolic distance from origin', shrink=0.8)

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Integers: PSL(2,ℤ) Orbit on the Poincaré Disk',
             fontsize=14, fontweight='bold')
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.legend(loc='upper right')
ax.grid(True, alpha=0.2)

fig.tight_layout()
plt.savefig('viz_poincare_orbit.png', dpi=150, bbox_inches='tight')
print(f"Saved visualization with {len(orbit)} orbit points")
