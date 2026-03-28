#!/usr/bin/env python3
"""
Demo 2: The Hopf Fibrations
============================
Visualizes the Hopf fibration S³ → S² and its connection to the
division algebras. The four Hopf fibrations exist ONLY because of
the four division algebras.

The Algebraic Theory of Reality
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def stereographic_project(x, y, z, w):
    """Stereographic projection from S³ to ℝ³."""
    denom = 1 - w + 1e-10
    return x / denom, y / denom, z / denom

def hopf_fiber(eta, t_range, base_theta, base_phi):
    """
    Generate a Hopf fiber over a point on S².

    The Hopf map h: S³ → S² sends (z₁, z₂) ∈ ℂ² with |z₁|²+|z₂|²=1
    to the point z₁/z₂ ∈ S² (via stereographic projection of ℂP¹).

    Each fiber is a great circle in S³.
    """
    # Base point on S² in spherical coordinates
    cos_half = np.cos(base_theta / 2)
    sin_half = np.sin(base_theta / 2)

    # Points on the fiber (great circle in S³)
    x = cos_half * np.cos(t_range + base_phi)
    y = cos_half * np.sin(t_range + base_phi)
    z = sin_half * np.cos(t_range + eta)
    w = sin_half * np.sin(t_range + eta)

    return stereographic_project(x, y, z, w)

def create_hopf_visualization():
    """Create the Hopf fibration visualization."""
    fig = plt.figure(figsize=(18, 14), facecolor='#0a0a1a')

    # Main 3D Hopf fibration plot
    ax1 = fig.add_subplot(221, projection='3d', facecolor='#0a0a1a')
    ax1.set_title('The Hopf Fibration S³ → S²\n(Stereographic projection to ℝ³)',
                 color='white', fontsize=12, pad=10)

    t = np.linspace(0, 2*np.pi, 200)

    # Color map for different base points
    n_fibers = 30
    cmap = plt.cm.plasma

    for i in range(n_fibers):
        theta = np.pi * (i + 0.5) / n_fibers
        for j in range(8):
            phi = 2 * np.pi * j / 8
            eta = phi * 0.5

            px, py, pz = hopf_fiber(eta, t, theta, phi)

            # Clip to reasonable range for visualization
            mask = (np.abs(px) < 4) & (np.abs(py) < 4) & (np.abs(pz) < 4)

            color = cmap(i / n_fibers)
            ax1.plot(px[mask], py[mask], pz[mask],
                    color=color, alpha=0.4, linewidth=0.5)

    ax1.set_xlim(-3, 3)
    ax1.set_ylim(-3, 3)
    ax1.set_zlim(-3, 3)
    ax1.set_xlabel('x', color='white')
    ax1.set_ylabel('y', color='white')
    ax1.set_zlabel('z', color='white')
    ax1.tick_params(colors='white')
    ax1.xaxis.pane.fill = False
    ax1.yaxis.pane.fill = False
    ax1.zaxis.pane.fill = False

    # Panel 2: The four Hopf fibrations table
    ax2 = fig.add_subplot(222, facecolor='#0a0a1a')
    ax2.axis('off')
    ax2.set_title('The Four Hopf Fibrations\n(One per division algebra)',
                 color='white', fontsize=12, pad=10)

    table_data = [
        ['Algebra', 'Fibration', 'Fiber', 'Base', 'Physics'],
        ['ℝ', 'S⁰ → S¹ → S¹', 'S⁰ = {±1}', 'S¹', 'Charge conjugation'],
        ['ℂ', 'S¹ → S³ → S²', 'S¹ (circle)', 'S² (sphere)', 'Magnetic monopole'],
        ['ℍ', 'S³ → S⁷ → S⁴', 'S³ (3-sphere)', 'S⁴', 'Instanton bundles'],
        ['𝕆', 'S⁷ → S¹⁵ → S⁸', 'S⁷ (7-sphere)', 'S⁸', 'M-theory'],
    ]

    colors_row = ['#FFD93D', '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4']

    for i, row in enumerate(table_data):
        y_pos = 0.85 - i * 0.15
        for j, cell in enumerate(row):
            x_pos = 0.02 + j * 0.2
            fontsize = 9 if i > 0 else 10
            weight = 'bold' if i == 0 else 'normal'
            color = colors_row[i] if i > 0 else '#FFD93D'
            ax2.text(x_pos, y_pos, cell, fontsize=fontsize,
                    fontweight=weight, color=color, alpha=0.9,
                    transform=ax2.transAxes, va='center')

    # Adams' theorem note
    ax2.text(0.5, 0.1, "Adams' Theorem (1960): These are the ONLY\n"
            "fiber bundles of spheres over spheres.\n"
            "No other dimensions work!",
            fontsize=10, ha='center', va='center', color='#FFD93D',
            transform=ax2.transAxes, alpha=0.7,
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#1a1a2e',
                     edgecolor='#FFD93D', alpha=0.5))

    # Panel 3: Parallelizable spheres
    ax3 = fig.add_subplot(223, facecolor='#0a0a1a')
    ax3.axis('off')
    ax3.set_title('Parallelizable Spheres\n(Where global vector fields exist)',
                 color='white', fontsize=12, pad=10)

    # Draw spheres of different dimensions
    sphere_data = [
        {'name': 'S⁰', 'dim': 0, 'parallel': True, 'algebra': 'ℝ',
         'note': '2 points', 'color': '#FF6B6B'},
        {'name': 'S¹', 'dim': 1, 'parallel': True, 'algebra': 'ℂ',
         'note': 'Circle (1 tangent field)', 'color': '#4ECDC4'},
        {'name': 'S²', 'dim': 2, 'parallel': False, 'algebra': '—',
         'note': 'Hairy ball theorem!', 'color': '#888888'},
        {'name': 'S³', 'dim': 3, 'parallel': True, 'algebra': 'ℍ',
         'note': '3 tangent fields', 'color': '#45B7D1'},
        {'name': 'S⁴–S⁶', 'dim': 456, 'parallel': False, 'algebra': '—',
         'note': 'Not parallelizable', 'color': '#888888'},
        {'name': 'S⁷', 'dim': 7, 'parallel': True, 'algebra': '𝕆',
         'note': '7 tangent fields', 'color': '#96CEB4'},
        {'name': 'Sⁿ (n≥8)', 'dim': 8, 'parallel': False, 'algebra': '—',
         'note': 'Never again!', 'color': '#888888'},
    ]

    for i, s in enumerate(sphere_data):
        y = 0.88 - i * 0.12
        marker = '●' if s['parallel'] else '○'
        status = '✓ Parallelizable' if s['parallel'] else '✗ Not parallelizable'

        ax3.text(0.05, y, f"{marker} {s['name']}", fontsize=14, color=s['color'],
                fontweight='bold', transform=ax3.transAxes, va='center')
        ax3.text(0.3, y, status, fontsize=10, color=s['color'],
                transform=ax3.transAxes, va='center', alpha=0.8)
        ax3.text(0.65, y, s['note'], fontsize=9, color=s['color'],
                transform=ax3.transAxes, va='center', alpha=0.6)
        if s['parallel']:
            ax3.text(0.9, y, f"← {s['algebra']}", fontsize=12, color=s['color'],
                    fontweight='bold', transform=ax3.transAxes, va='center')

    # Panel 4: The linking number / topology
    ax4 = fig.add_subplot(224, facecolor='#0a0a1a')
    ax4.set_title('Hopf Fibers: Linked Circles\n(Every pair of fibers is linked once)',
                 color='white', fontsize=12, pad=10)

    # Draw two linked circles
    t = np.linspace(0, 2*np.pi, 100)

    # Circle 1
    r1 = 1.5
    cx1, cy1 = 0, 0
    x1 = cx1 + r1 * np.cos(t)
    y1 = cy1 + r1 * np.sin(t)
    ax4.plot(x1, y1, color='#4ECDC4', linewidth=3, alpha=0.8)

    # Circle 2 (linked through circle 1)
    r2 = 1.0
    cx2, cy2 = 1.5, 0
    # Draw as ellipse to show linking
    x2 = cx2 + r2 * np.cos(t) * 0.3
    y2 = cy2 + r2 * np.sin(t)

    # Split to show over/under crossing
    mask_front = (t > np.pi/2) & (t < 3*np.pi/2)
    mask_back = ~mask_front

    ax4.plot(x2[mask_back], y2[mask_back], color='#FF6B6B', linewidth=3, alpha=0.8)
    ax4.plot(x1, y1, color='#4ECDC4', linewidth=3, alpha=0.8)  # redraw over
    ax4.plot(x2[mask_front], y2[mask_front], color='#FF6B6B', linewidth=3, alpha=0.8)

    ax4.text(0, -2.5, 'Linking number = 1\n(Topological invariant from ℂ)',
            fontsize=10, ha='center', color='white', alpha=0.7)
    ax4.text(0, -3.2, 'π₃(S²) = ℤ — the Hopf invariant',
            fontsize=9, ha='center', color='#FFD93D', alpha=0.6)

    ax4.set_xlim(-3, 4)
    ax4.set_ylim(-4, 3)
    ax4.set_aspect('equal')
    ax4.axis('off')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Theory of Reality/figures/02_hopf_fibrations.png',
               dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
    plt.close()
    print("✅ Saved: figures/02_hopf_fibrations.png")

if __name__ == '__main__':
    create_hopf_visualization()
