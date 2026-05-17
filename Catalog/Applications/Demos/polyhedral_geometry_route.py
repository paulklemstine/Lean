#!/usr/bin/env python3
"""
Applications of Tropical Polyhedral Robustness

Demonstrates real-world applications:
1. Adversarial robustness certification for a simple classifier
2. Comparison of polyhedral vs Lipschitz certificates across a dataset
3. Robustness heatmap for visualization
4. Label stability under perturbation channels
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import TropicalClassifier, AffineForm, batch_certify


def application_adversarial_robustness():
    """Application 1: Adversarial robustness certification.

    Simulates a 4-class image classifier where each class is defined
    by a linear score function (as in the last layer of a neural network).
    """
    print("=" * 60)
    print("APPLICATION 1: Adversarial Robustness Certification")
    print("=" * 60)

    np.random.seed(42)

    # Simulate a 4-class classifier in ℝ¹⁰ (e.g., final layer of a network)
    n_classes = 4
    dim = 10
    W = np.random.randn(n_classes, dim) * 0.5
    bias = np.random.randn(n_classes) * 0.1

    classifier = TropicalClassifier(
        forms=[AffineForm(a=W[i], b=float(bias[i])) for i in range(n_classes)]
    )

    # Generate test "images" (feature vectors)
    n_test = 500
    test_points = np.random.randn(n_test, dim)

    # Certify each point
    radii_poly = batch_certify(classifier, test_points)
    radii_lip = np.array([classifier.lipschitz_certificate(x) for x in test_points])

    # Statistics
    print(f"  Classifier: {n_classes} classes in ℝ^{dim}")
    print(f"  Test points: {n_test}")
    print(f"\n  Polyhedral certificates:")
    print(f"    Mean radius: {np.mean(radii_poly):.4f}")
    print(f"    Median radius: {np.median(radii_poly):.4f}")
    print(f"    % certified at ε=0.1: {100*np.mean(radii_poly > 0.1):.1f}%")
    print(f"\n  Lipschitz certificates:")
    print(f"    Mean radius: {np.mean(radii_lip):.4f}")
    print(f"    Median radius: {np.median(radii_lip):.4f}")
    print(f"    % certified at ε=0.1: {100*np.mean(radii_lip > 0.1):.1f}%")
    print(f"\n  Average improvement: {np.mean(radii_poly / np.maximum(radii_lip, 1e-10)):.2f}×")
    print()

    return radii_poly, radii_lip


def application_robustness_heatmap():
    """Application 2: Robustness heatmap.

    Creates a spatial map of certified robustness radii,
    showing which regions of input space are most/least robust.
    """
    print("=" * 60)
    print("APPLICATION 2: Robustness Heatmap")
    print("=" * 60)

    classifier = TropicalClassifier(forms=[
        AffineForm(a=np.array([2.0, 1.0]), b=0.0),
        AffineForm(a=np.array([-1.0, 2.0]), b=1.0),
        AffineForm(a=np.array([0.0, -1.0]), b=3.0),
    ])

    # Create grid
    x_range = np.linspace(-3, 5, 200)
    y_range = np.linspace(-3, 5, 200)
    X, Y = np.meshgrid(x_range, y_range)

    R = np.zeros_like(X)
    Z = np.zeros_like(X)
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            pt = np.array([X[i, j], Y[i, j]])
            k = classifier.classify(pt)
            Z[i, j] = k
            R[i, j] = classifier.certified_radius(pt, k)

    # Cap for visualization
    R_capped = np.minimum(R, 3.0)

    fig, ax = plt.subplots(figsize=(8, 7))
    im = ax.pcolormesh(X, Y, R_capped, cmap='viridis', shading='auto')
    ax.contour(X, Y, Z, levels=[0.5, 1.5], colors='white', linewidths=2)
    plt.colorbar(im, label='Certified Radius', ax=ax)
    ax.set_title('Robustness Heatmap: Certified Radius Across Input Space', fontsize=13)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    plt.tight_layout()
    plt.savefig('/workspace/request-project/robustness_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: robustness_heatmap.png")
    print(f"  Max certified radius: {np.max(R_capped):.2f}")
    print(f"  Points near boundary (r < 0.1): {np.sum(R < 0.1)} / {R.size}")
    print()


def application_label_stability():
    """Application 3: Label stability under perturbation.

    Demonstrates that within the certified radius, label is invariant,
    and quantifies the probability of label change for random perturbations.
    """
    print("=" * 60)
    print("APPLICATION 3: Label Stability Under Perturbation")
    print("=" * 60)

    classifier = TropicalClassifier(forms=[
        AffineForm(a=np.array([2.0, 1.0]), b=0.0),
        AffineForm(a=np.array([-1.0, 2.0]), b=1.0),
        AffineForm(a=np.array([0.0, -1.0]), b=3.0),
    ])

    x = np.array([2.0, 0.5])
    k = classifier.classify(x)
    r = classifier.certified_radius(x, k)

    epsilons = np.linspace(0, 2 * r, 50)
    flip_probs = []

    np.random.seed(42)
    n_samples = 2000

    for eps in epsilons:
        flips = 0
        for _ in range(n_samples):
            direction = np.random.randn(2)
            direction /= np.linalg.norm(direction)
            y = x + eps * direction
            if classifier.classify(y) != k:
                flips += 1
        flip_probs.append(flips / n_samples)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(epsilons / r, flip_probs, 'b-', linewidth=2)
    ax.axvline(x=1.0, color='r', linestyle='--', linewidth=2, label='Certified radius')
    ax.fill_between(epsilons / r, 0, 1, where=np.array(epsilons) <= r,
                    alpha=0.15, color='green', label='Certified safe zone')
    ax.set_xlabel('Perturbation magnitude / Certified radius', fontsize=12)
    ax.set_ylabel('Probability of label change', fontsize=12)
    ax.set_title('Label Stability: Certified vs Empirical', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/label_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: label_stability.png")
    print(f"  Certified radius: {r:.4f}")
    print(f"  Label changes within certified radius: {sum(1 for e, p in zip(epsilons, flip_probs) if e <= r and p > 0)}")
    print()


if __name__ == "__main__":
    application_adversarial_robustness()
    application_robustness_heatmap()
    application_label_stability()
    print("\nAll applications completed successfully!")


#!/usr/bin/env python3
"""
Demonstration of Tropical Polyhedral Robustness Certificates

