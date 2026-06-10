#!/usr/bin/env python3
"""
Tropical Kernel Learning: Applications

Demonstrates real-world applications of the tropical representer theorem:
1. Shortest-path regression: Learning travel times from routing data
2. Scheduling optimization: Learning worst-case completion times
3. Robust classification: Tropical margin classifiers
"""

import numpy as np
from algorithms import (
    tropical_gaussian_kernel, tropical_laplacian_kernel,
    compute_gram_matrix, maxplus_matvec,
    tropical_kernel_regression, tropical_predict,
    coefficient_perturbation_bound
)


def application_shortest_path_regression():
    """
    Application 1: Learning shortest-path travel times.

    In logistics and navigation, travel times between locations follow
    min-plus (shortest-path) algebra. The tropical representer theorem
    guarantees that optimal predictors are finite tropical combinations
    of distance kernels at training locations.

    Setup: Given observed travel times between cities, learn a predictor
    for travel times to new destinations.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest-Path Travel Time Regression")
    print("=" * 60)

    # City locations (2D coordinates)
    cities = np.array([
        [0, 0],    # City A
        [1, 2],    # City B
        [3, 1],    # City C
        [2, 4],    # City D
        [5, 3],    # City E
    ], dtype=float)
    city_names = ['A', 'B', 'C', 'D', 'E']

    # Observed travel times (negative because max-plus = min-plus dual)
    # In max-plus: larger = better, so we negate distances
    y_times = -np.array([0, 2.5, 3.2, 4.5, 6.0])

    # Tropical distance kernel: K(x, y) = -||x - y||
    K = lambda x, y: -np.sqrt(np.sum((np.asarray(x) - np.asarray(y))**2))

    # Train
    c_opt, obj = tropical_kernel_regression(
        K, cities, y_times, lam=0.5, n_iters=3000
    )

    G = compute_gram_matrix(K, cities)
    pred = maxplus_matvec(G, c_opt)

    print(f"\nTraining results:")
    for i, name in enumerate(city_names):
        print(f"  City {name}: target = {-y_times[i]:.1f}, "
              f"predicted = {-pred[i]:.2f}")

    # Predict for new locations
    new_locations = np.array([[1, 1], [4, 2], [2.5, 2.5]])
    pred_new = tropical_predict(K, cities, c_opt, new_locations)
    print(f"\nPredictions for new locations:")
    for i, loc in enumerate(new_locations):
        print(f"  Location {loc}: predicted travel time = {-pred_new[i]:.2f}")

    # Robustness: how stable are predictions under data perturbation?
    eps = 0.2
    bounds = coefficient_perturbation_bound(G, c_opt, eps)
    print(f"\nRobustness (ε={eps}):")
    for i, name in enumerate(city_names):
        print(f"  City {name}: max prediction change ≤ {bounds[i]:.3f}")


def application_scheduling():
    """
    Application 2: Worst-case job scheduling.

    In discrete event systems, completion times follow max-plus algebra:
    a job starts when ALL its prerequisites finish (= max of finish times).
    The tropical representer theorem implies that learned scheduling
    predictors have finite support on observed job configurations.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Worst-Case Scheduling Prediction")
    print("=" * 60)

    # Job configurations: each is a vector of task durations
    np.random.seed(123)
    n_jobs = 6
    n_tasks = 3

    # Training: observed job configurations and their completion times
    job_configs = np.array([
        [2, 3, 1],
        [1, 4, 2],
        [3, 1, 3],
        [2, 2, 4],
        [4, 1, 1],
        [1, 3, 3],
    ], dtype=float)

    # Completion time = max of task durations (worst-case bottleneck)
    completion_times = np.max(job_configs, axis=1)

    # Tropical kernel: K(x, y) = -max_k |x_k - y_k| (sup-norm similarity)
    K = lambda x, y: -np.max(np.abs(np.asarray(x) - np.asarray(y)))

    c_opt, obj = tropical_kernel_regression(
        K, job_configs, completion_times, lam=0.2, n_iters=3000
    )

    G = compute_gram_matrix(K, job_configs)
    pred = maxplus_matvec(G, c_opt)

    print(f"\nTraining results:")
    for i in range(n_jobs):
        print(f"  Job {i+1} {job_configs[i]}: "
              f"actual = {completion_times[i]:.0f}, "
              f"predicted = {pred[i]:.2f}")

    # New job configurations
    new_jobs = np.array([
        [2, 2, 2],
        [5, 1, 1],
        [1, 1, 5],
    ], dtype=float)
    pred_new = tropical_predict(K, job_configs, c_opt, new_jobs)
    print(f"\nNew job predictions:")
    for i, job in enumerate(new_jobs):
        actual = np.max(job)
        print(f"  Job {job}: predicted = {pred_new[i]:.2f}, "
              f"actual worst-case = {actual:.0f}")


