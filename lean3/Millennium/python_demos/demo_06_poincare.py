#!/usr/bin/env python3
"""
Poincaré Conjecture (SOLVED) — Visual Demonstration

Visualizes:
1. Simply connected spaces vs non-simply connected
2. Ricci flow — the key tool in Perelman's proof
3. How Ricci flow "rounds out" a manifold

Run: python demo_06_poincare.py
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm


def plot_simply_connected():
    """Illustrate simply connected vs non-simply connected spaces."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Simply connected — sphere (every loop contracts)
    ax = axes[0]
    u = np.linspace(0, 2 * np.pi, 50)
    v = np.linspace(0, np.pi, 50)
    U, V = np.meshgrid(u, v)

    X = np.sin(V) * np.cos(U)
    Y = np.sin(V) * np.sin(U)
    Z = np.cos(V)

    ax = fig.add_subplot(131, projection='3d')
    ax.plot_surface(X, Y, Z, alpha=0.3, color='skyblue', edgecolor='none')

    # Draw a loop that can contract
    t = np.linspace(0, 2 * np.pi, 100)
    for r in [0.8, 0.5, 0.2]:
        x_loop = r * np.cos(t)
        y_loop = r * np.sin(t)
        z_loop = np.sqrt(np.maximum(1 - r**2, 0)) * np.ones_like(t)
        ax.plot(x_loop, y_loop, z_loop, 'r-', linewidth=2, alpha=0.7)

    ax.set_title('S² — Simply Connected ✓\nEvery loop contracts to a point',
                fontsize=11, fontweight='bold')
    ax.set_axis_off()

    # Panel 2: Not simply connected — torus
    ax2 = fig.add_subplot(132, projection='3d')
    R, r = 2, 0.7
    U2, V2 = np.meshgrid(u, v * 2)

    X2 = (R + r * np.cos(V2)) * np.cos(U2)
    Y2 = (R + r * np.cos(V2)) * np.sin(U2)
    Z2 = r * np.sin(V2)

    ax2.plot_surface(X2, Y2, Z2, alpha=0.3, color='lightcoral', edgecolor='none')

    # Draw a non-contractible loop
    t = np.linspace(0, 2 * np.pi, 100)
    x_loop = (R + r) * np.cos(t)
    y_loop = (R + r) * np.sin(t)
    z_loop = np.zeros_like(t)
    ax2.plot(x_loop, y_loop, z_loop, 'b-', linewidth=3)

    ax2.set_title('T² — NOT Simply Connected ✗\nBlue loop cannot contract',
                fontsize=11, fontweight='bold')
    ax2.set_axis_off()

    # Panel 3: The Poincaré Conjecture statement
    ax3 = fig.add_subplot(133)
    ax3.set_xlim(0, 10)
    ax3.set_ylim(0, 10)

    text = """POINCARÉ CONJECTURE
(Proved by Perelman, 2003)

If a closed 3-manifold M satisfies:
  • M is compact (bounded)
  • M has no boundary
  • π₁(M) = 0 (simply connected)

Then M ≅ S³

"Every loop contracts
 ⟹ it's a 3-sphere"

Tool: Hamilton's Ricci flow
  ∂g/∂t = -2 Ric(g)

The metric flows to constant
curvature — a round sphere!"""

    ax3.text(5, 5, text, fontsize=12, ha='center', va='center',
            fontfamily='monospace',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                     edgecolor='black', linewidth=2))
    ax3.axis('off')

    plt.tight_layout()
    plt.savefig('demo_06_poincare.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_06_poincare.png")


def plot_ricci_flow():
    """
    Visualize Ricci flow — how it deforms a surface toward constant curvature.
    We show a 2D analog: curve shortening flow.
    """
    fig, axes = plt.subplots(2, 4, figsize=(18, 9))

    # Simulate "Ricci flow" on a 2D curve (curve shortening flow as analog)
    N = 200
    theta = np.linspace(0, 2 * np.pi, N, endpoint=False)

    # Start with a bumpy shape
    r = 1.0 + 0.3 * np.cos(3 * theta) + 0.2 * np.sin(5 * theta) + 0.15 * np.cos(7 * theta)
    x = r * np.cos(theta)
    y = r * np.sin(theta)

    dt = 0.0005
    snapshots = [0, 50, 150, 500]
    snap_idx = 0

    for step in range(501):
        if step in snapshots:
            row = snap_idx // 4
            col = snap_idx % 4
            ax = axes[row][col]

            ax.fill(x, y, alpha=0.3, color='skyblue')
            ax.plot(np.append(x, x[0]), np.append(y, y[0]), 'b-', linewidth=2)

            # Draw the circle with same area for reference
            area = 0.5 * abs(np.sum(x * np.roll(y, -1) - np.roll(x, -1) * y))
            r_circle = np.sqrt(area / np.pi)
            circle_x = r_circle * np.cos(theta)
            circle_y = r_circle * np.sin(theta)
            ax.plot(np.append(circle_x, circle_x[0]),
                   np.append(circle_y, circle_y[0]), 'r--', linewidth=1.5, alpha=0.5)

            ax.set_xlim(-1.8, 1.8)
            ax.set_ylim(-1.8, 1.8)
            ax.set_aspect('equal')
            ax.set_title(f'Step {step}', fontsize=12, fontweight='bold')
            ax.grid(True, alpha=0.2)
            snap_idx += 1

        # Evolve by curvature (curve shortening flow)
        dx = np.roll(x, -1) - np.roll(x, 1)
        dy = np.roll(y, -1) - np.roll(y, 1)
        d2x = np.roll(x, -1) - 2 * x + np.roll(x, 1)
        d2y = np.roll(y, -1) - 2 * y + np.roll(y, 1)

        ds = np.sqrt(dx**2 + dy**2)
        kappa_x = d2x / (ds + 1e-10)
        kappa_y = d2y / (ds + 1e-10)

        x += dt * kappa_x
        y += dt * kappa_y

    # Fill remaining panels with 3D surface evolution
    from mpl_toolkits.mplot3d import Axes3D

    u = np.linspace(0, 2 * np.pi, 40)
    v = np.linspace(0, np.pi, 40)
    U, V = np.meshgrid(u, v)

    perturbations = [0.3, 0.15, 0.05, 0.0]  # decreasing perturbation = "flowing"
    titles = ['Initial Bumpy\n3-Manifold', 'After Ricci Flow\n(t=1)',
              'Nearly Round\n(t=5)', 'Perfect S³\n(t→∞) ✓']

    for i, (pert, title) in enumerate(zip(perturbations, titles)):
        ax = fig.add_subplot(2, 4, 5 + i, projection='3d')
        R = 1 + pert * (np.cos(3 * U) * np.sin(2 * V) + np.sin(5 * U) * np.cos(3 * V))

        X = R * np.sin(V) * np.cos(U)
        Y = R * np.sin(V) * np.sin(U)
        Z = R * np.cos(V)

        # Color by curvature (deviation from sphere)
        curvature = np.abs(R - 1)
        ax.plot_surface(X, Y, Z, facecolors=cm.RdYlGn_r(curvature / max(0.01, curvature.max())),
                       alpha=0.8, edgecolor='none')
        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.set_axis_off()
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_zlim(-1.5, 1.5)

    plt.suptitle('Ricci Flow: Bumpy → Round (Perelman\'s Tool)',
                fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('demo_06b_ricci_flow.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_06b_ricci_flow.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Poincaré Conjecture (SOLVED) — Visual Demonstrations")
    print("=" * 60)
    print("\n1. Generating simply connected space illustrations...")
    plot_simply_connected()
    print("\n2. Generating Ricci flow visualization...")
    plot_ricci_flow()
    print("\nDone! Check the generated PNG files.")