This script illustrates the core theorems:
1. Distance from a point to an affine hyperplane = |⟨u,x⟩ - c| / ‖u‖
2. Tropical cells as intersections of halfspaces (convex, closed)
3. Certified robustness radius = minimum normalized margin

We show concrete numerical examples in ℝ² with 3-class tropical classifiers.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.collections import LineCollection


def affine_score(a, b, x):
    """Compute affine score ℓ_i(x) = a_i · x + b_i"""
    return np.dot(a, x) + b


def tropical_max(A, B, x):
    """Compute f(x) = max_i (a_i · x + b_i) and the winning index"""
    scores = np.array([affine_score(A[i], B[i], x) for i in range(len(A))])
    return np.max(scores), np.argmax(scores)


def normalized_margin(A, B, k, j, x):
    """Compute (ℓ_k(x) - ℓ_j(x)) / ‖a_k - a_j‖"""
    gap = affine_score(A[k], B[k], x) - affine_score(A[j], B[j], x)
    normal = np.linalg.norm(A[k] - A[j])
    if normal < 1e-12:
        return float('inf') if gap >= 0 else float('-inf')
    return gap / normal


def certified_radius(A, B, k, x):
    """Compute the certified robustness radius = min_{j≠k} normalized_margin(k, j, x)"""
    n_classes = len(A)
    margins = []
    for j in range(n_classes):
        if j != k:
            m = normalized_margin(A, B, k, j, x)
            margins.append(m)
    return min(margins) if margins else float('inf')


