#!/usr/bin/env python3
"""
Applications of the Lipschitz margin cell ball-inclusion theorem.

Demonstrates practical use in:
1. Neural network robustness certification
2. Decision boundary visualization
3. Geometric analysis of classifier regions
"""

import numpy as np
from algorithms import certified_radius, batch_certify, inscribed_radius_estimate


def application_1_neural_network_robustness():
    """
    Simulate robustness certification for a simple neural network.

    Uses a 2-layer ReLU network with known weight matrices.
    Computes certified radii via spectral norm bounds.
    """
    print("=" * 60)
    print("Application 1: Neural Network Robustness Certification")
    print("=" * 60)

    np.random.seed(42)

    # 2-layer network: f(x) = W2 * ReLU(W1 * x + b1) + b2
    dim_in, dim_hidden, n_classes = 10, 20, 5
    W1 = np.random.randn(dim_hidden, dim_in) * 0.5
    b1 = np.random.randn(dim_hidden) * 0.1
    W2 = np.random.randn(n_classes, dim_hidden) * 0.3
    b2 = np.random.randn(n_classes) * 0.1

    def network(x):
        h = np.maximum(0, W1 @ x + b1)  # ReLU
        return W2 @ h + b2

    # Lipschitz bound: product of spectral norms (ReLU is 1-Lipschitz)
    s1 = np.linalg.norm(W1, ord=2)
    s2 = np.linalg.norm(W2, ord=2)
    network_lip = s1 * s2
    gap_lip = 2 * network_lip  # gap function Lipschitz bound

    print(f"\nNetwork: {dim_in}→{dim_hidden}→{n_classes}")
    print(f"Spectral norms: layer 1 = {s1:.4f}, layer 2 = {s2:.4f}")
    print(f"Network Lipschitz bound: {network_lip:.4f}")
    print(f"Gap Lipschitz bound: {gap_lip:.4f}")

    # Certify several random inputs
    n_test = 20
    X_test = np.random.randn(n_test, dim_in)
    print(f"\nCertifying {n_test} random inputs:")
    print(f"{'Point':>6} {'Pred':>5} {'Margin γ':>10} {'Cert. Radius':>14}")
    print("-" * 40)

    for idx in range(n_test):
        x = X_test[idx]
        scores_vec = network(x)
        pred = int(np.argmax(scores_vec))
        scores = {i: float(scores_vec[i]) for i in range(n_classes)}
        lip = {j: gap_lip for j in range(n_classes) if j != pred}
        gamma, K, radius = certified_radius(scores, lip, pred)
        print(f"{idx:>6} {pred:>5} {gamma:>10.4f} {radius:>14.6f}")

    print()


def application_2_decision_boundary_analysis():
    """
    Analyze the decision boundary geometry for a 2D classifier.

    Computes certified radii on a grid and identifies thin/thick regions.
    """
    print("=" * 60)
    print("Application 2: Decision Boundary Geometry Analysis")
    print("=" * 60)

    # 3-class linear classifier in R^2
    W = np.array([[2.0, 1.0], [1.0, 2.0], [-1.0, -1.0]])
    b = np.array([0.0, 0.0, 3.0])

    # Grid of points
    grid_points = []
    for x1 in np.linspace(-2, 4, 13):
        for x2 in np.linspace(-2, 4, 13):
            grid_points.append([x1, x2])
    X_grid = np.array(grid_points)

    radii = batch_certify(W, b, X_grid)

    print(f"\nGrid analysis: {len(X_grid)} points")
    print(f"Mean certified radius: {radii.mean():.4f}")
    print(f"Max certified radius: {radii.max():.4f}")
    print(f"Points with zero radius (on boundary): {(radii == 0).sum()}")

    # Find the point with maximum certified radius
    best_idx = np.argmax(radii)
    best_point = X_grid[best_idx]
    scores = X_grid[best_idx] @ W.T + b
    pred = np.argmax(scores)
    print(f"\nMost robust point: ({best_point[0]:.1f}, {best_point[1]:.1f})")
    print(f"  Predicted class: {pred}")
    print(f"  Certified radius: {radii[best_idx]:.4f}")
    print(f"  Scores: {scores}")

    # Classify regions
    predictions = np.argmax(X_grid @ W.T + b, axis=1)
    for c in range(3):
        mask = predictions == c
        if mask.any():
            mean_r = radii[mask].mean()
            print(f"\nClass {c}: {mask.sum()} points, mean radius = {mean_r:.4f}")

    print()


