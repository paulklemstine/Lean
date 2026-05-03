#!/usr/bin/env python3
"""
Pullback Stability of Universal Approximation — Interactive Demo

This script demonstrates the mathematical content of the formally verified
theorem: when φ : X → Y is a continuous map between compact spaces and A is
a dense subalgebra of C(Y, ℝ), the pullbacks {f ∘ φ : f ∈ A} approximate
exactly the fiber-constant functions on X.

Five demonstrations:
1. Injective φ: full approximation of any target function
2. Non-injective φ: approximation only of fiber-constant targets
3. ε-convergence: how approximation quality improves
4. Neural network feature maps: practical ML application
5. Fiber structure visualization for various maps
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

def poly_approx(f_values, x_grid, degree):
    """Best polynomial approximation of degree ≤ d."""
    coeffs = np.polyfit(x_grid, f_values, degree)
    return np.polyval(coeffs, x_grid)


def demo_injective():
    """Injective φ = id: full approximation of any target."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    fig.suptitle("Demo 1: Injective Feature Map — Full Approximation",
                 fontsize=14, fontweight='bold')

    x = np.linspace(0, 1, 500)
    targets = [
        ("sin(4πx)", np.sin(4 * np.pi * x)),
        ("|x − 0.5| − 0.25", np.abs(x - 0.5) - 0.25),
        ("1/(1+25(2x−1)²)", 1.0 / (1 + 25 * (2*x - 1)**2)),
    ]

    for ax, (name, target) in zip(axes, targets):
        ax.plot(x, target, 'k-', linewidth=2, label='Target g(x)')
        for deg, color in [(3, '#1f77b4'), (8, '#ff7f0e'), (20, '#2ca02c')]:
            approx = poly_approx(target, x, deg)
            err = np.max(np.abs(approx - target))
            ax.plot(x, approx, color=color, linewidth=1.2, alpha=0.8,
                    label=f'deg {deg} (‖err‖={err:.3f})')
        ax.set_title(f'g(x) = {name}', fontsize=10)
        ax.legend(fontsize=7, loc='best')
        ax.set_xlabel('x')
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig1_injective_approximation.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1 saved: fig1_injective_approximation.png")