def dist_to_hyperplane(u, c, x):
    """Distance from x to {y : ⟨u, y⟩ = c} = |⟨u,x⟩ - c| / ‖u‖"""
    return abs(np.dot(u, x) - c) / np.linalg.norm(u)


def demo_hyperplane_distance():
    """Demo 1: Distance to affine hyperplane formula"""
    print("=" * 60)
    print("DEMO 1: Distance to Affine Hyperplane")
    print("=" * 60)

    # Hyperplane in ℝ²: ⟨(3,4), y⟩ = 10, i.e., 3y₁ + 4y₂ = 10
    u = np.array([3.0, 4.0])
    c = 10.0
    x = np.array([5.0, 7.0])

    # Formula: |⟨u,x⟩ - c| / ‖u‖
    inner_val = np.dot(u, x)
    formula_dist = abs(inner_val - c) / np.linalg.norm(u)

    # Nearest point on hyperplane (orthogonal projection)
    t = (c - inner_val) / np.dot(u, u)
    proj = x + t * u
    actual_dist = np.linalg.norm(x - proj)

    print(f"  Normal vector u = {u}")
    print(f"  Constant c = {c}")
    print(f"  Point x = {x}")
    print(f"  ⟨u, x⟩ = {inner_val}")
    print(f"  |⟨u, x⟩ - c| / ‖u‖ = |{inner_val} - {c}| / {np.linalg.norm(u):.4f} = {formula_dist:.4f}")
    print(f"  Actual distance (via projection) = {actual_dist:.4f}")
    print(f"  Formula verified: {np.isclose(formula_dist, actual_dist)}")
    print()


def demo_tropical_cells():
    """Demo 2: Tropical cells as polyhedral sets"""
    print("=" * 60)
    print("DEMO 2: Tropical Cells as Polyhedral Sets")
    print("=" * 60)

    # 3-class classifier in ℝ²
    A = np.array([
        [2.0, 1.0],   # class 0
        [-1.0, 2.0],  # class 1
        [0.0, -1.0],  # class 2
    ])
    B = np.array([0.0, 1.0, 3.0])

    # Check convexity: for two points in the same cell, their midpoint is too
    x1 = np.array([3.0, 0.0])
    x2 = np.array([4.0, -1.0])
    mid = (x1 + x2) / 2

    _, k1 = tropical_max(A, B, x1)
    _, k2 = tropical_max(A, B, x2)
    _, k_mid = tropical_max(A, B, mid)

    print(f"  Affine forms:")
    for i in range(3):
        print(f"    ℓ_{i}(x) = {A[i]} · x + {B[i]}")
    print()
    print(f"  Point x₁ = {x1}, winner = class {k1}")
    print(f"  Point x₂ = {x2}, winner = class {k2}")
    print(f"  Midpoint  = {mid}, winner = class {k_mid}")
    if k1 == k2:
        print(f"  Convexity check: x₁, x₂ in class {k1}, midpoint in class {k_mid} → {'✓' if k_mid == k1 else '✗'}")
    print()


