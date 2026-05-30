#!/usr/bin/env python3
"""
Visualization 1: The Poincaré Disk with SL₂(ℤ) Orbit Points

Visualizes the hyperbolic lattice: orbit points of the origin under
the action of SL₂(ℤ), colored by trace value. Shows how the discrete
group action creates a regular tessellation of hyperbolic space.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def mobius_action_disk(a, b, c, d, z):
    """Apply Möbius transformation [[a,b],[c,d]] to complex number z in disk model.
    First map disk to upper half-plane, apply, then map back."""
    # Cayley transform: disk → upper half-plane: w = i(1+z)/(1-z)
    if abs(1 - z) < 1e-15:
        return complex(0, 0)
    w = 1j * (1 + z) / (1 - z)
    # Apply Möbius: w -> (aw+b)/(cw+d)
    denom = c * w + d
    if abs(denom) < 1e-15:
        return complex(0, 0)
    w_new = (a * w + b) / denom
    # Inverse Cayley: upper half-plane → disk: z = (w-i)/(w+i)
    denom2 = w_new + 1j
    if abs(denom2) < 1e-15:
        return complex(0, 0)
    z_new = (w_new - 1j) / denom2
    return z_new


def generate_orbit_points(max_trace=15, max_entries=30):
    """Generate SL₂(ℤ) orbit points of i (mapped to origin in disk model)."""
    points = []
    traces = []

    for a in range(-max_entries, max_entries + 1):
        for c in range(-max_entries, max_entries + 1):
            for d in range(-max_entries, max_entries + 1):
                det_rem = a * d - 1
                if c == 0:
                    continue
                if det_rem % c != 0:
                    continue
                b = det_rem // c
                if abs(a + d) > max_trace:
                    continue
                # Apply to origin (which corresponds to i in UHP)
                z = mobius_action_disk(a, b, c, d, complex(0, 0))
                r = abs(z)
                if r < 0.999:
                    points.append((z.real, z.imag))
                    traces.append(abs(a + d))

    return points, traces


# Generate orbit points
points, traces = generate_orbit_points(max_trace=12, max_entries=15)

# Create figure
fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw unit circle
theta = np.linspace(0, 2 * np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Draw some geodesics (arcs of circles orthogonal to unit circle)
for angle in np.linspace(0, np.pi, 7)[1:-1]:
    center_x = 1.0 / np.cos(angle)
    center_y = 0
    radius = abs(np.tan(angle))
    arc_angles = np.linspace(-np.pi/2, np.pi/2, 100)
    arc_x = center_x + radius * np.cos(arc_angles)
    arc_y = center_y + radius * np.sin(arc_angles)
    mask = arc_x**2 + arc_y**2 < 0.999
    if np.any(mask):
        ax.plot(arc_x[mask], arc_y[mask], 'lightblue', alpha=0.3, linewidth=0.5)

# Plot orbit points
if points:
    xs, ys = zip(*points)
    scatter = ax.scatter(xs, ys, c=traces, cmap='plasma', s=20, alpha=0.8,
                         edgecolors='black', linewidth=0.3, zorder=5)
    plt.colorbar(scatter, ax=ax, label='|Trace|', shrink=0.8)

# Mark origin
ax.plot(0, 0, 'r*', markersize=15, zorder=10, label='Origin (= i in UHP)')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('SL₂(ℤ) Orbit in the Poincaré Disk\nColored by |Trace| of the Group Element',
             fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=10)
ax.grid(True, alpha=0.1)

# Add annotation
ax.text(-1.1, -1.08,
        f'{len(points)} orbit points shown\nTrace values determine hyperbolic distance from origin',
        fontsize=8, style='italic', alpha=0.7)

plt.tight_layout()
plt.savefig('poincare_disk_orbit.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"Generated Poincaré disk visualization with {len(points)} orbit points")