def demo_non_injective():
    """Non-injective φ(x) = |2x-1|: fiber-constant vs general targets."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    fig.suptitle("Demo 2: Non-Injective φ(x) = |2x−1| — Fiber-Constant vs General",
                 fontsize=14, fontweight='bold')

    x = np.linspace(0, 1, 500)
    phi_x = np.abs(2 * x - 1)
    y_grid = np.linspace(0, 1, 500)

    # Feature map
    ax = axes[0]
    ax.plot(x, phi_x, 'b-', linewidth=2)
    ax.set_title('Feature map φ(x) = |2x−1|', fontsize=10)
    ax.set_xlabel('x'); ax.set_ylabel('φ(x)')
    ax.annotate('Fibers: φ(x) = φ(1−x)', xy=(0.5, 0.05), fontsize=9,
                ha='center', style='italic', color='red')
    ax.plot([0.2, 0.8], [phi_x[100], phi_x[400]], 'ro', markersize=6)
    ax.plot([0.2, 0.8], [phi_x[100], phi_x[400]], 'r--', alpha=0.5)
    ax.grid(True, alpha=0.3)

    # Fiber-constant target — CAN approximate
    ax = axes[1]
    target_fc = np.cos(2 * np.pi * phi_x)
    h_target = np.cos(2 * np.pi * y_grid)
    ax.plot(x, target_fc, 'k-', linewidth=2,
            label='g(x) = cos(2π|2x−1|)\n(fiber-constant ✓)')
    for deg, color in [(3, '#1f77b4'), (8, '#ff7f0e'), (15, '#2ca02c')]:
        h_coeffs = np.polyfit(y_grid, h_target, deg)
        pullback = np.polyval(h_coeffs, phi_x)
        err = np.max(np.abs(pullback - target_fc))
        ax.plot(x, pullback, color=color, linewidth=1.2, alpha=0.8,
                label=f'pullback deg {deg} (‖err‖={err:.3f})')
    ax.set_title('Fiber-constant target: ✓ Approx', fontsize=10)
    ax.legend(fontsize=7, loc='best')
    ax.set_xlabel('x')
    ax.grid(True, alpha=0.3)

    # Non-fiber-constant target — CANNOT approximate
    ax = axes[2]
    target_nfc = x
    ax.plot(x, target_nfc, 'k-', linewidth=2,
            label='g(x) = x\n(NOT fiber-constant ✗)')
    for deg, color in [(3, '#1f77b4'), (10, '#ff7f0e'), (30, '#2ca02c')]:
        h_coeffs = np.polyfit(y_grid, y_grid, deg)
        pullback = np.polyval(h_coeffs, phi_x)
        err = np.max(np.abs(pullback - target_nfc))
        ax.plot(x, pullback, color=color, linewidth=1.2, alpha=0.8,
                label=f'best pullback deg {deg}\n(‖err‖={err:.3f})')
    ax.set_title('Non-fiber-constant target: ✗ Barrier', fontsize=10)
    ax.legend(fontsize=7, loc='best')
    ax.set_xlabel('x')
    ax.grid(True, alpha=0.3)
    ax.annotate('Irreducible error:\ng(x) ≠ g(1−x)', xy=(0.25, 0.25), fontsize=8,
                ha='center', color='red', style='italic',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig2_non_injective.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 2 saved: fig2_non_injective.png")


def demo_epsilon_convergence():
    """ε-convergence: error rate for fiber-constant vs non-fiber-constant targets."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle("Demo 3: Convergence of Pullback Approximation Error",
                 fontsize=14, fontweight='bold')

    x = np.linspace(0, 1, 1000)
    degrees = list(range(1, 40))

    # Injective case
    ax = axes[0]
    target = np.sin(6 * np.pi * x) * np.exp(-2 * x)
    errors = [np.max(np.abs(poly_approx(target, x, d) - target)) for d in degrees]
    ax.semilogy(degrees, errors, 'b.-', linewidth=1.5, markersize=4)
    ax.set_xlabel('Polynomial degree')
    ax.set_ylabel('Sup-norm error ‖f∘φ − g‖')
    ax.set_title('Injective φ = id: error → 0', fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0.01, color='r', linestyle='--', alpha=0.5, label='ε = 0.01')
    ax.legend(fontsize=9)

    # Non-injective case
    ax = axes[1]
    phi_x = np.abs(2 * x - 1)
    y_grid = np.linspace(0, 1, 1000)

    target_fc = np.cos(4 * np.pi * phi_x) * np.exp(-phi_x)
    h_target_fc = np.cos(4 * np.pi * y_grid) * np.exp(-y_grid)
    errors_fc = []
    errors_nfc = []
    for d in degrees:
        h_coeffs = np.polyfit(y_grid, h_target_fc, d)
        pullback = np.polyval(h_coeffs, phi_x)
        errors_fc.append(np.max(np.abs(pullback - target_fc)))

        h_coeffs2 = np.polyfit(y_grid, y_grid, d)
        pullback2 = np.polyval(h_coeffs2, phi_x)
        errors_nfc.append(np.max(np.abs(pullback2 - x)))

    ax.semilogy(degrees, errors_fc, 'b.-', linewidth=1.5, markersize=4,
                label='Fiber-const target (→ 0)')
    ax.semilogy(degrees, errors_nfc, 'r.-', linewidth=1.5, markersize=4,
                label='Non-fiber-const target (→ barrier)')
    ax.axhline(y=0.25, color='r', linestyle='--', alpha=0.5, label='Barrier = 0.25')
    ax.set_xlabel('Polynomial degree')
    ax.set_ylabel('Sup-norm error')
    ax.set_title('Non-injective φ = |2x−1|', fontsize=11)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig3_convergence.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 3 saved: fig3_convergence.png")