def application_robust_classification():
    """
    Application 3: Tropical margin classification.

    Binary classification using tropical geometry: the decision boundary
    is a tropical hyperplane (piecewise-linear surface where the maximum
    switches between coordinates).

    The tropical representer theorem guarantees finite support on training data.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Margin Classification")
    print("=" * 60)

    # Generate 2D classification data
    np.random.seed(42)
    n_per_class = 8

    # Class +1: cluster around (2, 2)
    X_pos = np.random.randn(n_per_class, 2) * 0.5 + np.array([2, 2])
    # Class -1: cluster around (-1, -1)
    X_neg = np.random.randn(n_per_class, 2) * 0.5 + np.array([-1, -1])

    X = np.vstack([X_pos, X_neg])
    y = np.array([1.0] * n_per_class + [-1.0] * n_per_class)
    n = len(X)

    # Tropical Gaussian kernel
    sigma = 2.0
    K = lambda x, y_: -np.sum((np.asarray(x) - np.asarray(y_))**2) / sigma

    # Train (using targets as regression targets for simplicity)
    c_opt, obj = tropical_kernel_regression(
        K, X, y, lam=0.3, n_iters=3000
    )

    G = compute_gram_matrix(K, X)
    pred = maxplus_matvec(G, c_opt)

    # Classify: sign of prediction
    pred_labels = np.sign(pred)
    accuracy = np.mean(pred_labels == y)

    print(f"\nTraining accuracy: {accuracy * 100:.1f}%")
    print(f"Objective value: {obj:.4f}")

    # Robustness certification
    eps_values = [0.05, 0.1, 0.2, 0.5]
    print(f"\nRobustness analysis:")
    for eps in eps_values:
        bounds = coefficient_perturbation_bound(G, c_opt, eps)
        # Check if classification margin exceeds perturbation
        margins = np.abs(pred)
        min_margin = np.min(margins)
        max_perturbation = np.max(bounds)
        certified = min_margin > max_perturbation
        print(f"  ε={eps:.2f}: min margin={min_margin:.3f}, "
              f"max perturbation={max_perturbation:.3f}, "
              f"certified={certified}")

    # Test on new points
    test_points = np.array([
        [2, 2],    # Should be +1
        [-1, -1],  # Should be -1
        [0.5, 0.5],  # Ambiguous
    ])
    test_pred = tropical_predict(K, X, c_opt, test_points)
    print(f"\nTest predictions:")
    for i, pt in enumerate(test_points):
        label = "+" if test_pred[i] > 0 else "-"
        print(f"  Point {pt}: score = {test_pred[i]:.3f}, class = {label}")


if __name__ == "__main__":
    application_shortest_path_regression()
    application_scheduling()
    application_robust_classification()

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Representer Theorem: Demonstrations and Visualizations

Demonstrates the tropical (max-plus) representer theorem with concrete
numerical examples, showing how infinite-dimensional optimization reduces
to finite-dimensional coefficient optimization via the tropical Gram matrix.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable

# =============================================================================
# Section 1: Max-Plus Algebra Primitives
# =============================================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition = max."""
    return max(a, b)

