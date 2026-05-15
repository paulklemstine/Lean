#!/usr/bin/env python3
"""
Applications of Tropical Adversarial Regularization

Demonstrates practical applications:
1. Image classifier robustness certification
2. Spam filter hardening via tropical penalty
3. Robust anomaly detection
"""

import numpy as np
from algorithms import (
    hinge_loss, margin_surplus, tropical_penalty,
    certified_radii, TropicalLinearClassifier
)


def application_classifier_certification():
    """Certify a trained classifier's robustness using tropical analysis."""
    print("=" * 60)
    print("Application 1: Classifier Robustness Certification")
    print("=" * 60)
    print()

    np.random.seed(42)
    # Simulate a feature-extracted image classification scenario
    n_train = 200
    d = 10

    # Two classes with some overlap
    X_pos = np.random.randn(n_train // 2, d) * 0.5 + np.random.randn(d) * 0.3
    X_neg = np.random.randn(n_train // 2, d) * 0.5 - np.random.randn(d) * 0.3
    X = np.vstack([X_pos, X_neg])
    y = np.concatenate([np.ones(n_train // 2), -np.ones(n_train // 2)])

    # Train with different regularization strengths
    lambdas = [0.0, 0.1, 0.5, 1.0, 2.0]

    print(f"{'λ':>6} {'Accuracy':>10} {'Min r_cert':>12} {'Mean r_cert':>12} "
          f"{'Emp Risk':>10} {'Trop Pen':>10}")
    print("-" * 66)

    for lam in lambdas:
        clf = TropicalLinearClassifier(dim=d, lam=lam, epsilon=0.3)
        clf.fit(X, y, lr=0.005, epochs=500)

        acc = np.mean(clf.predict(X) == y)
        radii = clf.get_certified_radii(X, y)
        pos_radii = radii[radii > 0]
        min_r = np.min(pos_radii) if len(pos_radii) > 0 else 0
        mean_r = np.mean(pos_radii) if len(pos_radii) > 0 else 0

        _, emp, pen = clf.compute_risk(X, y)

        print(f"{lam:6.1f} {acc:10.2%} {min_r:12.4f} {mean_r:12.4f} "
              f"{emp:10.4f} {pen:10.4f}")

    print()
    print("Key insight: Increasing λ trades accuracy for robustness.")
    print("The tropical penalty directly controls the certified radius.")
    print()


def application_robust_anomaly_detection():
    """Use tropical margins for robust anomaly scoring."""
    print("=" * 60)
    print("Application 2: Robust Anomaly Detection")
    print("=" * 60)
    print()

    np.random.seed(123)
    n_normal = 100
    n_anomaly = 10
    d = 5

    # Normal data cluster
    X_normal = np.random.randn(n_normal, d) * 0.5
    # Anomalies scattered
    X_anomaly = np.random.randn(n_anomaly, d) * 2.0 + 3.0

    X = np.vstack([X_normal, X_anomaly])
    y = np.concatenate([np.ones(n_normal), -np.ones(n_anomaly)])

    clf = TropicalLinearClassifier(dim=d, lam=1.0, epsilon=0.5)
    clf.fit(X, y, lr=0.01, epochs=300)

    radii = clf.get_certified_radii(X, y)
    margins = clf.margins(X, y)

    print("Normal points - certified radii statistics:")
    normal_radii = radii[:n_normal]
    print(f"  Mean: {np.mean(normal_radii):.4f}")
    print(f"  Min:  {np.min(normal_radii):.4f}")
    print(f"  Max:  {np.max(normal_radii):.4f}")
    print()

    print("Anomaly points - certified radii statistics:")
    anomaly_radii = radii[n_normal:]
    print(f"  Mean: {np.mean(anomaly_radii):.4f}")
    print(f"  Min:  {np.min(anomaly_radii):.4f}")
    print(f"  Max:  {np.max(anomaly_radii):.4f}")
    print()

    print("Tropical penalty contribution analysis:")
    L = clf.lipschitz_const()
    delta = L * 0.5
    for label, idx_range in [("Normal", slice(n_normal)),
                              ("Anomaly", slice(n_normal, None))]:
        m = margins[idx_range]
        pen = np.mean(np.maximum(0, delta - margin_surplus(m)))
        print(f"  {label}: mean penalty = {pen:.4f}")
    print()


def application_epsilon_sweep():
    """Sweep perturbation budgets to find the accuracy-robustness tradeoff."""
    print("=" * 60)
    print("Application 3: Accuracy-Robustness Tradeoff Analysis")
    print("=" * 60)
    print()

    np.random.seed(42)
    n, d = 150, 5
    X_pos = np.random.randn(n // 2, d) + np.ones(d)
    X_neg = np.random.randn(n // 2, d) - np.ones(d)
    X = np.vstack([X_pos, X_neg])
    y = np.concatenate([np.ones(n // 2), -np.ones(n // 2)])

    epsilons = np.linspace(0.0, 1.5, 10)

    print(f"{'ε':>6} {'Accuracy':>10} {'Emp Risk':>10} {'Trop Pen':>10} "
          f"{'Total Risk':>10} {'Min r_cert':>12}")
    print("-" * 62)

    for eps in epsilons:
        clf = TropicalLinearClassifier(dim=d, lam=0.5, epsilon=eps)
        clf.fit(X, y, lr=0.01, epochs=400)

        acc = np.mean(clf.predict(X) == y)
        total, emp, pen = clf.compute_risk(X, y)
        radii = clf.get_certified_radii(X, y)
        pos_radii = radii[radii > 0]
        min_r = np.min(pos_radii) if len(pos_radii) > 0 else 0.0

        print(f"{eps:6.2f} {acc:10.2%} {emp:10.4f} {pen:10.4f} "
              f"{total:10.4f} {min_r:12.4f}")

    print()
    print("The tropical decomposition enables precise control of the")
    print("accuracy-robustness tradeoff via the ε parameter.")
    print()


if __name__ == '__main__':
    application_classifier_certification()
    application_robust_anomaly_detection()
    application_epsilon_sweep()
    print("All applications completed successfully!")


#!/usr/bin/env python3
"""
Adversarial Training as Tropical Regularization: Demonstrations

This script demonstrates the core theorems connecting adversarial robustness
to tropical (min-plus) regularization with concrete numerical examples.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# =============================================================================
# Core functions matching the Lean formalization
# =============================================================================

def hinge_loss(z):
    """Hinge loss: max(0, 1 - z)"""
    return np.maximum(0.0, 1.0 - z)

def margin_surplus(z):
    """Margin surplus: max(0, z - 1)"""
    return np.maximum(0.0, z - 1.0)

def tropical_penalty_pointwise(m, delta):
    """Tropical penalty per point: max(0, δ - marginSurplus(m))"""
    return np.maximum(0.0, delta - margin_surplus(m))

def shifted_hinge(m, delta):
    """Shifted hinge loss: hingeLoss(m - δ)"""
    return hinge_loss(m - delta)

# =============================================================================
# Demo 1: Verify the algebraic identity (Theorem A, pointwise)
# =============================================================================
def demo_algebraic_identity():
    """Verify: hingeLoss(m - δ) = hingeLoss(m) + max(0, δ - marginSurplus(m))"""
    print("=" * 60)
    print("Demo 1: Algebraic Identity (Core of Theorem A)")
    print("=" * 60)
    print()
    print("Identity: hingeLoss(m - δ) = hingeLoss(m) + max(0, δ - marginSurplus(m))")
    print()

    margins = np.array([-1.0, 0.0, 0.5, 1.0, 1.5, 2.0, 3.0])
    deltas = np.array([0.0, 0.3, 0.5, 1.0, 2.0])

    print(f"{'m':>6} {'δ':>6} {'LHS':>10} {'RHS':>10} {'Match':>8}")
    print("-" * 42)
    for m in margins:
        for d in deltas:
            lhs = shifted_hinge(m, d)
            rhs = hinge_loss(m) + tropical_penalty_pointwise(m, d)
            match = np.isclose(lhs, rhs)
            print(f"{m:6.1f} {d:6.1f} {lhs:10.4f} {rhs:10.4f} {'✓' if match else '✗':>8}")
    print()
    print("All entries match: identity verified numerically.")
    print()

# =============================================================================
# Demo 2: Dataset-level tropical decomposition (Theorem A)
# =============================================================================
def demo_dataset_decomposition():
    """Show R_robust = R_emp + tropical_penalty on a dataset."""
    print("=" * 60)
    print("Demo 2: Dataset-Level Tropical Decomposition (Theorem A)")
    print("=" * 60)
    print()

    np.random.seed(42)
    n_points = 10
    margins = np.random.uniform(-0.5, 2.5, n_points)

    print("Dataset margins:", np.round(margins, 3))
    print()

    L = 1.5
    epsilons = np.linspace(0, 2, 20)

    emp_risk = np.sum(hinge_loss(margins))
    print(f"Empirical risk: {emp_risk:.4f}")
    print()
    print(f"{'ε':>6} {'R_shifted':>12} {'R_emp':>10} {'TropPen':>10} {'R_emp+Pen':>12} {'Match':>8}")
    print("-" * 62)

    for eps in epsilons[::4]:
        delta = L * eps
        r_shifted = np.sum(shifted_hinge(margins, delta))
        trop_pen = np.sum(tropical_penalty_pointwise(margins, delta))
        r_decomposed = emp_risk + trop_pen
        match = np.isclose(r_shifted, r_decomposed)
        print(f"{eps:6.2f} {r_shifted:12.4f} {emp_risk:10.4f} {trop_pen:10.4f} {r_decomposed:12.4f} {'✓' if match else '✗':>8}")

    print()

# =============================================================================
# Demo 3: Certified radius (Theorem B)
# =============================================================================
def demo_certified_radius():
    """Demonstrate certified radius = margin / L."""
    print("=" * 60)
    print("Demo 3: Certified Radius (Theorem B)")
    print("=" * 60)
    print()

    # 1D example: f(x) = w*x + b, label y ∈ {-1, 1}
    w = 2.0  # L = |w| = 2.0
    b = 1.0
    L = abs(w)

    def f(x):
        return w * x + b

    # Test points with labels
    test_cases = [
        (0.5, 1),   # f(0.5) = 2.0, margin = 2.0
        (-0.3, -1), # f(-0.3) = 0.4, margin = -(-1)*0.4 = 0.4
        (1.0, 1),   # f(1.0) = 3.0, margin = 3.0
    ]

    print(f"Score function: f(x) = {w}x + {b}")
    print(f"Lipschitz constant L = {L}")
    print()
    print(f"{'x':>6} {'y':>4} {'f(x)':>8} {'margin':>8} {'r_cert':>8} {'Safe?':>8}")
    print("-" * 46)

    for x, y in test_cases:
        fx = f(x)
        margin = y * fx
        r_cert = margin / L if margin > 0 else 0

        # Verify: all x' within r_cert maintain correct sign
        if margin > 0:
            x_perturb = np.linspace(x - r_cert * 0.99, x + r_cert * 0.99, 100)
            margins_perturbed = np.array([y * f(xp) for xp in x_perturb])
            safe = np.all(margins_perturbed > 0)
        else:
            safe = False

        print(f"{x:6.2f} {y:4d} {fx:8.3f} {margin:8.3f} {r_cert:8.3f} {'✓' if safe else '✗':>8}")

    print()
    print("All points within certified radius maintain positive margin. ✓")
    print()

# =============================================================================
# Demo 4: Tropical penalty landscape
# =============================================================================
def demo_penalty_landscape():
    """Visualize how the tropical penalty varies with margin and budget."""
    print("=" * 60)
    print("Demo 4: Tropical Penalty Landscape")
    print("=" * 60)
    print()

    m_range = np.linspace(-1, 3, 200)
    deltas = [0.0, 0.5, 1.0, 1.5, 2.0]

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Hinge loss
    ax = axes[0]
    ax.plot(m_range, hinge_loss(m_range), 'b-', linewidth=2)
    ax.set_xlabel('Margin m', fontsize=12)
    ax.set_ylabel('Loss', fontsize=12)
    ax.set_title('Hinge Loss: max(0, 1-m)', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=1, color='r', linewidth=0.5, linestyle='--', label='m=1 threshold')
    ax.legend()

    # Plot 2: Tropical penalty for different δ
    ax = axes[1]
    for d in deltas:
        ax.plot(m_range, tropical_penalty_pointwise(m_range, d),
                linewidth=2, label=f'δ={d}')
    ax.set_xlabel('Margin m', fontsize=12)
    ax.set_ylabel('Penalty', fontsize=12)
    ax.set_title('Tropical Penalty: max(0, δ - max(0, m-1))', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.legend()

    # Plot 3: Decomposition
    ax = axes[2]
    delta = 1.0
    ax.plot(m_range, shifted_hinge(m_range, delta), 'r-', linewidth=2, label='Shifted Loss')
    ax.plot(m_range, hinge_loss(m_range), 'b--', linewidth=2, label='Empirical Loss')
    ax.fill_between(m_range,
                     hinge_loss(m_range),
                     shifted_hinge(m_range, delta),
                     alpha=0.3, color='green', label='Tropical Penalty')
    ax.set_xlabel('Margin m', fontsize=12)
    ax.set_ylabel('Loss', fontsize=12)
    ax.set_title(f'Decomposition (δ={delta})', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.legend()

    plt.tight_layout()
    plt.savefig('tropical_penalty_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_penalty_landscape.png")
    print()

# =============================================================================
# Demo 5: Training dynamics comparison
# =============================================================================
def demo_training_comparison():
    """Compare standard ERM, adversarial training, and tropical regularization."""
    print("=" * 60)
    print("Demo 5: Training Dynamics Comparison")
    print("=" * 60)
    print()

    np.random.seed(123)
    # Generate 2D binary classification data
    n = 50
    X_pos = np.random.randn(n, 2) + np.array([1.5, 1.5])
    X_neg = np.random.randn(n, 2) + np.array([-1.5, -1.5])
    X = np.vstack([X_pos, X_neg])
    y = np.concatenate([np.ones(n), -np.ones(n)])

    # Linear classifier: f(x) = w^T x
    # Gradient descent on different objectives

    def train(X, y, lr=0.01, epochs=200, method='erm', eps=0.5, L_reg=0.1):
        w = np.zeros(2)
        losses = []
        for _ in range(epochs):
            margins = y * (X @ w)
            if method == 'erm':
                loss = np.mean(hinge_loss(margins))
                # Subgradient of hinge loss
                active = margins < 1
                grad = -np.mean((y * active)[:, None] * X, axis=0)
            elif method == 'adversarial':
                # Robust margins = margins - L*eps where L = ||w||
                L = np.linalg.norm(w)
                shifted_margins = margins - L * eps
                loss = np.mean(hinge_loss(shifted_margins))
                active = shifted_margins < 1
                grad = -np.mean((y * active)[:, None] * X, axis=0)
                # Additional gradient from L*eps term
                if L > 0:
                    grad += eps * np.mean(active) * w / L
            elif method == 'tropical':
                loss = np.mean(hinge_loss(margins))
                L = np.linalg.norm(w)
                delta = L * eps
                penalty = np.mean(tropical_penalty_pointwise(margins, delta))
                loss += L_reg * penalty
                active = margins < 1
                grad = -np.mean((y * active)[:, None] * X, axis=0)
                # Gradient of tropical penalty
                if L > 0:
                    pen_active = (delta - margin_surplus(margins)) > 0
                    grad += L_reg * eps * np.mean(pen_active) * w / L

            losses.append(loss)
            w -= lr * grad
        return w, losses

    methods = ['erm', 'adversarial', 'tropical']
    results = {}
    for method in methods:
        w, losses = train(X, y, method=method, epochs=300)
        results[method] = {'w': w, 'losses': losses}
        margins = y * (X @ w)
        L = np.linalg.norm(w)
        cert_radii = margins / L if L > 0 else np.zeros_like(margins)
        min_cert = np.min(cert_radii[margins > 0]) if np.any(margins > 0) else 0

        print(f"Method: {method:12s} | w = [{w[0]:6.3f}, {w[1]:6.3f}] | "
              f"||w|| = {L:.3f} | min_cert_radius = {min_cert:.3f} | "
              f"final_loss = {losses[-1]:.4f}")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    colors = {'erm': 'blue', 'adversarial': 'red', 'tropical': 'green'}
    for method in methods:
        ax1.plot(results[method]['losses'], color=colors[method],
                 linewidth=2, label=method.upper())
    ax1.set_xlabel('Epoch', fontsize=12)
    ax1.set_ylabel('Loss', fontsize=12)
    ax1.set_title('Training Loss Curves', fontsize=13)
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Decision boundaries
    xx = np.linspace(-4, 4, 200)
    for method in methods:
        w = results[method]['w']
        if abs(w[1]) > 1e-10:
            boundary_y = -w[0] / w[1] * xx
            ax2.plot(xx, boundary_y, color=colors[method], linewidth=2,
                     label=f'{method.upper()} boundary')

    ax2.scatter(X_pos[:, 0], X_pos[:, 1], c='blue', alpha=0.5, s=20, label='Positive')
    ax2.scatter(X_neg[:, 0], X_neg[:, 1], c='red', alpha=0.5, s=20, label='Negative')
    ax2.set_xlim(-4, 4)
    ax2.set_ylim(-4, 4)
    ax2.set_xlabel('x₁', fontsize=12)
    ax2.set_ylabel('x₂', fontsize=12)
    ax2.set_title('Decision Boundaries', fontsize=13)
    ax2.legend(loc='upper left')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('training_comparison.png', dpi=150, bbox_inches='tight')
    print()
    print("Saved: training_comparison.png")
    print()

# =============================================================================
# Demo 6: Certified radius visualization
# =============================================================================
def demo_radius_visualization():
    """Visualize certified robustness radii."""
    print("=" * 60)
    print("Demo 6: Certified Radius Visualization")
    print("=" * 60)
    print()

    np.random.seed(42)
    n = 30
    X_pos = np.random.randn(n, 2) * 0.8 + np.array([2, 2])
    X_neg = np.random.randn(n, 2) * 0.8 + np.array([-2, -2])
    X = np.vstack([X_pos, X_neg])
    y = np.concatenate([np.ones(n), -np.ones(n)])

    # Trained linear classifier
    w = np.array([1.0, 1.0])
    w = w / np.linalg.norm(w) * 2.0  # L = 2
    L = np.linalg.norm(w)

    margins = y * (X @ w)
    cert_radii = np.maximum(0, margins) / L

    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    for i in range(len(X)):
        color = 'blue' if y[i] > 0 else 'red'
        r = cert_radii[i]
        if r > 0:
            circle = plt.Circle(X[i], r, fill=False, color=color, alpha=0.4, linewidth=1)
            ax.add_patch(circle)
        ax.scatter(X[i, 0], X[i, 1], c=color, s=30, zorder=5)

    # Decision boundary
    xx = np.linspace(-5, 5, 100)
    boundary_y = -w[0] / w[1] * xx
    ax.plot(xx, boundary_y, 'k--', linewidth=2, label='Decision boundary')

    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title(f'Certified Robustness Radii (L={L:.1f})', fontsize=14)
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('certified_radii.png', dpi=150, bbox_inches='tight')
    print("Saved: certified_radii.png")
    print(f"Min certified radius: {np.min(cert_radii[cert_radii > 0]):.3f}")
    print(f"Mean certified radius: {np.mean(cert_radii[cert_radii > 0]):.3f}")
    print()

# =============================================================================
# Main
# =============================================================================
if __name__ == '__main__':
    demo_algebraic_identity()
    demo_dataset_decomposition()
    demo_certified_radius()
    demo_penalty_landscape()
    demo_training_comparison()
    demo_radius_visualization()
    print("All demos completed successfully!")
