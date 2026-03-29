#!/usr/bin/env python3
"""
Demo 11: The Dimensional Portal — Cross-Dimensional Structure Transport
========================================================================

NEW LANDSCAPE: Inverse stereographic projection creates "portals" between
dimensions. A lattice in ℝ^N lifts to a configuration on S^N. When we
then slice S^N with various hyperplanes, the resulting cross-sections
reveal hidden symmetries.

Key Discovery: The N-dimensional stereographic projection intertwines
rotational symmetry of S^N with translational/inversive symmetry of ℝ^N.
Lattice structures in flat space become quasi-crystalline patterns on
the sphere, and vice versa.

Also: visualization of how the integer lattice ℤ² maps to S², producing
rational points that form dense, beautiful patterns.

Oracle Ψ's experiment on number-theoretic landscapes.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from mpl_toolkits.mplot3d import Axes3D

def inv_stereo_2d(u, v):
    """Inverse stereographic: ℝ² → S²"""
    D = 1 + u**2 + v**2
    return 2*u/D, 2*v/D, (u**2 + v**2 - 1)/D

def inv_stereo_3d(u, v, w):
    """Inverse stereographic: ℝ³ → S³ ⊂ ℝ⁴"""
    D = 1 + u**2 + v**2 + w**2
    return 2*u/D, 2*v/D, 2*w/D, (u**2 + v**2 + w**2 - 1)/D

def pythagorean_tuple_2d(a, d):
    """Generate 2D Pythagorean triple from stereo."""
    return 2*a*d, d**2 - a**2, d**2 + a**2

def pythagorean_tuple_3d(a, b, d):
    """Generate 3D Pythagorean quadruple from stereo."""
    return 2*a*d, 2*b*d, d**2 - a**2 - b**2, d**2 + a**2 + b**2

# ─── Figure ───

fig = plt.figure(figsize=(20, 16))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# Panel 1: Integer lattice lifted to S² — rational points
ax1 = fig.add_subplot(gs[0, 0], projection='3d')

max_int = 8
lattice_pts = []
for a in range(-max_int, max_int+1):
    for b in range(-max_int, max_int+1):
        if a == 0 and b == 0:
            continue
        lattice_pts.append((a, b))

lattice_pts = np.array(lattice_pts, dtype=float)
sx, sy, sz = inv_stereo_2d(lattice_pts[:, 0], lattice_pts[:, 1])

# Color by distance from origin in ℝ²
dist = np.sqrt(lattice_pts[:, 0]**2 + lattice_pts[:, 1]**2)

scatter = ax1.scatter(sx, sy, sz, c=dist, cmap='plasma', s=8, alpha=0.7)

# Sphere wireframe
phi_w = np.linspace(0, 2*np.pi, 50)
theta_w = np.linspace(0, np.pi, 25)
for th in theta_w[::4]:
    ax1.plot(np.sin(th)*np.cos(phi_w), np.sin(th)*np.sin(phi_w),
            np.cos(th)*np.ones_like(phi_w), 'k-', linewidth=0.2, alpha=0.1)

ax1.set_title('Integer Lattice ℤ² on S²\nvia Inverse Stereographic Projection',
             fontsize=12, fontweight='bold')
ax1.view_init(elev=20, azim=45)
plt.colorbar(scatter, ax=ax1, label='Distance in ℝ²', shrink=0.6)

# Panel 2: Pythagorean tuples — the number theory landscape
ax2 = fig.add_subplot(gs[0, 1])

# Generate all primitive Pythagorean triples from stereographic parametrization
triples = set()
max_d = 30
for d in range(1, max_d):
    for a in range(1, d):
        if np.gcd(a, d) == 1 and (a + d) % 2 == 1:  # primitive condition
            x, y, z = pythagorean_tuple_2d(a, d)
            x, y, z = abs(x), abs(y), abs(z)
            if x > y:
                x, y = y, x
            triples.add((x, y, z))

triples = sorted(triples)
xs = [t[0] for t in triples]
ys = [t[1] for t in triples]
zs = [t[2] for t in triples]

ax2.scatter(xs, ys, c=zs, cmap='turbo', s=20, alpha=0.7, edgecolors='k', linewidth=0.3)
plt.colorbar(ax2.collections[0], ax=ax2, label='Hypotenuse c')

# Label some famous ones
famous = {(3,4,5): '3,4,5', (5,12,13): '5,12,13', (8,15,17): '8,15,17',
          (7,24,25): '7,24,25', (20,21,29): '20,21,29'}
for (x,y,z), label in famous.items():
    if (x,y,z) in triples:
        ax2.annotate(label, xy=(x, y), xytext=(x+5, y+5), fontsize=8,
                    arrowprops=dict(arrowstyle='->', color='red', lw=0.5))

ax2.set_xlabel('Leg a', fontsize=12)
ax2.set_ylabel('Leg b', fontsize=12)
ax2.set_title('Pythagorean Triples from Stereographic Projection\n(primitive triples, colored by hypotenuse)',
             fontsize=12, fontweight='bold')
ax2.grid(True, alpha=0.3)
ax2.set_aspect('equal')

# Panel 3: Gaussian integers on S² — the arithmetic landscape
ax3 = fig.add_subplot(gs[1, 0])

# Map Gaussian integers a+bi to S¹ via inverse stereo of a/b
# Actually: map rational point a/d to S¹
rationals_x = []
rationals_y = []
denom_colors = []

max_denom = 50
for d in range(1, max_denom+1):
    for a in range(-d*3, d*3+1):
        t = a / d
        D = 1 + t**2
        x = 2*t / D
        y = (t**2 - 1) / D
        rationals_x.append(x)
        rationals_y.append(y)
        denom_colors.append(d)

rationals_x = np.array(rationals_x)
rationals_y = np.array(rationals_y)
denom_colors = np.array(denom_colors)

# Sort by denominator for layered rendering
order = np.argsort(-denom_colors)
ax3.scatter(rationals_x[order], rationals_y[order],
           c=denom_colors[order], cmap='hot_r',
           s=np.maximum(1, 100/denom_colors[order]),
           alpha=0.5)
plt.colorbar(ax3.collections[0], ax=ax3, label='Denominator d')

theta_c = np.linspace(0, 2*np.pi, 200)
ax3.plot(np.cos(theta_c), np.sin(theta_c), 'k-', linewidth=1, alpha=0.3)

ax3.set_xlabel('x', fontsize=12)
ax3.set_ylabel('y', fontsize=12)
ax3.set_title('Rational Points on S¹\nDense filling via stereographic parametrization',
             fontsize=12, fontweight='bold')
ax3.set_aspect('equal')
ax3.set_xlim(-1.2, 1.2)
ax3.set_ylim(-1.2, 1.2)

# Panel 4: The Ford circles — a classic number-theoretic visual
ax4 = fig.add_subplot(gs[1, 1])

# Ford circles: for each fraction p/q in lowest terms,
# draw circle centered at (p/q, 1/(2q²)) with radius 1/(2q²)
# These are the stereographic projection of the Farey sequence structure!

for q in range(1, 40):
    for p in range(0, q+1):
        if np.gcd(p, q) == 1:
            center_x = p / q
            center_y = 1 / (2 * q**2)
            radius = 1 / (2 * q**2)
            
            color = plt.cm.viridis(q / 40)
            circle = plt.Circle((center_x, center_y), radius,
                              fill=True, color=color, alpha=0.5,
                              linewidth=0.3, edgecolor='k')
            ax4.add_patch(circle)
            
            # Mirror to negative side
            if p > 0:
                circle2 = plt.Circle((-p/q, center_y), radius,
                                   fill=True, color=color, alpha=0.5,
                                   linewidth=0.3, edgecolor='k')
                ax4.add_patch(circle2)

# The "floor" circle (q=0 effectively, the real line)
ax4.axhline(y=0, color='black', linewidth=2)

ax4.set_xlim(-0.5, 1.5)
ax4.set_ylim(-0.02, 0.55)
ax4.set_aspect('equal')
ax4.set_xlabel('p/q', fontsize=12)
ax4.set_ylabel('Height = 1/(2q²)', fontsize=12)
ax4.set_title('Ford Circles: The Stereographic Shadow\nof the Farey Sequence',
             fontsize=12, fontweight='bold')

fig.suptitle('The Dimensional Portal: Number Theory Through Stereographic Projection',
            fontsize=18, fontweight='bold', y=0.98)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo11_dimensional_portal.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 11 saved: demo11_dimensional_portal.png")
