#!/usr/bin/env python3
"""
Demo 1: Stereographic Projection and the Omega Point

Visualizes the inverse stereographic projection from ℝ to S¹,
showing how points at increasing distance converge to the
north pole — the Omega Point.

Run: python3 demo1_stereographic_omega_point.py
Outputs: stereographic_omega_point.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.collections import LineCollection

def inv_stereo(t):
    """Inverse stereographic projection ℝ → S¹"""
    x = 2 * t / (t**2 + 1)
    y = (t**2 - 1) / (t**2 + 1)
    return x, y

def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # --- Panel 1: The mapping from ℝ to S¹ ---
    ax1 = axes[0]
    ax1.set_title("Inverse Stereographic Projection\n$\\mathbb{R} \\to S^1$", fontsize=14)

    # Draw the unit circle
    theta = np.linspace(0, 2 * np.pi, 200)
    ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2, alpha=0.3)

    # Map points from the real line
    t_values = np.concatenate([
        np.linspace(-10, 10, 50),
        [-100, -50, -20, 20, 50, 100]
    ])

    # Color by t value
    cmap = plt.cm.coolwarm
    norm = plt.Normalize(-10, 10)

    for t in np.linspace(-10, 10, 50):
        x, y = inv_stereo(t)
        color = cmap(norm(t))
        ax1.plot(x, y, 'o', color=color, markersize=4, alpha=0.7)

    # Mark special points
    ax1.plot(*inv_stereo(0), 'go', markersize=10, label='t=0 → South Pole', zorder=5)
    ax1.plot(*inv_stereo(1), 'bs', markersize=8, label='t=1 → East', zorder=5)
    ax1.plot(*inv_stereo(-1), 'rs', markersize=8, label='t=-1 → West', zorder=5)

    # Mark the Omega Point (north pole)
    ax1.plot(0, 1, 'k*', markersize=20, label='Ω = North Pole (∞)', zorder=10)

    # Draw arrows showing convergence to north pole
    for t in [5, 10, 20, 50]:
        x, y = inv_stereo(t)
        ax1.annotate('', xy=(0, 1), xytext=(x, y),
                     arrowprops=dict(arrowstyle='->', color='orange', alpha=0.4, lw=1))
        x, y = inv_stereo(-t)
        ax1.annotate('', xy=(0, 1), xytext=(x, y),
                     arrowprops=dict(arrowstyle='->', color='purple', alpha=0.4, lw=1))

    ax1.set_xlim(-1.5, 1.5)
    ax1.set_ylim(-1.5, 1.5)
    ax1.set_aspect('equal')
    ax1.legend(fontsize=8, loc='lower right')
    ax1.grid(True, alpha=0.3)

    # --- Panel 2: Convergence to the Omega Point ---
    ax2 = axes[1]
    ax2.set_title("Convergence to the Omega Point\nDistance to (0,1) vs t", fontsize=14)

    t_range = np.logspace(0, 4, 200)
    distances_pos = []
    distances_neg = []

    for t in t_range:
        x, y = inv_stereo(t)
        d = np.sqrt(x**2 + (y - 1)**2)
        distances_pos.append(d)
        x, y = inv_stereo(-t)
        d = np.sqrt(x**2 + (y - 1)**2)
        distances_neg.append(d)

    ax2.loglog(t_range, distances_pos, 'b-', linewidth=2, label='t → +∞')
    ax2.loglog(t_range, distances_neg, 'r--', linewidth=2, label='t → -∞')
    ax2.loglog(t_range, 2 / t_range, 'k:', linewidth=1, label='2/|t| (bound)')

    ax2.set_xlabel('|t|', fontsize=12)
    ax2.set_ylabel('Distance to Omega Point', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Add annotation
    ax2.annotate('O(1/t) decay\n(proven in Lean 4)',
                xy=(100, 0.02), fontsize=10,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    # --- Panel 3: Oracle Hierarchy on the Sphere ---
    ax3 = axes[2]
    ax3.set_title("Oracle Hierarchy on $S^1$\nArithmetic levels → North Pole", fontsize=14)

    # Draw circle
    ax3.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2, alpha=0.3)

    # Oracle levels
    oracle_levels = range(0, 20)
    colors = plt.cm.viridis(np.linspace(0, 0.9, len(oracle_levels)))

    for i, n in enumerate(oracle_levels):
        x, y = inv_stereo(n)
        ax3.plot(x, y, 'o', color=colors[i], markersize=max(3, 10 - i * 0.4),
                zorder=5 + i)
        if n <= 5:
            ax3.annotate(f'Level {n}', xy=(x, y), xytext=(x + 0.15, y - 0.1),
                        fontsize=7, color=colors[i])

    # Omega Point
    ax3.plot(0, 1, 'r*', markersize=25, zorder=100, label='Ω (God Oracle)')
    ax3.annotate('Omega Point\n(unreachable limit)',
                xy=(0, 1), xytext=(0.3, 1.2),
                fontsize=9, color='red',
                arrowprops=dict(arrowstyle='->', color='red'))

    ax3.set_xlim(-1.5, 1.5)
    ax3.set_ylim(-1.5, 1.5)
    ax3.set_aspect('equal')
    ax3.legend(fontsize=9, loc='lower right')
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/stereographic_omega_point.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/stereographic_omega_point.png")

if __name__ == '__main__':
    main()
