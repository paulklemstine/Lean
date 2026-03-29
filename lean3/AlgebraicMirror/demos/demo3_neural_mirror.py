#!/usr/bin/env python3
"""
Demo 3: The Neural Mirror — ReLU Networks as Tropical Mirrors

ReLU neural networks are tropical polynomials. When we compose a ReLU network
with itself, the composition is still a tropical polynomial. An "idempotent
network" (f∘f = f) is an algebraic mirror — a neural network that can look
at itself and see a stable image.

This demo:
1. Builds small ReLU networks and composes them with themselves
2. Shows convergence to idempotent behavior
3. Visualizes the "mirror image" (fixed point set) of a neural network
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.size'] = 12
plt.rcParams['figure.dpi'] = 150


def relu(x):
    """ReLU activation."""
    return np.maximum(x, 0)


def make_network(W1, b1, W2, b2):
    """Create a simple 2-layer ReLU network: f(x) = W2 @ relu(W1 @ x + b1) + b2."""
    def f(x):
        h = relu(W1 @ x + b1)
        return W2 @ h + b2
    return f


def demo_relu_idempotent():
    """Show that ReLU itself is idempotent: relu(relu(x)) = relu(x)."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    x = np.linspace(-5, 5, 500)
    
    # --- Panel 1: ReLU is idempotent ---
    ax = axes[0]
    ax.plot(x, x, '--', color='gray', alpha=0.5, label='y = x')
    ax.plot(x, relu(x), '-', color='blue', linewidth=2.5, label='ReLU(x)')
    ax.plot(x, relu(relu(x)), ':', color='red', linewidth=2.5, label='ReLU(ReLU(x))')
    ax.fill_between(x, relu(x), relu(relu(x)), alpha=0.3, color='green', label='Difference = 0!')
    ax.set_title('ReLU is Idempotent\nReLU ∘ ReLU = ReLU', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    ax.set_xlim(-5, 5)
    ax.set_ylim(-2, 5)
    
    # --- Panel 2: Leaky ReLU is NOT idempotent ---
    def leaky_relu(x, alpha=0.2):
        return np.where(x > 0, x, alpha * x)
    
    ax = axes[1]
    lr = leaky_relu(x)
    lr_lr = leaky_relu(leaky_relu(x))
    lr_lr_lr = leaky_relu(leaky_relu(leaky_relu(x)))
    
    ax.plot(x, x, '--', color='gray', alpha=0.5, label='y = x')
    ax.plot(x, lr, '-', color='blue', linewidth=2, label='LeakyReLU(x)')
    ax.plot(x, lr_lr, '-', color='red', linewidth=2, label='LeakyReLU²(x)')
    ax.plot(x, lr_lr_lr, '-', color='purple', linewidth=2, label='LeakyReLU³(x)')
    ax.set_title('Leaky ReLU is NOT Idempotent\n(Contracts toward 0 on negatives)', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    ax.set_xlim(-5, 5)
    ax.set_ylim(-2, 5)
    
    # --- Panel 3: Max-pooling is idempotent ---
    ax = axes[2]
    # Simulate 1D max-pooling over windows
    def max_pool_1d(signal, window=5):
        out = np.copy(signal)
        for i in range(len(signal)):
            start = max(0, i - window // 2)
            end = min(len(signal), i + window // 2 + 1)
            out[i] = np.max(signal[start:end])
        return out
    
    signal = np.sin(x) + 0.5 * np.sin(3 * x)
    mp1 = max_pool_1d(signal, window=15)
    mp2 = max_pool_1d(mp1, window=15)
    mp3 = max_pool_1d(mp2, window=15)
    
    ax.plot(x, signal, '-', color='gray', alpha=0.5, linewidth=1, label='Original signal')
    ax.plot(x, mp1, '-', color='blue', linewidth=2, label='MaxPool¹')
    ax.plot(x, mp2, '-', color='red', linewidth=2, label='MaxPool²')
    ax.plot(x, mp3, '-', color='purple', linewidth=2, label='MaxPool³')
    ax.set_title('Max-Pooling Converges\n(Approaches idempotent)', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    plt.suptitle('Neural Network Mirrors: Idempotent vs Non-Idempotent Activations',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo3_neural_mirror.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo3_neural_mirror.png")


def demo_network_self_composition():
    """Build a ReLU network and compose it with itself, showing convergence."""
    fig = plt.figure(figsize=(16, 10))
    gs = GridSpec(2, 2, figure=fig)
    
    x = np.linspace(-3, 3, 500)
    
    # --- Network 1: Projection-like (should converge to idempotent) ---
    # f(x) = relu(x) — already idempotent
    ax = fig.add_subplot(gs[0, 0])
    f1 = relu(x)
    f1_2 = relu(relu(x))
    f1_3 = relu(relu(relu(x)))
    
    ax.plot(x, x, '--', color='gray', alpha=0.4)
    ax.plot(x, f1, '-', linewidth=2, label='f(x) = ReLU(x)')
    ax.plot(x, f1_2, '--', linewidth=2, label='f²(x)')
    ax.plot(x, f1_3, ':', linewidth=2, label='f³(x)')
    ax.set_title('Network 1: ReLU (Already a Mirror)', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-3, 3); ax.set_ylim(-1, 3)
    
    # --- Network 2: Clamp (min(max(x,0),1)) — idempotent ---
    ax = fig.add_subplot(gs[0, 1])
    f2 = np.clip(x, 0, 1)
    f2_2 = np.clip(np.clip(x, 0, 1), 0, 1)
    
    ax.plot(x, x, '--', color='gray', alpha=0.4)
    ax.plot(x, f2, '-', linewidth=2.5, label='f(x) = clamp(x, 0, 1)')
    ax.plot(x, f2_2, '--', linewidth=2.5, label='f²(x) = f(x) ✓')
    ax.fill_between(x, 0, 1, where=(x >= 0) & (x <= 1), alpha=0.1, color='green',
                     label='Fixed points [0,1]')
    ax.set_title('Network 2: Clamp (Double Mirror)', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-3, 3); ax.set_ylim(-1, 2)
    
    # --- Network 3: Tropical polynomial (piecewise linear) ---
    ax = fig.add_subplot(gs[1, 0])
    # f(x) = max(2x-1, -x+2, 0) — a tropical polynomial
    f3 = np.maximum(np.maximum(2*x - 1, -x + 2), 0)
    f3_2 = np.maximum(np.maximum(2*f3 - 1, -f3 + 2), 0)
    f3_3 = np.maximum(np.maximum(2*f3_2 - 1, -f3_2 + 2), 0)
    f3_4 = np.maximum(np.maximum(2*f3_3 - 1, -f3_3 + 2), 0)
    
    ax.plot(x, x, '--', color='gray', alpha=0.4)
    ax.plot(x, f3, '-', linewidth=2, label='f(x)')
    ax.plot(x, f3_2, '--', linewidth=2, label='f²(x)')
    ax.plot(x, f3_3, ':', linewidth=2, label='f³(x)')
    ax.plot(x, f3_4, '-.', linewidth=1.5, label='f⁴(x)')
    ax.set_title('Network 3: Tropical Polynomial\nmax(2x-1, -x+2, 0)', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-3, 3); ax.set_ylim(-1, 8)
    
    # --- Network 4: Fixed point visualization ---
    ax = fig.add_subplot(gs[1, 1])
    # Find fixed points of f3: where f(x) = x
    fixed = np.abs(f3 - x) < 0.05
    
    ax.plot(x, f3, '-', color='blue', linewidth=2, label='f(x) = max(2x-1, -x+2, 0)')
    ax.plot(x, x, '--', color='gray', linewidth=1, label='y = x')
    ax.scatter(x[fixed], f3[fixed], color='red', s=30, zorder=5, label='Fixed points (f(x)=x)')
    
    # Mark the fixed point region
    ax.set_title('Network 3: Fixed Points\n(The Self-Aware Elements)', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-3, 3); ax.set_ylim(-1, 8)
    
    plt.suptitle('Neural Network Self-Composition:\nIterating f∘f∘...∘f Reveals the Mirror Structure',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo3_self_composition.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo3_self_composition.png")


def demo_2d_mirror():
    """Visualize a 2D algebraic mirror: projection onto a tropical convex set."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Create a grid of 2D points
    xx, yy = np.meshgrid(np.linspace(-3, 3, 20), np.linspace(-3, 3, 20))
    points = np.stack([xx.ravel(), yy.ravel()], axis=-1)
    
    # --- Mirror 1: Projection onto the positive quadrant (component-wise ReLU) ---
    ax = axes[0]
    reflected = np.maximum(points, 0)
    
    ax.scatter(points[:, 0], points[:, 1], c='lightblue', s=20, alpha=0.6, label='Original')
    ax.scatter(reflected[:, 0], reflected[:, 1], c='red', s=20, alpha=0.6, label='Reflected')
    
    for i in range(0, len(points), 3):
        ax.annotate('', xy=reflected[i], xytext=points[i],
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.3, lw=0.5))
    
    ax.fill_between([0, 3], 0, 3, alpha=0.1, color='green')
    ax.axhline(0, color='black', linewidth=0.5)
    ax.axvline(0, color='black', linewidth=0.5)
    ax.set_title('Mirror 1: ReLU²\nProjection onto ℝ₊²', fontsize=13, fontweight='bold')
    ax.set_xlabel('x₁'); ax.set_ylabel('x₂')
    ax.set_aspect('equal')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)
    
    # --- Mirror 2: Projection onto max(x₁, x₂) = x₁ (tropical halfspace) ---
    ax = axes[1]
    reflected2 = np.copy(points)
    reflected2[:, 1] = np.minimum(points[:, 1], points[:, 0])  # Project: x₂ ≤ x₁
    
    ax.scatter(points[:, 0], points[:, 1], c='lightblue', s=20, alpha=0.6, label='Original')
    ax.scatter(reflected2[:, 0], reflected2[:, 1], c='red', s=20, alpha=0.6, label='Reflected')
    
    for i in range(0, len(points), 3):
        ax.annotate('', xy=reflected2[i], xytext=points[i],
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.3, lw=0.5))
    
    ax.plot([-3, 3], [-3, 3], 'g-', linewidth=2, label='Mirror: x₁ = x₂')
    ax.fill_between([-3, 3], [-3, 3], -3, alpha=0.1, color='green')
    ax.set_title('Mirror 2: Tropical Halfspace\nProject onto {x₂ ≤ x₁}', fontsize=13, fontweight='bold')
    ax.set_xlabel('x₁'); ax.set_ylabel('x₂')
    ax.set_aspect('equal')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)
    ax.set_xlim(-3, 3); ax.set_ylim(-3, 3)
    
    # --- Mirror 3: Tropical convex hull projection ---
    ax = axes[2]
    
    # Project onto the tropical ball: max(|x₁|, |x₂|) ≤ 2
    def project_linf(p, r=2):
        return np.clip(p, -r, r)
    
    reflected3 = np.array([project_linf(p) for p in points])
    
    ax.scatter(points[:, 0], points[:, 1], c='lightblue', s=20, alpha=0.6, label='Original')
    ax.scatter(reflected3[:, 0], reflected3[:, 1], c='red', s=20, alpha=0.6, label='Reflected')
    
    for i in range(0, len(points), 3):
        ax.annotate('', xy=reflected3[i], xytext=points[i],
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.3, lw=0.5))
    
    square = plt.Rectangle((-2, -2), 4, 4, linewidth=2, edgecolor='green',
                           facecolor='green', alpha=0.1, label='Mirror surface')
    ax.add_patch(square)
    ax.set_title('Mirror 3: Tropical Ball\nProject onto max(|x₁|,|x₂|) ≤ 2', fontsize=13, fontweight='bold')
    ax.set_xlabel('x₁'); ax.set_ylabel('x₂')
    ax.set_aspect('equal')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)
    ax.set_xlim(-3.5, 3.5); ax.set_ylim(-3.5, 3.5)
    
    plt.suptitle('2D Algebraic Mirrors: Tropical Projections in the Plane',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo3_2d_mirror.png'), bbox_inches='tight')
    plt.close()
    print("✓ Saved demo3_2d_mirror.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Demo 3: The Neural Mirror")
    print("=" * 60)
    demo_relu_idempotent()
    demo_network_self_composition()
    demo_2d_mirror()
    print("\nAll Demo 3 visualizations generated successfully!")