def demo_certified_robustness():
    """Demo 3: Certified robustness radius"""
    print("=" * 60)
    print("DEMO 3: Certified Robustness Radius")
    print("=" * 60)

    # 3-class classifier in ℝ²
    A = np.array([
        [2.0, 1.0],   # class 0
        [-1.0, 2.0],  # class 1
        [0.0, -1.0],  # class 2
    ])
    B = np.array([0.0, 1.0, 3.0])

    x = np.array([2.0, 0.5])
    _, k = tropical_max(A, B, x)
    r = certified_radius(A, B, k, x)

    print(f"  Point x = {x}")
    print(f"  Winning class k = {k}")
    print(f"  Scores: {[affine_score(A[i], B[i], x) for i in range(3)]}")
    print(f"  Normalized margins:")
    for j in range(3):
        if j != k:
            m = normalized_margin(A, B, k, j, x)
            print(f"    vs class {j}: {m:.4f}")
    print(f"  Certified radius = {r:.4f}")

    # Verify: perturb in random directions within the certified radius
    np.random.seed(42)
    n_tests = 1000
    violations = 0
    for _ in range(n_tests):
        direction = np.random.randn(2)
        direction /= np.linalg.norm(direction)
        delta = direction * r * 0.99  # just inside the certified ball
        y = x + delta
        _, ky = tropical_max(A, B, y)
        if ky != k:
            violations += 1

    print(f"\n  Verification: {n_tests} random perturbations within 0.99 × certified radius")
    print(f"  Violations: {violations} (should be 0)")

    # Check that perturbations outside CAN change the class
    violations_outside = 0
    for _ in range(n_tests):
        direction = np.random.randn(2)
        direction /= np.linalg.norm(direction)
        delta = direction * r * 1.5  # outside the certified ball
        y = x + delta
        _, ky = tropical_max(A, B, y)
        if ky != k:
            violations_outside += 1

    print(f"  At 1.5 × certified radius: {violations_outside}/{n_tests} class changes")
    print()


def demo_lipschitz_comparison():
    """Demo 4: Polyhedral certificate vs Lipschitz certificate"""
    print("=" * 60)
    print("DEMO 4: Polyhedral vs Lipschitz Certificate Comparison")
    print("=" * 60)

    A = np.array([
        [2.0, 1.0],
        [-1.0, 2.0],
        [0.0, -1.0],
    ])
    B = np.array([0.0, 1.0, 3.0])

    # Global Lipschitz constant K = max_{j≠k} ‖a_k - a_j‖
    K = max(np.linalg.norm(A[i] - A[j]) for i in range(3) for j in range(3) if i != j)

    x = np.array([2.0, 0.5])
    _, k = tropical_max(A, B, x)

    # Polyhedral certificate (our theorem)
    r_poly = certified_radius(A, B, k, x)

    # Lipschitz certificate: margin / (2K)
    scores = [affine_score(A[i], B[i], x) for i in range(3)]
    margin = min(scores[k] - scores[j] for j in range(3) if j != k)
    r_lipschitz = margin / (2 * K)

    print(f"  Point x = {x}, winning class = {k}")
    print(f"  Global Lipschitz constant K = {K:.4f}")
    print(f"  Raw margin = {margin:.4f}")
    print(f"  Lipschitz certificate: margin/(2K) = {r_lipschitz:.4f}")
    print(f"  Polyhedral certificate: min normalized margin = {r_poly:.4f}")
    print(f"  Improvement ratio: {r_poly / r_lipschitz:.2f}×")
    print(f"  The polyhedral certificate is {'sharper' if r_poly > r_lipschitz else 'equal or weaker'}")
    print()


