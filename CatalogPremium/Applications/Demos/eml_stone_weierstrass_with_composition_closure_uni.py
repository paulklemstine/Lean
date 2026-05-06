#!/usr/bin/env python3
"""
Demonstration of the EML Continuous Scalar Functional Calculus Theorem.

This script visualizes the key ideas behind the formally verified theorem:
if A is a set of continuous functions on a compact space X, closed under
constants, addition, multiplication, max, and min, and if f ∈ A, then
for any continuous φ, the composition φ ∘ f lies in the uniform closure of A.

We demonstrate this by:
1. Showing polynomial approximation of continuous functions on intervals
   (the Weierstrass engine behind the functional calculus)
2. Showing how composing polynomials with f gives functions in A
3. Showing the convergence of these compositions to φ ∘ f
4. Demonstrating the full Stone-Weierstrass density result
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

# Ensure output directory exists
os.makedirs("demos/figures", exist_ok=True)


def bernstein_poly(n, k, x):
    """Bernstein basis polynomial B_{k,n}(x)."""
    from math import comb
    return comb(n, k) * x**k * (1 - x)**(n - k)


def bernstein_approx(f, n, x):
    """Bernstein polynomial approximation of f on [0,1]."""
    result = np.zeros_like(x, dtype=float)
    for k in range(n + 1):
        result += f(k / n) * bernstein_poly(n, k, x)
    return result


def chebyshev_nodes(n, a, b):
    """Chebyshev nodes on [a, b]."""
    k = np.arange(1, n + 1)
    nodes = 0.5 * (a + b) + 0.5 * (b - a) * np.cos((2*k - 1) / (2*n) * np.pi)
    return nodes


def lagrange_interp(nodes, values, x):
    """Lagrange interpolation polynomial."""
    n = len(nodes)
    result = np.zeros_like(x, dtype=float)
    for i in range(n):
        term = values[i] * np.ones_like(x)
        for j in range(n):
            if j != i:
                term *= (x - nodes[j]) / (nodes[i] - nodes[j])
        result += term
    return result


# ============================================================
# Figure 1: Weierstrass Approximation — The Engine
# ============================================================
def plot_weierstrass_approximation():
    """Show polynomial approximation of continuous functions on [a,b]."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Example 1: |x| on [-1, 1] (a classic)
    x = np.linspace(0, 1, 500)
    phi = lambda t: np.abs(2*t - 1)  # |x| mapped to [0,1]

    ax = axes[0]
    ax.plot(2*x - 1, phi(x), 'k-', linewidth=2, label='$|x|$')
    for n in [5, 15, 50]:
        approx = bernstein_approx(phi, n, x)
        ax.plot(2*x - 1, approx, '--', linewidth=1.5, label=f'$B_n, n={n}$')
    ax.set_xlabel('$x$')
    ax.set_ylabel('$\\varphi(x)$')
    ax.set_title('Bernstein approx of $|x|$')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Example 2: sin(πx) on [0, 1]
    phi2 = lambda t: np.sin(np.pi * t)
    ax = axes[1]
    ax.plot(x, phi2(x), 'k-', linewidth=2, label='$\\sin(\\pi x)$')
    for n in [3, 8, 20]:
        approx = bernstein_approx(phi2, n, x)
        ax.plot(x, approx, '--', linewidth=1.5, label=f'$B_n, n={n}$')
    ax.set_xlabel('$x$')
    ax.set_title('Bernstein approx of $\\sin(\\pi x)$')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Example 3: ReLU on [-1, 1]
    phi3 = lambda t: np.maximum(2*t - 1, 0)  # ReLU on [-1,1]
    ax = axes[2]
    ax.plot(2*x - 1, phi3(x), 'k-', linewidth=2, label='ReLU')
    for n in [5, 15, 50]:
        approx = bernstein_approx(phi3, n, x)
        ax.plot(2*x - 1, approx, '--', linewidth=1.5, label=f'$B_n, n={n}$')
    ax.set_xlabel('$x$')
    ax.set_title('Bernstein approx of ReLU')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Weierstrass Approximation: The Engine Behind Functional Calculus',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/weierstrass_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Generated: demos/figures/weierstrass_approximation.png")


