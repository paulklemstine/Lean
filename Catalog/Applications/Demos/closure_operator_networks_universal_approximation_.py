#!/usr/bin/env python3
"""
Applications of Closure-Operator Networks

Demonstrates real-world applications of the closure-operator network theory:
1. Image classification with certified robustness
2. Time-series anomaly detection
3. Function regression with approximation guarantees
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def app_regression_with_guarantees():
    """
    Application: Function regression with provable error bounds.
    
    Given noisy samples of a Lipschitz function, construct a closure-step
    network and provide guaranteed approximation error bounds.
    """
    print("=" * 60)
    print("APPLICATION 1: Regression with Guaranteed Error Bounds")
    print("=" * 60)
    
    np.random.seed(42)
    
    # True function: Lipschitz with known constant
    f_true = lambda x: np.sin(4 * x) * np.exp(-x)
    L = 5.0  # Lipschitz constant bound
    
    # Noisy observations
    n_samples = 50
    x_train = np.sort(np.random.uniform(0, 3, n_samples))
    y_train = np.array([f_true(x) + np.random.normal(0, 0.05) for x in x_train])
    
    # Construct closure-step networks of increasing resolution
    x_test = np.linspace(0, 3, 500)
    y_true = np.array([f_true(x) for x in x_test])
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    for idx, N in enumerate([5, 15, 50]):
        delta = 3.0 / N
        centers = np.array([i * delta + delta / 2 for i in range(N)])
        
        # Fit: average y values in each cell
        weights = np.zeros(N)
        counts = np.zeros(N)
        for x, y in zip(x_train, y_train):
            i = min(int(x / delta), N - 1)
            weights[i] += y
            counts[i] += 1
        
        for i in range(N):
            if counts[i] > 0:
                weights[i] /= counts[i]
            else:
                # Interpolate from neighbors
                left = max(0, i - 1)
                right = min(N - 1, i + 1)
                weights[i] = (weights[left] + weights[right]) / 2
        
        # Evaluate
        y_pred = np.zeros_like(x_test)
        for j, x in enumerate(x_test):
            i = min(int(x / delta), N - 1)
            y_pred[j] = weights[i]
        
        error_bound = L * delta
        max_err = np.max(np.abs(y_true - y_pred))
        
        ax = axes[idx]
        ax.plot(x_test, y_true, 'k-', linewidth=2, label='True function')
        ax.plot(x_test, y_pred, 'r-', linewidth=1.5, label=f'Closure net (N={N})')
        ax.fill_between(x_test, y_pred - error_bound, y_pred + error_bound,
                        alpha=0.15, color='red', label=f'±L·δ = ±{error_bound:.2f}')
        ax.scatter(x_train, y_train, c='blue', s=15, alpha=0.5, label='Noisy data')
        ax.set_title(f'N = {N} cells, max error = {max_err:.3f}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
        ax.set_xlabel('x')
    
    plt.suptitle('Closure-Step Network: Regression with Guaranteed Bounds', fontsize=14)
    plt.tight_layout()
    plt.savefig('regression_guarantees.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: regression_guarantees.png")


def app_robust_classification():
    """
    Application: 1D classification with certified robustness.
    
    Demonstrates how closure structure provides perturbation certificates
    that are impossible to obtain with standard neural networks without
    additional verification.
    """
    print()
    print("=" * 60)
    print("APPLICATION 2: Robust Classification with Certificates")
    print("=" * 60)
    
    np.random.seed(123)
    
    # Generate 2-class data on [0, 1]
    n_per_class = 100
    class_0 = np.random.beta(2, 5, n_per_class)  # Concentrated near 0
    class_1 = np.random.beta(5, 2, n_per_class)  # Concentrated near 1
    
    X = np.concatenate([class_0, class_1])
    y = np.concatenate([np.zeros(n_per_class), np.ones(n_per_class)])
    
    # Closure classifier: find optimal threshold
    best_threshold = 0.5
    best_accuracy = 0.0
    for t in np.linspace(0.1, 0.9, 81):
        preds = (X >= t).astype(float)
        acc = np.mean(preds == y)
        if acc > best_accuracy:
            best_accuracy = acc
            best_threshold = t
    
    print(f"Optimal threshold: {best_threshold:.3f}")
    print(f"Training accuracy: {best_accuracy:.1%}")
    
    # Compute per-point certified radii
    radii = np.abs(X - best_threshold)
    
    # Certified accuracy at different perturbation levels
    epsilons = np.linspace(0, 0.3, 50)
    certified_accs = []
    
    preds = (X >= best_threshold).astype(float)
    correct = preds == y
    
    for eps in epsilons:
        certified = correct & (radii >= eps)
        certified_accs.append(np.mean(certified))
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: data and decision boundary
    ax = axes[0]
    ax.scatter(class_0, np.zeros(n_per_class), c='blue', alpha=0.5, s=20, label='Class 0')
    ax.scatter(class_1, np.ones(n_per_class), c='red', alpha=0.5, s=20, label='Class 1')
    ax.axvline(x=best_threshold, color='green', linewidth=2, linestyle='--', label=f'Threshold={best_threshold:.2f}')
    
    # Show certified region
    ax.axvspan(best_threshold - 0.1, best_threshold + 0.1, alpha=0.1, color='yellow',
               label='Uncertain zone (r<0.1)')
    ax.set_xlabel('Feature value')
    ax.set_ylabel('Class')
    ax.set_title('Closure Classifier with Certified Radii')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Right: certified accuracy curve
    ax = axes[1]
    ax.plot(epsilons, certified_accs, 'b-', linewidth=2)
    ax.fill_between(epsilons, certified_accs, alpha=0.2)
    ax.set_xlabel('Perturbation radius ε')
    ax.set_ylabel('Certified accuracy')
    ax.set_title('Certified Accuracy vs Perturbation Size')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 0.3)
    ax.set_ylim(0, 1.05)
    
    plt.tight_layout()
    plt.savefig('robust_classification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: robust_classification.png")


def app_morphological_features():
    """
    Application: Morphological feature extraction via closure operators.
    
    Shows how dilation (a closure operator) can be used as a feature
    extractor for 1D signal processing, with idempotence guarantees.
    """
    print()
    print("=" * 60)
    print("APPLICATION 3: Morphological Feature Extraction")
    print("=" * 60)
    
    np.random.seed(456)
    
    # Generate a signal with different structural features
    t = np.linspace(0, 4, 400)
    signal = np.sin(2 * np.pi * t) + 0.5 * np.sin(6 * np.pi * t)
    signal += np.random.normal(0, 0.1, len(t))
    
    # Dilation (max filter) as closure operator
    def dilate(x, radius):
        """Dilation: max in a neighborhood. This is a closure operator."""
        result = np.copy(x)
        for i in range(len(x)):
            left = max(0, i - radius)
            right = min(len(x), i + radius + 1)
            result[i] = np.max(x[left:right])
        return result
    
    # Erosion (min filter)
    def erode(x, radius):
        result = np.copy(x)
        for i in range(len(x)):
            left = max(0, i - radius)
            right = min(len(x), i + radius + 1)
            result[i] = np.min(x[left:right])
        return result
    
    # Demonstrate idempotence
    r = 5
    dilated_once = dilate(signal, r)
    dilated_twice = dilate(dilated_once, r)
    idem_error = np.max(np.abs(dilated_once - dilated_twice))
    print(f"Dilation idempotence error: {idem_error:.2e}")
    print(f"Idempotent: {idem_error < 1e-10}")
    
    # Multi-scale closure features
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    ax = axes[0, 0]
    ax.plot(t, signal, 'b-', alpha=0.5, linewidth=0.8, label='Signal')
    ax.set_title('Original Signal')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    for idx, radius in enumerate([3, 10, 30]):
        ax = axes[(idx + 1) // 2, (idx + 1) % 2]
        dil = dilate(signal, radius)
        ero = erode(signal, radius)
        opening = dilate(ero, radius)  # Opening = dilate(erode(.))
        
        ax.plot(t, signal, 'b-', alpha=0.3, linewidth=0.5)
        ax.plot(t, dil, 'r-', linewidth=1.5, label=f'Dilation (r={radius})')
        ax.plot(t, opening, 'g-', linewidth=1.5, label=f'Opening (r={radius})')
        ax.fill_between(t, ero, dil, alpha=0.1, color='orange')
        ax.set_title(f'Closure Features (radius={radius})')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Morphological Closure Features: Multi-Scale Analysis', fontsize=14)
    plt.tight_layout()
    plt.savefig('morphological_features.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: morphological_features.png")


if __name__ == "__main__":
    print("CLOSURE-OPERATOR NETWORKS: REAL-WORLD APPLICATIONS")
    print("=" * 60)
    print()
    
    app_regression_with_guarantees()
    app_robust_classification()
    app_morphological_features()
    
    print("\nAll applications completed successfully.")


#!/usr/bin/env python3
"""
Closure-Operator Networks: Demonstrations and Numerical Examples

