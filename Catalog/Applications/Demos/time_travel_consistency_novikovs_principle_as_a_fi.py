#!/usr/bin/env python3
"""
Demo: Novikov's Self-Consistency Principle via Fixed-Point Theory

Demonstrates the core theorems with numerical examples.
"""

from algorithms import (
    fixed_point_iteration,
    affine_fixed_point,
    paradox_severity,
    polynomial_deriv_bound,
    polynomial_eval,
    perturbation_stability,
    compose_causal_loops,
)


def demo_affine_fixed_point():
    """Demo 1: Affine causal map f(x) = 0.5x + 3"""
    print("=" * 60)
    print("DEMO 1: Affine Causal Map")
    print("f(x) = 0.5x + 3, contraction factor K = 0.5")
    print("=" * 60)

    a, b = 0.5, 3.0

    # Closed-form solution
    x_star = affine_fixed_point(a, b)
    print(f"\nClosed-form fixed point: x* = {b}/(1-{a}) = {x_star}")
    print(f"Verification: f(x*) = {a}*{x_star} + {b} = {a*x_star + b}")

    # Iterative solution
    f = lambda x: a * x + b
    x_iter, n_iter, sev = fixed_point_iteration(f, 0.0, abs(a))
    print(f"\nIterative solution from x₀ = 0:")
    print(f"  Converged in {n_iter} iterations")
    print(f"  Fixed point: {x_iter}")
    print(f"  Final paradox severity: {sev:.2e}")

    # Show convergence
    print("\nIteration trace:")
    x = 0.0
    for i in range(10):
        sev = paradox_severity(f, x)
        print(f"  x_{i} = {x:8.4f}, severity = {sev:.6f}, K^n * sev_0 = {0.5**i * 3.0:.6f}")
        x = f(x)


def demo_polynomial_causal_map():
    """Demo 2: Polynomial causal map f(x) = 0.3x² + 0.1x + 0.2"""
    print("\n" + "=" * 60)
    print("DEMO 2: Polynomial Causal Map (Conjecture Test)")
    print("f(x) = 0.3x² + 0.1x + 0.2 on [-1, 1]")
    print("=" * 60)

    coeffs = [0.2, 0.1, 0.3]
    r = 1.0

    # Check derivative bound
    db = polynomial_deriv_bound(coeffs, r)
    print(f"\nDerivative bound: Σ i|aᵢ|r^(i-1) = {db}")
    print(f"Contraction condition: {db} < 1? {'YES ✓' if db < 1 else 'NO ✗'}")

    # Find fixed point iteratively
    f = lambda x: polynomial_eval(coeffs, x)
    x_iter, n_iter, sev = fixed_point_iteration(f, 0.0, db)
    print(f"\nIterative solution from x₀ = 0:")
    print(f"  Converged in {n_iter} iterations")
    print(f"  Fixed point: x* ≈ {x_iter:.6f}")
    print(f"  Verification: f(x*) = {f(x_iter):.6f}")
    print(f"  Final severity: {sev:.2e}")

    # Verify f maps [-1,1] to [-1,1]
    xs = [(-1 + 2 * i / 999) for i in range(1000)]
    fxs = [polynomial_eval(coeffs, x) for x in xs]
    print(f"\n  f([-1,1]) ⊆ [{min(fxs):.4f}, {max(fxs):.4f}]")
    print(f"  Maps into [-1,1]? {'YES ✓' if min(fxs) >= -1 and max(fxs) <= 1 else 'NO ✗'}")


def demo_grandfather_paradox():
    """Demo 3: The grandfather paradox as f(x) = -x"""
    print("\n" + "=" * 60)
    print("DEMO 3: Grandfather Paradox (No Fixed Point)")
    print("f(x) = -x (complete state negation)")
    print("=" * 60)

    f = lambda x: -x

    print("\nTesting for fixed points:")
    for x in [1.0, -1.0, 0.5, -0.5, 3.14]:
        sev = paradox_severity(f, x)
        print(f"  x = {x:6.2f}: f(x) = {f(x):6.2f}, severity = {sev:.2f}, fixed? {'YES' if sev == 0 else 'NO'}")

    print(f"\n  x = 0.00: f(0) = 0.00, severity = 0.00, fixed? YES (trivial)")
    print("\nConclusion: Only the trivial state x=0 is self-consistent.")
    print("The grandfather paradox has no nontrivial resolution.")
    print("This is because |K| = 1 ≥ 1 (not a contraction).")


def demo_nested_loops():
    """Demo 4: Nested time loops (composition)"""
    print("\n" + "=" * 60)
    print("DEMO 4: Nested Time Loops (Composition)")
    print("f₁(x) = 0.6x + 2, f₂(x) = 0.7x + 1")
    print("=" * 60)

    a1, b1, K1 = 0.6, 2.0, 0.6
    a2, b2, K2 = 0.7, 1.0, 0.7

    f1 = lambda x: a1 * x + b1
    f2 = lambda x: a2 * x + b2

    # Individual fixed points
    x1_star = affine_fixed_point(a1, b1)
    x2_star = affine_fixed_point(a2, b2)
    print(f"\nIndividual fixed points:")
    print(f"  f₁: x* = {x1_star:.4f} (K₁ = {K1})")
    print(f"  f₂: x* = {x2_star:.4f} (K₂ = {K2})")

    # Composed loop
    f_composed, K_composed = compose_causal_loops(f1, f2, K1, K2)
    print(f"\nComposed loop f₁ ∘ f₂:")
    print(f"  Contraction factor: K₁ × K₂ = {K_composed}")

    x_comp, n_comp, sev_comp = fixed_point_iteration(f_composed, 0.0, K_composed)
    print(f"  Fixed point: x* ≈ {x_comp:.4f}")
    print(f"  Iterations: {n_comp}")
    print(f"  Verification: f₁(f₂(x*)) = {f_composed(x_comp):.4f}")