# ============================================================
# Figure 2: Functional Calculus in Action
# ============================================================
def plot_functional_calculus():
    """
    Demonstrate: if f ∈ A, then φ ∘ f ∈ closure(A) for any continuous φ.
    """
    fig = plt.figure(figsize=(16, 10))
    gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

    # Choose a base function f(x) = cos(2πx) on [0, 1]
    x = np.linspace(0, 1, 500)
    f = np.cos(2 * np.pi * x)

    # f maps [0,1] into [-1, 1]
    a, b = -1.0, 1.0
    t = np.linspace(a, b, 500)

    # Choose activation φ(t) = max(t, 0) (ReLU)
    phi = lambda t: np.maximum(t, 0)

    # The target: φ ∘ f
    target = phi(f)

    # Chebyshev polynomial approximations of φ on [a, b]
    poly_degrees = [2, 5, 15, 50]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

    # Top left: polynomial approximations of φ on [a, b]
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.plot(t, phi(t), 'k-', linewidth=2, label='$\\varphi(t) = \\mathrm{ReLU}(t)$')
    for deg, color in zip(poly_degrees, colors):
        nodes = chebyshev_nodes(deg + 1, a, b)
        values = phi(nodes)
        poly_approx = lagrange_interp(nodes, values, t)
        ax1.plot(t, poly_approx, '--', color=color, linewidth=1.5,
                label=f'deg {deg} poly')
    ax1.set_xlabel('$t$')
    ax1.set_ylabel('$\\varphi(t)$')
    ax1.set_title('Step 1: Approximate $\\varphi$ by polynomials')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-0.3, 1.3)

    # Top middle: the base function f
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.plot(x, f, 'b-', linewidth=2)
    ax2.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
    ax2.set_xlabel('$x$')
    ax2.set_ylabel('$f(x)$')
    ax2.set_title('Base function $f(x) = \\cos(2\\pi x) \\in A$')
    ax2.grid(True, alpha=0.3)

    # Top right: target φ ∘ f
    ax3 = fig.add_subplot(gs[0, 2])
    ax3.plot(x, target, 'k-', linewidth=2, label='$\\varphi \\circ f$ (target)')
    ax3.set_xlabel('$x$')
    ax3.set_ylabel('$(\\varphi \\circ f)(x)$')
    ax3.set_title('Target: $\\varphi \\circ f \\in \\overline{A}$')
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)

    # Bottom left+center: polynomial compositions converging to φ ∘ f
    ax4 = fig.add_subplot(gs[1, :2])
    ax4.plot(x, target, 'k-', linewidth=2.5, label='$\\varphi \\circ f$ (target)')
    for deg, color in zip(poly_degrees, colors):
        nodes = chebyshev_nodes(deg + 1, a, b)
        values = phi(nodes)
        # p(f(x)) where p ≈ φ
        poly_of_f = lagrange_interp(nodes, values, f)
        ax4.plot(x, poly_of_f, '--', color=color, linewidth=1.5,
                label=f'$p_{{\\deg {deg}}} \\circ f \\in A$')
    ax4.set_xlabel('$x$')
    ax4.set_ylabel('$(p \\circ f)(x)$')
    ax4.set_title('Step 2: $p \\circ f \\in A$ converges to $\\varphi \\circ f \\in \\overline{A}$')
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)

    # Bottom right: convergence rate
    ax5 = fig.add_subplot(gs[1, 2])
    degrees = list(range(1, 60))
    errors = []
    for deg in degrees:
        nodes = chebyshev_nodes(deg + 1, a, b)
        values = phi(nodes)
        poly_of_f = lagrange_interp(nodes, values, f)
        err = np.max(np.abs(poly_of_f - target))
        errors.append(err)
    ax5.semilogy(degrees, errors, 'b-o', markersize=3)
    ax5.set_xlabel('Polynomial degree')
    ax5.set_ylabel('$\\|p \\circ f - \\varphi \\circ f\\|_\\infty$')
    ax5.set_title('Convergence rate')
    ax5.grid(True, alpha=0.3)

    fig.suptitle('Continuous Scalar Functional Calculus: $f \\in A \\Rightarrow \\varphi \\circ f \\in \\overline{A}$',
                 fontsize=14, fontweight='bold')
    plt.savefig('demos/figures/functional_calculus.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Generated: demos/figures/functional_calculus.png")


# ============================================================
# Figure 3: Stone-Weierstrass Density
# ============================================================
def plot_stone_weierstrass_density():
    """
    Show that a lattice-subalgebra separating points is dense in C(X, ℝ).
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    x = np.linspace(0, 1, 500)

    targets = [
        (lambda x: np.sin(5 * np.pi * x) * np.exp(-2*x), '$\\sin(5\\pi x) e^{-2x}$'),
        (lambda x: np.abs(x - 0.3) - np.abs(x - 0.7), '$|x-0.3| - |x-0.7|$'),
        (lambda x: np.where(x < 0.5, 2*x, 2 - 2*x), 'Triangle wave'),
        (lambda x: np.log(1 + 10*x) / np.log(11), '$\\log(1+10x)/\\log(11)$'),
    ]

    for ax, (target_fn, name) in zip(axes.flat, targets):
        y_target = target_fn(x)
        ax.plot(x, y_target, 'k-', linewidth=2, label=f'Target: {name}')

        for deg, color, ls in [(3, '#e74c3c', '--'), (8, '#3498db', '--'),
                                (20, '#2ecc71', '-.'), (50, '#9b59b6', ':')]:
            nodes = chebyshev_nodes(deg + 1, 0, 1)
            values = target_fn(nodes)
            approx = lagrange_interp(nodes, values, x)
            err = np.max(np.abs(approx - y_target))
            ax.plot(x, approx, linestyle=ls, color=color, linewidth=1.5,
                   label=f'deg {deg} ($\\varepsilon$={err:.1e})')

        ax.set_xlabel('$x$')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Stone-Weierstrass: Every Continuous Function Is a Uniform Limit',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/stone_weierstrass_density.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Generated: demos/figures/stone_weierstrass_density.png")


# ============================================================
# Figure 4: Neural Network Universality via Functional Calculus
# ============================================================
def plot_neural_network_universality():
    """
    Show how the functional calculus connects to neural network universality.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    x = np.linspace(-2, 2, 500)

    activations = {
        'ReLU': lambda t: np.maximum(t, 0),
        'Sigmoid': lambda t: 1 / (1 + np.exp(-t)),
        'Softplus': lambda t: np.log(1 + np.exp(t)),
    }

    target = lambda x: np.sin(np.pi * x) * np.exp(-x**2/4)

    for ax, (act_name, sigma) in zip(axes, activations.items()):
        y_target = target(x)
        ax.plot(x, y_target, 'k-', linewidth=2.5, label='Target')

        for n_neurons in [3, 10, 50]:
            np.random.seed(42)
            W = np.random.randn(n_neurons) * 2
            B = np.random.randn(n_neurons) * 2

            features = np.array([sigma(w * x + b) for w, b in zip(W, B)]).T
            coeffs, _, _, _ = np.linalg.lstsq(features, y_target, rcond=None)
            approx = features @ coeffs

            err = np.max(np.abs(approx - y_target))
            ax.plot(x, approx, '--', linewidth=1.5,
                   label=f'{n_neurons} neurons ($\\varepsilon$={err:.3f})')

        ax.set_xlabel('$x$')
        ax.set_title(f'Activation: {act_name}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Neural Network Universality via Functional Calculus',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/neural_universality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Generated: demos/figures/neural_universality.png")


# ============================================================
# Main
# ============================================================
if __name__ == '__main__':
    print("=" * 60)
    print("EML Functional Calculus & Stone-Weierstrass Demonstration")
    print("=" * 60)
    print()

    plot_weierstrass_approximation()
    plot_functional_calculus()
    plot_stone_weierstrass_density()
    plot_neural_network_universality()

    print()
    print("All figures generated successfully!")
    print()
    print("Key theorem (formally verified in Lean 4):")
    print("  If A ⊆ C(X, ℝ) contains constants, is closed under +, ·, max, min,")
    print("  and separates points, then:")
    print("    1. For f ∈ A and φ continuous: φ ∘ f ∈ closure(A)")
    print("    2. closure(A) = C(X, ℝ)  (uniform density)")
    print()
    print("This means any continuous scalar nonlinearity applied to functions")
    print("in the class stays in the uniform closure — the mathematical")
    print("foundation of universal approximation theorems.")
