#!/usr/bin/env python3
"""
Demo 1: The Tropical Mirror — Visualizing Idempotent Self-Reference

This script visualizes the fundamental difference between classical and tropical
self-reference:
- Classical: f(x) = x + x doubles the value (unstable self-reference)
- Tropical: f(x) = max(x, x) = x is the identity (stable self-reference)

We show how iterated self-reference behaves in both algebras, and visualize
the "algebraic mirror" as a projection onto fixed points.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec
import os

# --- Configuration ---
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.size'] = 12
plt.rcParams['figure.dpi'] = 150

def demo_idempotent_vs_classical():
    """Compare iterated self-reference in classical vs tropical algebra."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # --- Panel 1: Classical iterated addition f(x) = x + x ---
    ax = axes[0]
    x0_values = [0.1, 0.5, 1.0, 1.5, 2.0]
    iterations = 10
    
    for x0 in x0_values:
        trajectory = [x0]
        x = x0
        for _ in range(iterations):
            x = x + x  # Classical: x ↦ x + x (doubling)
            trajectory.append(x)
        ax.plot(range(len(trajectory)), trajectory, 'o-', label=f'x₀={x0}', markersize=4)
    
    ax.set_title('Classical: x ↦ x + x\n(Exponential Divergence)', fontsize=14, fontweight='bold')
    ax.set_xlabel('Iteration')
    ax.set_ylabel('Value')
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.text(0.05, 0.95, 'UNSTABLE\nSelf-reference diverges', transform=ax.transAxes,
            fontsize=11, verticalalignment='top', color='red', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='mistyrose', alpha=0.8))

    # --- Panel 2: Tropical iterated addition f(x) = max(x, x) ---
    ax = axes[1]
    for x0 in x0_values:
        trajectory = [x0]
        x = x0
        for _ in range(iterations):
            x = max(x, x)  # Tropical: x ↦ max(x, x) = x (identity!)
            trajectory.append(x)
        ax.plot(range(len(trajectory)), trajectory, 'o-', label=f'x₀={x0}', markersize=4)
    
    ax.set_title('Tropical: x ↦ max(x, x)\n(Immediate Stability)', fontsize=14, fontweight='bold')
    ax.set_xlabel('Iteration')
    ax.set_ylabel('Value')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 3)
    ax.text(0.05, 0.95, 'STABLE\nSelf-reference = identity', transform=ax.transAxes,
            fontsize=11, verticalalignment='top', color='green', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='honeydew', alpha=0.8))

    # --- Panel 3: The Mirror (ReLU = tropical projection) ---
    ax = axes[2]
    x = np.linspace(-3, 3, 300)
    relu = np.maximum(x, 0)
    relu_relu = np.maximum(relu, 0)
    
    ax.plot(x, x, '--', color='gray', alpha=0.5, label='Identity (y=x)')
    ax.plot(x, relu, '-', color='blue', linewidth=2.5, label='ReLU(x) = max(x,0)')
    ax.plot(x, relu_relu, ':', color='red', linewidth=2.5, label='ReLU(ReLU(x))')
    
    # Shade the fixed point region
    ax.fill_between(x[x >= 0], 0, x[x >= 0], alpha=0.15, color='green', label='Fixed points (x ≥ 0)')
    
    ax.set_title('The Algebraic Mirror (ReLU)\nReLU ∘ ReLU = ReLU', fontsize=14, fontweight='bold')
    ax.set_xlabel('Input x')
    ax.set_ylabel('Output')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-1, 3)
    ax.text(0.05, 0.95, 'IDEMPOTENT\nMirror ∘ Mirror = Mirror', transform=ax.transAxes,
            fontsize=11, verticalalignment='top', color='blue', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='lavender', alpha=0.8))

    plt.suptitle('The Algebraic Mirror: Why Tropical Self-Reference is Stable',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo1_tropical_mirror.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo1_tropical_mirror.png")


def demo_mirror_convergence():
    """Show how iterated mirror reflection converges in exactly 1 step."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # --- Panel 1: Trajectory of points under iterated ReLU ---
    ax = axes[0]
    start_points = np.array([-3, -2, -1, -0.5, 0, 0.5, 1, 2, 3])
    colors = plt.cm.coolwarm(np.linspace(0, 1, len(start_points)))
    
    for i, x0 in enumerate(start_points):
        # Trajectory: x0 → relu(x0) → relu(relu(x0)) → ...
        traj = [x0, max(x0, 0), max(max(x0, 0), 0)]
        ax.plot([0, 1, 2], traj, 'o-', color=colors[i], markersize=8,
                linewidth=2, label=f'x₀={x0:.1f}')
        # Arrow from start to fixed point
        ax.annotate('', xy=(2, traj[2]), xytext=(0, traj[0]),
                    arrowprops=dict(arrowstyle='->', color=colors[i], alpha=0.3, lw=1.5))
    
    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
    ax.set_xticks([0, 1, 2])
    ax.set_xticklabels(['Original', 'After 1\nReflection', 'After 2\nReflections'])
    ax.set_ylabel('Value')
    ax.set_title('Mirror Convergence\n(All points stabilize in 1 step)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=8, ncol=2, loc='upper left')
    ax.grid(True, alpha=0.3)
    
    # --- Panel 2: The Mirror Depth Function ---
    ax = axes[1]
    x = np.linspace(-3, 3, 1000)
    depth = np.where(np.maximum(x, 0) == x, 0, 1)
    
    ax.fill_between(x, depth, step='mid', alpha=0.4, color='orange', label='Mirror Depth')
    ax.step(x, depth, where='mid', color='darkorange', linewidth=2)
    ax.axvline(x=0, color='red', linewidth=1.5, linestyle='--', label='Mirror boundary (x=0)')
    
    ax.set_xlabel('x')
    ax.set_ylabel('Mirror Depth')
    ax.set_title('Mirror Depth: Distance to Self-Awareness\n(0 = self-aware, 1 = needs one reflection)',
                 fontsize=14, fontweight='bold')
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['0 (Self-Aware)', '1 (One Step)'])
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo1_mirror_convergence.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo1_mirror_convergence.png")


def demo_cancellativity_failure():
    """Visualize why the diagonal argument fails in tropical algebra."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # --- Panel 1: Classical addition preserves information ---
    ax = axes[0]
    a_vals = np.arange(0, 6)
    b_vals = np.arange(0, 6)
    A, B = np.meshgrid(a_vals, b_vals)
    C = A + B  # Classical addition
    
    im = ax.imshow(C, cmap='viridis', origin='lower', extent=[-0.5, 5.5, -0.5, 5.5])
    plt.colorbar(im, ax=ax, label='a + b')
    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_title('Classical: a + b\n(Injective — preserves information)', fontsize=13, fontweight='bold')
    
    # Annotate: each output is unique
    for i in range(6):
        for j in range(6):
            ax.text(i, j, str(i+j), ha='center', va='center', fontsize=7, color='white')
    
    # --- Panel 2: Tropical addition loses information ---
    ax = axes[1]
    T = np.maximum(A, B)  # Tropical addition
    
    im = ax.imshow(T, cmap='magma', origin='lower', extent=[-0.5, 5.5, -0.5, 5.5])
    plt.colorbar(im, ax=ax, label='max(a, b)')
    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_title('Tropical: max(a, b)\n(Non-injective — loses information)', fontsize=13, fontweight='bold')
    
    for i in range(6):
        for j in range(6):
            ax.text(i, j, str(max(i,j)), ha='center', va='center', fontsize=7, color='white')
    
    plt.suptitle('Why Gödel Numbering Fails Tropically:\nmax Loses Information, + Preserves It',
                 fontsize=15, fontweight='bold', y=1.05)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo1_cancellativity.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo1_cancellativity.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Demo 1: The Tropical Mirror")
    print("=" * 60)
    demo_idempotent_vs_classical()
    demo_mirror_convergence()
    demo_cancellativity_failure()
    print("\nAll Demo 1 visualizations generated successfully!")
