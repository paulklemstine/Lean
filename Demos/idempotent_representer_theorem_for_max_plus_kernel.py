#!/usr/bin/env python3
"""
Max-Plus Representer Theorem: Numerical Demonstration
=====================================================

This script demonstrates the idempotent representer theorem for max-plus
kernel regression with concrete numerical examples. It shows how:

1. A Kronecker tropical kernel enables exact interpolation on training data.
2. The representer theorem guarantees that optimization over all functions
   reduces to optimization over kernel-span coefficients.
3. The coefficient-space objective is equivalent to the full function-space
   objective for span-supported functions.

Mathematical Setting
--------------------
In the max-plus semiring (R ∪ {-∞}, max, +):
  - "Addition" is max (⊕ = sup)
  - "Multiplication" is classical + (⊗)
  - "Zero" for addition is -∞ (= ⊥)
  - "Identity" for multiplication is 0

A tropical kernel span function has the form:
  f(z) = max_{x ∈ train} (K(z,x) + c(x))

The representer theorem says: any minimizer of a regularized empirical risk
can be replaced by one in this span without increasing the objective.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as cartesian_product

# Use -∞ as the tropical zero (bot)
NEG_INF = -np.inf


def tropical_add(a, b):
    """Tropical addition = max."""
    return np.maximum(a, b)


def tropical_mul(a, b):
    """Tropical multiplication = classical addition."""
    return a + b


def tropical_span_eval(K, train_indices, coeffs, z):
    """
    Evaluate a tropical span function at point z:
      f(z) = max_{x in train} (K(z, x) + c(x))
    """
    vals = [tropical_mul(K[z, x], coeffs[x]) for x in train_indices]
    return max(vals) if vals else NEG_INF


def kronecker_kernel(n_points, train_indices):
    """
    Build a Kronecker tropical kernel on a finite set {0, ..., n-1}.
    K(x, x) = 0 for x in train, K(z, x) = -∞ for z ≠ x in train.
    Off-train entries: K(z, x) = -∞ for x in train, z not in train
    (could be anything for x not in train, set to 0 on diag, -∞ off diag).
    """
    K = np.full((n_points, n_points), NEG_INF)
    for x in train_indices:
        K[x, x] = 0.0
    return K


def gaussian_tropical_kernel(points, sigma=1.0):
    """
    A smooth tropical kernel: K(z, x) = -||z - x||^2 / (2*sigma^2).
    This is a negative definite kernel in the max-plus sense.
    """
    n = len(points)
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = -np.sum((points[i] - points[j])**2) / (2 * sigma**2)
    return K


def empirical_risk(train_indices, loss_fn, y, f):
    """Empirical risk = max_{x in train} loss(x, f(x), y(x))."""
    return max(loss_fn(x, f[x], y[x]) for x in train_indices)


def objective(train_indices, loss_fn, y, reg_fn, f):
    """Objective = max(empirical_risk, reg(f))."""
    return max(empirical_risk(train_indices, loss_fn, y, f), reg_fn(f))


# ==============================================================================
# Demo 1: Kronecker Kernel Interpolation
# ==============================================================================

def demo_kronecker_interpolation():
    """
    Show that a Kronecker tropical kernel can interpolate any function
    exactly on the training set by setting c(x) = f(x).
    """
    print("=" * 70)
    print("DEMO 1: Kronecker Tropical Kernel — Exact Training Interpolation")
    print("=" * 70)

    n_points = 6
    train_indices = [0, 2, 4]  # Training set

    K = kronecker_kernel(n_points, train_indices)
    print(f"\nPoints: {{0, 1, 2, 3, 4, 5}}")
    print(f"Training set: {train_indices}")
    print(f"\nKronecker kernel (on train×train):")
    for i in train_indices:
        row = [f"{K[i,j]:6.1f}" for j in train_indices]
        print(f"  K[{i},:] = [{', '.join(row)}]")

    # Target function
    f_target = np.array([3.0, 1.0, -2.0, 5.0, 7.0, 0.0])
    print(f"\nTarget function values: {f_target}")

    # Set coefficients = target values (the interpolation trick)
    coeffs = f_target.copy()

    print(f"Coefficients c = f: {coeffs}")
    print(f"\nInterpolation check on training points:")
    for x in train_indices:
        val = tropical_span_eval(K, train_indices, coeffs, x)
        print(f"  f_span({x}) = max_{{z∈train}} (K({x},z) + c(z))")
        details = []
        for z in train_indices:
            kv = K[x, z]
            cv = coeffs[z]
            s = tropical_mul(kv, cv)
            details.append(f"    K({x},{z}) + c({z}) = {kv:.1f} + {cv:.1f} = {s:.1f}")
        for d in details:
            print(d)
        print(f"  → max = {val:.1f} (target: {f_target[x]:.1f}) ✓" if abs(val - f_target[x]) < 1e-10
              else f"  → max = {val:.1f} (target: {f_target[x]:.1f}) ✗")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot kernel matrix
    ax = axes[0]
    K_display = K.copy()
    K_display[K_display == NEG_INF] = np.nan
    im = ax.imshow(K_display, cmap='RdYlBu_r', aspect='equal')
    ax.set_title('Kronecker Tropical Kernel', fontsize=14)
    ax.set_xlabel('Column index')
    ax.set_ylabel('Row index')
    for i in range(n_points):
        for j in range(n_points):
            v = K[i, j]
            txt = '0' if v == 0 else '-∞'
            ax.text(j, i, txt, ha='center', va='center', fontsize=10,
                    color='white' if v == NEG_INF else 'black')
    plt.colorbar(im, ax=ax, label='Kernel value')

    # Plot interpolation
    ax = axes[1]
    x_all = np.arange(n_points)
    f_span = np.array([tropical_span_eval(K, train_indices, coeffs, z) for z in range(n_points)])
    ax.plot(x_all, f_target, 'ko-', label='Target f', markersize=8)
    ax.plot(train_indices, [f_span[i] for i in train_indices], 'r^',
            label='Span interpolation (on train)', markersize=12, zorder=5)
    ax.set_xlabel('Point index', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Exact Interpolation on Training Set', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo1_kronecker_interpolation.png', dpi=150, bbox_inches='tight')
    print(f"\n→ Figure saved: demo1_kronecker_interpolation.png")
    plt.close()


# ==============================================================================
# Demo 2: Representer Theorem in Action
# ==============================================================================

def demo_representer_theorem():
    """
    Show that the representer theorem reduces function-space optimization
    to coefficient-space optimization.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Representer Theorem — Optimization Reduction")
    print("=" * 70)

    n_points = 5
    train_indices = [0, 1, 2]

    # Use a Gaussian-like tropical kernel
    points = np.array([[0.0], [1.0], [2.0], [3.0], [4.0]])
    K = gaussian_tropical_kernel(points, sigma=1.5)

    print(f"\nPoints: {points.flatten()}")
    print(f"Training set indices: {train_indices}")
    print(f"\nGaussian tropical kernel K(z,x) = -||z-x||²/(2σ²), σ=1.5:")
    for i in range(n_points):
        row = [f"{K[i,j]:6.3f}" for j in range(n_points)]
        print(f"  K[{i},:] = [{', '.join(row)}]")

    # Training labels
    y_train = {0: 2.0, 1: -1.0, 2: 3.0}
    print(f"\nTraining labels: {y_train}")

    # Loss function: absolute deviation (in max-plus: just the value, but
    # for illustration we use |f(x) - y(x)|)
    def loss_fn(x, fx, yx):
        return abs(fx - yx)

    # Regularizer: max of absolute values (sup norm)
    def reg_fn(f):
        return max(abs(v) for v in f)

    # Search over coefficients
    print(f"\nSearching over coefficient space...")
    best_obj = np.inf
    best_coeffs = None
    n_grid = 30
    coeff_range = np.linspace(-5, 5, n_grid)

    results = []
    for c0 in coeff_range:
        for c1 in coeff_range:
            for c2 in coeff_range:
                coeffs = {0: c0, 1: c1, 2: c2}
                # Reconstruct function
                f = np.zeros(n_points)
                for z in range(n_points):
                    f[z] = max(K[z, x] + coeffs[x] for x in train_indices)

                obj = objective(train_indices, loss_fn, y_train, reg_fn, f)
                results.append((obj, [c0, c1, c2], f.copy()))
                if obj < best_obj:
                    best_obj = obj
                    best_coeffs = [c0, c1, c2]

    # Best result
    f_best = np.zeros(n_points)
    for z in range(n_points):
        f_best[z] = max(K[z, x] + best_coeffs[x] for x in train_indices)

    print(f"  Best coefficients: c = [{', '.join(f'{c:.3f}' for c in best_coeffs)}]")
    print(f"  Best objective value: {best_obj:.4f}")
    print(f"  Reconstructed function: [{', '.join(f'{v:.3f}' for v in f_best)}]")
    print(f"  Training values: {[f'{f_best[i]:.3f}' for i in train_indices]}")

    # Compare with a "general" function (not in span)
    print(f"\n  For comparison, an arbitrary function not in the span:")
    f_arb = np.array([2.0, -1.0, 3.0, 0.0, 0.0])  # matches training perfectly
    obj_arb = objective(train_indices, loss_fn, y_train, reg_fn, f_arb)
    print(f"    f_arb = {f_arb}")
    print(f"    objective(f_arb) = {obj_arb:.4f}")

    print(f"\n  KEY INSIGHT: The representer theorem guarantees that the span-minimizer")
    print(f"  achieves an objective ≤ any function's objective.")
    print(f"  Here: obj(span-min) = {best_obj:.4f} vs obj(f_arb) = {obj_arb:.4f}")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot the kernel matrix
    ax = axes[0]
    im = ax.imshow(K, cmap='viridis', aspect='equal')
    ax.set_title('Gaussian Tropical Kernel', fontsize=14)
    ax.set_xlabel('Column index')
    ax.set_ylabel('Row index')
    for i in range(n_points):
        for j in range(n_points):
            ax.text(j, i, f'{K[i,j]:.2f}', ha='center', va='center',
                    fontsize=9, color='white' if K[i,j] < -0.3 else 'black')
    plt.colorbar(im, ax=ax, label='K(z,x)')

    # Plot the span-optimal function
    ax = axes[1]
    x_all = np.arange(n_points)
    ax.bar(x_all - 0.15, f_best, 0.3, label='Span minimizer', alpha=0.7, color='steelblue')
    ax.bar(x_all + 0.15, f_arb, 0.3, label='Arbitrary f', alpha=0.7, color='salmon')
    for i in train_indices:
        ax.plot(i, y_train[i], 'k*', markersize=15, zorder=5,
                label='Training labels' if i == 0 else '')
    ax.set_xlabel('Point index', fontsize=12)
    ax.set_ylabel('Function value', fontsize=12)
    ax.set_title('Representer Theorem: Span vs Arbitrary', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo2_representer_theorem.png', dpi=150, bbox_inches='tight')
    print(f"\n→ Figure saved: demo2_representer_theorem.png")
    plt.close()


# ==============================================================================
# Demo 3: Dimensional Reduction Visualization
# ==============================================================================

def demo_dimensional_reduction():
    """
    Visualize how the representer theorem reduces the search space from
    all functions (|α|^|X| possibilities) to coefficients (|α|^|train|).
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Dimensional Reduction — From Functions to Coefficients")
    print("=" * 70)

    n_points = 4
    train_indices = [0, 1]

    points = np.array([[0.0], [1.0], [2.0], [3.0]])
    K = gaussian_tropical_kernel(points, sigma=1.0)

    y_train = {0: 1.0, 1: 2.0}

    def loss_fn(x, fx, yx):
        return abs(fx - yx)

    def reg_fn(f):
        return 0.1 * max(abs(v) for v in f)

    print(f"\n|X| = {n_points}, |train| = {len(train_indices)}")
    print(f"Full function space: ℝ^{n_points} (4-dimensional)")
    print(f"Coefficient space:   ℝ^{len(train_indices)} (2-dimensional)")
    print(f"\nThe representer theorem guarantees optimization over the")
    print(f"4-dimensional space can be reduced to the 2-dimensional space!")

    # Grid search in 2D coefficient space
    n_grid = 100
    c_range = np.linspace(-3, 5, n_grid)
    obj_grid = np.zeros((n_grid, n_grid))

    for i, c0 in enumerate(c_range):
        for j, c1 in enumerate(c_range):
            coeffs = {0: c0, 1: c1}
            f = np.zeros(n_points)
            for z in range(n_points):
                f[z] = max(K[z, x] + coeffs[x] for x in train_indices)
            obj_grid[j, i] = objective(train_indices, loss_fn, y_train, reg_fn, f)

    best_idx = np.unravel_index(np.argmin(obj_grid), obj_grid.shape)
    best_c = [c_range[best_idx[1]], c_range[best_idx[0]]]

    print(f"\nOptimal coefficients: c = ({best_c[0]:.3f}, {best_c[1]:.3f})")
    print(f"Optimal objective: {obj_grid[best_idx]:.4f}")

    # Visualization
    fig, ax = plt.subplots(figsize=(8, 7))
    extent = [c_range[0], c_range[-1], c_range[0], c_range[-1]]
    im = ax.imshow(obj_grid, extent=extent, origin='lower', cmap='hot_r',
                   aspect='equal')
    ax.plot(best_c[0], best_c[1], 'c*', markersize=20, label='Optimal',
            markeredgecolor='white', markeredgewidth=1.5)
    ax.set_xlabel('c₀ (coefficient for train point 0)', fontsize=13)
    ax.set_ylabel('c₁ (coefficient for train point 1)', fontsize=13)
    ax.set_title('Coefficient-Space Objective Landscape\n'
                 '(Representer theorem reduces 4D → 2D optimization)',
                 fontsize=14)
    ax.legend(fontsize=12, loc='upper right')
    plt.colorbar(im, ax=ax, label='Objective value', shrink=0.8)

    plt.tight_layout()
    plt.savefig('demo3_dimensional_reduction.png', dpi=150, bbox_inches='tight')
    print(f"\n→ Figure saved: demo3_dimensional_reduction.png")
    plt.close()


# ==============================================================================
# Demo 4: Tropical Kernel Regression on 1D Data
# ==============================================================================

def demo_tropical_regression():
    """
    Full tropical kernel regression pipeline on 1D synthetic data.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Tropical Kernel Regression on 1D Synthetic Data")
    print("=" * 70)

    # Generate data
    np.random.seed(42)
    n_train = 8
    n_test = 50
    x_train = np.sort(np.random.uniform(0, 10, n_train))
    y_values = np.sin(x_train) + 0.2 * np.random.randn(n_train)
    x_test = np.linspace(0, 10, n_test)

    # All points
    all_x = np.concatenate([x_train, x_test])
    n_all = len(all_x)
    train_indices = list(range(n_train))

    # Build kernel
    sigma = 1.5
    K = np.zeros((n_all, n_all))
    for i in range(n_all):
        for j in range(n_all):
            K[i, j] = -(all_x[i] - all_x[j])**2 / (2 * sigma**2)

    print(f"\nTraining points: {n_train}")
    print(f"Test points: {n_test}")
    print(f"Kernel: Gaussian tropical, σ = {sigma}")

    # Optimize coefficients by grid search (small-scale)
    # For illustration, use gradient-free optimization
    from scipy.optimize import minimize as scipy_minimize

    def coeff_objective(c):
        f = np.zeros(n_all)
        for z in range(n_all):
            f[z] = max(K[z, x] + c[x] for x in train_indices)
        # Empirical risk: max of squared losses on train
        emp = max(abs(f[x] - y_values[x]) for x in train_indices)
        # Regularizer: coefficient norm
        reg = 0.01 * max(abs(c[x]) for x in train_indices)
        return max(emp, reg)

    # Multiple random starts
    best_result = None
    for _ in range(20):
        c0 = np.random.randn(n_train)
        result = scipy_minimize(coeff_objective, c0, method='Nelder-Mead',
                                options={'maxiter': 5000, 'xatol': 1e-8})
        if best_result is None or result.fun < best_result.fun:
            best_result = result

    c_opt = best_result.x
    print(f"Optimal objective: {best_result.fun:.6f}")
    print(f"Optimal coefficients: [{', '.join(f'{c:.3f}' for c in c_opt)}]")

    # Reconstruct function
    f_opt = np.zeros(n_all)
    for z in range(n_all):
        f_opt[z] = max(K[z, x] + c_opt[x] for x in train_indices)

    # Visualization
    fig, axes = plt.subplots(2, 1, figsize=(12, 10))

    ax = axes[0]
    ax.plot(x_test, np.sin(x_test), 'g--', alpha=0.5, label='True function (sin)',
            linewidth=2)
    ax.plot(x_train, y_values, 'ro', markersize=10, label='Training data',
            zorder=5, markeredgecolor='black')
    ax.plot(x_test, f_opt[n_train:], 'b-', linewidth=2.5,
            label='Tropical kernel regression')
    ax.fill_between(x_test, f_opt[n_train:] - 0.3, f_opt[n_train:] + 0.3,
                    alpha=0.15, color='blue')
    ax.set_xlabel('x', fontsize=13)
    ax.set_ylabel('y', fontsize=13)
    ax.set_title('Tropical (Max-Plus) Kernel Regression', fontsize=15)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Show kernel sections
    ax = axes[1]
    colors = plt.cm.tab10(np.linspace(0, 1, n_train))
    for i, x_i in enumerate(train_indices):
        section = np.array([K[n_train + j, x_i] + c_opt[i] for j in range(n_test)])
        ax.plot(x_test, section, '--', color=colors[i], alpha=0.6,
                label=f'K(·,x_{i}) + c_{i}')
    ax.plot(x_test, f_opt[n_train:], 'k-', linewidth=2.5,
            label='Envelope (sup)')
    ax.set_xlabel('x', fontsize=13)
    ax.set_ylabel('y', fontsize=13)
    ax.set_title('Tropical Span Decomposition: f = sup of kernel sections',
                fontsize=14)
    ax.legend(fontsize=9, ncol=3)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo4_tropical_regression.png', dpi=150, bbox_inches='tight')
    print(f"\n→ Figure saved: demo4_tropical_regression.png")
    plt.close()


# ==============================================================================
# Main
# ==============================================================================

if __name__ == '__main__':
    demo_kronecker_interpolation()
    demo_representer_theorem()
    demo_dimensional_reduction()
    demo_tropical_regression()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
    print("""
Summary of the Idempotent Representer Theorem:
  1. In the max-plus semiring, "kernel regression" uses tropical spans:
     f(z) = max_{x ∈ train} (K(z,x) + c(x))
  2. The representer theorem guarantees that any minimizer of a regularized
     tropical empirical risk can be replaced by a span-supported function.
  3. This reduces infinite-dimensional optimization to |train|-dimensional
     coefficient optimization — a tropical linear program.
  4. For Kronecker kernels, exact interpolation is immediate.
  5. For smooth kernels (Gaussian tropical), the span provides a natural
     nonlinear regression model with piecewise-linear structure.
""")
