"""
Visualization: The Poincaré Disk and Möbius Automorphisms

Shows how Möbius transformations map the unit disk to itself,
illustrating the fundamental algebraic identity that governs
hyperbolic geometry. The grid lines show how Euclidean geometry
is "warped" near the boundary of the disk.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def moebius_map(a, z):
    """Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a)*z)."""
    return (z - a) / (1 - np.conj(a) * z)


fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# Parameters
a_values = [0.0 + 0.0j, 0.3 + 0.4j, -0.5 + 0.3j]
titles = [
    "Identity Map (a = 0)",
    "Möbius Map (a = 0.3 + 0.4i)",
    "Möbius Map (a = -0.5 + 0.3i)"
]

for ax, a, title in zip(axes, a_values, titles):
    # Draw unit disk boundary
    circle = patches.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    # Create grid of points in the disk
    n_lines = 8
    n_pts = 200

    # Radial lines
    for angle in np.linspace(0, 2 * np.pi, n_lines, endpoint=False):
        r = np.linspace(0, 0.95, n_pts)
        z = r * np.exp(1j * angle)
        w = moebius_map(a, z)
        ax.plot(w.real, w.imag, 'b-', alpha=0.3, linewidth=0.8)

    # Circular arcs
    for r in np.linspace(0.1, 0.9, 6):
        theta = np.linspace(0, 2 * np.pi, n_pts)
        z = r * np.exp(1j * theta)
        w = moebius_map(a, z)
        ax.plot(w.real, w.imag, 'r-', alpha=0.3, linewidth=0.8)

    # Plot lattice points (images of regular grid intersections)
    for r in [0.2, 0.4, 0.6, 0.8]:
        for angle in np.linspace(0, 2*np.pi, 12, endpoint=False):
            z = r * np.exp(1j * angle)
            w = moebius_map(a, z)
            ax.plot(w.real, w.imag, 'ko', markersize=2)

    # Mark the center point a and its image (0)
    if abs(a) > 0:
        ax.plot(a.real, a.imag, 'g^', markersize=8, label=f'a = {a}', zorder=5)
        ax.plot(0, 0, 'rs', markersize=6, label='φ_a(a) = 0', zorder=5)
        ax.legend(loc='upper right', fontsize=8)

    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=11)
    ax.grid(True, alpha=0.15)
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)

plt.suptitle("Möbius Automorphisms of the Poincaré Disk\n"
             "Blue: radial geodesics | Red: hyperbolic circles | "
             "Key identity: |1-āz|² - |z-a|² = (1-|z|²)(1-|a|²)",
             fontsize=12, y=1.02)
plt.tight_layout()
plt.savefig("viz_poincare_disk.png", dpi=150, bbox_inches='tight')
plt.close()
