#!/usr/bin/env python3
"""
Hodge Conjecture — Visual Demonstration

Visualizes:
1. Hodge decomposition on a torus (the simplest non-trivial example)
2. Algebraic cycles on surfaces
3. The Hodge diamond

Run: python demo_02_hodge.py
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.patches import FancyBboxPatch
import matplotlib.gridspec as gridspec


def plot_torus_with_cycles():
    """
    Visualize algebraic cycles on a torus — the simplest example
    where Hodge classes = algebraic cycles.
    """
    fig = plt.figure(figsize=(18, 6))

    # Panel 1: The torus with its two fundamental cycles
    ax1 = fig.add_subplot(131, projection='3d')

    R, r = 3, 1  # major and minor radius
    u = np.linspace(0, 2 * np.pi, 100)
    v = np.linspace(0, 2 * np.pi, 100)
    U, V = np.meshgrid(u, v)

    X = (R + r * np.cos(V)) * np.cos(U)
    Y = (R + r * np.cos(V)) * np.sin(U)
    Z = r * np.sin(V)

    ax1.plot_surface(X, Y, Z, alpha=0.2, color='lightblue', edgecolor='none')

    # Draw the two fundamental cycles
    # Cycle A: goes around the "hole" (longitudinal)
    theta_a = np.linspace(0, 2 * np.pi, 100)
    xa = (R + r) * np.cos(theta_a)
    ya = (R + r) * np.sin(theta_a)
    za = np.zeros_like(theta_a)
    ax1.plot(xa, ya, za, 'r-', linewidth=4, label='Cycle α (H₁)')

    # Cycle B: goes around the "tube" (meridional)
    theta_b = np.linspace(0, 2 * np.pi, 100)
    xb = (R + r * np.cos(theta_b)) * np.cos(0)
    yb = (R + r * np.cos(theta_b)) * np.sin(0)
    zb = r * np.sin(theta_b)
    ax1.plot(xb, yb, zb, 'b-', linewidth=4, label='Cycle β (H₁)')

    ax1.set_title('Torus T² with Generators\nof H₁(T², ℤ)', fontsize=12, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.set_axis_off()

    # Panel 2: Hodge diamond for a torus
    ax2 = fig.add_subplot(132)
    ax2.set_xlim(-2, 2)
    ax2.set_ylim(-0.5, 4.5)
    ax2.set_aspect('equal')

    # Hodge diamond for T² = elliptic curve × elliptic curve (abelian surface)
    # h^{p,q} for T²:
    # h^{0,0} = 1
    # h^{1,0} = h^{0,1} = 1
    # h^{1,1} = 1 = h^{2,0} = h^{0,2} = 0 (for curve)
    # Actually for a complex torus of dim 1: h^{0,0}=1, h^{1,0}=h^{0,1}=1, h^{1,1}=1

    # Let's do a K3 surface for a more interesting diamond
    diamond = {
        (0, 0): ('1', 4),
        (-1, 1): ('0', 3), (1, 1): ('0', 3),
        (-2, 2): ('1', 2), (0, 2): ('20', 2), (2, 2): ('1', 2),
        (-1, 3): ('0', 1), (1, 3): ('0', 1),
        (0, 4): ('1', 0),
    }

    ax2.set_title('Hodge Diamond of K3 Surface\nh^{p,q} = dim H^{p,q}(X)', fontsize=12, fontweight='bold')

    for (x, y), (val, _) in diamond.items():
        color = 'gold' if val != '0' else 'lightgray'
        bbox = dict(boxstyle='round,pad=0.3', facecolor=color, edgecolor='black', alpha=0.8)
        ax2.text(x, y, f'h={val}', ha='center', va='center', fontsize=14,
                fontweight='bold', bbox=bbox)

    # Labels
    ax2.text(-2.5, 2, 'p+q=2\n(middle\ncohomology)', fontsize=9, ha='center',
            color='darkred', style='italic')
    ax2.text(0, -0.3, 'h^{p,q} with p on horizontal, p+q on vertical', fontsize=9,
            ha='center', color='gray')
    ax2.axis('off')

    # Panel 3: Algebraic cycles vs Hodge classes illustration
    ax3 = fig.add_subplot(133)
    ax3.set_xlim(0, 10)
    ax3.set_ylim(0, 10)
    ax3.set_aspect('equal')

    # Draw nested sets
    from matplotlib.patches import Ellipse

    # All cohomology classes
    e1 = Ellipse((5, 5), 9, 8, alpha=0.15, facecolor='blue', edgecolor='blue', linewidth=2)
    ax3.add_patch(e1)
    ax3.text(5, 9.2, 'H^{2p}(X, ℚ)', fontsize=12, ha='center', color='blue', fontweight='bold')

    # Hodge classes
    e2 = Ellipse((5, 5), 6, 5.5, alpha=0.2, facecolor='orange', edgecolor='orange', linewidth=2)
    ax3.add_patch(e2)
    ax3.text(5, 7.8, 'Hodge Classes', fontsize=11, ha='center', color='darkorange', fontweight='bold')

    # Algebraic classes
    e3 = Ellipse((5, 4.8), 4, 3.5, alpha=0.3, facecolor='green', edgecolor='green', linewidth=2)
    ax3.add_patch(e3)
    ax3.text(5, 4.8, 'Algebraic\nCycle Classes', fontsize=11, ha='center', color='darkgreen', fontweight='bold')

    # The question
    ax3.annotate('Hodge Conjecture:\nAre these equal?', xy=(7, 6), xytext=(8.5, 8),
                fontsize=10, ha='center', color='red', fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='red', lw=2))

    ax3.set_title('The Hodge Conjecture\nin Pictures', fontsize=12, fontweight='bold')
    ax3.axis('off')

    plt.tight_layout()
    plt.savefig('demo_02_hodge.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_02_hodge.png")


def plot_curves_on_surface():
    """Visualize algebraic curves on a surface as concrete algebraic cycles."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Curves in P²
    ax = axes[0]
    t = np.linspace(-3, 3, 500)

    # Line: x + y = 1
    ax.plot(t, 1 - t, 'r-', linewidth=2, label='Line: x + y = 1')

    # Conic: x² + y² = 4
    theta = np.linspace(0, 2 * np.pi, 500)
    ax.plot(2 * np.cos(theta), 2 * np.sin(theta), 'b-', linewidth=2, label='Conic: x² + y² = 4')

    # Cubic: y² = x³ - x (elliptic curve)
    x_vals = np.linspace(-1.5, 3, 1000)
    for x in x_vals:
        val = x**3 - x
        if val >= 0:
            y = np.sqrt(val)
            ax.plot(x, y, 'g.', markersize=1)
            ax.plot(x, -y, 'g.', markersize=1)
    ax.plot([], [], 'g-', linewidth=2, label='Cubic: y² = x³ - x')

    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Algebraic Curves in ℝ²\n(Codimension-1 Cycles)', fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Panel 2: Intersection numbers
    ax = axes[1]
    theta = np.linspace(0, 2 * np.pi, 500)
    ax.plot(2 * np.cos(theta), 2 * np.sin(theta), 'b-', linewidth=3, label='Circle')
    ax.plot(t, 0.5 * t + 0.5, 'r-', linewidth=3, label='Line')

    # Find intersections
    # Circle: x² + y² = 4, Line: y = 0.5x + 0.5
    # x² + (0.5x+0.5)² = 4 → 1.25x² + 0.5x - 3.75 = 0
    a, b, c = 1.25, 0.5, -3.75
    disc = b**2 - 4*a*c
    x1 = (-b + np.sqrt(disc)) / (2*a)
    x2 = (-b - np.sqrt(disc)) / (2*a)
    y1 = 0.5*x1 + 0.5
    y2 = 0.5*x2 + 0.5

    ax.plot([x1, x2], [y1, y2], 'ko', markersize=12, zorder=5)
    ax.annotate(f'Intersection\nnumber = 2', xy=(x1, y1), xytext=(x1+0.5, y1+1),
               fontsize=11, fontweight='bold',
               arrowprops=dict(arrowstyle='->', lw=2))

    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_title('Intersection Numbers\n(Cycle · Cycle = Degree)', fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Panel 3: Lefschetz (1,1) theorem — the solved case
    ax = axes[2]
    categories = ['Codim 1\n(Lefschetz)', 'Codim 2', 'Codim 3', 'General']
    status = [1.0, 0.6, 0.3, 0.0]
    colors_bar = ['#2ecc71', '#f39c12', '#e74c3c', '#95a5a6']
    bars = ax.bar(categories, status, color=colors_bar, edgecolor='black', linewidth=1.5)

    ax.set_ylabel('Progress toward Proof', fontsize=12)
    ax.set_title('Hodge Conjecture:\nStatus by Codimension', fontsize=12, fontweight='bold')
    ax.set_ylim(0, 1.2)

    labels = ['PROVED ✓', 'Partial\nResults', 'Limited\nResults', 'OPEN']
    for bar, label in zip(bars, labels):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
               label, ha='center', va='bottom', fontsize=10, fontweight='bold')

    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('demo_02b_hodge_cycles.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_02b_hodge_cycles.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Hodge Conjecture — Visual Demonstrations")
    print("=" * 60)
    print("\n1. Generating torus and Hodge diamond plots...")
    plot_torus_with_cycles()
    print("\n2. Generating algebraic cycles visualization...")
    plot_curves_on_surface()
    print("\nDone! Check the generated PNG files.")
