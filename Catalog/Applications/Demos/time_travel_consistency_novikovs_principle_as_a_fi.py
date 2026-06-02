#!/usr/bin/env python3
"""
Novikov Self-Consistency Principle: Numerical Demonstrations

Demonstrates the key theorems from the Lean formalization:
1. Affine causal maps converge to unique fixed points
2. Composition of causal loops preserves consistency
3. Exponential convergence rate matches theoretical bound K^n
4. Stability under perturbation
"""

import math


def affine_causal_demo():
    """Demonstrate self-consistency for affine causal map F(x) = ax + b."""
    print("=" * 60)
    print("DEMO 1: Affine Causal Map Self-Consistency")
    print("=" * 60)

    a, b = 0.3, 700.0
    fixed_point = b / (1 - a)
    print(f"\nCausal map: F(x) = {a}*x + {b}")
    print(f"Theoretical fixed point: x* = {b}/(1-{a}) = {fixed_point}")
    print(f"Verification: F(x*) = {a}*{fixed_point} + {b} = {a * fixed_point + b}")

    # Iterate from arbitrary starting point
    x = 0.0
    print(f"\nIterating from x₀ = {x}:")
    for n in range(15):
        x_new = a * x + b
        error = abs(x - fixed_point)
        theoretical_error = abs(a) ** n * abs(0.0 - fixed_point)
        print(f"  n={n:2d}: x = {x:12.6f}, |x - x*| = {error:.2e}, "
              f"K^n * |x₀ - x*| = {theoretical_error:.2e}")
        x = x_new

    print(f"\nFinal: x = {x:.10f} (fixed point = {fixed_point:.10f})")


def composition_demo():
    """Demonstrate self-consistency for composed causal loops."""
    print("\n" + "=" * 60)
    print("DEMO 2: Composition of Two Causal Loops")
    print("=" * 60)

    # Loop 1: F₁(x) = 0.6x + 200, K₁ = 0.6
    # Loop 2: F₂(x) = 0.5x + 100, K₂ = 0.5
    # Composed: F₂∘F₁(x) = 0.5*(0.6x + 200) + 100 = 0.3x + 200
    # K₁ * K₂ = 0.3 < 1 ✓
    a1, b1, K1 = 0.6, 200.0, 0.6
    a2, b2, K2 = 0.5, 100.0, 0.5

    print(f"\nLoop 1: F₁(x) = {a1}x + {b1}, K₁ = {K1}")
    print(f"Loop 2: F₂(x) = {a2}x + {b2}, K₂ = {K2}")
    print(f"K₁ × K₂ = {K1 * K2} < 1 ✓")

    # Composed map
    a_comp = a1 * a2
    b_comp = a2 * b1 + b2
    fixed_composed = b_comp / (1 - a_comp)
    print(f"\nComposed: (F₂∘F₁)(x) = {a_comp}x + {b_comp}")
    print(f"Fixed point: x* = {b_comp}/(1-{a_comp}) = {fixed_composed:.6f}")

    x = 5000.0
    print(f"\nIterating composed map from x₀ = {x}:")
    for n in range(20):
        x_new = a2 * (a1 * x + b1) + b2
        error = abs(x - fixed_composed)
        print(f"  n={n:2d}: x = {x:12.4f}, |x - x*| = {error:.2e}")
        x = x_new

    print(f"\nConverged to: {x:.10f} (exact: {fixed_composed:.10f})")