def application_3_adversarial_training_objective():
    """
    Demonstrate the connection between certified radius and training objectives.

    Shows that maximizing margin/Lipschitz is equivalent to maximizing
    the inscribed radius of decision cells.
    """
    print("=" * 60)
    print("Application 3: Geometric Training Objective")
    print("=" * 60)

    np.random.seed(123)

    n_classes = 3
    dim = 2
    n_train = 50

    # Generate training data (simple clusters)
    X_train = np.vstack([
        np.random.randn(n_train // 3, dim) + [2, 0],
        np.random.randn(n_train // 3, dim) + [0, 2],
        np.random.randn(n_train - 2 * (n_train // 3), dim) + [-2, -2],
    ])
    y_train = np.concatenate([
        np.zeros(n_train // 3, dtype=int),
        np.ones(n_train // 3, dtype=int),
        2 * np.ones(n_train - 2 * (n_train // 3), dtype=int),
    ])

    # Simple linear classifier (solved by pseudo-inverse)
    # One-hot encoding
    Y_onehot = np.zeros((n_train, n_classes))
    for i in range(n_train):
        Y_onehot[i, y_train[i]] = 1.0

    # Least squares: W^T X ≈ Y
    W_opt = np.linalg.lstsq(X_train, Y_onehot, rcond=None)[0].T
    b_opt = np.zeros(n_classes)

    # Compute certified radii
    radii = batch_certify(W_opt, b_opt, X_train)
    accuracy = np.mean(np.argmax(X_train @ W_opt.T + b_opt, axis=1) == y_train)

    print(f"\nTraining set: {n_train} points, {n_classes} classes, dim={dim}")
    print(f"Accuracy: {accuracy:.2%}")
    print(f"Mean certified radius: {radii.mean():.4f}")
    print(f"Min certified radius: {radii.min():.4f}")
    print(f"Max certified radius: {radii.max():.4f}")

    # The geometric interpretation:
    print("\nGeometric interpretation:")
    print(f"  The minimum certified radius {radii[radii > 0].min():.4f} is a lower bound")
    print(f"  on the Chebyshev radius of every decision cell.")
    print(f"  Maximizing this quantity during training would produce")
    print(f"  the fattest possible decision regions.")

    # Spectral norm analysis
    for i in range(n_classes):
        print(f"\n  Weight vector for class {i}: norm = {np.linalg.norm(W_opt[i]):.4f}")

    print()


if __name__ == "__main__":
    application_1_neural_network_robustness()
    application_2_decision_boundary_analysis()
    application_3_adversarial_training_objective()
    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
Demonstration of the Lipschitz ball inclusion theorem for margin cells.

This script illustrates the key mathematical results with concrete examples:
1. Linear 3-class classifier in R^2
2. Nonlinear 2-class classifier
3. Infinite-class conceptual demonstration (dense label set approximation)
"""

import numpy as np


def compute_certified_radius(scores_at_x: dict, lipschitz_constants: dict, predicted_class):
    """
    Compute the certified radius γ/K for a given point.

    Parameters
    ----------
    scores_at_x : dict
        Mapping from class label to score value at point x.
    lipschitz_constants : dict
        Mapping from competitor class label to Lipschitz constant of the
        gap function (s_predicted - s_competitor).
    predicted_class : hashable
        The predicted class label.

    Returns
    -------
    gamma : float
        The minimum margin (gap to closest competitor).
    K : float
        The maximum Lipschitz constant.
    radius : float
        The certified radius γ/K (or inf if K=0 and γ>0).
    """
    gamma = float('inf')
    K = 0.0

    for j, score_j in scores_at_x.items():
        if j == predicted_class:
            continue
        gap = scores_at_x[predicted_class] - score_j
        gamma = min(gamma, gap)
        K = max(K, lipschitz_constants.get(j, 0.0))

    if gamma <= 0:
        return gamma, K, 0.0
    if K == 0:
        return gamma, K, float('inf')

    return gamma, K, gamma / K


def verify_ball_inclusion(score_fns, predicted_class, center, radius, n_samples=10000):
    """
    Empirically verify that random points in the ball are in the margin cell.

    Parameters
    ----------
    score_fns : dict
        Mapping from class label to callable score function.
    predicted_class : hashable
        The predicted class.
    center : np.ndarray
        Center point.
    radius : float
        Ball radius.
    n_samples : int
        Number of random samples.

    Returns
    -------
    all_inside : bool
        Whether all sampled points were in the margin cell.
    fraction_inside : float
        Fraction of points verified to be inside.
    """
    dim = len(center)
    inside_count = 0

    for _ in range(n_samples):
        # Sample uniformly from ball
        direction = np.random.randn(dim)
        direction /= np.linalg.norm(direction)
        r = np.random.uniform(0, radius) ** (1.0 / dim) * radius
        # Actually: uniform in ball uses r^(1/dim) * radius * uniform^(1/dim)
        u = np.random.uniform()
        r = radius * u ** (1.0 / dim)
        point = center + r * direction

        # Check margin cell membership
        pred_score = score_fns[predicted_class](point)
        in_cell = True
        for j, fn in score_fns.items():
            if j == predicted_class:
                continue
            if fn(point) >= pred_score:
                in_cell = False
                break

        if in_cell:
            inside_count += 1

    return inside_count == n_samples, inside_count / n_samples


def example_1_linear_3class():
    """Example 1: Linear 3-class classifier in R^2."""
    print("=" * 60)
    print("Example 1: Linear 3-class classifier in R^2")
    print("=" * 60)

    # Score functions: s_i(x) = w_i · x + b_i
    w = {1: np.array([2.0, 1.0]), 2: np.array([1.0, 2.0]), 3: np.array([-1.0, -1.0])}
    b = {1: 0.0, 2: 0.0, 3: 3.0}

    score_fns = {i: (lambda x, i=i: w[i] @ x + b[i]) for i in [1, 2, 3]}

    x = np.array([2.0, 0.0])
    predicted = 1

    print(f"\nPoint x = {x}")
    print(f"Predicted class: {predicted}")

    scores = {i: score_fns[i](x) for i in [1, 2, 3]}
    print(f"Scores: {scores}")

    # Lipschitz constants of gap functions
    # s_1 - s_2 has gradient w_1 - w_2 = (1, -1), ||·|| = sqrt(2)
    # s_1 - s_3 has gradient w_1 - w_3 = (3, 2), ||·|| = sqrt(13)
    lip = {
        2: np.linalg.norm(w[1] - w[2]),
        3: np.linalg.norm(w[1] - w[3]),
    }
    print(f"Lipschitz constants: {lip}")

    gamma, K, radius = compute_certified_radius(scores, lip, predicted)
    print(f"\nMinimum margin γ = {gamma:.4f}")
    print(f"Maximum Lipschitz K = {K:.4f}")
    print(f"Certified radius γ/K = {radius:.4f}")

    # Empirical verification
    all_ok, frac = verify_ball_inclusion(score_fns, predicted, x, radius * 0.999)
    print(f"\nEmpirical verification (r = 0.999 × γ/K):")
    print(f"  All {10000} samples inside margin cell: {all_ok} ({frac:.4%})")

    print()


def example_2_nonlinear_2class():
    """Example 2: Nonlinear 2-class classifier."""
    print("=" * 60)
    print("Example 2: Nonlinear 2-class classifier in R^2")
    print("=" * 60)

    # s_1(x) = ||x||^2, s_2(x) = ||x - (3,0)||^2
    # Gap: g(x) = ||x||^2 - ||x-(3,0)||^2 = 6x_1 - 9
    # Lipschitz constant of g: ||gradient|| = ||(6,0)|| = 6

    score_fns = {
        1: lambda x: np.sum(x ** 2),
        2: lambda x: np.sum((x - np.array([3.0, 0.0])) ** 2),
    }

    x = np.array([2.0, 0.0])
    predicted = 1

    print(f"\nPoint x = {x}")
    scores = {i: score_fns[i](x) for i in [1, 2]}
    print(f"Scores: s_1(x) = {scores[1]:.2f}, s_2(x) = {scores[2]:.2f}")
    print(f"Gap = {scores[1] - scores[2]:.2f}")

    lip = {2: 6.0}  # gradient of gap is (6, 0)
    gamma, K, radius = compute_certified_radius(scores, lip, predicted)
    print(f"Margin γ = {gamma:.4f}, Lipschitz K = {K:.4f}")
    print(f"Certified radius = {radius:.4f}")
    print(f"True inscribed radius (distance to boundary x_1=1.5) = {x[0] - 1.5:.4f}")
    print("→ Certified radius matches true inscribed radius (tight bound for linear gap)")

    all_ok, frac = verify_ball_inclusion(score_fns, predicted, x, radius * 0.999)
    print(f"\nEmpirical verification: all inside = {all_ok} ({frac:.4%})")

    print()


def example_3_many_classes():
    """Example 3: Many-class classifier (approximating infinite labels)."""
    print("=" * 60)
    print("Example 3: 100-class classifier (approximating ∞)")
    print("=" * 60)

    np.random.seed(42)
    n_classes = 100
    dim = 10

    # Random linear classifier
    W = np.random.randn(n_classes, dim)
    b = np.random.randn(n_classes)

    score_fns = {i: (lambda x, i=i: W[i] @ x + b[i]) for i in range(n_classes)}

    x = np.random.randn(dim)
    scores = {i: score_fns[i](x) for i in range(n_classes)}
    predicted = max(scores, key=scores.get)

    print(f"\nDimension: {dim}, Number of classes: {n_classes}")
    print(f"Predicted class: {predicted}")
    print(f"Top score: {scores[predicted]:.4f}")
    print(f"Runner-up score: {sorted(scores.values())[-2]:.4f}")

    # Lipschitz constants
    lip = {}
    for j in range(n_classes):
        if j == predicted:
            continue
        lip[j] = np.linalg.norm(W[predicted] - W[j])

    gamma, K, radius = compute_certified_radius(scores, lip, predicted)
    print(f"\nMinimum margin γ = {gamma:.6f}")
    print(f"Maximum Lipschitz K = {K:.4f}")
    print(f"Certified radius γ/K = {radius:.6f}")

    if radius > 0:
        all_ok, frac = verify_ball_inclusion(score_fns, predicted, x, radius * 0.999)
        print(f"Empirical verification: all inside = {all_ok} ({frac:.4%})")
    else:
        print("Margin is non-positive; point is on decision boundary.")

    print()


def example_4_inscribed_radius():
    """Example 4: Inscribed radius computation and comparison."""
    print("=" * 60)
    print("Example 4: Inscribed radius vs certified radius")
    print("=" * 60)

    # Simple 2D, 2-class: s_1(x) = x_1, s_2(x) = 0
    # Margin cell of class 1: {x : x_1 > 0}
    # Inscribed radius at (a, 0): distance to boundary = a

    print("\nClassifier: s_1(x) = x_1, s_2(x) = 0")
    print("Margin cell: {x : x_1 > 0}")
    print("Gap function: g(x) = x_1, Lipschitz constant K = 1")

    for a in [0.5, 1.0, 2.0, 5.0]:
        x = np.array([a, 0.0])
        gamma = a  # gap at x
        K = 1.0
        certified_r = gamma / K
        true_inscribed_r = a  # distance to boundary x_1 = 0
        print(f"  x = ({a}, 0): certified r = {certified_r:.2f}, "
              f"true inscribed r = {true_inscribed_r:.2f}, "
              f"ratio = {certified_r / true_inscribed_r:.2f}")

    print("\n→ For this linear case, certified radius = true inscribed radius (tight)")
    print()


if __name__ == "__main__":
    example_1_linear_3class()
    example_2_nonlinear_2class()
    example_3_many_classes()
    example_4_inscribed_radius()
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualizations for the Lipschitz margin cell ball-inclusion theorem.
Generates publication-quality figures saved as PNG files.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
import base64
import json
import io


def fig_to_base64(fig):
    """Convert a matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz1_margin_cell_and_ball():
    """Visualize margin cells with certified balls for a 3-class linear classifier."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    W = np.array([[2.0, 1.0], [1.0, 2.0], [-1.0, -1.0]])
    b = np.array([0.0, 0.0, 3.0])

    # Create grid
    x1 = np.linspace(-2, 5, 500)
    x2 = np.linspace(-2, 5, 500)
    X1, X2 = np.meshgrid(x1, x2)
    grid = np.stack([X1, X2], axis=-1)
    scores = grid @ W.T + b
    predictions = np.argmax(scores, axis=-1)

    colors = ['#3498db', '#e74c3c', '#2ecc71']
    color_map = np.zeros((*predictions.shape, 3))
    for c in range(3):
        mask = predictions == c
        color_map[mask] = matplotlib.colors.to_rgb(colors[c])

    # Lighten for background
    color_map = 0.3 * color_map + 0.7

    ax.imshow(color_map, extent=[-2, 5, -2, 5], origin='lower', aspect='equal')

    # Draw decision boundaries
    for i in range(3):
        for j in range(i+1, 3):
            dw = W[i] - W[j]
            db = b[i] - b[j]
            if abs(dw[1]) > 1e-10:
                x1_line = np.linspace(-2, 5, 100)
                x2_line = -(dw[0] * x1_line + db) / dw[1]
                mask = (x2_line >= -2) & (x2_line <= 5)
                ax.plot(x1_line[mask], x2_line[mask], 'k-', linewidth=1.5, alpha=0.7)
            elif abs(dw[0]) > 1e-10:
                x1_val = -db / dw[0]
                ax.axvline(x1_val, color='k', linewidth=1.5, alpha=0.7)

    # Test points with certified balls
    test_points = [(2.5, 0.5), (0.5, 2.5), (0.0, 0.0)]
    for px, py in test_points:
        x = np.array([px, py])
        s = x @ W.T + b
        pred = np.argmax(s)

        gamma = float('inf')
        K = 0.0
        for j in range(3):
            if j == pred:
                continue
            gap = s[pred] - s[j]
            gamma = min(gamma, gap)
            lip = np.linalg.norm(W[pred] - W[j])
            K = max(K, lip)

        if gamma > 0 and K > 0:
            r = gamma / K
            circle = Circle((px, py), r, fill=False, edgecolor=colors[pred],
                           linewidth=2.5, linestyle='-')
            ax.add_patch(circle)

        ax.plot(px, py, 'o', color=colors[pred], markersize=8,
               markeredgecolor='black', markeredgewidth=1)

    ax.set_xlim(-2, 5)
    ax.set_ylim(-2, 5)
    ax.set_xlabel('$x_1$', fontsize=14)
    ax.set_ylabel('$x_2$', fontsize=14)
    ax.set_title('Margin Cells with Certified Inscribed Balls', fontsize=16)

    # Legend
    for c, name in enumerate(['Class 1', 'Class 2', 'Class 3']):
        ax.plot([], [], 's', color=colors[c], markersize=10, label=name)
    ax.legend(loc='upper left', fontsize=12)

    fig.savefig('/workspace/request-project/viz_margin_cells.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz2_certified_radius_heatmap():
    """Heatmap of certified radii across the input space."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    W = np.array([[2.0, 1.0], [1.0, 2.0], [-1.0, -1.0]])
    b = np.array([0.0, 0.0, 3.0])

    n = 200
    x1 = np.linspace(-2, 5, n)
    x2 = np.linspace(-2, 5, n)
    X1, X2 = np.meshgrid(x1, x2)
    radii = np.zeros((n, n))

    for i in range(n):
        for j in range(n):
            x = np.array([X1[i, j], X2[i, j]])
            s = x @ W.T + b
            pred = np.argmax(s)
            gamma = float('inf')
            K = 0.0
            for c in range(3):
                if c == pred:
                    continue
                gap = s[pred] - s[c]
                gamma = min(gamma, gap)
                lip = np.linalg.norm(W[pred] - W[c])
                K = max(K, lip)
            if gamma > 0 and K > 0:
                radii[i, j] = gamma / K

    im = ax.imshow(radii, extent=[-2, 5, -2, 5], origin='lower', aspect='equal',
                   cmap='viridis', vmin=0)
    plt.colorbar(im, ax=ax, label='Certified Radius γ/K', shrink=0.8)

    # Draw boundaries
    for i in range(3):
        for j in range(i+1, 3):
            dw = W[i] - W[j]
            db = b[i] - b[j]
            if abs(dw[1]) > 1e-10:
                x1_line = np.linspace(-2, 5, 100)
                x2_line = -(dw[0] * x1_line + db) / dw[1]
                mask = (x2_line >= -2) & (x2_line <= 5)
                ax.plot(x1_line[mask], x2_line[mask], 'w--', linewidth=1, alpha=0.8)

    ax.set_xlabel('$x_1$', fontsize=14)
    ax.set_ylabel('$x_2$', fontsize=14)
    ax.set_title('Certified Radius Landscape', fontsize=16)

    fig.savefig('/workspace/request-project/viz_radius_heatmap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz3_margin_vs_radius():
    """Plot relationship between margin, Lipschitz constant, and certified radius."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: radius vs margin for fixed K
    gammas = np.linspace(0, 5, 100)
    for K in [0.5, 1.0, 2.0, 5.0]:
        radii = gammas / K
        ax1.plot(gammas, radii, linewidth=2, label=f'K = {K}')

    ax1.set_xlabel('Margin γ', fontsize=14)
    ax1.set_ylabel('Certified Radius γ/K', fontsize=14)
    ax1.set_title('Certified Radius vs Margin', fontsize=15)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(0, 5)
    ax1.set_ylim(0, 10)

    # Panel 2: radius vs K for fixed margin
    Ks = np.linspace(0.1, 5, 100)
    for g in [0.5, 1.0, 2.0, 5.0]:
        radii = g / Ks
        ax2.plot(Ks, radii, linewidth=2, label=f'γ = {g}')

    ax2.set_xlabel('Lipschitz Constant K', fontsize=14)
    ax2.set_ylabel('Certified Radius γ/K', fontsize=14)
    ax2.set_title('Certified Radius vs Lipschitz Constant', fontsize=15)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 5)
    ax2.set_ylim(0, 10)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_margin_vs_radius.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz1_margin_cell_and_ball()
    print(f"  viz1: {len(b64_1)} chars")
    b64_2 = viz2_certified_radius_heatmap()
    print(f"  viz2: {len(b64_2)} chars")
    b64_3 = viz3_margin_vs_radius()
    print(f"  viz3: {len(b64_3)} chars")
    print("All visualizations generated.")

    # Save base64 data for PACKAGE.json
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump({
            "margin_cells": b64_1,
            "radius_heatmap": b64_2,
            "margin_vs_radius": b64_3,
        }, f)
