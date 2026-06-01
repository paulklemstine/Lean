#!/usr/bin/env python3
"""
Visualization: 2D Gravitational Orbits vs 3D
Shows the non-closing precessing orbits in 2D gravity.
"""

import math
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def integrate_2d_gravity(k, L, m, r0, rdot0, dt, n_steps):
    """Integrate 2D gravity orbit."""
    r, rdot, theta = r0, rdot0, 0.0
    xs, ys = [], []
    for _ in range(n_steps):
        xs.append(r * math.cos(theta))
        ys.append(r * math.sin(theta))
        a_r = -k / r + L**2 / (m * r**3)
        r_new = max(r + rdot * dt + 0.5 * a_r * dt**2, 0.01)
        a_r_new = -k / r_new + L**2 / (m * r_new**3)
        rdot = rdot + 0.5 * (a_r + a_r_new) * dt
        theta += L / (m * r**2) * dt
        r = r_new
    return xs, ys


def integrate_3d_gravity(k, L, m, r0, rdot0, dt, n_steps):
    """Integrate 3D gravity orbit (Kepler problem)."""
    r, rdot, theta = r0, rdot0, 0.0
    xs, ys = [], []
    for _ in range(n_steps):
        xs.append(r * math.cos(theta))
        ys.append(r * math.sin(theta))
        a_r = -k / r**2 + L**2 / (m * r**3)
        r_new = max(r + rdot * dt + 0.5 * a_r * dt**2, 0.01)
        a_r_new = -k / r_new**2 + L**2 / (m * r_new**3)
        rdot = rdot + 0.5 * (a_r + a_r_new) * dt
        theta += L / (m * r**2) * dt
        r = r_new
    return xs, ys


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Parameters
k, L, m = 1.0, 1.0, 1.0
dt = 0.005

# 2D gravity orbit
r0_2d = abs(L) / math.sqrt(m * k) * 1.3
x2d, y2d = integrate_2d_gravity(k, L, m, r0_2d, 0.0, dt, 80000)

ax1 = axes[0]
ax1.plot(x2d, y2d, linewidth=0.3, alpha=0.7, color='#2196F3')
ax1.plot(0, 0, 'ko', markersize=8)
ax1.set_title('2D Gravity: Orbit Never Closes\n(Apsidal angle = π/√2, irrational)', fontsize=12)
ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# Draw annulus
radii = [math.sqrt(x**2 + y**2) for x, y in zip(x2d, y2d)]
r_min, r_max = min(radii), max(radii)
circle_inner = plt.Circle((0, 0), r_min, fill=False, color='red', linestyle='--', linewidth=1)
circle_outer = plt.Circle((0, 0), r_max, fill=False, color='red', linestyle='--', linewidth=1)
ax1.add_patch(circle_inner)
ax1.add_patch(circle_outer)
lim = r_max * 1.2
ax1.set_xlim(-lim, lim)
ax1.set_ylim(-lim, lim)

# 3D gravity orbit (Kepler)
r0_3d = 1.0 / (1 - 0.3)  # e = 0.3 ellipse
x3d, y3d = integrate_3d_gravity(k, L, m, r0_3d, 0.0, dt, 20000)

ax2 = axes[1]
ax2.plot(x3d, y3d, linewidth=0.8, color='#4CAF50')
ax2.plot(0, 0, 'ko', markersize=8)
ax2.set_title('3D Gravity: Closed Elliptical Orbit\n(Apsidal angle = π, rational)', fontsize=12)
ax2.set_xlabel('x')
ax2.set_ylabel('y')
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.3)
radii3d = [math.sqrt(x**2 + y**2) for x, y in zip(x3d, y3d)]
lim3d = max(radii3d) * 1.2
ax2.set_xlim(-lim3d, lim3d)
ax2.set_ylim(-lim3d, lim3d)

plt.suptitle('Flatland Catastrophe: 2D vs 3D Gravitational Orbits', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('orbits_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved orbits_comparison.png")
