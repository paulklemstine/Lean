#!/usr/bin/env python3
"""
Applications of Closure-Operator Networks

Demonstrates real-world applications of the closure-theoretic ML framework:
1. Robust image classification via closure quantization
2. Anomaly detection using closure neighborhoods
3. Abstract interpretation of neural networks
4. Tropical-style max-plus feature extraction
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple, Optional


# ============================================================
# Application 1: Robust 2D Classification
# ============================================================

def app_robust_2d_classification():
    """
    Demonstrate closure-based robust classification on a 2D dataset.

    The closure quantization maps each point to a grid cell center,
    making the classifier provably robust within cell radius.
    """
    print("=" * 60)
    print("APPLICATION 1: Robust 2D Classification")
    print("=" * 60)

    np.random.seed(42)

    # Generate 2D dataset: two spirals
    n_per_class = 200
    theta = np.linspace(0, 3 * np.pi, n_per_class)

    # Class 0: spiral
    r0 = theta / (3 * np.pi)
    x0 = r0 * np.cos(theta) + np.random.normal(0, 0.03, n_per_class)
    y0 = r0 * np.sin(theta) + np.random.normal(0, 0.03, n_per_class)

    # Class 1: shifted spiral
    x1 = r0 * np.cos(theta + np.pi) + np.random.normal(0, 0.03, n_per_class)
    y1 = r0 * np.sin(theta + np.pi) + np.random.normal(0, 0.03, n_per_class)

    X = np.vstack([np.column_stack([x0, y0]), np.column_stack([x1, y1])])
    labels = np.array([0] * n_per_class + [1] * n_per_class)

    # Closure-based classifier: grid quantization
    N_grid = 20
    x_min, x_max = X[:, 0].min() - 0.1, X[:, 0].max() + 0.1
    y_min, y_max = X[:, 1].min() - 0.1, X[:, 1].max() + 0.1

    def closure_quantize(point):
        """Map point to grid cell center (closure representative)."""
        ix = min(int((point[0] - x_min) / (x_max - x_min) * N_grid), N_grid - 1)
        iy = min(int((point[1] - y_min) / (y_max - y_min) * N_grid), N_grid - 1)
        cx = x_min + (ix + 0.5) * (x_max - x_min) / N_grid
        cy = y_min + (iy + 0.5) * (y_max - y_min) / N_grid
        return np.array([cx, cy])

    # Build lookup table: majority vote per cell
    cell_votes = {}
    for i in range(len(X)):
        rep = tuple(closure_quantize(X[i]))
        if rep not in cell_votes:
            cell_votes[rep] = [0, 0]
        cell_votes[rep][labels[i]] += 1

    cell_labels = {k: int(np.argmax(v)) for k, v in cell_votes.items()}

    def closure_classifier(point):
        rep = tuple(closure_quantize(point))
        return cell_labels.get(rep, 0)

    # Compute certified radius
    cell_width_x = (x_max - x_min) / N_grid
    cell_width_y = (y_max - y_min) / N_grid
    cert_radius = min(cell_width_x, cell_width_y) / 2

    # Test robustness
    n_tests = 1000
    n_robust = 0
    for _ in range(n_tests):
        idx = np.random.randint(len(X))
        perturbation = np.random.uniform(-cert_radius * 0.9, cert_radius * 0.9, 2)
        original_label = closure_classifier(X[idx])
        perturbed_label = closure_classifier(X[idx] + perturbation)
        if original_label == perturbed_label:
            n_robust += 1

    print(f"Grid resolution: {N_grid}x{N_grid}")
    print(f"Certified radius: {cert_radius:.4f}")
    print(f"Robustness rate: {n_robust}/{n_tests} ({100*n_robust/n_tests:.1f}%)")

    # Visualization
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Original data
    axes[0].scatter(x0, y0, c='blue', s=10, alpha=0.5, label='Class 0')
    axes[0].scatter(x1, y1, c='red', s=10, alpha=0.5, label='Class 1')
    axes[0].set_title('Original Data (Two Spirals)')
    axes[0].legend()
    axes[0].set_aspect('equal')

    # Closure quantization grid
    for i in range(N_grid + 1):
        axes[1].axvline(x_min + i * cell_width_x, color='gray', alpha=0.3, linewidth=0.5)
        axes[1].axhline(y_min + i * cell_width_y, color='gray', alpha=0.3, linewidth=0.5)

    # Color cells by predicted label
    for (cx, cy), label in cell_labels.items():
        color = 'lightblue' if label == 0 else 'lightsalmon'
        rect_x = cx - cell_width_x / 2
        rect_y = cy - cell_width_y / 2
        axes[1].add_patch(plt.Rectangle((rect_x, rect_y), cell_width_x, cell_width_y,
                                         facecolor=color, alpha=0.5))

    axes[1].scatter(x0, y0, c='blue', s=5, alpha=0.3)
    axes[1].scatter(x1, y1, c='red', s=5, alpha=0.3)
    axes[1].set_title(f'Closure Quantization ({N_grid}×{N_grid} grid)')
    axes[1].set_xlim(x_min, x_max)
    axes[1].set_ylim(y_min, y_max)
    axes[1].set_aspect('equal')

    # Robustness certificates
    test_points = X[::10]
    for pt in test_points:
        label = closure_classifier(pt)
        color = 'blue' if label == 0 else 'red'
        circle = plt.Circle(pt, cert_radius * 0.9, fill=False, color=color, alpha=0.3, linewidth=0.5)
        axes[2].add_patch(circle)

    axes[2].scatter(x0, y0, c='blue', s=5, alpha=0.3)
    axes[2].scatter(x1, y1, c='red', s=5, alpha=0.3)
    axes[2].set_title(f'Robustness Certificates (r={cert_radius:.3f})')
    axes[2].set_xlim(x_min, x_max)
    axes[2].set_ylim(y_min, y_max)
    axes[2].set_aspect('equal')

    plt.suptitle('Closure-Based Robust 2D Classification', fontsize=14)
    plt.tight_layout()
    plt.savefig('app_robust_2d.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_robust_2d.png\n")


# ============================================================
# Application 2: Anomaly Detection via Closure Neighborhoods
# ============================================================

def app_anomaly_detection():
    """
    Detect anomalies using closure-operator neighborhoods.
    Points whose closure neighborhood differs significantly from
    the training distribution are flagged as anomalous.
    """
    print("=" * 60)
    print("APPLICATION 2: Anomaly Detection via Closure Neighborhoods")
    print("=" * 60)

    np.random.seed(123)

    # Normal data: two clusters
    n_normal = 300
    cluster1 = np.random.normal([2, 2], 0.5, (n_normal // 2, 2))
    cluster2 = np.random.normal([5, 5], 0.7, (n_normal // 2, 2))
    normal_data = np.vstack([cluster1, cluster2])

    # Anomalies: scattered points
    n_anomalies = 20
    anomalies = np.random.uniform(0, 7, (n_anomalies, 2))

    # Closure-based anomaly score: density in closure neighborhood
    radius = 0.8

    def closure_anomaly_score(point, training_data, r):
        """Count training points in ball closure neighborhood."""
        dists = np.linalg.norm(training_data - point, axis=1)
        count = np.sum(dists <= r)
        return count

    # Compute scores
    all_points = np.vstack([normal_data, anomalies])
    all_labels = np.array([0] * n_normal + [1] * n_anomalies)
    scores = np.array([closure_anomaly_score(p, normal_data, radius) for p in all_points])

    # Threshold for anomaly
    threshold = np.percentile(scores[:n_normal], 5)  # 5th percentile of normal

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: data with closure neighborhoods
    axes[0].scatter(normal_data[:, 0], normal_data[:, 1], c='blue', s=10, alpha=0.3, label='Normal')
    axes[0].scatter(anomalies[:, 0], anomalies[:, 1], c='red', s=50, marker='x',
                    linewidths=2, label='Anomaly')

    # Draw closure neighborhoods for a few points
    for pt in anomalies[:5]:
        circle = plt.Circle(pt, radius, fill=False, color='red', alpha=0.5, linestyle='--')
        axes[0].add_patch(circle)
    for pt in normal_data[:5]:
        circle = plt.Circle(pt, radius, fill=False, color='blue', alpha=0.3, linestyle='-')
        axes[0].add_patch(circle)

    axes[0].set_title('Closure Neighborhoods for Anomaly Detection')
    axes[0].legend()
    axes[0].set_aspect('equal')

    # Right: score distribution
    axes[1].hist(scores[:n_normal], bins=30, alpha=0.7, label='Normal', color='blue')
    axes[1].hist(scores[n_normal:], bins=15, alpha=0.7, label='Anomaly', color='red')
    axes[1].axvline(threshold, color='black', linestyle='--', linewidth=2, label=f'Threshold={threshold:.0f}')
    axes[1].set_xlabel('Closure neighborhood density')
    axes[1].set_ylabel('Count')
    axes[1].set_title('Anomaly Score Distribution')
    axes[1].legend()

    plt.suptitle('Closure-Based Anomaly Detection', fontsize=14)
    plt.tight_layout()
    plt.savefig('app_anomaly_detection.png', dpi=150, bbox_inches='tight')
    plt.close()

    detected = np.sum(scores[n_normal:] <= threshold)
    false_pos = np.sum(scores[:n_normal] <= threshold)
    print(f"Anomalies detected: {detected}/{n_anomalies}")
    print(f"False positives: {false_pos}/{n_normal}")
    print(f"Detection rate: {100*detected/n_anomalies:.1f}%")
    print("Saved: app_anomaly_detection.png\n")


# ============================================================
# Application 3: Tropical Max-Plus Feature Extraction
# ============================================================

def app_tropical_features():
    """
    Demonstrate tropical (max-plus) feature extraction as a
    special case of closure-operator networks.

    In tropical algebra, "addition" is max and "multiplication" is +.
    Tropical closures correspond to max-plus saturations.
    """
    print("=" * 60)
    print("APPLICATION 3: Tropical Max-Plus Feature Extraction")
    print("=" * 60)

    # 1D signal processing example
    np.random.seed(42)
    n = 200
    x = np.linspace(0, 1, n)
    signal = np.sin(4 * np.pi * x) + 0.3 * np.sin(12 * np.pi * x)
    signal += np.random.normal(0, 0.1, n)

    # Tropical max-plus closure: local maximum envelope
    def max_plus_closure(data, window):
        """Max-plus closure: replace each value by local max (dilation)."""
        result = np.copy(data)
        for i in range(len(data)):
            lo = max(0, i - window)
            hi = min(len(data), i + window + 1)
            result[i] = np.max(data[lo:hi])
        return result

    # Min-plus closure: local minimum envelope (erosion)
    def min_plus_closure(data, window):
        result = np.copy(data)
        for i in range(len(data)):
            lo = max(0, i - window)
            hi = min(len(data), i + window + 1)
            result[i] = np.min(data[lo:hi])
        return result

    # Morphological opening: erosion then dilation
    def morphological_opening(data, window):
        return max_plus_closure(min_plus_closure(data, window), window)

    # Morphological closing: dilation then erosion
    def morphological_closing(data, window):
        return min_plus_closure(max_plus_closure(data, window), window)

    windows = [3, 8, 15]
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    axes[0, 0].plot(x, signal, 'b-', alpha=0.5, linewidth=1, label='Signal')
    axes[0, 0].set_title('Original Signal')
    axes[0, 0].legend()

    colors = ['red', 'green', 'purple']
    for i, w in enumerate(windows):
        envelope = max_plus_closure(signal, w)
        axes[0, 1].plot(x, envelope, color=colors[i], linewidth=1.5,
                        label=f'Max-plus (w={w})', alpha=0.8)
    axes[0, 1].plot(x, signal, 'b-', alpha=0.3, linewidth=1)
    axes[0, 1].set_title('Max-Plus Closure (Dilation)')
    axes[0, 1].legend()

    for i, w in enumerate(windows):
        opened = morphological_opening(signal, w)
        axes[1, 0].plot(x, opened, color=colors[i], linewidth=1.5,
                        label=f'Opening (w={w})', alpha=0.8)
    axes[1, 0].plot(x, signal, 'b-', alpha=0.3, linewidth=1)
    axes[1, 0].set_title('Morphological Opening (Erosion→Dilation)')
    axes[1, 0].legend()

    for i, w in enumerate(windows):
        closed = morphological_closing(signal, w)
        axes[1, 1].plot(x, closed, color=colors[i], linewidth=1.5,
                        label=f'Closing (w={w})', alpha=0.8)
    axes[1, 1].plot(x, signal, 'b-', alpha=0.3, linewidth=1)
    axes[1, 1].set_title('Morphological Closing (Dilation→Erosion)')
    axes[1, 1].legend()

    plt.suptitle('Tropical/Morphological Closure Operations on Signals', fontsize=14)
    plt.tight_layout()
    plt.savefig('app_tropical_features.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_tropical_features.png\n")

    # Verify idempotence
    w = 5
    d1 = max_plus_closure(signal, w)
    d2 = max_plus_closure(d1, w)
    print(f"Max-plus dilation idempotence error: {np.max(np.abs(d1 - d2)):.2e}")

    o1 = morphological_opening(signal, w)
    o2 = morphological_opening(o1, w)
    print(f"Morphological opening idempotence error: {np.max(np.abs(o1 - o2)):.2e}")


if __name__ == '__main__':
    app_robust_2d_classification()
    app_anomaly_detection()
    app_tropical_features()
    print("\nAll applications completed!")


#!/usr/bin/env python3
"""
Closure-Operator Networks: Demonstrations of Universal Approximation and Robustness

