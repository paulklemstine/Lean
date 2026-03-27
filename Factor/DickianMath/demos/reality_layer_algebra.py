#!/usr/bin/env python3
"""
Reality Layer Algebra (RLA) — Interactive Demo
===============================================
Inspired by Philip K. Dick's VALIS, Time Out of Joint, and The Man in the High Castle.

This demo simulates nested reality layers with perception operators and demonstrates:
1. Convergence to the Black Iron Prison (contractive perception)
2. Escape via the "Pink Laser" (non-contractive perturbation)
3. Reality Bleed-Through between alternate histories
4. Knaster-Tarski fixed-point visualization

Run: python reality_layer_algebra.py
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.gridspec as gridspec


def perception_operator(reality_state, alpha=0.85, noise=0.02):
    """
    Contractive perception operator: Φ(ℓ) = α·ℓ + noise
    Models information loss at each perception layer.
    α < 1 makes it contractive → converges to Black Iron Prison.
    """
    return alpha * reality_state + np.random.normal(0, noise, size=reality_state.shape)


def pink_laser(reality_state, injection_strength=0.3, target_dims=None):
    """
    Non-contractive perturbation (VALIS pink laser).
    Injects information into specific dimensions of reality.
    """
    boost = np.zeros_like(reality_state)
    if target_dims is None:
        target_dims = [0, 1]
    for d in target_dims:
        if d < len(boost):
            boost[d] = injection_strength
    return reality_state + boost


def simulate_reality_descent(initial_state, n_steps=50, alpha=0.85,
                              pink_laser_at=None, laser_strength=0.3):
    """Simulate perception iteration with optional pink laser intervention."""
    trajectory = [initial_state.copy()]
    state = initial_state.copy()

    for t in range(n_steps):
        if pink_laser_at and t == pink_laser_at:
            state = pink_laser(state, laser_strength)
        state = perception_operator(state, alpha, noise=0.01)
        state = np.clip(state, 0, 1)
        trajectory.append(state.copy())

    return np.array(trajectory)


def find_fixed_points(alpha, n_dims=2, n_samples=1000):
    """
    Numerically find fixed points of the perception operator.
    For Φ(x) = αx (noiseless), the unique fixed point is 0 (Black Iron Prison).
    """
    fixed_points = []
    for _ in range(n_samples):
        x = np.random.rand(n_dims)
        for _ in range(500):
            x_new = alpha * x
            if np.linalg.norm(x_new - x) < 1e-10:
                break
            x = x_new
        # Check if it's a fixed point
        if np.linalg.norm(alpha * x - x) < 1e-8:
            # Check if we already have this one
            is_new = True
            for fp in fixed_points:
                if np.linalg.norm(fp - x) < 1e-6:
                    is_new = False
                    break
            if is_new:
                fixed_points.append(x.copy())
    return fixed_points


def demo_black_iron_prison():
    """Demo 1: Convergence to the Black Iron Prison."""
    print("=" * 60)
    print("DEMO 1: THE BLACK IRON PRISON")
    print("Contractive perception → inevitable collapse to minimal reality")
    print("=" * 60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Multiple starting points, all converge to origin
    colors = plt.cm.plasma(np.linspace(0.2, 0.9, 8))
    alphas_to_test = [0.95, 0.85, 0.7]
    titles = ['Weak Contraction (α=0.95)', 'Medium Contraction (α=0.85)',
              'Strong Contraction (α=0.70)']

    for ax_idx, (alpha, title) in enumerate(zip(alphas_to_test, titles)):
        ax = axes[ax_idx]
        for i in range(8):
            init = np.random.rand(2) * 0.8 + 0.1
            traj = simulate_reality_descent(init, n_steps=40, alpha=alpha)
            ax.plot(traj[:, 0], traj[:, 1], '-', color=colors[i], alpha=0.7,
                    linewidth=1.5)
            ax.plot(traj[0, 0], traj[0, 1], 'o', color=colors[i], markersize=8)
            ax.plot(traj[-1, 0], traj[-1, 1], 's', color='black', markersize=6)

        # Mark the Black Iron Prison
        ax.plot(0, 0, '*', color='red', markersize=20, zorder=5,
                label='Black Iron Prison')
        ax.set_xlim(-0.05, 1.0)
        ax.set_ylim(-0.05, 1.0)
        ax.set_xlabel('Reality Dimension 1 (Information Content)')
        ax.set_ylabel('Reality Dimension 2 (Temporal Coherence)')
        ax.set_title(title)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    plt.suptitle('The Black Iron Prison: All Realities Collapse Under Contractive Perception',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo1_black_iron_prison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo1_black_iron_prison.png")
    print(f"  All {8} starting realities converge to the Black Iron Prison at origin.")
    print(f"  This is the Knaster-Tarski least fixed point of the contractive operator.")
    print()


def demo_pink_laser_escape():
    """Demo 2: Escape from the Black Iron Prison via VALIS pink laser."""
    print("=" * 60)
    print("DEMO 2: THE PINK LASER (VALIS)")
    print("Non-contractive perturbation enables escape from the Prison")
    print("=" * 60)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Without pink laser
    ax = axes[0]
    init = np.array([0.9, 0.8])
    traj_no_laser = simulate_reality_descent(init, n_steps=60, alpha=0.88)
    ax.plot(traj_no_laser[:, 0], traj_no_laser[:, 1], 'b-', linewidth=2,
            label='Without VALIS')
    ax.plot(init[0], init[1], 'go', markersize=12, label='Start')
    ax.plot(0, 0, 'r*', markersize=20, label='Black Iron Prison')
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.set_title('Without Pink Laser: Inevitable Collapse', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # With pink laser at step 25
    ax = axes[1]
    traj_laser = simulate_reality_descent(init, n_steps=60, alpha=0.88,
                                           pink_laser_at=25, laser_strength=0.5)
    ax.plot(traj_laser[:25, 0], traj_laser[:25, 1], 'b-', linewidth=2,
            label='Before VALIS')
    ax.plot(traj_laser[25:, 0], traj_laser[25:, 1], 'm-', linewidth=2,
            label='After VALIS')
    ax.plot(traj_laser[25, 0], traj_laser[25, 1], 'm*', markersize=20,
            label='Pink Laser Strike!', zorder=5)
    ax.plot(init[0], init[1], 'go', markersize=12, label='Start')
    ax.plot(0, 0, 'r*', markersize=20, label='Black Iron Prison')
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.set_title('With Pink Laser: Temporary Escape', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('VALIS: The Pink Laser as Non-Contractive Perturbation',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo2_pink_laser.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo2_pink_laser.png")
    print("  The pink laser injects information, temporarily lifting reality above the attractor.")
    print("  But without sustained injection, contraction resumes. Ubik must be constant!")
    print()


def demo_reality_bleedthrough():
    """Demo 3: Reality Bleed-Through between alternate histories."""
    print("=" * 60)
    print("DEMO 3: REALITY BLEED-THROUGH")
    print("Two alternate realities with coupled perception operators")
    print("=" * 60)

    n_steps = 80
    coupling = 0.15  # Bleed-through coupling strength

    # Reality 1: "Our" timeline
    r1 = np.array([0.9, 0.1])  # High info dim 1, low dim 2
    # Reality 2: "Axis won" timeline
    r2 = np.array([0.1, 0.9])  # Low dim 1, high dim 2

    traj1, traj2 = [r1.copy()], [r2.copy()]
    alpha = 0.92

    for t in range(n_steps):
        # Coupled perception: each reality "bleeds" into the other
        bleed_1to2 = coupling * (r1 - r2)
        bleed_2to1 = coupling * (r2 - r1)

        r1_new = alpha * r1 + bleed_2to1 + np.random.normal(0, 0.005, 2)
        r2_new = alpha * r2 + bleed_1to2 + np.random.normal(0, 0.005, 2)

        r1, r2 = np.clip(r1_new, 0, 1), np.clip(r2_new, 0, 1)
        traj1.append(r1.copy())
        traj2.append(r2.copy())

    traj1, traj2 = np.array(traj1), np.array(traj2)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Phase space
    ax = axes[0]
    ax.plot(traj1[:, 0], traj1[:, 1], 'b-', linewidth=2, alpha=0.8,
            label='Reality 1 ("Our" timeline)')
    ax.plot(traj2[:, 0], traj2[:, 1], 'r-', linewidth=2, alpha=0.8,
            label='Reality 2 ("Axis won")')
    ax.plot(traj1[0, 0], traj1[0, 1], 'bo', markersize=10)
    ax.plot(traj2[0, 0], traj2[0, 1], 'ro', markersize=10)
    # Convergence point
    midpoint = (traj1[-1] + traj2[-1]) / 2
    ax.plot(midpoint[0], midpoint[1], 'g*', markersize=20,
            label='Bleed-through convergence')
    ax.set_xlabel('Dimension 1')
    ax.set_ylabel('Dimension 2')
    ax.set_title('Phase Space: Two Realities Converging')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Distance over time
    ax = axes[1]
    distances = np.linalg.norm(traj1 - traj2, axis=1)
    ax.plot(distances, 'purple', linewidth=2)
    ax.axhline(y=0, color='green', linestyle='--', alpha=0.5,
               label='Complete bleed-through')
    ax.set_xlabel('Time Step')
    ax.set_ylabel('Distance Between Realities')
    ax.set_title('Reality Bleed-Through: Converging Timelines')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('The Man in the High Castle: Coupled Reality Bleed-Through',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo3_reality_bleedthrough.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo3_reality_bleedthrough.png")
    print(f"  Initial reality distance: {distances[0]:.3f}")
    print(f"  Final reality distance: {distances[-1]:.3f}")
    print(f"  Coupling creates convergence: both realities become 'true and false'")
    print()


def demo_fixed_point_landscape():
    """Demo 4: Fixed-point landscape of Reality Layer Algebras."""
    print("=" * 60)
    print("DEMO 4: FIXED-POINT LANDSCAPE")
    print("Knaster-Tarski theorem: the lattice of stable realities")
    print("=" * 60)

    # Non-linear perception operator with multiple fixed points
    def nonlinear_phi(x, a=2.5):
        """x - a*x*(1-x): has fixed points at 0, 1-1/a, and potentially others."""
        return np.clip(x + a * x * (1 - x) * (0.5 - x), 0, 1)

    x_range = np.linspace(0, 1, 1000)
    y_range = np.array([nonlinear_phi(x) for x in x_range])

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Cobweb diagram
    ax = axes[0]
    ax.plot(x_range, y_range, 'b-', linewidth=2, label='Φ(x)')
    ax.plot(x_range, x_range, 'k--', linewidth=1, label='y = x (fixed points)')

    # Find fixed points
    fixed_pts = []
    for i in range(len(x_range) - 1):
        if (y_range[i] - x_range[i]) * (y_range[i + 1] - x_range[i + 1]) < 0:
            fixed_pts.append((x_range[i] + x_range[i + 1]) / 2)

    for fp in fixed_pts:
        ax.plot(fp, fp, 'ro', markersize=12, zorder=5)
        label = 'Black Iron Prison' if fp < 0.1 else ('Ground Truth' if fp > 0.9 else 'Metastable Reality')
        ax.annotate(label, (fp, fp), textcoords="offset points",
                    xytext=(15, 10), fontsize=9, color='red',
                    arrowprops=dict(arrowstyle='->', color='red'))

    # Cobweb from a starting point
    x = 0.15
    cobweb_x, cobweb_y = [x], [0]
    for _ in range(30):
        y = nonlinear_phi(x)
        cobweb_x.extend([x, y])
        cobweb_y.extend([y, y])
        x = y
    ax.plot(cobweb_x, cobweb_y, 'g-', alpha=0.5, linewidth=1)

    ax.set_xlabel('Current Reality State')
    ax.set_ylabel('Perceived Reality State Φ(x)')
    ax.set_title('Cobweb Diagram: Iterating Perception')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Basin of attraction
    ax = axes[1]
    x0_range = np.linspace(0.001, 0.999, 500)
    final_states = []
    for x0 in x0_range:
        x = x0
        for _ in range(200):
            x = nonlinear_phi(x)
        final_states.append(x)

    ax.scatter(x0_range, final_states, c=final_states, cmap='RdYlGn',
               s=3, alpha=0.8)
    ax.set_xlabel('Initial Reality State')
    ax.set_ylabel('Final (Stable) Reality State')
    ax.set_title('Basins of Attraction: Which Prison Do You End Up In?')
    ax.grid(True, alpha=0.3)
    for fp in fixed_pts:
        ax.axhline(y=fp, color='red', linestyle=':', alpha=0.5)

    plt.suptitle('Reality Layer Algebra: Fixed Points and Basins of Attraction',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo4_fixed_points.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo4_fixed_points.png")
    print(f"  Found {len(fixed_pts)} fixed points (stable realities)")
    for i, fp in enumerate(fixed_pts):
        print(f"    Fixed point {i + 1}: x = {fp:.4f}")
    print()


if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  REALITY LAYER ALGEBRA — DICKIAN MATHEMATICS DEMO          ║")
    print("║  Based on VALIS, Time Out of Joint, Man in the High Castle ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_black_iron_prison()
    demo_pink_laser_escape()
    demo_reality_bleedthrough()
    demo_fixed_point_landscape()

    print("=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
