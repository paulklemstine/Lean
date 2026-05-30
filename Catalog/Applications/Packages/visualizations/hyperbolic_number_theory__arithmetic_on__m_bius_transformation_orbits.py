"""
Visualization 2: Möbius Transformation Orbits and Hyperbolic Tessellation

Shows how Möbius transformations generate lattice-like structures in the
Poincaré disk, creating "hyperbolic integers" through orbit generation.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Helper functions (all self-contained) ---

def moebius_translate(ax, ay, zx, zy):
    """Apply Möbius translation T_a(z) = (z-a)/(1-āz)."""
    denom = (1 - ax*zx - ay*zy)**2 + (ax*zy - ay*zx)**2
    if denom < 1e-15:
        return zx, zy
    rx = ((zx - ax)*(1 - ax*zx - ay*zy) + (zy - ay)*(ax*zy - ay*zx)) / denom
    ry = ((zy - ay)*(1 - ax*zx - ay*zy) - (zx - ax)*(ax*zy - ay*zx)) / denom
    return rx, ry

def generate_orbit(generators, max_depth=5):
    """Generate orbit of origin under iterated Möbius translations."""
    points = [(0.0, 0.0)]
    current = [(0.0, 0.0)]
    seen = {(0, 0)}

    for _ in range(max_depth):
        next_layer = []
        for px, py in current:
            for gx, gy in generators:
                nx, ny = moebius_translate(gx, gy, px, py)
                key = (round(nx, 6), round(ny, 6))
                if key not in seen and nx**2 + ny**2 < 0.999:
                    seen.add(key)
                    points.append((nx, ny))
                    next_layer.append((nx, ny))
                # Also apply inverse
                nx2, ny2 = moebius_translate(-gx, -gy, px, py)
                key2 = (round(nx2, 6), round(ny2, 6))
                if key2 not in seen and nx2**2 + ny2**2 < 0.999:
                    seen.add(key2)
                    points.append((nx2, ny2))
                    next_layer.append((nx2, ny2))
        current = next_layer
    return points

# --- Left panel: Orbit of a single generator ---
ax = axes[0]
ax.set_aspect('equal')
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.03, color='blue')

# Single generator: translation along x-axis
gen = [(0.5, 0.0)]
orbit = generate_orbit(gen, max_depth=8)

xs = [p[0] for p in orbit]
ys = [p[1] for p in orbit]

# Color by hyperbolic distance from origin
hyp_norms = []
for x, y in orbit:
    r = np.sqrt(x**2 + y**2)
    if r < 0.9999:
        hyp_norms.append(np.log((1+r)/(1-r)))
    else:
        hyp_norms.append(10)

sc = ax.scatter(xs, ys, c=hyp_norms, cmap='plasma', s=20, zorder=5,
                edgecolors='black', linewidths=0.3)
plt.colorbar(sc, ax=ax, label='Hyperbolic distance from origin', shrink=0.8)
ax.plot(0, 0, 'r*', markersize=12, zorder=10)
ax.set_title('Orbit of Single Generator (r=0.5)', fontsize=12)
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)

# --- Right panel: Two generators (richer tessellation) ---
ax2 = axes[1]
ax2.set_aspect('equal')
ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax2.fill(np.cos(theta), np.sin(theta), alpha=0.03, color='green')

# Two generators: translations in different directions
angle1, angle2 = 0, 2*np.pi/3
r = 0.4
gens = [(r*np.cos(angle1), r*np.sin(angle1)),
        (r*np.cos(angle2), r*np.sin(angle2))]

orbit2 = generate_orbit(gens, max_depth=5)
xs2 = [p[0] for p in orbit2]
ys2 = [p[1] for p in orbit2]

hyp_norms2 = []
for x, y in orbit2:
    rr = np.sqrt(x**2 + y**2)
    if rr < 0.9999:
        hyp_norms2.append(np.log((1+rr)/(1-rr)))
    else:
        hyp_norms2.append(10)

sc2 = ax2.scatter(xs2, ys2, c=hyp_norms2, cmap='viridis', s=15, zorder=5,
                  edgecolors='black', linewidths=0.2)
plt.colorbar(sc2, ax=ax2, label='Hyperbolic distance from origin', shrink=0.8)
ax2.plot(0, 0, 'r*', markersize=12, zorder=10)
ax2.set_title(f'Orbit of 2 Generators ({len(orbit2)} points)', fontsize=12)
ax2.set_xlim(-1.1, 1.1)
ax2.set_ylim(-1.1, 1.1)

plt.tight_layout()
plt.savefig('viz_moebius_orbits.png', dpi=150, bbox_inches='tight')
plt.close()