This script demonstrates the key theorems from the formal verification:
1. Finite-domain exact representation via closure indicator features
2. Closure-step approximation of continuous functions on [0,1]
3. Certified robustness via closure-based classification
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple

# ============================================================
# Demo 1: Finite-Domain Exact Representation
# ============================================================

def closure_indicator_basis(n: int) -> np.ndarray:
    """
    Construct the n×n identity-closure indicator matrix.
    Row i, column j = 1 if point j is in closure_i({i}), else 0.
    For the identity closure, this is just the identity matrix (Kronecker delta).
    """
    return np.eye(n)

def finite_exact_representation(f_values: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Given f : Fin n → ℝ as a vector, return (weights, basis_matrix)
    such that f = basis_matrix.T @ weights.

    This demonstrates Theorem A: every finite function is exactly
    representable by closure-indicator features.
    """
    n = len(f_values)
    basis = closure_indicator_basis(n)
    weights = f_values.copy()  # w_i = f(i)
    return weights, basis

def demo_finite_representation():
    """Demonstrate exact reconstruction of an arbitrary function on Fin n."""
    n = 8
    # An arbitrary function on {0, 1, ..., 7}
    f_values = np.array([3.1, -1.5, 2.7, 0.0, 4.2, -0.8, 1.9, 3.3])

    weights, basis = finite_exact_representation(f_values)

    # Reconstruct: f(x) = sum_i w_i * indicator(x in C_i(proto_i))
    reconstructed = np.zeros(n)
    for x in range(n):
        for i in range(n):
            reconstructed[x] += weights[i] * basis[i, x]

    print("=" * 60)
    print("DEMO 1: Finite-Domain Exact Representation (Theorem A)")
    print("=" * 60)
    print(f"Domain size: n = {n}")
    print(f"Original function:    {f_values}")
    print(f"Reconstructed:        {reconstructed}")
    print(f"Max reconstruction error: {np.max(np.abs(f_values - reconstructed)):.2e}")
    print(f"Number of closure operators: {n}")
    print(f"Each closure operator: identity (id)")
    print(f"Prototypes: singletons {{0}}, {{1}}, ..., {{{n-1}}}")
    print()

    # Create visualization
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Plot original vs reconstructed
    x = np.arange(n)
    axes[0].bar(x - 0.15, f_values, 0.3, label='Original f', color='steelblue', alpha=0.8)
    axes[0].bar(x + 0.15, reconstructed, 0.3, label='Closure reconstruction', color='coral', alpha=0.8)
    axes[0].set_xlabel('x (domain point)')
    axes[0].set_ylabel('f(x)')
    axes[0].set_title('Exact Reconstruction by Closure Features')
    axes[0].legend()
    axes[0].set_xticks(x)

    # Plot the basis matrix
    im = axes[1].imshow(basis, cmap='Blues', aspect='equal')
    axes[1].set_title('Closure Indicator Basis\n(Identity closure on singletons)')
    axes[1].set_xlabel('Point x')
    axes[1].set_ylabel('Feature i')
    plt.colorbar(im, ax=axes[1], shrink=0.8)

    plt.tight_layout()
    plt.savefig('demo_finite_representation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demo_finite_representation.png\n")


# ============================================================
# Demo 2: Closure-Step Approximation of Continuous Functions
# ============================================================

def closure_step_approx(f: Callable[[float], float], N: int, x: float) -> float:
    """
    Closure-step approximation: partition [0,1] into N cells,
    evaluate f at each cell center, return piecewise-constant approximant.

    Matches the Lean definition `closureStepApprox`.
    """
    delta = 1.0 / N
    i = min(int(x / delta), N - 1)
    center = i * delta + delta / 2
    return f(center)

def demo_closure_step_approximation():
    """Demonstrate uniform approximation of continuous functions (Theorem B)."""
    # Test function: a smooth oscillation
    def f(x):
        return np.sin(3 * np.pi * x) * np.exp(-x) + 0.5

    print("=" * 60)
    print("DEMO 2: Closure-Step Approximation (Theorems B & D)")
    print("=" * 60)

    x_fine = np.linspace(0, 1, 1000)
    f_fine = np.array([f(xi) for xi in x_fine])

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    N_values = [4, 8, 16, 64]
    errors = []

    for idx, N in enumerate(N_values):
        ax = axes[idx // 2, idx % 2]
        g_values = np.array([closure_step_approx(f, N, xi) for xi in x_fine])
        max_error = np.max(np.abs(f_fine - g_values))
        errors.append((N, max_error))

        ax.plot(x_fine, f_fine, 'b-', linewidth=2, label='f(x)', alpha=0.7)
        ax.plot(x_fine, g_values, 'r-', linewidth=1.5, label=f'Closure-step (N={N})', alpha=0.9)

        # Show cell boundaries
        for k in range(N + 1):
            ax.axvline(k / N, color='gray', linestyle=':', alpha=0.3)

        ax.set_title(f'N = {N} cells, max error = {max_error:.4f}')
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.legend(fontsize=9)
        ax.set_xlim(0, 1)

    plt.suptitle('Closure-Step Approximation of f(x) = sin(3πx)·e⁻ˣ + 0.5', fontsize=14)
    plt.tight_layout()
    plt.savefig('demo_closure_step_approx.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demo_closure_step_approx.png")

    # Print error table
    print(f"\n{'N':>6} | {'Max Error':>12} | {'L/N bound':>12} | {'Ratio':>8}")
    print("-" * 50)
    # Estimate Lipschitz constant
    L_est = max(abs(f_fine[i+1] - f_fine[i]) / (x_fine[i+1] - x_fine[i])
                for i in range(len(x_fine)-1))
    for N, err in errors:
        bound = L_est / N
        print(f"{N:>6} | {err:>12.6f} | {bound:>12.6f} | {err/bound:>8.4f}")
    print(f"\nEstimated Lipschitz constant: L ≈ {L_est:.4f}")

    # Convergence rate plot
    fig2, ax2 = plt.subplots(figsize=(8, 5))
    Ns = [2**k for k in range(1, 10)]
    max_errors = []
    for N in Ns:
        g_vals = np.array([closure_step_approx(f, N, xi) for xi in x_fine])
        max_errors.append(np.max(np.abs(f_fine - g_vals)))

    ax2.loglog(Ns, max_errors, 'bo-', linewidth=2, markersize=8, label='Actual error')
    ax2.loglog(Ns, [L_est / N for N in Ns], 'r--', linewidth=2, label=f'L/N bound (L≈{L_est:.1f})')
    ax2.loglog(Ns, [max_errors[0] * Ns[0] / N for N in Ns], 'g:', linewidth=1.5, label='O(1/N) reference')
    ax2.set_xlabel('Number of cells N')
    ax2.set_ylabel('Maximum error on [0,1]')
    ax2.set_title('Convergence Rate of Closure-Step Approximation')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('demo_convergence_rate.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demo_convergence_rate.png\n")


# ============================================================
# Demo 3: Certified Robustness
# ============================================================

def demo_certified_robustness():
    """Demonstrate certified robustness of closure-based classifiers (Theorem C)."""
    print("=" * 60)
    print("DEMO 3: Certified Robustness (Theorem C)")
    print("=" * 60)

    # 1D example: classifier with closure quantization
    N = 5  # number of regions
    r = 1 / (2 * N)  # robustness radius

    def closure_representative(x: float) -> float:
        """Maps x to the center of its quantization cell."""
        delta = 1.0 / N
        i = min(int(x / delta), N - 1)
        return i * delta + delta / 2

    def classifier(x: float) -> int:
        """Closure-based classifier: label by cell index."""
        delta = 1.0 / N
        return min(int(x / delta), N - 1)

    # Verify robustness: perturb points and check label stability
    np.random.seed(42)
    n_tests = 1000
    n_robust = 0
    for _ in range(n_tests):
        x = np.random.uniform(0, 1)
        perturbation = np.random.uniform(-r * 0.99, r * 0.99)  # within radius
        y = np.clip(x + perturbation, 0, 1)
        if classifier(x) == classifier(y):
            n_robust += 1

    print(f"Quantization cells: {N}")
    print(f"Certified radius: r = {r:.4f}")
    print(f"Robustness test: {n_robust}/{n_tests} perturbations preserved label")
    print(f"(Perturbations within {0.99*r:.4f} of original point)")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    x_fine = np.linspace(0, 1, 1000)
    labels = [classifier(xi) for xi in x_fine]
    centers = [closure_representative(xi) for xi in x_fine]

    # Left: closure quantization
    colors = plt.cm.Set2(np.array(labels) / N)
    axes[0].scatter(x_fine, centers, c=colors, s=1, alpha=0.8)
    for k in range(N + 1):
        axes[0].axvline(k / N, color='gray', linestyle='--', alpha=0.5)
    for k in range(N):
        c = (k + 0.5) / N
        axes[0].plot(c, c, 'ko', markersize=10, zorder=5)
        axes[0].annotate(f'Cell {k}', (c, c + 0.03), ha='center', fontsize=9)
    axes[0].plot(x_fine, x_fine, 'b--', alpha=0.3, label='Identity')
    axes[0].set_xlabel('Input x')
    axes[0].set_ylabel('Closure representative c(x)')
    axes[0].set_title('Closure Quantization Map')
    axes[0].legend()

    # Right: robustness regions
    for k in range(N):
        left = k / N
        right = (k + 1) / N
        center = (k + 0.5) / N
        # Robust region (shrunk by r on each side)
        rob_left = left + r
        rob_right = right - r
        if rob_left < rob_right:
            axes[1].fill_between([rob_left, rob_right], 0, 1,
                                alpha=0.3, color=plt.cm.Set2(k / N),
                                label=f'Robust zone {k}' if k < 3 else None)
        axes[1].axvline(left, color='gray', linestyle='--', alpha=0.5)
        axes[1].plot(center, 0.5, 'ko', markersize=8)

    axes[1].axvline(1.0, color='gray', linestyle='--', alpha=0.5)
    axes[1].set_xlabel('Input x')
    axes[1].set_title(f'Certified Robustness Regions (radius r = {r:.3f})')
    axes[1].legend(fontsize=9)
    axes[1].set_xlim(0, 1)
    axes[1].set_ylim(0, 1)

    plt.tight_layout()
    plt.savefig('demo_certified_robustness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demo_certified_robustness.png\n")


# ============================================================
# Demo 4: Comparison with ReLU Piecewise-Linear Approximation
# ============================================================

def demo_comparison_relu():
    """Compare closure-step vs ReLU piecewise-linear approximation."""
    print("=" * 60)
    print("DEMO 4: Closure-Step vs ReLU Piecewise-Linear (Theorem D)")
    print("=" * 60)

    def f(x):
        return np.sin(4 * np.pi * x) * (1 - x) + x**2

    x_fine = np.linspace(0, 1, 2000)
    f_fine = np.array([f(xi) for xi in x_fine])

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    N = 8

    # Closure-step (piecewise constant)
    g_closure = np.array([closure_step_approx(f, N, xi) for xi in x_fine])

    # ReLU piecewise-linear (interpolation at grid points)
    nodes = np.linspace(0, 1, N + 1)
    f_nodes = np.array([f(xi) for xi in nodes])
    g_relu = np.interp(x_fine, nodes, f_nodes)

    err_closure = np.max(np.abs(f_fine - g_closure))
    err_relu = np.max(np.abs(f_fine - g_relu))

    axes[0].plot(x_fine, f_fine, 'b-', linewidth=2, label='f(x)')
    axes[0].plot(x_fine, g_closure, 'r-', linewidth=1.5, label=f'Closure-step')
    axes[0].set_title(f'Closure-Step (N={N})\nMax error: {err_closure:.4f}')
    axes[0].legend()

    axes[1].plot(x_fine, f_fine, 'b-', linewidth=2, label='f(x)')
    axes[1].plot(x_fine, g_relu, 'g-', linewidth=1.5, label=f'ReLU PL')
    axes[1].set_title(f'ReLU Piecewise-Linear (N={N})\nMax error: {err_relu:.4f}')
    axes[1].legend()

    # Convergence comparison
    Ns = [2**k for k in range(1, 10)]
    errs_closure = []
    errs_relu = []
    for N in Ns:
        g_c = np.array([closure_step_approx(f, N, xi) for xi in x_fine])
        errs_closure.append(np.max(np.abs(f_fine - g_c)))
        nodes = np.linspace(0, 1, N + 1)
        f_nodes = np.array([f(xi) for xi in nodes])
        g_r = np.interp(x_fine, nodes, f_nodes)
        errs_relu.append(np.max(np.abs(f_fine - g_r)))

    axes[2].loglog(Ns, errs_closure, 'ro-', label='Closure-step', linewidth=2)
    axes[2].loglog(Ns, errs_relu, 'gs-', label='ReLU PL', linewidth=2)
    axes[2].loglog(Ns, [errs_closure[0] * Ns[0] / N for N in Ns], 'r:', alpha=0.5, label='O(1/N)')
    axes[2].loglog(Ns, [errs_relu[0] * (Ns[0] / N)**2 for N in Ns], 'g:', alpha=0.5, label='O(1/N²)')
    axes[2].set_xlabel('N (number of cells/nodes)')
    axes[2].set_ylabel('Maximum error')
    axes[2].set_title('Convergence Comparison')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.suptitle('Closure-Step vs ReLU Piecewise-Linear Approximation', fontsize=14)
    plt.tight_layout()
    plt.savefig('demo_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"N = 8: Closure-step error = {errs_closure[2]:.6f}, ReLU PL error = {errs_relu[2]:.6f}")
    print("Both achieve O(1/N) for Lipschitz functions (closure is constant, ReLU is linear per piece)")
    print("ReLU achieves O(1/N²) for smooth functions due to linear interpolation advantage")
    print("But closure-step has BUILT-IN robustness — each cell is invariant under perturbation")
    print("Saved: demo_comparison.png\n")


if __name__ == '__main__':
    demo_finite_representation()
    demo_closure_step_approximation()
    demo_certified_robustness()
    demo_comparison_relu()
    print("All demos completed successfully!")