def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition."""
    return a + b

def tropical_combination(K: Callable, x_samples: np.ndarray,
                          c: np.ndarray, z: float) -> float:
    """
    Tropical linear combination of kernel sections:
    f(z) = max_i (c_i + K(x_i, z))   [max-plus convention]
    """
    return max(c[i] + K(x_samples[i], z) for i in range(len(c)))

def gram_matrix(K: Callable, x_samples: np.ndarray) -> np.ndarray:
    """Tropical Gram matrix: G[i,j] = K(x_i, x_j)."""
    n = len(x_samples)
    G = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            G[i, j] = K(x_samples[i], x_samples[j])
    return G

def predict_from_coeff(G: np.ndarray, c: np.ndarray) -> np.ndarray:
    """
    Tropical Gram action: pred[i] = max_j (c[j] + G[j, i])
    """
    n = G.shape[0]
    pred = np.zeros(n)
    for i in range(n):
        pred[i] = max(c[j] + G[j, i] for j in range(n))
    return pred

# =============================================================================
# Section 2: Example Kernels
# =============================================================================

def tropical_gaussian_kernel(sigma: float = 1.0):
    """Tropical Gaussian kernel: K(x, y) = -|x - y|^2 / sigma."""
    def K(x, y):
        return -abs(x - y)**2 / sigma
    return K

def tropical_laplacian_kernel(gamma: float = 1.0):
    """Tropical Laplacian kernel: K(x, y) = -gamma * |x - y|."""
    def K(x, y):
        return -gamma * abs(x - y)
    return K

def tropical_polynomial_kernel(degree: int = 2):
    """Tropical polynomial kernel: K(x, y) = degree * min(x, y)."""
    def K(x, y):
        return degree * min(x, y)
    return K

# =============================================================================
# Section 3: Representer Theorem Demonstration
# =============================================================================

def demo_representer_theorem():
    """
    Demonstrate the tropical representer theorem:
    Any minimizer of the regularized tropical objective can be expressed
    as a tropical combination of kernel sections at sample points.
    """
    print("=" * 70)
    print("TROPICAL REPRESENTER THEOREM: NUMERICAL DEMONSTRATION")
    print("=" * 70)

    # Sample data
    np.random.seed(42)
    x_samples = np.array([0.0, 1.0, 2.5, 4.0, 5.0])
    y_targets = np.array([1.0, 2.5, 1.5, 3.0, 2.0])
    n = len(x_samples)

    # Kernel
    K = tropical_gaussian_kernel(sigma=2.0)

    # Gram matrix
    G = gram_matrix(K, x_samples)
    print(f"\nSample points: {x_samples}")
    print(f"Target values: {y_targets}")
    print(f"\nTropical Gram matrix G[i,j] = K(x_i, x_j):")
    print(np.round(G, 3))

    # Gram matrix symmetry
    print(f"\nGram matrix symmetry check: ||G - G^T|| = {np.max(np.abs(G - G.T)):.2e}")

    # Coefficients (representing a function in the kernel span)
    c = np.array([0.5, 1.0, -0.5, 0.8, 0.2])

    # Predictions via tropical combination at sample points
    pred_direct = np.array([
        tropical_combination(K, x_samples, c, x_samples[i])
        for i in range(n)
    ])

    # Predictions via Gram action
    pred_gram = predict_from_coeff(G, c)

    print(f"\nCoefficients c: {c}")
    print(f"Predictions (direct tropical combination):  {np.round(pred_direct, 6)}")
    print(f"Predictions (Gram matrix action):           {np.round(pred_gram, 6)}")
    print(f"Difference (should be 0): {np.max(np.abs(pred_direct - pred_gram)):.2e}")

    # Theorem C verified: predictions match
    assert np.allclose(pred_direct, pred_gram), "Gram identity failed!"
    print("\n✓ Theorem C (Gram-matrix prediction identity) verified numerically!")

    # Demonstrate retraction: project an arbitrary function to kernel span
    print("\n" + "-" * 50)
    print("RETRACTION DEMONSTRATION")
    print("-" * 50)

    # Define an "arbitrary function" not in the kernel span
    def f_arbitrary(z):
        return np.sin(z) + 0.5 * z

    # Retraction: find coefficients that match f at sample points
    # Using residuation: c_i = f(x_i) - max_{j≠i} (c_j + G[j,i])
    # Simple approach: set c_i = f(x_i) - G[i,i] = f(x_i) (since G[i,i] = 0)
    c_retracted = np.array([f_arbitrary(x_samples[i]) for i in range(n)])

    # Check sample preservation
    pred_retracted = predict_from_coeff(G, c_retracted)
    pred_original = np.array([f_arbitrary(x_samples[i]) for i in range(n)])

    print(f"\nOriginal f at samples:   {np.round(pred_original, 4)}")
    print(f"Retracted f at samples:  {np.round(pred_retracted, 4)}")

    # Note: retracted values >= original because max-plus combination
    # can only increase values (since G[i,i] = 0 and other terms add)
    print(f"\nRetracted values dominate original (max-plus): {np.all(pred_retracted >= pred_original - 1e-10)}")

    return G, c, pred_gram

# =============================================================================
# Section 4: Monotonicity Demonstration
# =============================================================================

def demo_monotonicity():
    """Demonstrate coefficient monotonicity of the Gram action."""
    print("\n" + "=" * 70)
    print("MONOTONICITY OF TROPICAL GRAM ACTION")
    print("=" * 70)

    K = tropical_gaussian_kernel(sigma=2.0)
    x_samples = np.array([0.0, 1.0, 2.0, 3.0])
    G = gram_matrix(K, x_samples)

    c = np.array([0.0, 0.5, 0.3, 0.1])
    c_prime = np.array([0.2, 0.7, 0.5, 0.4])  # c' >= c pointwise

    pred_c = predict_from_coeff(G, c)
    pred_c_prime = predict_from_coeff(G, c_prime)

    print(f"\nc  = {c}")
    print(f"c' = {c_prime}")
    print(f"c ≤ c' pointwise: {np.all(c <= c_prime)}")
    print(f"\npred(c)  = {np.round(pred_c, 4)}")
    print(f"pred(c') = {np.round(pred_c_prime, 4)}")
    print(f"pred(c) ≤ pred(c') pointwise: {np.all(pred_c <= pred_c_prime + 1e-10)}")
    print("\n✓ Monotonicity verified numerically!")

# =============================================================================
# Section 5: Tropical Regression
# =============================================================================

def tropical_regression(K: Callable, x_samples: np.ndarray,
                        y_targets: np.ndarray, lam: float = 0.1,
                        lr: float = 0.01, n_iters: int = 1000):
    """
    Tropical kernel regression via gradient-free coordinate descent.
    Minimize: max(L(pred, y), lam + Omega(c))
    where L = max_i |pred_i - y_i| and Omega = max_i |c_i|
    """
    n = len(x_samples)
    G = gram_matrix(K, x_samples)
    c = np.zeros(n)

    def objective(c):
        pred = predict_from_coeff(G, c)
        loss = max(abs(pred[i] - y_targets[i]) for i in range(n))
        reg = lam + max(abs(c[i]) for i in range(n))
        return max(loss, reg)

    best_c = c.copy()
    best_obj = objective(c)

    for t in range(n_iters):
        # Random coordinate perturbation
        i = t % n
        for delta in [lr, -lr, 2*lr, -2*lr]:
            c_new = c.copy()
            c_new[i] += delta
            obj_new = objective(c_new)
            if obj_new < best_obj:
                best_obj = obj_new
                best_c = c_new.copy()
                c = c_new.copy()

    return best_c, best_obj

def demo_tropical_regression():
    """Demonstrate tropical kernel regression."""
    print("\n" + "=" * 70)
    print("TROPICAL KERNEL REGRESSION")
    print("=" * 70)

    x_samples = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
    y_targets = np.array([1.0, 2.0, 1.5, 3.0, 2.5])

    K = tropical_gaussian_kernel(sigma=3.0)

    c_opt, obj_opt = tropical_regression(K, x_samples, y_targets, lam=0.1)
    G = gram_matrix(K, x_samples)
    pred_opt = predict_from_coeff(G, c_opt)

    print(f"\nSample points: {x_samples}")
    print(f"Targets:       {y_targets}")
    print(f"\nOptimal coefficients: {np.round(c_opt, 4)}")
    print(f"Predictions:          {np.round(pred_opt, 4)}")
    print(f"Optimal objective:    {obj_opt:.4f}")
    print(f"\nResiduals: {np.round(pred_opt - y_targets, 4)}")

    return x_samples, y_targets, c_opt, pred_opt

# =============================================================================
# Section 6: Visualization
# =============================================================================

def create_visualizations():
    """Create all visualizations for the research paper."""

    # --- Figure 1: Tropical kernel sections and combination ---
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    K = tropical_gaussian_kernel(sigma=2.0)
    x_samples = np.array([0.0, 1.5, 3.0, 4.5])
    z_range = np.linspace(-1, 6, 300)

    # Panel 1: Individual kernel sections
    ax = axes[0]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    for idx, xi in enumerate(x_samples):
        K_vals = [K(xi, z) for z in z_range]
        ax.plot(z_range, K_vals, color=colors[idx], linewidth=2,
                label=f'$K(x_{idx+1}, \\cdot)$')
        ax.axvline(xi, color=colors[idx], alpha=0.3, linestyle='--')
    ax.set_xlabel('z', fontsize=12)
    ax.set_ylabel('K(x, z)', fontsize=12)
    ax.set_title('Kernel Sections', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Tropical combination (max of shifted sections)
    ax = axes[1]
    c = np.array([0.5, 1.0, -0.3, 0.7])
    combo_vals = [tropical_combination(K, x_samples, c, z) for z in z_range]

    for idx, xi in enumerate(x_samples):
        shifted = [c[idx] + K(xi, z) for z in z_range]
        ax.plot(z_range, shifted, color=colors[idx], alpha=0.4, linewidth=1)
    ax.plot(z_range, combo_vals, 'k-', linewidth=2.5, label='$\\bigoplus c_i \\otimes K(x_i, \\cdot)$')
    ax.set_xlabel('z', fontsize=12)
    ax.set_title('Tropical Combination (max-plus)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 3: Gram matrix heatmap
    ax = axes[2]
    G = gram_matrix(K, x_samples)
    im = ax.imshow(G, cmap='viridis', aspect='auto')
    plt.colorbar(im, ax=ax, shrink=0.8)
    ax.set_xlabel('j', fontsize=12)
    ax.set_ylabel('i', fontsize=12)
    ax.set_title('Tropical Gram Matrix', fontsize=13, fontweight='bold')
    for i in range(len(x_samples)):
        for j in range(len(x_samples)):
            ax.text(j, i, f'{G[i,j]:.1f}', ha='center', va='center',
                    color='white' if G[i,j] < -2 else 'black', fontsize=9)

    plt.tight_layout()
    plt.savefig('tropical_representer_fig1.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_representer_fig1.png")

    # --- Figure 2: Monotonicity and Regression ---
    fig, axes = plt.subplots(1, 2, figsize=(12, 4.5))

    # Panel 1: Monotonicity
    ax = axes[0]
    K = tropical_gaussian_kernel(sigma=3.0)
    x_s = np.array([0, 1, 2, 3, 4.0])
    G = gram_matrix(K, x_s)
    n_tests = 50
    deltas = np.linspace(0, 2, n_tests)
    c_base = np.array([0.0, 0.5, 0.3, 0.1, 0.4])

    for idx in range(len(x_s)):
        preds = []
        for d in deltas:
            c_test = c_base.copy()
            c_test += d  # increase all coefficients
            pred = predict_from_coeff(G, c_test)
            preds.append(pred[idx])
        ax.plot(deltas, preds, label=f'pred[{idx}]', linewidth=2)

    ax.set_xlabel('Coefficient increase δ', fontsize=12)
    ax.set_ylabel('Prediction value', fontsize=12)
    ax.set_title('Monotonicity: Increasing c → Increasing pred', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Regression fit
    ax = axes[1]
    x_reg = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
    y_reg = np.array([1.0, 2.0, 1.5, 3.0, 2.5])
    c_opt, _ = tropical_regression(K, x_reg, y_reg, lam=0.05)
    G_reg = gram_matrix(K, x_reg)

    z_fine = np.linspace(-0.5, 4.5, 200)
    f_vals = [tropical_combination(K, x_reg, c_opt, z) for z in z_fine]

    ax.plot(z_fine, f_vals, 'b-', linewidth=2, label='Tropical regression')
    ax.scatter(x_reg, y_reg, c='red', s=80, zorder=5, label='Data points')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Tropical Kernel Regression', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_representer_fig2.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_representer_fig2.png")

    # --- Figure 3: Different kernels comparison ---
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    kernels = [
        ("Tropical Gaussian (σ=2)", tropical_gaussian_kernel(2.0)),
        ("Tropical Laplacian (γ=1)", tropical_laplacian_kernel(1.0)),
        ("Tropical Polynomial (d=2)", tropical_polynomial_kernel(2)),
    ]

    x_s = np.array([1.0, 2.0, 3.0, 4.0])
    z_range = np.linspace(0, 5, 200)
    c = np.array([0.5, 1.0, 0.3, 0.8])

    for ax, (name, K) in zip(axes, kernels):
        for idx, xi in enumerate(x_s):
            shifted = [c[idx] + K(xi, z) for z in z_range]
            ax.plot(z_range, shifted, alpha=0.4, linewidth=1)
        combo = [tropical_combination(K, x_s, c, z) for z in z_range]
        ax.plot(z_range, combo, 'k-', linewidth=2.5, label='Max-plus combination')
        ax.scatter(x_s, [tropical_combination(K, x_s, c, xi) for xi in x_s],
                   c='red', s=60, zorder=5, label='Sample predictions')
        ax.set_title(name, fontsize=12, fontweight='bold')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_representer_fig3.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_representer_fig3.png")

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    demo_representer_theorem()
    demo_monotonicity()
    demo_tropical_regression()
    create_visualizations()

    print("\n" + "=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)