def demo_perturbation():
    """Demo 5: Perturbation stability"""
    print("\n" + "=" * 60)
    print("DEMO 5: Perturbation Stability")
    print("How much does the self-consistent state shift when we")
    print("change the time traveler's mission?")
    print("=" * 60)

    a = 0.5

    print(f"\nSlope a = {a}, amplification factor 1/|1-a| = {1/abs(1-a):.2f}")
    print(f"\n{'b1':>8} {'b2':>8} {'|Δb|':>8} {'|Δx*|':>10} {'predicted':>10}")
    print("-" * 50)

    for b1, b2 in [(3.0, 3.1), (3.0, 4.0), (1.0, 5.0), (0.0, 0.01)]:
        shift, amp = perturbation_stability(a, b1, b2)
        x1 = affine_fixed_point(a, b1)
        x2 = affine_fixed_point(a, b2)
        actual = abs(x1 - x2)
        print(f"{b1:8.2f} {b2:8.2f} {abs(b1-b2):8.2f} {actual:10.4f} {shift:10.4f}")


def demo_convergence_rates():
    """Demo 6: Convergence rate comparison"""
    print("\n" + "=" * 60)
    print("DEMO 6: Convergence Rates for Different K")
    print("=" * 60)

    print(f"\n{'K':>6} {'Iterations to ε=1e-10':>25} {'x*':>10}")
    print("-" * 45)

    for K in [0.1, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        f = lambda x, k=K: k * x + 1.0
        x_star, n, sev = fixed_point_iteration(f, 0.0, K)
        print(f"{K:6.2f} {n:25d} {x_star:10.4f}")


if __name__ == "__main__":
    demo_affine_fixed_point()
    demo_polynomial_causal_map()
    demo_grandfather_paradox()
    demo_nested_loops()
    demo_perturbation()
    demo_convergence_rates()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Fixed-point iteration convergence for causal loops."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_convergence():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Plot 1: Cobweb diagram for affine map
    ax = axes[0, 0]
    a, b = 0.5, 3.0
    f = lambda x: a * x + b
    x = np.linspace(-1, 12, 200)
    ax.plot(x, f(x), 'b-', linewidth=2, label=f'f(x) = {a}x + {b}')
    ax.plot(x, x, 'k--', linewidth=1, label='y = x')

    # Cobweb
    cx, cy = 0.0, 0.0
    for _ in range(15):
        new_y = f(cx)
        ax.plot([cx, cx], [cy, new_y], 'r-', alpha=0.6, linewidth=0.8)
        ax.plot([cx, new_y], [new_y, new_y], 'r-', alpha=0.6, linewidth=0.8)
        cx, cy = new_y, new_y

    ax.plot(b/(1-a), b/(1-a), 'go', markersize=10, zorder=5, label=f'x* = {b/(1-a)}')
    ax.set_title('Cobweb: f(x) = 0.5x + 3', fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend(fontsize=9)
    ax.set_xlim(-1, 12)
    ax.set_ylim(-1, 12)
    ax.grid(True, alpha=0.3)

    # Plot 2: Paradox severity decay
    ax = axes[0, 1]
    for K in [0.3, 0.5, 0.7, 0.9]:
        f_k = lambda x, k=K: k * x + 1.0
        x_val = 0.0
        severities = []
        for i in range(30):
            sev = abs(x_val - f_k(x_val))
            severities.append(sev)
            x_val = f_k(x_val)
        ax.semilogy(severities, label=f'K = {K}', linewidth=2)

    ax.set_title('Paradox Severity Decay', fontsize=12)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('|x_n - f(x_n)|')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 3: Polynomial causal map
    ax = axes[1, 0]
    coeffs = [0.2, 0.1, 0.3]
    poly_f = lambda x: coeffs[0] + coeffs[1]*x + coeffs[2]*x**2
    x = np.linspace(-1.5, 1.5, 200)
    ax.plot(x, poly_f(x), 'b-', linewidth=2, label='f(x) = 0.3x² + 0.1x + 0.2')
    ax.plot(x, x, 'k--', linewidth=1, label='y = x')
    ax.fill_between([-1, 1], -1.5, 1.5, alpha=0.1, color='green', label='[-1, 1] domain')

    # Find fixed point iteratively
    x_val = 0.0
    for _ in range(100):
        x_val = poly_f(x_val)
    ax.plot(x_val, x_val, 'ro', markersize=10, zorder=5, label=f'x* ≈ {x_val:.4f}')

    ax.set_title('Polynomial Causal Map', fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend(fontsize=9)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 1.5)
    ax.grid(True, alpha=0.3)

    # Plot 4: Perturbation stability
    ax = axes[1, 1]
    a_val = 0.5
    bs = np.linspace(0, 5, 100)
    fixed_pts = bs / (1 - a_val)
    ax.plot(bs, fixed_pts, 'b-', linewidth=2, label=f'x*(b) = b/(1-{a_val})')

    # Show specific perturbations
    for b_val in [1.0, 2.0, 3.0, 4.0]:
        fp = b_val / (1 - a_val)
        ax.plot(b_val, fp, 'ro', markersize=8)
        ax.annotate(f'({b_val}, {fp:.1f})', (b_val, fp),
                   textcoords="offset points", xytext=(10, 5), fontsize=8)

    ax.set_title(f'Perturbation Stability (a={a_val})', fontsize=12)
    ax.set_xlabel('Offset b')
    ax.set_ylabel('Fixed point x*(b)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Novikov Self-Consistency: Fixed-Point Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('novikov_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved: novikov_convergence.png")


if __name__ == "__main__":
    plot_convergence()