def convergence_rate_demo():
    """Verify that convergence rate matches K^n bound."""
    print("\n" + "=" * 60)
    print("DEMO 3: Convergence Rate Verification")
    print("=" * 60)

    test_cases = [
        (0.1, 50.0, "Strong contraction (K=0.1)"),
        (0.5, 50.0, "Moderate contraction (K=0.5)"),
        (0.9, 50.0, "Weak contraction (K=0.9)"),
        (0.99, 50.0, "Very weak contraction (K=0.99)"),
    ]

    for a, b, label in test_cases:
        fixed = b / (1 - a)
        x = 0.0
        iters_to_converge = 0
        while abs(x - fixed) > 1e-10:
            x = a * x + b
            iters_to_converge += 1
            if iters_to_converge > 10000:
                break

        # Theoretical bound: K^n * |x0 - x*| < eps
        # n > log(eps / |x0 - x*|) / log(K)
        theoretical = math.ceil(
            math.log(1e-10 / abs(0 - fixed)) / math.log(a)
        )

        print(f"\n{label}:")
        print(f"  Iterations needed: {iters_to_converge}")
        print(f"  Theoretical bound: {theoretical}")
        print(f"  Ratio: {iters_to_converge / theoretical:.2f}")


def stability_demo():
    """Demonstrate perturbation stability."""
    print("\n" + "=" * 60)
    print("DEMO 4: Perturbation Stability")
    print("=" * 60)

    a, b = 0.4, 300.0
    fixed = b / (1 - a)

    x1, x2 = 100.0, 100.5  # Two nearby initial states
    initial_dist = abs(x1 - x2)

    print(f"\nCausal map: F(x) = {a}x + {b}, K = {a}")
    print(f"Initial states: x₁ = {x1}, x₂ = {x2}")
    print(f"Initial distance: {initial_dist}")
    print(f"\nEvolution:")

    for n in range(20):
        actual_dist = abs(x1 - x2)
        bound = a ** n * initial_dist
        print(f"  n={n:2d}: dist = {actual_dist:.2e}, "
              f"bound K^n·d₀ = {bound:.2e}, "
              f"ratio = {actual_dist / bound if bound > 0 else 0:.4f}")
        x1 = a * x1 + b
        x2 = a * x2 + b

    print(f"\nBoth converge to x* = {fixed}")


def polynomial_causal_demo():
    """Demonstrate self-consistency for a polynomial causal map."""
    print("\n" + "=" * 60)
    print("DEMO 5: Polynomial Causal Map")
    print("=" * 60)

    # F(x) = 0.1x² - 0.3x + 2 on [-1, 3]
    # F'(x) = 0.2x - 0.3, max |F'| on [-1,3] = max(0.5, 0.3) = 0.5 < 1
    def F(x):
        return 0.1 * x ** 2 - 0.3 * x + 2

    def Fprime(x):
        return 0.2 * x - 0.3

    print("\nCausal map: F(x) = 0.1x² - 0.3x + 2")
    print(f"Max |F'(x)| on [-1, 3] = {max(abs(Fprime(-1)), abs(Fprime(3)))}")
    print("Contraction on [-1, 3]: ✓ (K = 0.5)")

    x = 0.0
    print(f"\nIterating from x₀ = {x}:")
    prev_x = x
    for n in range(25):
        x_new = F(x)
        if n > 0:
            change = abs(x - prev_x)
            print(f"  n={n:2d}: x = {x:12.8f}, |Δx| = {change:.2e}")
        else:
            print(f"  n={n:2d}: x = {x:12.8f}")
        prev_x = x
        x = x_new

    # Verify: solve 0.1x² - 0.3x + 2 = x → 0.1x² - 1.3x + 2 = 0
    # x = (1.3 ± sqrt(1.69 - 0.8)) / 0.2 = (1.3 ± sqrt(0.89)) / 0.2
    disc = 1.69 - 0.8
    x_sol1 = (1.3 - math.sqrt(disc)) / 0.2
    x_sol2 = (1.3 + math.sqrt(disc)) / 0.2
    print(f"\nExact fixed points: {x_sol1:.8f} and {x_sol2:.8f}")
    print(f"Iteration converged to: {x:.8f} (attracting fixed point)")
    print(f"Verification: F({x:.8f}) = {F(x):.8f}")


if __name__ == "__main__":
    affine_causal_demo()
    composition_demo()
    convergence_rate_demo()
    stability_demo()
    polynomial_causal_demo()