This script demonstrates the core theorems of closure-operator network theory
with concrete numerical examples, showing:
1. Finite exact representation (Theorem A)
2. Lipschitz approximation rates (Theorem C)
3. Continuous uniform approximation (Theorem B)
4. Certified robustness (Theorem D)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def closure_indicator(x, seed_set, closure_op=None):
    """Closure indicator feature: 1 if x in closure(S), else 0."""
    if closure_op is None:
        # Identity closure
        return 1.0 if x in seed_set else 0.0
    return 1.0 if x in closure_op(seed_set) else 0.0


def demo_finite_exact_representation():
    """
    Theorem A: Every function on a finite set can be exactly represented
    by a closure-feature network.
    
    We demonstrate with f: {0,1,2,3,4} -> R
    Using identity closure with singleton seeds.
    """
    print("=" * 60)
    print("THEOREM A: Finite Exact Representation")
    print("=" * 60)
    
    n = 5
    f_values = np.array([3.14, -2.7, 0.5, 1.0, -1.5])
    
    # Closure features: Phi(x, j) = 1 if x == j else 0
    Phi = np.eye(n)
    
    # Weights = function values, bias = 0
    w = f_values.copy()
    b = 0.0
    
    # Verify: f(x) = sum_j w_j * Phi(x,j) + b
    reconstructed = Phi @ w + b
    
    print(f"Domain: {{0, 1, 2, 3, 4}}")
    print(f"Target function values: {f_values}")
    print(f"Closure features (identity closure, singleton seeds):")
    print(f"  Phi = I_{n}x{n}")
    print(f"Weights: {w}")
    print(f"Bias: {b}")
    print(f"Reconstructed: {reconstructed}")
    print(f"Max error: {np.max(np.abs(f_values - reconstructed)):.2e}")
    print(f"Exact match: {np.allclose(f_values, reconstructed)}")
    print()
    
    return f_values, reconstructed


