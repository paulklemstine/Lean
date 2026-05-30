#!/usr/bin/env python3
"""
Visualization 2: Cayley Transform — Bridge Between Disk and Half-Plane

Shows how the Cayley transform C(z) = i(1+z)/(1-z) maps the Poincaré disk
to the upper half-plane. This is the geometric bridge between hyperbolic
geometry (where our integers live) and the domain of modular forms
and L-functions (where the Riemann hypothesis lives).
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


def cayley_transform(z):
    if abs(1 - z) < 1e-15:
        return complex(0, 1e6)
    return 1j * (1 + z) / (1 - z)


def cayley_inverse(w):
    return (w - 1j) / (w + 1j)


def mobius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def hyp_norm(z):
    r = abs(z)
    if r >= 1:
        return float('inf')
    if r < 1e-15:
        return 0.0
    return np.log((1 + r) / (1 - r)) / 2


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# ─── Left: Poincaré Disk ───────────────────────────────────────────

ax1 = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax1.add_patch(circle)

# Draw geodesics (circles orthogonal to boundary)
# A geodesic through 0 is a diameter
for angle in np.linspace(0, np.pi, 6, endpoint=False):
    t = np.linspace(-0.95, 0.95, 100)
    x = t * np.cos(angle)
    y = t * np.sin(angle)
    ax1.plot(x, y, 'gray', alpha=0.3, linewidth=0.8)

# Draw concentric hyperbolic circles (constant hyperbolic distance from origin)
for R in [0.5, 1.0, 1.5, 2.0]:
    r_euclid = np.tanh(R)
    circ = plt.Circle((0, 0), r_euclid, fill=False, color='steelblue',
                       linewidth=0.8, linestyle='--', alpha=0.5)
    ax1.add_patch(circ)
    ax1.text(r_euclid + 0.02, 0.02, f'R={R}', fontsize=7, color='steelblue')

# Sample points with colors
np.random.seed(42)
disk_points = []
colors = []
for i in range(50):
    r = np.random.random() * 0.9
    theta = np.random.random() * 2 * np.pi
    z = r * np.exp(1j * theta)
    disk_points.append(z)
    colors.append(hyp_norm(z))

scatter1 = ax1.scatter([z.real for z in disk_points],
                        [z.imag for z in disk_points],
                        c=colors, cmap='plasma', s=30, zorder=3,
                        edgecolors='black', linewidth=0.5)
ax1.scatter(0, 0, c='red', s=80, zorder=5, marker='*')

ax1.set_xlim(-1.3, 1.3)
ax1.set_ylim(-1.3, 1.3)
ax1.set_aspect('equal')
ax1.set_title('Poincaré Disk Model', fontsize=14, fontweight='bold')
ax1.set_xlabel('Re(z)')
ax1.set_ylabel('Im(z)')
plt.colorbar(scatter1, ax=ax1, label='Hyperbolic norm', shrink=0.7)

# ─── Right: Upper Half-Plane ───────────────────────────────────────

ax2 = axes[1]

# Transform points
uhp_points = [cayley_transform(z) for z in disk_points]

# Filter out extreme points for display
uhp_filtered = [(w, c) for w, c in zip(uhp_points, colors)
                if abs(w.real) < 15 and 0 < w.imag < 15]

if uhp_filtered:
    ws, cs = zip(*uhp_filtered)
    scatter2 = ax2.scatter([w.real for w in ws], [w.imag for w in ws],
                            c=cs, cmap='plasma', s=30, zorder=3,
                            edgecolors='black', linewidth=0.5)

# Mark C(0) = i
ax2.scatter(0, 1, c='red', s=80, zorder=5, marker='*')
ax2.annotate('C(0) = i', (0, 1), (0.5, 1.5), fontsize=10, color='red',
             arrowprops=dict(arrowstyle='->', color='red'))

# Draw the real axis (boundary of UHP)
ax2.axhline(y=0, color='black', linewidth=2)

# Draw some horizontal horocycles
for y in [0.5, 1, 2, 4]:
    ax2.axhline(y=y, color='steelblue', linewidth=0.5, linestyle='--', alpha=0.4)

ax2.set_xlim(-8, 8)
ax2.set_ylim(-0.5, 10)
ax2.set_title('Upper Half-Plane (via Cayley Transform)', fontsize=14, fontweight='bold')
ax2.set_xlabel('Re(w)')
ax2.set_ylabel('Im(w)')
ax2.text(3, 9, 'C(z) = i(1+z)/(1−z)', fontsize=11, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow'))

# Draw arrow between panels
fig.patches.append(FancyArrowPatch(
    (0.48, 0.5), (0.52, 0.5),
    transform=fig.transFigure,
    arrowstyle='->', mutation_scale=30,
    color='darkgreen', linewidth=3
))
fig.text(0.5, 0.54, 'Cayley\nTransform', ha='center', va='bottom',
         fontsize=11, color='darkgreen', fontweight='bold',
         transform=fig.transFigure)

plt.tight_layout(w_pad=3)
plt.savefig('viz_cayley_bridge.png', dpi=150, bbox_inches='tight')
print("Saved Cayley bridge visualization")