#!/usr/bin/env python3
"""
Visualization: Convergence of Banach Iteration for Causal Maps

Plots the cobweb diagram and convergence trajectory for affine and
polynomial causal maps, demonstrating the Novikov self-consistency principle.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def plot_cobweb(ax, f, x0, n_iter, x_range, label, color='blue'):
    """Plot cobweb diagram for iteration x_{n+1} = f(x_n)."""
    xs = np.linspace(x_range[0], x_range[1], 500)
    ys = [f(x) for x in xs]

    ax.plot(xs, ys, color=color, linewidth=2, label=f'F(x) = {label}')
    ax.plot(xs, xs, 'k--', linewidth=1, label='y = x')

    # Cobweb
    x = x0
    for i in range(n_iter):
        y = f(x)
        ax.plot([x, x], [x if i == 0 else f_prev, y],
                color='red', linewidth=0.8, alpha=0.6)
        ax.plot([x, y], [y, y],
                color='red', linewidth=0.8, alpha=0.6)
        f_prev = y
        x = y


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # Panel 1: Affine map cobweb
    ax = axes[0, 0]
    a, b = 0.4, 300
    f = lambda x: a * x + b
    fixed = b / (1 - a)
    plot_cobweb(ax, f, 0, 20, (-100, 800), f'{a}x + {b}', 'royalblue')
    ax.axhline(y=fixed, color='green', linestyle=':', alpha=0.5)
    ax.axvline(x=fixed, color='green', linestyle=':', alpha=0.5)
    ax.scatter([fixed], [fixed], color='green', s=100, zorder=5,
               label=f'x* = {fixed:.0f}')
    ax.set_title('Affine Causal Map: Cobweb Diagram', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('F(x)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Convergence rate comparison
    ax = axes[0, 1]
    K_values = [0.1, 0.3, 0.5, 0.7, 0.9]
    colors = plt.cm.viridis(np.linspace(0, 0.9, len(K_values)))
    for K, col in zip(K_values, colors):
        f_k = lambda x, k=K: k * x + 50
        fixed_k = 50 / (1 - K)
        errors = []
        x = 0.0
        for n in range(50):
            errors.append(abs(x - fixed_k))
            x = K * x + 50
        ax.semilogy(range(50), errors, color=col, linewidth=2,
                     label=f'K = {K}')

    ax.set_title('Convergence Rate vs Contraction Constant', fontsize=13)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('|x_n - x*|')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-15, 1e3)

    # Panel 3: Polynomial causal map cobweb
    ax = axes[1, 0]
    fp = lambda x: 0.1 * x**2 - 0.3 * x + 2
    plot_cobweb(ax, fp, 0, 25, (-0.5, 4), '0.1x² - 0.3x + 2', 'darkorange')
    # Exact fixed points
    disc = 1.69 - 0.8
    x1 = (1.3 - math.sqrt(disc)) / 0.2
    x2 = (1.3 + math.sqrt(disc)) / 0.2
    ax.scatter([x1, x2], [x1, x2], color='green', s=100, zorder=5,
               label=f'Fixed points: {x1:.2f}, {x2:.2f}')
    ax.set_title('Polynomial Causal Map: Cobweb Diagram', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('F(x)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 4: Stability demonstration
    ax = axes[1, 1]
    a, b = 0.5, 100
    fixed_s = b / (1 - a)
    perturbations = [0.01, 0.1, 1.0, 10.0, 100.0]
    colors_s = plt.cm.plasma(np.linspace(0.1, 0.9, len(perturbations)))
    for eps, col in zip(perturbations, colors_s):
        x = fixed_s + eps
        trajectory = []
        for n in range(30):
            trajectory.append(x - fixed_s)
            x = a * x + b
        ax.plot(range(30), trajectory, color=col, linewidth=2,
                label=f'ε = {eps}')

    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_title('Stability: Perturbation Decay', fontsize=13)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('x_n - x*')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Novikov Self-Consistency via Banach Fixed-Point Theorem',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('novikov_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved novikov_convergence.png")


if __name__ == "__main__":
    main()
