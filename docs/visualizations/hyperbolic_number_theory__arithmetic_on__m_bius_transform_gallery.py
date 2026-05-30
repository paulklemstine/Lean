"""
Visualization: Möbius Transform Action on the Poincaré Disk
=============================================================
Shows how a Möbius transformation distorts the disk, mapping
the center point to the origin. The grid lines become circular
arcs — geodesics in hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_map(a, theta, z):
    """Möbius transformation: e^{iθ}(z-a)/(1-conj(a)z)"""
    eitheta = np.exp(1j * theta)
    denom = 1 - np.conj(a) * z
    # Avoid division by zero
    safe = np.abs(denom) > 1e-10
    result = np.where(safe, eitheta * (z - a) / np.where(safe, denom, 1), np.nan)
    # Mask points outside disk
    result = np.where(np.abs(result) < 1.5, result, np.nan)
    return result


fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Different centers and rotations
configs = [
    (0 + 0j, 0, 'Identity (a=0, θ=0)'),
    (0.5 + 0j, 0, 'Translation (a=0.5, θ=0)'),
    (0.3 + 0.4j, 0, 'Off-center (a=0.3+0.4i, θ=0)'),
    (0 + 0j, np.pi / 4, 'Rotation (a=0, θ=π/4)'),
    (0.3 + 0.4j, np.pi / 3, 'Combined (a=0.3+0.4i, θ=π/3)'),
    (0.7 + 0j, np.pi / 6, 'Near boundary (a=0.7, θ=π/6)'),
]

for idx, (a, theta, title) in enumerate(configs):
    ax = axes[idx // 3][idx % 3]

    # Draw unit circle
    circle_t = np.linspace(0, 2 * np.pi, 200)
    ax.plot(np.cos(circle_t), np.sin(circle_t), 'k-', linewidth=2)

    # Create a grid in the disk
    # Radial lines
    for angle in np.linspace(0, 2 * np.pi, 13)[:-1]:
        r_vals = np.linspace(0, 0.95, 50)
        z_line = r_vals * np.exp(1j * angle)
        w_line = mobius_map(a, theta, z_line)
        valid = ~np.isnan(w_line) & (np.abs(w_line) < 1)
        ax.plot(w_line[valid].real, w_line[valid].imag,
                color='steelblue', alpha=0.4, linewidth=0.8)

    # Concentric circles
    for r in np.linspace(0.1, 0.9, 5):
        z_circle = r * np.exp(1j * np.linspace(0, 2 * np.pi, 100))
        w_circle = mobius_map(a, theta, z_circle)
        valid = ~np.isnan(w_circle) & (np.abs(w_circle) < 1)
        ax.plot(w_circle[valid].real, w_circle[valid].imag,
                color='coral', alpha=0.5, linewidth=0.8)

    # Mark the center point and its image
    if abs(a) > 0.01:
        ax.plot(a.real, a.imag, 'g*', markersize=12, label='center a')
        # Image of origin
        w0 = mobius_map(a, theta, np.array([0 + 0j]))[0]
        if not np.isnan(w0):
            ax.plot(w0.real, w0.imag, 'r^', markersize=8, label='φ(0)')

    ax.plot(0, 0, 'k+', markersize=8)
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=10)
    ax.grid(True, alpha=0.15)
    if abs(a) > 0.01:
        ax.legend(fontsize=7, loc='lower right')

fig.suptitle('Möbius Transformations on the Poincaré Disk\n'
             '(Blue: radial geodesics, Coral: distance circles)',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('mobius_transforms.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: mobius_transforms.png")
