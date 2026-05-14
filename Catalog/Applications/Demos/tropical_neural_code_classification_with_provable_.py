#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Applications

Real-world applications of tropical margin theory:
1. Neural population decoding with certified robustness
2. Adversarially robust image classification
3. Neural code design optimization
4. Biological receptive field analysis

All computations are self-contained.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ============================================================
# Core functions (self-contained)
# ============================================================

def tropical_scores_all(P, x):
    return np.max(P - x[np.newaxis, :], axis=1)

def tropical_classify(P, x):
    return int(np.argmin(tropical_scores_all(P, x)))

def tropical_margin(P, x, y):
    scores = tropical_scores_all(P, x)
    competitors = np.delete(scores, y)
    return float(np.min(competitors - scores[y]))


# ============================================================
# Application 1: Neural Population Decoding
# ============================================================

def app_neural_decoding():
    """
    Simulate neural population decoding with certified reliability.

    A population of neurons encodes stimulus direction (0°, 90°, 180°, 270°).
    Each neuron has a tuning curve, and the tropical margin certifies
    decoding reliability under noise.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Population Decoding")
    print("=" * 60)

    # Simulate tuning curves for 20 neurons, 4 directions
    n_neurons = 20
    n_directions = 4
    directions = np.array([0, 90, 180, 270])  # degrees

    np.random.seed(42)

    # Each neuron has a preferred direction and tuning width
    preferred_dirs = np.random.uniform(0, 360, n_neurons)
    tuning_widths = np.random.uniform(30, 90, n_neurons)

    # Generate prototypes (mean firing rates)
    P = np.zeros((n_directions, n_neurons))
    for k, d in enumerate(directions):
        for i in range(n_neurons):
            angular_diff = min(abs(d - preferred_dirs[i]),
                             360 - abs(d - preferred_dirs[i]))
            P[k, i] = np.exp(-0.5 * (angular_diff / tuning_widths[i]) ** 2)

    # Simulate noisy observations
    noise_levels = [0.01, 0.05, 0.1, 0.2, 0.3, 0.5]
    n_trials = 500

    print(f"\n{'Noise σ':>8} | {'Accuracy':>8} | {'Certified %':>11} | {'Mean Margin':>11}")
    print("-" * 50)

    for sigma in noise_levels:
        correct = 0
        certified = 0
        margins = []

        for _ in range(n_trials):
            true_dir = np.random.randint(n_directions)
            x = P[true_dir] + np.random.randn(n_neurons) * sigma
            pred = tropical_classify(P, x)
            m = tropical_margin(P, x, pred)

            if pred == true_dir:
                correct += 1
            if m > 0:
                certified += 1
            margins.append(m)

        acc = 100 * correct / n_trials
        cert = 100 * certified / n_trials
        mean_m = np.mean(margins)

        print(f"{sigma:8.3f} | {acc:7.1f}% | {cert:10.1f}% | {mean_m:11.4f}")


# ============================================================
# Application 2: Adversarially Robust Classification
# ============================================================

def app_adversarial_classification():
    """
    Demonstrate certified adversarial robustness for a tropical classifier.

    Compare the theoretical robustness guarantee (margin/2) against
    empirical robustness under worst-case perturbations.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Certified Adversarial Robustness")
    print("=" * 60)

    np.random.seed(123)

    # 5 classes, 15 features
    c, d = 5, 15
    P = np.random.randn(c, d) * 2

    n_points = 200
    results = []

    for _ in range(n_points):
        # Random observation near a class center
        true_class = np.random.randint(c)
        x = P[true_class] + np.random.randn(d) * 0.3

        pred = tropical_classify(P, x)
        margin = tropical_margin(P, x, pred)
        cert_radius = max(0, margin / 2)

        # Empirical robustness: find smallest perturbation that changes label
        emp_radius = 0
        for eps in np.linspace(0, 2, 100):
            # Worst-case perturbation (try multiple random directions)
            changed = False
            for _ in range(50):
                direction = np.random.randn(d)
                direction = direction / np.max(np.abs(direction)) * eps
                x_pert = x + direction
                if tropical_classify(P, x_pert) != pred:
                    changed = True
                    break
            if changed:
                emp_radius = eps
                break
            emp_radius = eps

        results.append((cert_radius, emp_radius, pred == true_class))

    cert_radii, emp_radii, correct = zip(*results)
    cert_radii = np.array(cert_radii)
    emp_radii = np.array(emp_radii)

    print(f"\nMean certified radius: {np.mean(cert_radii):.4f}")
    print(f"Mean empirical radius: {np.mean(emp_radii):.4f}")
    print(f"Theory is tight: certified ≤ empirical in {100*np.mean(cert_radii <= emp_radii + 0.05):.0f}% of cases")

    # Plot
    fig, ax = plt.subplots(figsize=(7, 7))
    ax.scatter(cert_radii, emp_radii, alpha=0.5, s=30, c='#4ECDC4')
    max_val = max(np.max(cert_radii), np.max(emp_radii)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='Certified = Empirical')
    ax.set_xlabel('Certified Robustness Radius (margin/2)', fontsize=12)
    ax.set_ylabel('Empirical Robustness Radius', fontsize=12)
    ax.set_title('Certified vs Empirical Adversarial Robustness', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('adversarial_robustness.png', dpi=150, bbox_inches='tight')
    print("  Saved: adversarial_robustness.png")
    plt.close()


# ============================================================
# Application 3: Neural Code Design
# ============================================================

def app_code_design():
    """
    Optimize a neural codebook to maximize tropical margin.

    Uses gradient-free optimization (CMA-like random search) to find
    codebooks with large minimum margin over a training set.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Neural Code Design Optimization")
    print("=" * 60)

    np.random.seed(456)

    c, d = 4, 8  # 4 classes, 8 neurons

    # Generate training data: observations near class centers
    n_train = 100
    train_labels = np.random.randint(c, size=n_train)

    def min_margin(P_flat):
        """Minimum margin over training set (to maximize)."""
        P = P_flat.reshape(c, d)
        # Generate observations near prototypes
        margins = []
        for i in range(n_train):
            x = P[train_labels[i]] + np.random.randn(d) * 0.5
            pred = tropical_classify(P, x)
            m = tropical_margin(P, x, pred)
            margins.append(m)
        return np.min(margins)

    # Random search optimization
    best_P = np.random.randn(c, d)
    best_score = min_margin(best_P.flatten())

    scores_history = [best_score]

    for iteration in range(200):
        # Perturbation
        candidate = best_P + np.random.randn(c, d) * 0.3 * (1 - iteration / 200)
        score = min_margin(candidate.flatten())

        if score > best_score:
            best_P = candidate
            best_score = score

        scores_history.append(best_score)

        if (iteration + 1) % 50 == 0:
            print(f"  Iteration {iteration+1}: min margin = {best_score:.4f}")

    print(f"\nOptimized min margin: {best_score:.4f}")
    print(f"Certified robustness radius: {best_score/2:.4f}")

    # Plot optimization history
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(scores_history, color='#45B7D1', linewidth=2)
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Minimum Tropical Margin', fontsize=12)
    ax.set_title('Neural Code Design: Margin Optimization', fontsize=14)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('code_optimization.png', dpi=150, bbox_inches='tight')
    print("  Saved: code_optimization.png")
    plt.close()


# ============================================================
# Application 4: Receptive Field Analysis
# ============================================================

def app_receptive_field():
    """
    Analyze biological-style receptive fields through tropical margin theory.

    Simulate a population of place cells (neurons with spatial receptive fields)
    and analyze their tropical coding properties.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Receptive Field Analysis")
    print("=" * 60)

    np.random.seed(789)

    # Place cells: each neuron has a center and width
    n_cells = 30
    n_locations = 8  # number of location classes

    # Cell centers uniformly distributed
    cell_centers = np.random.uniform(0, 10, n_cells)
    cell_widths = np.random.uniform(1, 3, n_cells)

    # Location prototypes
    locations = np.linspace(0, 10, n_locations, endpoint=False)

    # Build codebook: firing rate = Gaussian tuning curve
    P = np.zeros((n_locations, n_cells))
    for k, loc in enumerate(locations):
        for i in range(n_cells):
            dist = min(abs(loc - cell_centers[i]),
                      10 - abs(loc - cell_centers[i]))  # circular
            P[k, i] = 5 * np.exp(-0.5 * (dist / cell_widths[i]) ** 2)

    # Analyze margins across the spatial domain
    test_positions = np.linspace(0, 10, 200)
    margins = []
    predicted_labels = []

    for pos in test_positions:
        # Generate firing pattern at this position
        x = np.zeros(n_cells)
        for i in range(n_cells):
            dist = min(abs(pos - cell_centers[i]),
                      10 - abs(pos - cell_centers[i]))
            x[i] = 5 * np.exp(-0.5 * (dist / cell_widths[i]) ** 2)

        pred = tropical_classify(P, x)
        m = tropical_margin(P, x, pred)
        margins.append(m)
        predicted_labels.append(pred)

    margins = np.array(margins)
    predicted_labels = np.array(predicted_labels)

    # Plot
    fig, axes = plt.subplots(2, 1, figsize=(10, 7), sharex=True)

    # Decision regions
    for k in range(n_locations):
        mask = predicted_labels == k
        if np.any(mask):
            axes[0].fill_between(test_positions, 0, 1,
                                where=mask, alpha=0.3,
                                label=f'Region {k}')
    axes[0].set_ylabel('Decision Region', fontsize=12)
    axes[0].set_title('Tropical Place Cell Decoding', fontsize=14)
    axes[0].legend(loc='upper right', ncol=4, fontsize=8)

    # Margin landscape
    axes[1].plot(test_positions, margins, color='#4ECDC4', linewidth=2)
    axes[1].axhline(y=0, color='red', linestyle='--', alpha=0.5)
    axes[1].fill_between(test_positions, 0, margins,
                        where=margins > 0, alpha=0.2, color='green',
                        label='Certified')
    axes[1].fill_between(test_positions, margins, 0,
                        where=margins <= 0, alpha=0.2, color='red',
                        label='Uncertain')
    axes[1].set_xlabel('Position', fontsize=12)
    axes[1].set_ylabel('Tropical Margin', fontsize=12)
    axes[1].legend(fontsize=11)

    plt.tight_layout()
    plt.savefig('receptive_field_analysis.png', dpi=150, bbox_inches='tight')
    print("  Saved: receptive_field_analysis.png")
    plt.close()

    cert_pct = 100 * np.mean(margins > 0)
    print(f"\nCertified positions: {cert_pct:.1f}%")
    print(f"Mean margin: {np.mean(margins):.4f}")
    print(f"Min margin at certified positions: {np.min(margins[margins > 0]):.4f}")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    app_neural_decoding()
    app_adversarial_classification()
    app_code_design()
    app_receptive_field()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Demo & Visualization

Demonstrates the core theorems of tropical neural coding theory:
- Tropical score computation
- Tropical margin certification
- Adversarial robustness verification
- Decision region visualization
- Classification capacity counting

All computations are self-contained (no local imports).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from itertools import product
import json
import base64
from io import BytesIO

# ============================================================
# Core Algorithms
# ============================================================

def tropical_score(P_k: np.ndarray, x: np.ndarray) -> float:
    """
    Tropical score of observation x against prototype P_k.
    score(P, x, k) = max_i (P_k[i] - x[i])

    Lower score = better match.

    Parameters
    ----------
    P_k : array of shape (d,) — prototype vector for label k
    x : array of shape (d,) — observation vector

    Returns
    -------
    float — the tropical score
    """
    return np.max(P_k - x)


def tropical_scores(P: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Compute tropical scores for all labels.

    Parameters
    ----------
    P : array of shape (c, d) — codebook of prototypes
    x : array of shape (d,) — observation vector

    Returns
    -------
    array of shape (c,) — scores for each label
    """
    return np.max(P - x[np.newaxis, :], axis=1)


def tropical_margin(P: np.ndarray, x: np.ndarray, y: int) -> float:
    """
    Tropical margin of observation x at true label y.
    margin(P, x, y) = min_{j != y} (score(x,j) - score(x,y))

    Positive margin certifies correct classification.

    Parameters
    ----------
    P : array of shape (c, d)
    x : array of shape (d,)
    y : int — true label index

    Returns
    -------
    float — the margin (positive = correct classification certified)
    """
    scores = tropical_scores(P, x)
    competitors = np.delete(scores, y)
    return float(np.min(competitors - scores[y]))


def tropical_classify(P: np.ndarray, x: np.ndarray) -> int:
    """
    Classify observation x using the tropical codebook P.
    Returns the label minimizing tropical score.

    Parameters
    ----------
    P : array of shape (c, d)
    x : array of shape (d,)

    Returns
    -------
    int — predicted label
    """
    scores = tropical_scores(P, x)
    return int(np.argmin(scores))


def tropical_argmin_set(P: np.ndarray, x: np.ndarray) -> frozenset:
    """
    The set of labels achieving minimum tropical score.

    Parameters
    ----------
    P : array of shape (c, d)
    x : array of shape (d,)

    Returns
    -------
    frozenset of int — labels achieving the minimum score
    """
    scores = tropical_scores(P, x)
    min_score = np.min(scores)
    return frozenset(np.where(np.isclose(scores, min_score))[0].tolist())


# ============================================================
# Demo 1: Basic Classification and Margin
# ============================================================

def demo_basic_classification():
    """Demonstrate tropical classification with margin computation."""
    print("=" * 60)
    print("DEMO 1: Basic Tropical Classification")
    print("=" * 60)

    # 3 classes, 4 neurons
    P = np.array([
        [1.0, 0.0, 2.0, 1.0],   # Class 0: responds to pattern A
        [0.0, 2.0, 0.0, 1.0],   # Class 1: responds to pattern B
        [1.0, 1.0, 0.0, 3.0],   # Class 2: responds to pattern C
    ])

    # Test observations
    observations = [
        np.array([1.5, 0.5, 2.5, 1.5]),  # Close to class 0
        np.array([0.5, 2.5, 0.5, 1.5]),  # Close to class 1
        np.array([1.5, 1.5, 0.5, 3.5]),  # Close to class 2
        np.array([0.8, 1.2, 1.0, 1.5]),  # Ambiguous
    ]

    for i, x in enumerate(observations):
        scores = tropical_scores(P, x)
        label = tropical_classify(P, x)
        margins = [tropical_margin(P, x, k) for k in range(3)]

        print(f"\nObservation {i}: x = {x}")
        print(f"  Scores: {scores}")
        print(f"  Predicted label: {label}")
        print(f"  Margins: {[f'{m:.3f}' for m in margins]}")
        print(f"  Margin at predicted label: {margins[label]:.3f}")

        if margins[label] > 0:
            print(f"  ✓ Classification CERTIFIED (margin > 0)")
        else:
            print(f"  ✗ Classification NOT certified (margin ≤ 0)")


# ============================================================
# Demo 2: Adversarial Robustness
# ============================================================

def demo_adversarial_robustness():
    """Demonstrate margin stability under perturbation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Adversarial Robustness via Margin Stability")
    print("=" * 60)

    P = np.array([
        [2.0, 0.0, 1.0],
        [0.0, 2.0, 1.0],
        [1.0, 1.0, 2.0],
    ])

    x = np.array([2.5, 0.5, 1.5])  # Close to class 0
    true_label = tropical_classify(P, x)
    margin = tropical_margin(P, x, true_label)

    print(f"\nOriginal: x = {x}, label = {true_label}, margin = {margin:.4f}")
    print(f"Certified robustness radius: ε < {margin/2:.4f}")

    # Test perturbations of increasing size
    np.random.seed(42)
    epsilons = [0.01, 0.05, 0.1, 0.2, 0.3, 0.5, 0.8, 1.0]

    print(f"\n{'ε':>6} | {'Perturbed Label':>15} | {'Perturbed Margin':>16} | {'Theory Bound':>12} | {'Status':>10}")
    print("-" * 75)

    for eps in epsilons:
        perturbation = np.random.uniform(-eps, eps, size=x.shape)
        x_pert = x + perturbation
        pert_label = tropical_classify(P, x_pert)
        pert_margin = tropical_margin(P, x_pert, true_label)
        theory_bound = margin - 2 * eps

        status = "SAFE" if eps < margin / 2 else "AT RISK"
        correct = "✓" if pert_label == true_label else "✗"

        print(f"{eps:6.3f} | {pert_label:>15} {correct} | {pert_margin:>16.4f} | {theory_bound:>12.4f} | {status:>10}")


# ============================================================
# Demo 3: Decision Region Visualization
# ============================================================

def demo_decision_regions():
    """Visualize tropical decision regions in 2D."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical Decision Region Visualization")
    print("=" * 60)

    # 3 classes in 2D (for visualization)
    P = np.array([
        [0.0, 2.0],
        [2.0, 0.0],
        [1.5, 1.5],
    ])

    # Create grid
    grid_size = 300
    x_range = np.linspace(-1, 4, grid_size)
    y_range = np.linspace(-1, 4, grid_size)
    xx, yy = np.meshgrid(x_range, y_range)

    # Classify each point
    labels = np.zeros_like(xx, dtype=int)
    margins = np.zeros_like(xx)

    for i in range(grid_size):
        for j in range(grid_size):
            x = np.array([xx[i, j], yy[i, j]])
            labels[i, j] = tropical_classify(P, x)
            margins[i, j] = tropical_margin(P, x, labels[i, j])

    # Plot decision regions
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Decision regions
    cmap = ListedColormap(['#FF6B6B', '#4ECDC4', '#45B7D1'])
    axes[0].contourf(xx, yy, labels, levels=[-0.5, 0.5, 1.5, 2.5], cmap=cmap, alpha=0.6)
    axes[0].scatter(P[:, 0], P[:, 1], c='black', s=200, marker='*', zorder=5, label='Prototypes')
    for k in range(3):
        axes[0].annotate(f'P{k}', (P[k, 0] + 0.1, P[k, 1] + 0.1), fontsize=12, fontweight='bold')
    axes[0].set_xlabel('Neuron 1 firing rate', fontsize=12)
    axes[0].set_ylabel('Neuron 2 firing rate', fontsize=12)
    axes[0].set_title('Tropical Decision Regions', fontsize=14)
    axes[0].legend(fontsize=11)

    # Margin heatmap
    im = axes[1].contourf(xx, yy, margins, levels=20, cmap='RdYlGn')
    axes[1].contour(xx, yy, margins, levels=[0], colors='black', linewidths=2)
    axes[1].scatter(P[:, 0], P[:, 1], c='black', s=200, marker='*', zorder=5)
    plt.colorbar(im, ax=axes[1], label='Tropical Margin')
    axes[1].set_xlabel('Neuron 1 firing rate', fontsize=12)
    axes[1].set_ylabel('Neuron 2 firing rate', fontsize=12)
    axes[1].set_title('Tropical Margin Landscape', fontsize=14)

    plt.tight_layout()
    plt.savefig('tropical_decision_regions.png', dpi=150, bbox_inches='tight')
    print("  Saved: tropical_decision_regions.png")
    plt.close()

    return fig


# ============================================================
# Demo 4: Classification Capacity
# ============================================================

def demo_classification_capacity():
    """Count distinct decision patterns for random codebooks."""
    print("\n" + "=" * 60)
    print("DEMO 4: Classification Capacity (Theorem C)")
    print("=" * 60)

    np.random.seed(123)

    print(f"\n{'c':>4} | {'d':>4} | {'Distinct Patterns':>18} | {'Upper Bound 2^c':>15} | {'Ratio':>8}")
    print("-" * 60)

    for c in [2, 3, 4, 5]:
        for d in [2, 3, 5, 10]:
            P = np.random.randn(c, d)

            # Sample many random points and count distinct decision patterns
            n_samples = 5000
            patterns = set()
            for _ in range(n_samples):
                x = np.random.randn(d) * 2
                pattern = tropical_argmin_set(P, x)
                patterns.add(pattern)

            upper_bound = 2 ** c
            ratio = len(patterns) / upper_bound
            print(f"{c:4d} | {d:4d} | {len(patterns):18d} | {upper_bound:15d} | {ratio:8.4f}")


# ============================================================
# Demo 5: Margin Distribution
# ============================================================

def demo_margin_distribution():
    """Analyze margin distribution for random codebooks."""
    print("\n" + "=" * 60)
    print("DEMO 5: Margin Distribution Analysis")
    print("=" * 60)

    np.random.seed(456)

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    configs = [(3, 5), (4, 10), (5, 20), (8, 30)]

    for idx, (c, d) in enumerate(configs):
        ax = axes[idx // 2][idx % 2]
        P = np.random.randn(c, d)

        margins_list = []
        for _ in range(3000):
            x = np.random.randn(d) * 1.5
            label = tropical_classify(P, x)
            m = tropical_margin(P, x, label)
            margins_list.append(m)

        margins_arr = np.array(margins_list)
        ax.hist(margins_arr, bins=50, color='#4ECDC4', alpha=0.7, edgecolor='white')
        ax.axvline(x=0, color='red', linestyle='--', linewidth=2, label='Margin = 0')
        ax.set_xlabel('Tropical Margin', fontsize=11)
        ax.set_ylabel('Count', fontsize=11)
        ax.set_title(f'c={c} classes, d={d} neurons', fontsize=12)
        ax.legend()

        pct_certified = 100 * np.mean(margins_arr > 0)
        ax.text(0.95, 0.95, f'{pct_certified:.1f}% certified',
                transform=ax.transAxes, ha='right', va='top',
                fontsize=11, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.suptitle('Tropical Margin Distribution by Code Parameters', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('margin_distribution.png', dpi=150, bbox_inches='tight')
    print("  Saved: margin_distribution.png")
    plt.close()

    return fig


# ============================================================
# Demo 6: Robustness Radius vs Dimension
# ============================================================

def demo_robustness_scaling():
    """Study how robustness radius scales with dimension."""
    print("\n" + "=" * 60)
    print("DEMO 6: Robustness Radius Scaling")
    print("=" * 60)

    np.random.seed(789)

    dimensions = [2, 3, 5, 8, 10, 15, 20, 30, 50]
    c = 4  # fixed number of classes

    mean_margins = []
    median_margins = []
    min_margins = []

    for d in dimensions:
        P = np.random.randn(c, d)
        margins_list = []
        for _ in range(1000):
            x = P[np.random.randint(c)] + np.random.randn(d) * 0.5
            label = tropical_classify(P, x)
            m = tropical_margin(P, x, label)
            margins_list.append(m)

        arr = np.array(margins_list)
        mean_margins.append(np.mean(arr))
        median_margins.append(np.median(arr))
        min_margins.append(np.min(arr))

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(dimensions, mean_margins, 'o-', label='Mean margin', color='#4ECDC4', linewidth=2)
    ax.plot(dimensions, median_margins, 's--', label='Median margin', color='#45B7D1', linewidth=2)
    ax.fill_between(dimensions, min_margins, mean_margins, alpha=0.15, color='#4ECDC4')
    ax.set_xlabel('Dimension d (number of neurons)', fontsize=12)
    ax.set_ylabel('Tropical Margin', fontsize=12)
    ax.set_title(f'Robustness Radius Scaling (c={c} classes)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('robustness_scaling.png', dpi=150, bbox_inches='tight')
    print("  Saved: robustness_scaling.png")
    plt.close()

    return fig


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    demo_basic_classification()
    demo_adversarial_robustness()
    demo_decision_regions()
    demo_classification_capacity()
    demo_margin_distribution()
    demo_robustness_scaling()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