def create_visualization():
    """Create visualization of tropical cells and certified radii"""
    A = np.array([
        [2.0, 1.0],
        [-1.0, 2.0],
        [0.0, -1.0],
    ])
    B = np.array([0.0, 1.0, 3.0])

    # Create grid
    x_range = np.linspace(-3, 5, 500)
    y_range = np.linspace(-3, 5, 500)
    X, Y = np.meshgrid(x_range, y_range)

    # Compute winning class at each point
    Z = np.zeros_like(X)
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            pt = np.array([X[i, j], Y[i, j]])
            _, k = tropical_max(A, B, pt)
            Z[i, j] = k

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Tropical cells
    ax1 = axes[0]
    colors = ['#3498db', '#e74c3c', '#2ecc71']
    cmap = plt.cm.colors.ListedColormap(colors)
    ax1.contourf(X, Y, Z, levels=[-0.5, 0.5, 1.5, 2.5], colors=colors, alpha=0.3)
    ax1.contour(X, Y, Z, levels=[0.5, 1.5], colors='black', linewidths=2)

    ax1.set_title('Tropical Decision Regions\n(3-Class Classifier in ℝ²)', fontsize=13)
    ax1.set_xlabel('x₁')
    ax1.set_ylabel('x₂')

    # Label regions
    ax1.text(3.5, -1, 'C₀', fontsize=16, fontweight='bold', color=colors[0])
    ax1.text(-2, 3.5, 'C₁', fontsize=16, fontweight='bold', color=colors[1])
    ax1.text(-1, -2, 'C₂', fontsize=16, fontweight='bold', color=colors[2])

    # Plot 2: Certified robustness radii
    ax2 = axes[1]
    ax2.contourf(X, Y, Z, levels=[-0.5, 0.5, 1.5, 2.5], colors=colors, alpha=0.15)
    ax2.contour(X, Y, Z, levels=[0.5, 1.5], colors='black', linewidths=1.5)

    # Show certified radii at several points
    test_points = [
        np.array([2.0, 0.5]),
        np.array([3.0, -1.0]),
        np.array([-1.5, 3.0]),
        np.array([0.0, -1.5]),
        np.array([1.0, 1.0]),
    ]

    for pt in test_points:
        _, k = tropical_max(A, B, pt)
        r = certified_radius(A, B, k, pt)
        if r > 0 and r < 10:
            circle = plt.Circle(pt, r, fill=False, edgecolor=colors[k],
                              linewidth=2, linestyle='--')
            ax2.add_patch(circle)
            ax2.plot(*pt, 'o', color=colors[k], markersize=6)
            ax2.annotate(f'r={r:.2f}', xy=pt, xytext=(pt[0]+0.1, pt[1]+0.2),
                        fontsize=8, color=colors[k])

    ax2.set_title('Certified Robustness Radii\n(Polyhedral Certificates)', fontsize=13)
    ax2.set_xlabel('x₁')
    ax2.set_ylabel('x₂')
    ax2.set_xlim(-3, 5)
    ax2.set_ylim(-3, 5)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/tropical_robustness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_robustness.png")


def create_comparison_chart():
    """Create chart comparing polyhedral vs Lipschitz certificates"""
    A = np.array([
        [2.0, 1.0],
        [-1.0, 2.0],
        [0.0, -1.0],
    ])
    B = np.array([0.0, 1.0, 3.0])

    K = max(np.linalg.norm(A[i] - A[j]) for i in range(3) for j in range(3) if i != j)

    # Sample points along a line
    t_vals = np.linspace(0, 4, 100)
    poly_radii = []
    lip_radii = []

    for t in t_vals:
        x = np.array([t, 0.5])
        _, k = tropical_max(A, B, x)
        r_poly = certified_radius(A, B, k, x)
        scores = [affine_score(A[i], B[i], x) for i in range(3)]
        margin = min(scores[k] - scores[j] for j in range(3) if j != k)
        r_lip = margin / (2 * K)
        poly_radii.append(max(r_poly, 0))
        lip_radii.append(max(r_lip, 0))

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.fill_between(t_vals, lip_radii, poly_radii, alpha=0.3, color='green',
                    label='Improvement (polyhedral − Lipschitz)')
    ax.plot(t_vals, poly_radii, 'b-', linewidth=2, label='Polyhedral certificate')
    ax.plot(t_vals, lip_radii, 'r--', linewidth=2, label='Lipschitz certificate')
    ax.set_xlabel('Position along x₁ axis (x₂ = 0.5)', fontsize=12)
    ax.set_ylabel('Certified robustness radius', fontsize=12)
    ax.set_title('Polyhedral vs Lipschitz Robustness Certificates', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/certificate_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: certificate_comparison.png")


if __name__ == "__main__":
    demo_hyperplane_distance()
    demo_tropical_cells()
    demo_certified_robustness()
    demo_lipschitz_comparison()
    create_visualization()
    create_comparison_chart()
    print("\nAll demos completed successfully!")
