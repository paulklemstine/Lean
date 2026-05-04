"""
Tropical Tensor-Product Universality: Numerical Demonstrations

This script demonstrates the main theorem: bivariate continuous functions on compact
spaces can be uniformly approximated by finite max-plus combinations of separable terms
("tropical pure tensors"). Each tropical pure tensor has the form:

    T_i(x, y) = c_i + a_i(x) + b_i(y)

and the approximation is:

    f(x, y) ≈ max_i T_i(x, y) = max_i [c_i + a_i(x) + b_i(y)]

This is the max-plus (tropical) analogue of tensor product decomposition.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def fit_tropical_approximation(f_target, x_grid, y_grid, n_terms=10, n_iter=500, lr=0.01):
    """
    Fit a tropical approximation to a target function using stochastic search.

    We parameterize:
        a_i(x) = alpha_i * x + beta_i
        b_i(y) = gamma_i * y + delta_i

    and optimize c_i, alpha_i, beta_i, gamma_i, delta_i to minimize the sup-norm error.
    """
    np.random.seed(42)
    X, Y = np.meshgrid(x_grid, y_grid)
    Z_target = f_target(X, Y)

    params = {
        'c': np.random.randn(n_terms) * 0.5,
        'alpha': np.random.randn(n_terms) * 0.5,
        'beta': np.random.randn(n_terms) * 0.5,
        'gamma': np.random.randn(n_terms) * 0.5,
        'delta': np.random.randn(n_terms) * 0.5,
    }

    best_params = {k: v.copy() for k, v in params.items()}
    best_error = np.inf

    for iteration in range(n_iter):
        terms = []
        for i in range(n_terms):
            term = (params['c'][i]
                    + params['alpha'][i] * X + params['beta'][i]
                    + params['gamma'][i] * Y + params['delta'][i])
            terms.append(term)
        Z_approx = np.maximum.reduce(terms)
        error = np.max(np.abs(Z_target - Z_approx))

        if error < best_error:
            best_error = error
            best_params = {k: v.copy() for k, v in params.items()}

        for key in params:
            perturbation = np.random.randn(*params[key].shape) * lr * (1 - iteration / n_iter)
            params_trial = {k: v.copy() for k, v in params.items()}
            params_trial[key] = params[key] + perturbation

            terms_trial = []
            for i in range(n_terms):
                term = (params_trial['c'][i]
                        + params_trial['alpha'][i] * X + params_trial['beta'][i]
                        + params_trial['gamma'][i] * Y + params_trial['delta'][i])
                terms_trial.append(term)
            Z_trial = np.maximum.reduce(terms_trial)
            error_trial = np.max(np.abs(Z_target - Z_trial))

            if error_trial < error:
                params[key] = params_trial[key]
                error = error_trial

    return best_params, best_error


def demo_1_basic_approximation():
    """Demo 1: Approximating a smooth bivariate function with tropical pure tensors."""
    print("=" * 70)
    print("DEMO 1: Basic Tropical Tensor Approximation")
    print("=" * 70)

    def f_target(x, y):
        return np.sin(2 * np.pi * x) * np.cos(np.pi * y) + 0.5 * x * y

    x = np.linspace(0, 1, 80)
    y = np.linspace(0, 1, 80)
    X, Y = np.meshgrid(x, y)
    Z_target = f_target(X, Y)

    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    fig.suptitle('Tropical Tensor Approximation of f(x,y) = sin(2πx)cos(πy) + xy/2',
                 fontsize=14, fontweight='bold')

    n_terms_list = [2, 5, 10, 20, 40, 80]

    for idx, n_terms in enumerate(n_terms_list):
        ax = axes[idx // 3, idx % 3]
        params, error = fit_tropical_approximation(f_target, x, y, n_terms=n_terms,
                                                    n_iter=300, lr=0.1)
        terms = []
        for i in range(n_terms):
            term = (params['c'][i]
                    + params['alpha'][i] * X + params['beta'][i]
                    + params['gamma'][i] * Y + params['delta'][i])
            terms.append(term)
        Z_approx = np.maximum.reduce(terms)

        ax.contourf(X, Y, Z_approx, levels=20, cmap='RdYlBu_r')
        ax.set_title(f'n = {n_terms}, ‖error‖∞ = {error:.4f}', fontsize=11)
        ax.set_xlabel('x')
        ax.set_ylabel('y')

    plt.tight_layout()
    plt.savefig('demos/demo1_tropical_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/demo1_tropical_approximation.png")


def demo_2_pure_tensors():
    """Demo 2: Visualize individual pure tensors and their tropical sum."""
    print("\n" + "=" * 70)
    print("DEMO 2: Pure Tensor Visualization")
    print("=" * 70)

    x = np.linspace(-1, 1, 100)
    y = np.linspace(-1, 1, 100)
    X, Y = np.meshgrid(x, y)

    tensors = [
        (0.0, 0.5, 0.3, '0.5x + 0.3y'),
        (-0.2, -0.4, 0.6, '-0.2 - 0.4x + 0.6y'),
        (0.1, 0.3, -0.5, '0.1 + 0.3x - 0.5y'),
        (-0.3, -0.2, -0.4, '-0.3 - 0.2x - 0.4y'),
    ]

    fig, axes = plt.subplots(1, 5, figsize=(22, 4))
    fig.suptitle('Pure Tensors T_i(x,y) = c_i + α_i·x + β_i·y and Their Tropical Sum',
                 fontsize=14, fontweight='bold')

    all_terms = []
    for idx, (c, alpha, beta, label) in enumerate(tensors):
        Z = c + alpha * X + beta * Y
        all_terms.append(Z)
        axes[idx].contourf(X, Y, Z, levels=15, cmap='viridis')
        axes[idx].set_title(f'T_{idx+1}: {label}', fontsize=9)
        axes[idx].set_xlabel('x')
        axes[idx].set_ylabel('y')

    Z_max = np.maximum.reduce(all_terms)
    axes[4].contourf(X, Y, Z_max, levels=15, cmap='magma')
    axes[4].set_title('max(T₁, T₂, T₃, T₄)', fontsize=11, fontweight='bold')
    axes[4].set_xlabel('x')
    axes[4].set_ylabel('y')

    plt.tight_layout()
    plt.savefig('demos/demo2_pure_tensors.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/demo2_pure_tensors.png")


def demo_3_separation():
    """Demo 3: Product point separation — pure tensors separate points of X × Y."""
    print("\n" + "=" * 70)
    print("DEMO 3: Product Point Separation")
    print("=" * 70)

    p1 = (0.3, 0.7)
    p2 = (0.8, 0.2)

    print(f"Points: p₁ = {p1}, p₂ = {p2}")
    print(f"  x-separator T(x,y)=x: T(p₁)={p1[0]}, T(p₂)={p2[0]}, separates={p1[0]!=p2[0]}")
    print(f"  y-separator T(x,y)=y: T(p₁)={p1[1]}, T(p₂)={p2[1]}, separates={p1[1]!=p2[1]}")

    x = np.linspace(0, 1, 100)
    y = np.linspace(0, 1, 100)
    X, Y = np.meshgrid(x, y)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    fig.suptitle('Point Separation by Pure Tensors on X × Y', fontsize=14, fontweight='bold')

    for idx, (Z, title) in enumerate([
        (X, 'T(x,y) = x (x-separator)'),
        (Y, 'T(x,y) = y (y-separator)'),
        (np.maximum(X, Y), 'max(x, y) (tropical sum)'),
    ]):
        c = axes[idx].contourf(X, Y, Z, levels=15, cmap='coolwarm')
        axes[idx].plot(*p1, 'ko', markersize=10, label=f'p₁={p1}')
        axes[idx].plot(*p2, 'k^', markersize=10, label=f'p₂={p2}')
        axes[idx].set_title(title)
        if idx == 0:
            axes[idx].legend(fontsize=8)
        plt.colorbar(c, ax=axes[idx])

    plt.tight_layout()
    plt.savefig('demos/demo3_separation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/demo3_separation.png")


def demo_4_convergence():
    """Demo 4: Convergence rate — sup-norm error vs number of tropical terms."""
    print("\n" + "=" * 70)
    print("DEMO 4: Convergence of Tropical Approximation")
    print("=" * 70)

    def f_target(x, y):
        return np.sin(3 * x) * np.cos(2 * y) + 0.3 * np.exp(-((x-0.5)**2 + (y-0.5)**2) / 0.1)

    x = np.linspace(0, 1, 50)
    y = np.linspace(0, 1, 50)

    n_terms_list = [1, 2, 5, 10, 20, 40, 70, 100]
    errors = []

    for n in n_terms_list:
        _, error = fit_tropical_approximation(f_target, x, y, n_terms=n, n_iter=400, lr=0.15)
        errors.append(error)
        print(f"  n = {n:3d} terms: ‖error‖∞ = {error:.6f}")

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(n_terms_list, errors, 'bo-', linewidth=2, markersize=8)
    ax.set_xlabel('Number of tropical terms (n)', fontsize=12)
    ax.set_ylabel('Sup-norm error ‖f − approx‖∞', fontsize=12)
    ax.set_title('Convergence of Tropical Tensor Approximation', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0.01, color='r', linestyle='--', alpha=0.5, label='ε = 0.01')
    ax.legend(fontsize=11)

    plt.tight_layout()
    plt.savefig('demos/demo4_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/demo4_convergence.png")


if __name__ == '__main__':
    print("Tropical Tensor-Product Universality — Numerical Demonstrations")
    print("=" * 70)
    print()
    print("Main Theorem (Lean formalization: dense_productMaxPlusFamily):")
    print("  For compact Hausdorff spaces X, Y and point-separating families")
    print("  A ⊆ C(X,ℝ), B ⊆ C(Y,ℝ), the max-plus family generated by")
    print("  lifted functions from A and B is uniformly dense in C(X×Y, ℝ).")
    print()

    demo_1_basic_approximation()
    demo_2_pure_tensors()
    demo_3_separation()
    demo_4_convergence()

    print("\n" + "=" * 70)
    print("All demos complete! Check the demos/ directory for output plots.")
    print("=" * 70)