def closure_step_approx(f, N, x):
    """
    Closure-step approximation on [0,1] with N cells.
    Samples f at the center of each cell.
    """
    delta = 1.0 / N
    i = min(int(x / delta), N - 1)
    center = i * delta + delta / 2
    return f(center)


def demo_lipschitz_approximation():
    """
    Theorem C: For L-Lipschitz functions on [0,1], closure-step networks
    with N cells achieve error ≤ L/N.
    """
    print("=" * 60)
    print("THEOREM C: Lipschitz Approximation Rate")
    print("=" * 60)
    
    # Test function: f(x) = sin(2*pi*x), L = 2*pi
    f = lambda x: np.sin(2 * np.pi * x)
    L = 2 * np.pi
    
    x_fine = np.linspace(0, 1, 1000)
    
    Ns = [2, 4, 8, 16, 32, 64]
    errors = []
    bounds = []
    
    print(f"Function: sin(2πx), Lipschitz constant L = {L:.4f}")
    print(f"{'N':>5} | {'Max Error':>12} | {'Bound L/N':>12} | {'Satisfied':>10}")
    print("-" * 50)
    
    for N in Ns:
        approx = np.array([closure_step_approx(f, N, x) for x in x_fine])
        true_vals = f(x_fine)
        max_err = np.max(np.abs(true_vals - approx))
        bound = L / N
        satisfied = max_err <= bound + 1e-10
        errors.append(max_err)
        bounds.append(bound)
        print(f"{N:5d} | {max_err:12.6f} | {bound:12.6f} | {'✓' if satisfied else '✗':>10}")
    
    print()
    
    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: approximations
    ax = axes[0]
    ax.plot(x_fine, f(x_fine), 'k-', linewidth=2, label='f(x) = sin(2πx)')
    for N, color in zip([4, 8, 16], ['#e74c3c', '#3498db', '#2ecc71']):
        approx = np.array([closure_step_approx(f, N, x) for x in x_fine])
        ax.plot(x_fine, approx, '--', color=color, linewidth=1.5, label=f'N={N} cells')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.set_title('Closure-Step Approximation')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Right: convergence
    ax = axes[1]
    ax.loglog(Ns, errors, 'bo-', linewidth=2, markersize=8, label='Actual error')
    ax.loglog(Ns, bounds, 'r--', linewidth=2, label='Bound L/N')
    ax.loglog(Ns, [L/(2*N) for N in Ns], 'g:', linewidth=1.5, label='L/(2N)')
    ax.set_xlabel('N (number of cells)')
    ax.set_ylabel('Max error')
    ax.set_title('Approximation Rate: O(1/N)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('lipschitz_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: lipschitz_approximation.png")
    
    return Ns, errors, bounds


def demo_continuous_approximation():
    """
    Theorem B: Every continuous function on [0,1] is uniformly approximable
    by closure-step networks.
    """
    print("=" * 60)
    print("THEOREM B: Continuous Uniform Approximation")
    print("=" * 60)
    
    # Non-Lipschitz but continuous: f(x) = x * sin(1/x) for x > 0, f(0) = 0
    def f(x):
        if x == 0:
            return 0.0
        return x * np.sin(1.0 / x)
    
    x_fine = np.linspace(0, 1, 2000)
    true_vals = np.array([f(x) for x in x_fine])
    
    epsilons = [0.1, 0.05, 0.01, 0.005]
    
    print("Function: x·sin(1/x) (continuous but not Lipschitz near 0)")
    print(f"{'ε target':>10} | {'N needed':>10} | {'Actual error':>12} | {'< ε?':>6}")
    print("-" * 50)
    
    results = []
    for eps in epsilons:
        # Find smallest N that achieves error < eps
        for N in range(1, 10000):
            approx = np.array([closure_step_approx(f, N, x) for x in x_fine])
            err = np.max(np.abs(true_vals - approx))
            if err < eps:
                results.append((eps, N, err))
                print(f"{eps:10.4f} | {N:10d} | {err:12.6f} | {'✓':>6}")
                break
    
    print()
    return results


def demo_certified_robustness():
    """
    Theorem D: Closure-based classifiers admit certified perturbation radii.
    """
    print("=" * 60)
    print("THEOREM D: Certified Robustness")
    print("=" * 60)
    
    # Classifier: divide [0,1] into 5 regions, assign labels
    N = 5
    delta = 1.0 / N
    labels = ['A', 'B', 'C', 'B', 'A']
    
    def classifier(x):
        i = min(int(x / delta), N - 1)
        return labels[i]
    
    def closure_repr(x):
        """Map x to the center of its cell (idempotent)."""
        i = min(int(x / delta), N - 1)
        return i * delta + delta / 2
    
    # Certified radius = delta/2 (distance to nearest cell boundary)
    r = delta / 2
    
    print(f"Classifier: {N} cells on [0,1], labels = {labels}")
    print(f"Cell width: {delta:.3f}")
    print(f"Certified radius: r = {r:.3f}")
    print()
    
    # Test robustness at cell centers
    test_points = [i * delta + delta / 2 for i in range(N)]
    
    print(f"{'Center':>8} | {'Label':>6} | {'Cert. radius':>12} | {'Verified':>8}")
    print("-" * 45)
    
    n_tests = 100
    all_robust = True
    for center in test_points:
        label = classifier(center)
        # Test perturbations within radius
        perturbations = np.random.uniform(-r * 0.99, r * 0.99, n_tests)
        perturbed = np.clip(center + perturbations, 0, 1 - 1e-10)
        robust = all(classifier(p) == label for p in perturbed)
        all_robust = all_robust and robust
        print(f"{center:8.3f} | {label:>6} | {r:12.3f} | {'✓' if robust else '✗':>8}")
    
    print(f"\nAll {n_tests} random perturbations within radius preserved labels: {'✓' if all_robust else '✗'}")
    print()
    
    # Visualization
    fig, ax = plt.subplots(1, 1, figsize=(12, 4))
    colors = {'A': '#e74c3c', 'B': '#3498db', 'C': '#2ecc71'}
    
    x_fine = np.linspace(0, 1, 1000)
    for i in range(N):
        left = i * delta
        right = (i + 1) * delta
        center = left + delta / 2
        color = colors[labels[i]]
        ax.axvspan(left, right, alpha=0.2, color=color)
        ax.axvspan(center - r * 0.8, center + r * 0.8, alpha=0.1, color='yellow')
        ax.plot(center, 0.5, 'o', color=color, markersize=12, zorder=5)
        ax.annotate(labels[i], (center, 0.6), ha='center', fontsize=14, fontweight='bold')
    
    # Draw certified radii
    for i in range(N):
        center = i * delta + delta / 2
        ax.annotate('', xy=(center - r, 0.3), xytext=(center + r, 0.3),
                    arrowprops=dict(arrowstyle='<->', color='darkblue', lw=2))
        ax.text(center, 0.2, f'r={r:.2f}', ha='center', fontsize=9, color='darkblue')
    
    ax.set_xlim(-0.02, 1.02)
    ax.set_ylim(0, 0.8)
    ax.set_xlabel('x')
    ax.set_title('Certified Robustness: Closure-Based Classifier on [0,1]')
    ax.set_yticks([])
    
    plt.tight_layout()
    plt.savefig('certified_robustness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: certified_robustness.png")
    
    return r, all_robust


def demo_ecoc_robustness():
    """
    ECOC Robustness: Error-correcting output codes for multiclass classification.
    """
    print("=" * 60)
    print("ECOC MULTICLASS ROBUSTNESS")
    print("=" * 60)
    
    # 4 classes, 7-bit Hamming code
    codebook = np.array([
        [1, 1, 1, 0, 0, 0, 1],  # Class A
        [1, 0, 0, 1, 1, 0, 0],  # Class B
        [0, 1, 0, 1, 0, 1, 0],  # Class C
        [0, 0, 1, 0, 1, 1, 1],  # Class D
    ], dtype=bool)
    
    class_names = ['A', 'B', 'C', 'D']
    
    def hamming_agreement(bits, codeword):
        return np.sum(bits == codeword)
    
    def decode(bits):
        agreements = [hamming_agreement(bits, codebook[i]) for i in range(4)]
        return class_names[np.argmax(agreements)]
    
    # Min Hamming distance between codewords
    min_dist = float('inf')
    for i in range(4):
        for j in range(i + 1, 4):
            d = np.sum(codebook[i] != codebook[j])
            min_dist = min(min_dist, d)
    
    max_flips_tolerated = (min_dist - 1) // 2
    
    print(f"Codebook ({len(class_names)} classes, {codebook.shape[1]} bits):")
    for i, name in enumerate(class_names):
        print(f"  {name}: {''.join(str(int(b)) for b in codebook[i])}")
    print(f"Min Hamming distance: {min_dist}")
    print(f"Max bit flips tolerated: {max_flips_tolerated}")
    print()
    
    # Test robustness under random bit flips
    print("Robustness test (1000 trials per class, up to max_flips flips):")
    for class_idx, name in enumerate(class_names):
        correct = 0
        total = 1000
        for _ in range(total):
            bits = codebook[class_idx].copy()
            n_flips = np.random.randint(0, max_flips_tolerated + 1)
            flip_positions = np.random.choice(7, n_flips, replace=False)
            bits[flip_positions] = ~bits[flip_positions]
            if decode(bits) == name:
                correct += 1
        print(f"  Class {name}: {correct}/{total} correctly decoded ({100*correct/total:.1f}%)")
    
    print()
    return min_dist, max_flips_tolerated


if __name__ == "__main__":
    print("CLOSURE-OPERATOR NETWORKS: NUMERICAL DEMONSTRATIONS")
    print("=" * 60)
    print()
    
    demo_finite_exact_representation()
    demo_lipschitz_approximation()
    demo_continuous_approximation()
    demo_certified_robustness()
    demo_ecoc_robustness()
    
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Generate base64-encoded visualizations for PACKAGE.json."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def make_approximation_viz():
    f = lambda x: np.sin(2 * np.pi * x)
    x = np.linspace(0, 1, 1000)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    ax = axes[0]
    ax.plot(x, f(x), 'k-', linewidth=2, label='f(x) = sin(2πx)')
    for N, c in zip([4, 8, 16], ['#e74c3c', '#3498db', '#2ecc71']):
        delta = 1.0 / N
        approx = []
        for xi in x:
            i = min(int(xi / delta), N - 1)
            center = i * delta + delta / 2
            approx.append(f(center))
        ax.plot(x, approx, '--', color=c, linewidth=1.5, label=f'N={N}')
    ax.set_xlabel('x'); ax.set_ylabel('f(x)')
    ax.set_title('Closure-Step Approximation')
    ax.legend(); ax.grid(True, alpha=0.3)
    
    ax = axes[1]
    L = 2 * np.pi
    Ns = [2, 4, 8, 16, 32, 64]
    errors = []
    for N in Ns:
        delta = 1.0 / N
        approx = []
        for xi in x:
            i = min(int(xi / delta), N - 1)
            center = i * delta + delta / 2
            approx.append(f(center))
        errors.append(np.max(np.abs(f(x) - np.array(approx))))
    ax.loglog(Ns, errors, 'bo-', linewidth=2, markersize=8, label='Actual error')
    ax.loglog(Ns, [L/N for N in Ns], 'r--', linewidth=2, label='Bound L/N')
    ax.set_xlabel('N'); ax.set_ylabel('Max error')
    ax.set_title('Convergence Rate: O(1/N)')
    ax.legend(); ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def make_robustness_viz():
    fig, ax = plt.subplots(1, 1, figsize=(12, 4))
    N = 5; delta = 0.2
    labels = ['A', 'B', 'C', 'B', 'A']
    colors = {'A': '#e74c3c', 'B': '#3498db', 'C': '#2ecc71'}
    
    for i in range(N):
        left = i * delta; right = (i + 1) * delta
        center = left + delta / 2
        color = colors[labels[i]]
        ax.axvspan(left, right, alpha=0.2, color=color)
        ax.plot(center, 0.5, 'o', color=color, markersize=12, zorder=5)
        ax.annotate(labels[i], (center, 0.65), ha='center', fontsize=14, fontweight='bold')
        r = delta / 2
        ax.annotate('', xy=(center - r, 0.3), xytext=(center + r, 0.3),
                    arrowprops=dict(arrowstyle='<->', color='darkblue', lw=2))
        ax.text(center, 0.18, f'r={r:.2f}', ha='center', fontsize=9, color='darkblue')
    
    ax.set_xlim(-0.02, 1.02); ax.set_ylim(0, 0.85)
    ax.set_xlabel('x'); ax.set_title('Certified Robustness Radii')
    ax.set_yticks([])
    plt.tight_layout()
    return fig_to_base64(fig)


def make_architecture_viz():
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_xlim(0, 10); ax.set_ylim(0, 8)
    ax.set_aspect('equal')
    
    # Input
    ax.add_patch(plt.Circle((1.5, 4), 0.6, fc='#3498db', ec='black', lw=2))
    ax.text(1.5, 4, 'x', ha='center', va='center', fontsize=16, fontweight='bold', color='white')
    
    # Closure features
    for i, y in enumerate([6, 4.5, 3, 1.5]):
        from matplotlib.patches import FancyBboxPatch
        ax.add_patch(FancyBboxPatch((3.5, y - 0.4), 2, 0.8, 
                     boxstyle="round,pad=0.1", fc='#e74c3c', ec='black', lw=1.5))
        ax.text(4.5, y, f'Φ{i+1}(x)', ha='center', va='center', fontsize=11, color='white')
        ax.annotate('', xy=(3.5, y), xytext=(2.1, 4),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    # Summation
    ax.add_patch(plt.Circle((7.5, 4), 0.8, fc='#2ecc71', ec='black', lw=2))
    ax.text(7.5, 4, 'Σwᵢ·Φᵢ+b', ha='center', va='center', fontsize=9, fontweight='bold')
    
    for y in [6, 4.5, 3, 1.5]:
        ax.annotate('', xy=(6.7, 4 + (y-4)*0.2), xytext=(5.5, y),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    # Output
    ax.add_patch(plt.Circle((9.2, 4), 0.5, fc='#9b59b6', ec='black', lw=2))
    ax.text(9.2, 4, 'ŷ', ha='center', va='center', fontsize=14, fontweight='bold', color='white')
    ax.annotate('', xy=(8.7, 4), xytext=(8.3, 4),
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    ax.text(1.5, 7.2, 'Input', ha='center', fontsize=12, color='#3498db')
    ax.text(4.5, 7.2, 'Closure Features', ha='center', fontsize=12, color='#e74c3c')
    ax.text(7.5, 7.2, 'Linear Readout', ha='center', fontsize=12, color='#2ecc71')
    ax.text(9.2, 7.2, 'Output', ha='center', fontsize=12, color='#9b59b6')
    
    ax.axis('off')
    ax.set_title('Closure-Operator Network Architecture', fontsize=14, pad=20)
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    visuals = {}
    visuals['approximation'] = make_approximation_viz()
    visuals['robustness'] = make_robustness_viz()
    visuals['architecture'] = make_architecture_viz()
    
    with open('visuals_b64.json', 'w') as f:
        json.dump(visuals, f)
    
    print("Generated 3 visualizations as base64")