def demo_neural_feature_map():
    """Neural network feature map φ : R² → R² — what can be learned?"""
    fig = plt.figure(figsize=(14, 5))
    gs = GridSpec(1, 3, figure=fig)
    fig.suptitle("Demo 4: Neural Feature Map — What Can Be Learned?",
                 fontsize=14, fontweight='bold')

    np.random.seed(42)
    n = 400
    x1 = np.random.uniform(0, 1, n)
    x2 = np.random.uniform(0, 1, n)
    phi1 = x1 + x2
    phi2 = x1 * x2

    ax1 = fig.add_subplot(gs[0])
    target_fc = np.sin(np.pi * (x1 + x2)) * np.cos(np.pi * x1 * x2)
    sc1 = ax1.scatter(x1, x2, c=target_fc, cmap='coolwarm', s=10, alpha=0.8)
    ax1.set_title('g = sin(π(x₁+x₂))cos(πx₁x₂)\n(fiber-constant ✓)', fontsize=9)
    ax1.set_xlabel('x₁'); ax1.set_ylabel('x₂')
    plt.colorbar(sc1, ax=ax1)

    ax2 = fig.add_subplot(gs[1])
    sc2 = ax2.scatter(phi1, phi2, c=target_fc, cmap='coolwarm', s=10, alpha=0.8)
    ax2.set_title('Feature space φ = (x₁+x₂, x₁x₂)\nColored by g', fontsize=9)
    ax2.set_xlabel('φ₁'); ax2.set_ylabel('φ₂')
    plt.colorbar(sc2, ax=ax2)

    ax3 = fig.add_subplot(gs[2])
    target_nfc = x1 - x2
    sc3 = ax3.scatter(phi1, phi2, c=target_nfc, cmap='coolwarm', s=10, alpha=0.8)
    ax3.set_title('g = x₁ − x₂\n(NOT fiber-constant ✗)', fontsize=9)
    ax3.set_xlabel('φ₁'); ax3.set_ylabel('φ₂')
    plt.colorbar(sc3, ax=ax3)
    ax3.annotate('Same feature, different colors\n→ cannot be learned!',
                 xy=(1.0, 0.2), fontsize=8, color='red', ha='center',
                 bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig4_neural_features.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 4 saved: fig4_neural_features.png")


def demo_fiber_structure():
    """Fiber structure visualization for various feature maps."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    fig.suptitle("Demo 5: Fiber Structure of Feature Maps",
                 fontsize=14, fontweight='bold')

    x = np.linspace(0, 1, 500)
    maps = [
        ("φ(x) = x\n(injective)", lambda t: t, True),
        ("φ(x) = x²\n(injective on [0,1])", lambda t: t**2, True),
        ("φ(x) = |2x−1|\n(folding)", lambda t: np.abs(2*t - 1), False),
        ("φ(x) = sin(2πx)\n(periodic-like)", lambda t: np.sin(2*np.pi*t), False),
        ("φ(x) = 4x(1−x)\n(logistic)", lambda t: 4*t*(1-t), False),
        ("φ(x) = ½\n(constant)", lambda t: 0.5*np.ones_like(t), False),
    ]

    for ax, (name, phi_func, is_inj) in zip(axes.flat, maps):
        ax.plot(x, phi_func(x), 'b-', linewidth=2)
        ax.set_title(name, fontsize=10)
        ax.set_xlabel('x'); ax.set_ylabel('φ(x)')
        ax.grid(True, alpha=0.3)
        label = ('FiberConst = C(X,ℝ)\n(all functions)' if is_inj
                 else 'FiberConst ⊊ C(X,ℝ)\n(strict subalgebra)')
        color = 'green' if is_inj else 'red'
        bg = 'lightgreen' if is_inj else 'lightyellow'
        ax.text(0.5, 0.05, label, transform=ax.transAxes, ha='center',
                fontsize=8, color=color, fontweight='bold',
                bbox=dict(boxstyle='round', facecolor=bg, alpha=0.3))

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig5_fiber_structure.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 5 saved: fig5_fiber_structure.png")


if __name__ == "__main__":
    print("=" * 60)
    print("Pullback Stability of Universal Approximation")
    print("Interactive Demonstration")
    print("=" * 60)
    print()

    demo_injective()
    demo_non_injective()
    demo_epsilon_convergence()
    demo_neural_feature_map()
    demo_fiber_structure()

    print()
    print("All demos completed. Figures saved in demos/ directory.")
    print()
    print("Key insight: The theorem precisely characterizes WHAT can be")
    print("approximated through a feature map φ:")
    print("  • If φ is injective: EVERYTHING (FiberConst = C(X,ℝ))")
    print("  • If φ is not injective: only fiber-constant functions")
    print("  • The approximation error for fiber-constant targets → 0")
    print("  • Non-fiber-constant targets have an irreducible barrier")
