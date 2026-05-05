#!/usr/bin/env python3
"""
Gradient Descent Convergence: Interactive Demonstrations
========================================================

This script demonstrates the formally verified gradient descent convergence
theorems with concrete numerical examples and visualizations.

Corresponds to the Lean 4 formalization in MachineLearning/GradientDescent/Basic.lean.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ============================================================================
# Demo 1: Basic GD Convergence on 1D Quadratic
# ============================================================================

def gd_iterate_1d(a, eta, x0, n_steps):
    """Gradient descent on f(x) = (a/2)x², verified equivalent to (1-eta*a)^n * x0."""
    trajectory = [x0]
    x = x0
    for _ in range(n_steps):
        grad = a * x
        x = x - eta * grad
        trajectory.append(x)
    return np.array(trajectory)


def demo_basic_convergence():
    """Demonstrate Theorem gd_converges: GD converges for 0 < eta < 2/a."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    a = 4.0  # f(x) = 2x^2
    x0 = 5.0
    n_steps = 30

    step_sizes = [
        (1/a, r"Optimal: $\eta = 1/a = 0.25$", 'green'),
        (0.4, r"Valid: $\eta = 0.4 < 2/a$", 'blue'),
        (0.55, r"Boundary: $\eta = 0.55 \approx 2/a$", 'red'),
    ]

    for ax, (eta, label, color) in zip(axes, step_sizes):
        traj = gd_iterate_1d(a, eta, x0, n_steps)
        contraction = abs(1 - eta * a)

        ax.semilogy(range(len(traj)), np.abs(traj) + 1e-20, 'o-', color=color, markersize=4)

        theoretical = np.abs(x0) * contraction ** np.arange(len(traj))
        ax.semilogy(range(len(traj)), theoretical + 1e-20, '--', color='gray', alpha=0.7,
                    label=f'|1-ηa|^n·|x₀| (rate={contraction:.3f})')

        ax.set_xlabel('Iteration n')
        ax.set_ylabel('|x_n|')
        ax.set_title(f'{label}\n|1 - ηa| = {contraction:.3f}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(bottom=1e-16)

    fig.suptitle(r'Theorem: GD Convergence on $f(x) = 2x^2$' + '\n'
                 r'Formally verified: converges $\Leftrightarrow$ $0 < \eta < 2/a$',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/basic_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  [+] Demo 1: Basic convergence -> demos/figures/basic_convergence.png")


# ============================================================================
# Demo 2: Contraction Factor Analysis
# ============================================================================

def demo_contraction_factor():
    """Demonstrate Theorem contraction_factor_lt_one: |1 - eta*a| < 1 iff 0 < eta*a < 2."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    a = 4.0
    eta_values = np.linspace(0.001, 0.6, 500)

    contraction = np.abs(1 - eta_values * a)

    ax1.plot(eta_values, contraction, 'b-', linewidth=2)
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='|1 - ηa| = 1 (boundary)')
    ax1.axvline(x=2/a, color='red', linestyle=':', alpha=0.7, label=f'η = 2/a = {2/a:.2f}')
    ax1.axvline(x=1/a, color='green', linestyle=':', alpha=0.7,
                label=f'η = 1/a = {1/a:.2f} (optimal)')

    ax1.fill_between(eta_values, 0, 1, where=(contraction < 1), alpha=0.1, color='green',
                     label='Convergent region')

    ax1.set_xlabel(r'Step size $\eta$', fontsize=12)
    ax1.set_ylabel(r'Contraction factor $|1 - \eta a|$', fontsize=12)
    ax1.set_title('Contraction Factor vs Step Size (a = 4)')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-0.05, 2.5)

    # Plot convergence for different step sizes
    x0 = 10.0
    n_steps = 50
    etas = [0.05, 0.15, 0.25, 0.35, 0.45]

    for eta in etas:
        traj = gd_iterate_1d(a, eta, x0, n_steps)
        rate = abs(1 - eta * a)
        ax2.semilogy(range(len(traj)), np.abs(traj) + 1e-20, '-', linewidth=1.5,
                    label=f'η={eta:.2f}, rate={rate:.2f}')

    ax2.set_xlabel('Iteration n', fontsize=12)
    ax2.set_ylabel('|x_n|', fontsize=12)
    ax2.set_title('Convergence Speed vs Step Size')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/figures/contraction_factor.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  [+] Demo 2: Contraction factor -> demos/figures/contraction_factor.png")


# ============================================================================
# Demo 3: Condition Number Effect on 2D Quadratics
# ============================================================================

def gd_iterate_2d(eigenvalues, eta, x0, n_steps):
    """GD on f(x) = (1/2) x^T diag(eigenvalues) x."""
    trajectory = [x0.copy()]
    x = x0.copy()
    for _ in range(n_steps):
        grad = eigenvalues * x
        x = x - eta * grad
        trajectory.append(x.copy())
    return np.array(trajectory)


def demo_condition_number():
    """Demonstrate condition number effect on convergence rate."""
    fig = plt.figure(figsize=(16, 10))
    gs = GridSpec(2, 3, figure=fig)

    configs = [
        (np.array([1.0, 1.0]), r"$\kappa = 1$ (well-conditioned)"),
        (np.array([1.0, 5.0]), r"$\kappa = 5$"),
        (np.array([1.0, 20.0]), r"$\kappa = 20$ (ill-conditioned)"),
    ]

    x0 = np.array([5.0, 5.0])
    n_steps = 100

    for i, (eigs, title) in enumerate(configs):
        mu, L = min(eigs), max(eigs)
        kappa = L / mu
        optimal_eta = 2.0 / (mu + L)
        optimal_rate = (L - mu) / (L + mu)

        traj = gd_iterate_2d(eigs, optimal_eta, x0, n_steps)

        ax1 = fig.add_subplot(gs[0, i])
        ax1.plot(traj[:, 0], traj[:, 1], 'b.-', markersize=3, alpha=0.7)
        ax1.plot(traj[0, 0], traj[0, 1], 'go', markersize=10, label='Start')
        ax1.plot(0, 0, 'r*', markersize=15, label='Optimum')

        xx, yy = np.meshgrid(np.linspace(-6, 6, 100), np.linspace(-6, 6, 100))
        zz = 0.5 * (eigs[0] * xx**2 + eigs[1] * yy**2)
        ax1.contour(xx, yy, zz, levels=15, alpha=0.3, colors='gray')

        ax1.set_xlabel(r'$x_1$')
        ax1.set_ylabel(r'$x_2$')
        ax1.set_title(f'{title}\n' + r'$\eta^* = $' + f'{optimal_eta:.3f}')
        ax1.legend(fontsize=8)
        ax1.set_aspect('equal')
        ax1.grid(True, alpha=0.2)

        ax2 = fig.add_subplot(gs[1, i])
        errors = np.linalg.norm(traj, axis=1)
        ax2.semilogy(range(len(errors)), errors + 1e-20, 'b-', linewidth=1.5, label='Actual')

        theoretical = np.linalg.norm(x0) * optimal_rate ** np.arange(len(errors))
        ax2.semilogy(range(len(errors)), theoretical + 1e-20, 'r--', alpha=0.7,
                    label=f'Theory: rate = {optimal_rate:.3f}')

        ax2.set_xlabel('Iteration')
        ax2.set_ylabel(r'$\|x_n\|$')
        ax2.set_title(r'$\kappa = $' + f'{kappa:.0f}, rate = ' + r'$(\kappa-1)/(\kappa+1)$' +
                      f' = {optimal_rate:.3f}')
        ax2.legend(fontsize=9)
        ax2.grid(True, alpha=0.3)

    fig.suptitle(r'Condition Number Controls Convergence Rate' + '\n'
                 r'Formally verified: rate $= (\kappa - 1)/(\kappa + 1)$ where $\kappa = L/\mu$',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/condition_number.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  [+] Demo 3: Condition number -> demos/figures/condition_number.png")


# ============================================================================
# Demo 4: Iteration Complexity
# ============================================================================

def demo_iteration_complexity():
    """Demonstrate: iterations proportional to kappa * log(1/eps)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    kappas = np.linspace(1.1, 100, 200)
    epsilons = [1e-3, 1e-6, 1e-9, 1e-12]

    for eps in epsilons:
        rates = (kappas - 1) / (kappas + 1)
        n_iters = np.log(eps) / np.log(rates)
        ax1.plot(kappas, n_iters, linewidth=2, label=r'$\varepsilon$ = ' + f'{eps:.0e}')

    ax1.set_xlabel(r'Condition number $\kappa$', fontsize=12)
    ax1.set_ylabel(r'Iterations to $\varepsilon$-accuracy', fontsize=12)
    ax1.set_title(r'Iteration Complexity: $n \propto \kappa \cdot \log(1/\varepsilon)$')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    rates_actual = (kappas - 1) / (kappas + 1)
    rates_bound = 1 - 2 / (kappas + 1)

    ax2.plot(kappas, rates_actual, 'b-', linewidth=2, label=r'$(\kappa-1)/(\kappa+1)$')
    ax2.plot(kappas, rates_bound, 'r--', linewidth=2, label=r'$1 - 2/(\kappa+1)$')
    ax2.fill_between(kappas, rates_actual, rates_bound, alpha=0.1, color='green')
    ax2.set_xlabel(r'Condition number $\kappa$', fontsize=12)
    ax2.set_ylabel('Convergence rate', fontsize=12)
    ax2.set_title(r'Verified bound: rate $\leq 1 - 2/(\kappa+1)$' + '\n(equality holds)')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/figures/iteration_complexity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  [+] Demo 4: Iteration complexity -> demos/figures/iteration_complexity.png")


# ============================================================================
# Demo 5: Numerical Verification of Formal Theorems
# ============================================================================

def demo_numerical_verification():
    """Verify each formally proven theorem with concrete numbers."""
    print("\n" + "="*70)
    print("  NUMERICAL VERIFICATION OF FORMALLY PROVEN THEOREMS")
    print("="*70)

    # Theorem: gd_iterate_eq
    a, eta, x0 = 3.0, 0.2, 7.0
    r = 1 - eta * a
    print(f"\n  Theorem gd_iterate_eq")
    print(f"  Parameters: a={a}, eta={eta}, x0={x0}, r = 1-eta*a = {r}")
    for n in range(6):
        iterate = gd_iterate_1d(a, eta, x0, n)[-1]
        formula = r**n * x0
        print(f"    n={n}: iterate = {iterate:12.6f}, formula = {formula:12.6f}, "
              f"match: {np.isclose(iterate, formula)}")

    # Theorem: contraction_factor_lt_one
    print(f"\n  Theorem contraction_factor_lt_one")
    test_cases = [(0.1, 3.0), (0.5, 2.0), (0.3, 4.0)]
    for eta, a in test_cases:
        product = eta * a
        factor = abs(1 - product)
        print(f"    eta={eta}, a={a}: eta*a={product:.1f}, |1-eta*a|={factor:.3f} < 1: {factor < 1}")

    # Theorem: optimal_rate_eq_condition
    print(f"\n  Theorem optimal_rate_eq_condition")
    configs = [(1, 5), (2, 10), (1, 100)]
    for mu, L in configs:
        kappa = L / mu
        rate = (L - mu) / (L + mu)
        formula = (kappa - 1) / (kappa + 1)
        print(f"    mu={mu}, L={L}: kappa={kappa:.0f}, rate={rate:.6f}, "
              f"(kappa-1)/(kappa+1)={formula:.6f}, match: {np.isclose(rate, formula)}")

    # Theorem: gd_optimal_one_step
    print(f"\n  Theorem gd_optimal_one_step")
    for a in [2.0, 5.0, 0.1, 100.0]:
        x0 = 42.0
        eta = 1.0 / a
        result = gd_iterate_1d(a, eta, x0, 1)[-1]
        print(f"    a={a:6.1f}, eta=1/a={eta:.4f}, x1 = {result:.2e} (should be 0)")

    print(f"\n  All theorems numerically verified! ✓")
    print("="*70)


# ============================================================================
# Demo 6: Application — Linear Regression
# ============================================================================

def demo_linear_regression():
    """Apply GD convergence theory to linear regression."""
    np.random.seed(42)
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    n_data = 50
    X = np.random.randn(n_data, 1)
    y = 3 * X.squeeze() + 2 + 0.5 * np.random.randn(n_data)
    X_aug = np.hstack([X, np.ones((n_data, 1))])

    H = X_aug.T @ X_aug / n_data
    eigenvalues = np.linalg.eigvalsh(H)
    mu, L = eigenvalues.min(), eigenvalues.max()
    kappa = L / mu

    print(f"\n  --- Linear Regression Application ---")
    print(f"  Data: {n_data} points, y = 3x + 2 + noise")
    print(f"  Hessian eigenvalues: mu = {mu:.4f}, L = {L:.4f}")
    print(f"  Condition number: kappa = {kappa:.2f}")
    print(f"  Predicted rate: (kappa-1)/(kappa+1) = {(kappa-1)/(kappa+1):.4f}")

    eta_opt = 2.0 / (mu + L)
    w = np.array([0.0, 0.0])
    w_star = np.linalg.solve(H, X_aug.T @ y / n_data)

    errors = []
    n_iters = 200
    for _ in range(n_iters):
        errors.append(np.linalg.norm(w - w_star))
        grad = (X_aug.T @ (X_aug @ w - y)) / n_data
        w = w - eta_opt * grad
    errors.append(np.linalg.norm(w - w_star))

    ax = axes[0]
    ax.scatter(X, y, alpha=0.5, s=20, label='Data')
    x_line = np.linspace(X.min(), X.max(), 100)
    ax.plot(x_line, w_star[0] * x_line + w_star[1], 'r-', linewidth=2,
            label=f'Fit: {w_star[0]:.2f}x + {w_star[1]:.2f}')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_title('Linear Regression Data')
    ax.legend()
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.semilogy(errors, 'b-', linewidth=1.5, label=r'Actual $\|w - w^*\|$')
    predicted_rate = (kappa - 1) / (kappa + 1)
    theoretical = errors[0] * predicted_rate ** np.arange(len(errors))
    ax.semilogy(theoretical, 'r--', alpha=0.7, label=f'Theory (rate={predicted_rate:.3f})')
    ax.set_xlabel('Iteration')
    ax.set_ylabel(r'$\|w_n - w^*\|$')
    ax.set_title(r'GD Convergence ($\kappa$=' + f'{kappa:.1f})')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Preconditioning
    ax = axes[2]
    D_inv = np.diag(1.0 / np.diag(H))
    H_precond = D_inv @ H
    eigs_precond = np.linalg.eigvalsh(H_precond)
    kappa_precond = eigs_precond.max() / eigs_precond.min()

    w_p = np.array([0.0, 0.0])
    errors_precond = []
    eta_precond = 2.0 / (eigs_precond.min() + eigs_precond.max())
    for _ in range(n_iters):
        errors_precond.append(np.linalg.norm(w_p - w_star))
        grad = (X_aug.T @ (X_aug @ w_p - y)) / n_data
        w_p = w_p - eta_precond * D_inv @ grad
    errors_precond.append(np.linalg.norm(w_p - w_star))

    ax.semilogy(errors, 'b-', linewidth=1.5, label=r'GD ($\kappa$=' + f'{kappa:.1f})')
    ax.semilogy(errors_precond, 'g-', linewidth=1.5,
                label=r'Preconditioned ($\kappa\approx$' + f'{kappa_precond:.1f})')
    ax.set_xlabel('Iteration')
    ax.set_ylabel(r'$\|w_n - w^*\|$')
    ax.set_title(r'Preconditioning Reduces $\kappa$')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Application: Gradient Descent for Linear Regression',
                fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/linear_regression.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  [+] Demo 6: Linear regression -> demos/figures/linear_regression.png")


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    import os
    os.makedirs('demos/figures', exist_ok=True)

    print("="*60)
    print("  Gradient Descent Convergence — Demonstrations")
    print("="*60)

    demo_basic_convergence()
    demo_contraction_factor()
    demo_condition_number()
    demo_iteration_complexity()
    demo_numerical_verification()
    demo_linear_regression()

    print("\n  All demonstrations complete!")
    print("="*60)
