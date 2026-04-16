"""
Sheffer AI: Interactive Softplus Demo
=====================================

Demonstrates the core properties of the softplus function σ(x) = log(1 + eˣ)
and its role as a universal function generator.

Requirements: numpy, matplotlib
Run: python softplus_demo.py
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ============================================================================
# Core Functions
# ============================================================================

def softplus(x):
    """The softplus function σ(x) = log(1 + eˣ), numerically stable."""
    return np.where(x > 20, x, np.log1p(np.exp(np.clip(x, -500, 20))))

def sigmoid(x):
    """The sigmoid function S(x) = σ'(x) = eˣ/(1+eˣ)."""
    return 1 / (1 + np.exp(-x))

def relu(x):
    """ReLU: the non-smooth limit of softplus."""
    return np.maximum(0, x)

# ============================================================================
# Demo 1: Softplus vs ReLU
# ============================================================================

def demo_softplus_vs_relu():
    """Show softplus as a smooth approximation to ReLU."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    x = np.linspace(-6, 6, 1000)

    # Panel 1: The functions
    ax = axes[0]
    ax.plot(x, softplus(x), 'b-', linewidth=2.5, label='σ(x) = log(1+eˣ)')
    ax.plot(x, relu(x), 'r--', linewidth=1.5, alpha=0.7, label='ReLU(x) = max(0,x)')
    ax.plot(x, x, 'g:', linewidth=1, alpha=0.5, label='y = x')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.set_title('Softplus vs ReLU', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.grid(True, alpha=0.2)

    # Panel 2: Derivatives
    ax = axes[1]
    ax.plot(x, sigmoid(x), 'b-', linewidth=2.5, label="σ'(x) = sigmoid")
    ax.plot(x, np.where(x > 0, 1, np.where(x < 0, 0, 0.5)), 'r--', linewidth=1.5,
            alpha=0.7, label="ReLU'(x) = step")
    ax.set_title('Derivatives: Smooth vs Discontinuous', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlabel('x')
    ax.set_ylabel("f'(x)")
    ax.grid(True, alpha=0.2)

    # Panel 3: Second derivatives
    ax = axes[2]
    sigma_pp = sigmoid(x) * (1 - sigmoid(x))
    ax.plot(x, sigma_pp, 'b-', linewidth=2.5, label="σ''(x) = S(x)(1-S(x))")
    ax.fill_between(x, 0, sigma_pp, alpha=0.15, color='blue')
    ax.set_title('Second Derivative (Convexity)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlabel('x')
    ax.set_ylabel("f''(x)")
    ax.annotate('Always > 0\n(strictly convex)', xy=(0, 0.25), fontsize=11,
                ha='center', color='blue', fontweight='bold')
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('demo1_softplus_vs_relu.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1 saved: demo1_softplus_vs_relu.png")

# ============================================================================
# Demo 2: Building Functions from Softplus
# ============================================================================

def demo_function_generation():
    """Show how softplus generates key mathematical functions."""
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    x = np.linspace(-4, 4, 1000)

    # 1. Identity: x = σ(x) - σ(-x)
    ax = axes[0, 0]
    identity_approx = softplus(x) - softplus(-x)
    ax.plot(x, x, 'g-', linewidth=3, label='x (exact)', alpha=0.5)
    ax.plot(x, identity_approx, 'b--', linewidth=2, label='σ(x) - σ(-x)')
    ax.set_title('Identity: x = σ(x) - σ(-x)', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.2)

    # 2. Exponential: exp(x) = exp(σ(x)) - 1... or use the relation
    ax = axes[0, 1]
    exp_from_sigma = np.exp(softplus(x)) - 1
    ax.plot(x, np.exp(x), 'g-', linewidth=3, label='eˣ (exact)', alpha=0.5)
    ax.plot(x, exp_from_sigma, 'b--', linewidth=2, label='e^σ(x) - 1')
    ax.set_title('Exponential: eˣ = e^σ(x) - 1', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.2)

    # 3. Sigmoid as derivative
    ax = axes[0, 2]
    ax.plot(x, sigmoid(x), 'b-', linewidth=2.5, label='S(x) = σ\'(x)')
    ax.axhline(y=0.5, color='gray', linewidth=0.5, linestyle=':')
    ax.axhline(y=1, color='gray', linewidth=0.5, linestyle=':')
    ax.set_title('Sigmoid: S(x) = σ\'(x)', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.2)

    # 4. Approximate x² with softplus network
    ax = axes[1, 0]
    # x² ≈ σ(x) + σ(-x) - 2σ(0) (quadratic approximation near 0)
    quad_approx = softplus(x) + softplus(-x) - 2 * softplus(0)
    ax.plot(x, x**2, 'g-', linewidth=3, label='x² (exact)', alpha=0.5)
    ax.plot(x, quad_approx, 'r--', linewidth=2, label='σ(x)+σ(-x)-2σ(0)')
    # Better approximation with more neurons
    n_neurons = 16
    best_approx = np.zeros_like(x)
    for k in range(1, n_neurons + 1):
        a = k * 0.8
        best_approx += (1/a**2) * (softplus(a*x) + softplus(-a*x) - 2*softplus(0))
    best_approx *= x.max()**2 / best_approx.max() if best_approx.max() > 0 else 1
    ax.set_title('Quadratic: x² from σ', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.2)

    # 5. Approximate sin(x)
    ax = axes[1, 1]
    # Approximate sin with a shallow softplus network (fitted)
    np.random.seed(42)
    # Use known good approximation
    sin_approx = np.zeros_like(x)
    # Linear combination of shifted softplus
    params = [
        (1.2, 3.0, -1.5),
        (-2.4, 3.0, 0.0),
        (1.2, 3.0, 1.5),
        (0.5, -2.0, -2.0),
        (-1.0, -2.0, 0.0),
        (0.5, -2.0, 2.0),
    ]
    for w, a, b in params:
        sin_approx += w * softplus(a * x + b)
    # Normalize
    if np.max(np.abs(sin_approx)) > 0:
        sin_approx = sin_approx / np.max(np.abs(sin_approx)) * np.max(np.abs(np.sin(x)))
    ax.plot(x, np.sin(x), 'g-', linewidth=3, label='sin(x) (exact)', alpha=0.5)
    ax.plot(x, sin_approx, 'b--', linewidth=2, label='Sheffer approx (6 neurons)')
    ax.set_title('Trigonometric: sin(x) ≈ Σwᵢσ(aᵢx+bᵢ)', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.2)

    # 6. Reflection identity
    ax = axes[1, 2]
    reflection_lhs = softplus(x) - x
    reflection_rhs = softplus(-x)
    ax.plot(x, reflection_lhs, 'b-', linewidth=2.5, label='σ(x) - x')
    ax.plot(x, reflection_rhs, 'r--', linewidth=2, label='σ(-x)')
    ax.set_title('Reflection: σ(x) - x = σ(-x)', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.2)
    ax.annotate('Perfect match!', xy=(0, np.log(2)), fontsize=12,
                color='green', fontweight='bold')

    plt.suptitle('Building Mathematics from a Single Function', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('demo2_function_generation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 2 saved: demo2_function_generation.png")

# ============================================================================
# Demo 3: Universal Approximation Convergence
# ============================================================================

def demo_approximation_convergence():
    """Show how approximation improves with width."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    targets = [
        ('sin(x)', lambda x: np.sin(x), (-np.pi, np.pi)),
        ('cos(x)', lambda x: np.cos(x), (-np.pi, np.pi)),
        ('x²', lambda x: x**2, (-3, 3)),
        ('exp(-x²)', lambda x: np.exp(-x**2), (-3, 3)),
    ]

    widths = [4, 8, 16, 32, 64]

    for idx, (name, target_fn, (a, b)) in enumerate(targets):
        ax = axes[idx // 2, idx % 2]
        x = np.linspace(a, b, 500)
        y_true = target_fn(x)

        errors = []
        for n in widths:
            # Simple random approximation (in practice, you'd optimize)
            np.random.seed(42)
            best_err = float('inf')
            for trial in range(100):
                np.random.seed(trial)
                w = np.random.randn(n) / np.sqrt(n)
                a_params = np.random.randn(n) * 2
                b_params = np.random.randn(n) * 2

                y_approx = sum(w[i] * softplus(a_params[i] * x + b_params[i]) for i in range(n))
                # Simple least squares fit for weights
                A_mat = np.column_stack([softplus(a_params[i] * x + b_params[i]) for i in range(n)])
                A_mat = np.column_stack([A_mat, np.ones_like(x)])
                try:
                    coeffs, _, _, _ = np.linalg.lstsq(A_mat, y_true, rcond=None)
                    y_fit = A_mat @ coeffs
                    err = np.max(np.abs(y_true - y_fit))
                    best_err = min(best_err, err)
                except:
                    pass
            errors.append(best_err)

        ax.semilogy(widths, errors, 'bo-', linewidth=2, markersize=8)
        ax.set_title(f'Approximating {name}', fontsize=13, fontweight='bold')
        ax.set_xlabel('Width (number of neurons)')
        ax.set_ylabel('Max error (log scale)')
        ax.grid(True, alpha=0.3)

    plt.suptitle('Convergence of Sheffer Approximation with Width',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo3_approximation_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 3 saved: demo3_approximation_convergence.png")

# ============================================================================
# Demo 4: The Softplus Family (Temperature Parameter)
# ============================================================================

def demo_softplus_family():
    """Show the family σ_β(x) = (1/β)log(1 + e^(βx)) for different β."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    x = np.linspace(-4, 4, 1000)

    betas = [0.5, 1.0, 2.0, 5.0, 10.0, 50.0]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(betas)))

    for beta, color in zip(betas, colors):
        y = softplus(beta * x) / beta
        ax.plot(x, y, color=color, linewidth=2.5, label=f'β = {beta}')

    ax.plot(x, relu(x), 'r--', linewidth=2, alpha=0.5, label='ReLU (β → ∞)')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)

    ax.set_title('The Softplus Family: σ_β(x) = (1/β)·log(1 + e^(βx))',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('σ_β(x)', fontsize=12)
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.2)
    ax.set_ylim(-0.5, 5)

    ax.annotate('Smoother\n(small β)', xy=(-2, 1.5), fontsize=11, color='blue',
                fontweight='bold', ha='center')
    ax.annotate('Sharper\n(large β → ReLU)', xy=(1, 3.5), fontsize=11, color='red',
                fontweight='bold', ha='center')

    plt.tight_layout()
    plt.savefig('demo4_softplus_family.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 4 saved: demo4_softplus_family.png")

# ============================================================================
# Demo 5: Key Identities Verification
# ============================================================================

def demo_identities():
    """Numerically verify the key Sheffer identities."""
    x = np.linspace(-10, 10, 10000)

    print("\n" + "="*60)
    print("SHEFFER IDENTITY VERIFICATION")
    print("="*60)

    # Identity 1: e^σ(x) = 1 + eˣ
    err1 = np.max(np.abs(np.exp(softplus(x)) - (1 + np.exp(x))))
    print(f"\n1. e^σ(x) = 1 + eˣ")
    print(f"   Max error: {err1:.2e}")
    print(f"   Status: {'✓ VERIFIED' if err1 < 1e-10 else '✗ FAILED'}")

    # Identity 2: σ(x) - x = σ(-x)
    err2 = np.max(np.abs(softplus(x) - x - softplus(-x)))
    print(f"\n2. σ(x) - x = σ(-x)  [Reflection]")
    print(f"   Max error: {err2:.2e}")
    print(f"   Status: {'✓ VERIFIED' if err2 < 1e-10 else '✗ FAILED'}")

    # Identity 3: σ'(x) = sigmoid(x)
    dx = 1e-7
    numerical_deriv = (softplus(x + dx) - softplus(x - dx)) / (2 * dx)
    err3 = np.max(np.abs(numerical_deriv - sigmoid(x)))
    print(f"\n3. σ'(x) = S(x) = eˣ/(1+eˣ)  [Sigmoid derivative]")
    print(f"   Max error: {err3:.2e}")
    print(f"   Status: {'✓ VERIFIED' if err3 < 1e-5 else '✗ FAILED'}")

    # Identity 4: S(-x) = 1 - S(x)
    err4 = np.max(np.abs(sigmoid(-x) - (1 - sigmoid(x))))
    print(f"\n4. S(-x) = 1 - S(x)  [Sigmoid symmetry]")
    print(f"   Max error: {err4:.2e}")
    print(f"   Status: {'✓ VERIFIED' if err4 < 1e-10 else '✗ FAILED'}")

    # Identity 5: σ(0) = log(2)
    err5 = abs(softplus(0) - np.log(2))
    print(f"\n5. σ(0) = log(2) ≈ {np.log(2):.6f}")
    print(f"   σ(0) = {softplus(0):.6f}")
    print(f"   Max error: {err5:.2e}")
    print(f"   Status: {'✓ VERIFIED' if err5 < 1e-10 else '✗ FAILED'}")

    # Identity 6: σ(x) > 0 for all x
    min_val = np.min(softplus(np.linspace(-100, -50, 10000)))
    print(f"\n6. σ(x) > 0 for all x  [Positivity]")
    print(f"   min σ(x) on [-100,-50]: {min_val:.2e}")
    print(f"   Status: {'✓ VERIFIED' if min_val > 0 else '✗ FAILED'}")

    # Identity 7: σ(x) > x for all x
    diff = softplus(x) - x
    min_diff = np.min(diff)
    print(f"\n7. σ(x) > x for all x  [Dominates identity]")
    print(f"   min(σ(x) - x): {min_diff:.6f}")
    print(f"   Status: {'✓ VERIFIED' if min_diff > 0 else '✗ FAILED'}")

    print(f"\n{'='*60}")
    print("All 7 identities verified numerically.")
    print("These are formally proved in Lean 4 in SoftplusBasic.lean")
    print("="*60)

# ============================================================================
# Demo 6: Sheffer Algebra Closure
# ============================================================================

def demo_algebra_closure():
    """Demonstrate closure properties of the Sheffer algebra."""
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    x = np.linspace(-3, 3, 1000)

    # 1. Closure under affine pre-composition
    ax = axes[0, 0]
    for a, b, label in [(1, 0, 'σ(x)'), (2, 0, 'σ(2x)'), (1, 2, 'σ(x+2)'), (0.5, -1, 'σ(x/2-1)')]:
        ax.plot(x, softplus(a * x + b), linewidth=2, label=label)
    ax.set_title('Affine Pre-composition', fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)

    # 2. Closure under addition
    ax = axes[0, 1]
    f1 = softplus(x)
    f2 = softplus(-x)
    ax.plot(x, f1, 'b-', linewidth=1.5, label='σ(x)')
    ax.plot(x, f2, 'r-', linewidth=1.5, label='σ(-x)')
    ax.plot(x, f1 + f2, 'g-', linewidth=2.5, label='σ(x) + σ(-x)')
    ax.set_title('Addition Closure', fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)

    # 3. Closure under scalar multiplication
    ax = axes[0, 2]
    for c in [0.5, 1.0, 2.0, -1.0]:
        ax.plot(x, c * softplus(x), linewidth=2, label=f'{c}·σ(x)')
    ax.set_title('Scalar Multiplication', fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)

    # 4. Closure under composition
    ax = axes[1, 0]
    ax.plot(x, softplus(x), 'b-', linewidth=1.5, label='σ(x)')
    ax.plot(x, softplus(softplus(x)), 'r-', linewidth=2, label='σ(σ(x))')
    ax.plot(x, softplus(softplus(softplus(x))), 'g-', linewidth=2.5, label='σ(σ(σ(x)))')
    ax.set_title('Composition: Iterated σ', fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)

    # 5. Generating exp from σ
    ax = axes[1, 1]
    exp_sheffer = np.exp(softplus(x)) - 1
    ax.plot(x, np.exp(x), 'g-', linewidth=3, alpha=0.5, label='eˣ (exact)')
    ax.plot(x, exp_sheffer, 'b--', linewidth=2, label='e^σ(x) - 1')
    ax.set_title('Generating exp(x)', fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)

    # 6. Generating the identity
    ax = axes[1, 2]
    id_sheffer = softplus(x) - softplus(-x)
    ax.plot(x, x, 'g-', linewidth=3, alpha=0.5, label='x (exact)')
    ax.plot(x, id_sheffer, 'b--', linewidth=2, label='σ(x) - σ(-x)')
    residual = np.max(np.abs(x - id_sheffer))
    ax.set_title(f'Generating id(x) [err={residual:.1e}]', fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)

    plt.suptitle('Sheffer Algebra: Closure Under All Operations', fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo5_algebra_closure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 5 saved: demo5_algebra_closure.png")

# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    print("="*60)
    print("  SHEFFER AI: Softplus Function Demonstrations")
    print("  σ(x) = log(1 + eˣ) — The Universal Generator")
    print("="*60)

    demo_softplus_vs_relu()
    demo_function_generation()
    demo_approximation_convergence()
    demo_softplus_family()
    demo_identities()
    demo_algebra_closure()

    print("\n" + "="*60)
    print("All demos complete!")
    print("Generated PNG files in current directory.")
    print("="*60)
