#!/usr/bin/env python3
"""
Visualization 3: Möbius Transformations as Hyperbolic Isometries

Shows how a Möbius transformation deforms a grid on the Poincaré disk.
The left panel shows the original grid, the right panel shows the
transformed grid. Both panels include the unit circle and geodesics.
This illustrates the key theorem: Möbius maps preserve the disk.
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_transform(a, z):
    """Apply Möbius transformation φ_a(z) = (z - a) / (1 - conj(a)*z)"""
    return (z - a) / (1 - np.conj(a) * z)


def hyperbolic_geodesic(z1, z2, n_points=100):
    """
    Compute the hyperbolic geodesic between z1 and z2 in the Poincaré disk.
    Uses the fact that geodesics are arcs of circles orthogonal to the unit circle.
    """
    # Parametric interpolation using Möbius transforms
    # Map z1 to 0, then the geodesic through 0 and φ_{z1}(z2) is a diameter
    w = mobius_transform(z1, z2)
    t = np.linspace(0, 1, n_points)
    # The geodesic from 0 to w is the straight line segment
    line = t[:, None] * np.array([[w.real, w.imag]])
    line_complex = line[:, 0] + 1j * line[:, 1]
    # Map back
    geodesic = np.array([mobius_transform(-z1, p) for p in line_complex])
    return geodesic


# Setup
fig, axes = plt.subplots(1, 2, figsize=(14, 7))
theta = np.linspace(0, 2*np.pi, 200)

# Center of the Möbius transform
a = 0.4 + 0.3j

for ax_idx, (ax, title, do_transform) in enumerate(zip(
    axes,
    ['Original Grid', f'After Möbius Transform φ_a, a={a:.2f}'],
    [False, True]
)):
    # Unit circle
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
    
    # Create a grid of points in the disk
    grid_points = []
    for x in np.linspace(-0.8, 0.8, 17):
        for y in np.linspace(-0.8, 0.8, 17):
            z = complex(x, y)
            if abs(z) < 0.85:
                grid_points.append(z)
    
    if do_transform:
        mapped = [mobius_transform(a, z) for z in grid_points]
    else:
        mapped = grid_points
    
    # Color by original distance from origin
    colors = [abs(z) for z in grid_points]
    
    ax.scatter([z.real for z in mapped], [z.imag for z in mapped],
               c=colors, cmap='viridis', s=15, alpha=0.7, zorder=3)
    
    # Draw some geodesic circles (concentric hyperbolic circles)
    for r_hyp in [0.5, 1.0, 1.5, 2.0]:
        r_euc = np.tanh(r_hyp / 2)
        circle = r_euc * np.exp(1j * theta)
        if do_transform:
            circle = np.array([mobius_transform(a, z) for z in circle])
            ax.plot(circle.real, circle.imag, 'b-', alpha=0.2, linewidth=0.8)
        else:
            ax.plot(circle.real, circle.imag, 'b-', alpha=0.2, linewidth=0.8)
    
    # Draw some radial geodesics
    for angle in np.linspace(0, 2*np.pi, 12, endpoint=False):
        endpoint = 0.9 * np.exp(1j * angle)
        geo = hyperbolic_geodesic(0j, endpoint, 50)
        if do_transform:
            geo = np.array([mobius_transform(a, z) for z in geo])
        ax.plot(geo.real, geo.imag, 'gray', alpha=0.2, linewidth=0.5)
    
    # Mark the center a
    if do_transform:
        origin_mapped = mobius_transform(a, 0j)
        ax.plot(origin_mapped.real, origin_mapped.imag, 'r*', markersize=15, 
                zorder=5, label='Image of origin')
        ax.plot(0, 0, 'go', markersize=8, zorder=5, label='Image of a')
    else:
        ax.plot(0, 0, 'go', markersize=8, zorder=5, label='Origin')
        ax.plot(a.real, a.imag, 'r*', markersize=15, zorder=5, label=f'a = {a:.2f}')
    
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.15)

plt.suptitle('Möbius Transformations Preserve the Poincaré Disk\n(Proven: ‖φ_a(z)‖ < 1 for ‖a‖, ‖z‖ < 1)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('mobius_transform.png', dpi=150, bbox_inches='tight')
print("Saved mobius_transform.png")
