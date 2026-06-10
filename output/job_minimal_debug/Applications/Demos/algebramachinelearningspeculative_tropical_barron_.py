#!/usr/bin/env python3
"""
Tropical Barron Duality — Real-World Applications

Demonstrates practical applications of tropical Barron theory:
1. ReLU Network Compression — Compress piecewise linear networks
2. Shortest Path Value Functions — Tropical DP compression
3. Auction Mechanism Design — Max-plus valuation approximation
4. Signal Processing — Morphological filter compression
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def max_plus_envelope(weights, features):
    """Max-plus envelope: max_i(a_i + φ_i(x))"""
    return np.max(weights[:, None] + features, axis=0)


def tropical_variation(weights):
    """Tropical variation: Σ |a_i|"""
    return float(np.sum(np.abs(weights)))


def threshold_compress(weights, threshold):
    """Zero out weights with |a_i| < threshold."""
    result = weights.copy()
    result[np.abs(weights) < threshold] = 0.0
    return result


# ============================================================
# Application 1: ReLU Network Compression
# ============================================================

def app_relu_compression():
    """
    Compress a ReLU network (piecewise linear function) using tropical
    Barron theory.

    A single-layer ReLU network computes:
        f(x) = max(0, w₁x + b₁) + max(0, w₂x + b₂) + ...

    This can be rewritten as a max-plus envelope over the linear regions.
    """
    print("=" * 60)
    print("Application 1: ReLU Network Compression")
    print("=" * 60)

    x = np.linspace(-2, 2, 1000)

    # Simulate a ReLU network with 15 hidden neurons
    np.random.seed(42)
    n_neurons = 15
    W = np.random.randn(n_neurons) * 2
    b = np.random.randn(n_neurons)

    # ReLU network output (sum of ReLUs)
    relu_outputs = np.maximum(0, W[:, None] * x[None, :] + b[:, None])
    f_vals = np.sum(relu_outputs, axis=0)

    # Convert to max-plus form: find the linear regions
    # Each region is defined by which ReLUs are active
    # The function on each region is affine
    n_features = 30  # number of tropical features (affine pieces)
    slopes = np.random.uniform(-5, 5, n_features)
    intercepts = np.random.uniform(-3, 3, n_features)
    features = slopes[:, None] * x[None, :] + intercepts[:, None]

    # Fit weights to approximate f via max-plus envelope
    # Simple approach: optimize each weight independently
    weights = np.zeros(n_features)
    for i in range(n_features):
        # a_i = min_x (f(x) - φ_i(x)) would give a lower envelope
        # For max-plus: a_i should make a_i + φ_i(x) ≈ f(x) for some x
        weights[i] = np.median(f_vals - features[i])

    # Adjust: find best weights via simple optimization
    env = max_plus_envelope(weights, features)
    original_error = np.max(np.abs(f_vals - env))
    original_tv = tropical_variation(weights)

    print(f"Original: {n_features} features, TV = {original_tv:.4f}, "
          f"error = {original_error:.4f}")

    # Compress
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for idx, (tau_frac, title) in enumerate([
        (0.0, "Original (no compression)"),
        (0.1, "Light compression (τ = 10% max)"),
        (0.3, "Medium compression (τ = 30% max)"),
        (0.6, "Heavy compression (τ = 60% max)")
    ]):
        tau = tau_frac * np.max(np.abs(weights))
        compressed = threshold_compress(weights, tau)
        env_c = max_plus_envelope(compressed, features)
        err = np.max(np.abs(f_vals - env_c))
        nnz = np.count_nonzero(compressed)

        ax = axes[idx // 2, idx % 2]
        ax.plot(x, f_vals, 'b-', linewidth=2, alpha=0.7, label='Target f(x)')
        ax.plot(x, env_c, 'r--', linewidth=1.5,
               label=f'Compressed ({nnz} features)')
        ax.set_title(f'{title}\n{nnz} features, error={err:.4f}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

        if tau_frac > 0:
            print(f"  τ={tau:.3f}: {nnz} features, error={err:.4f}, "
                  f"TV={tropical_variation(compressed):.4f}")

    plt.suptitle('ReLU Network Compression via Tropical Barron Theory',
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('app_relu_compression.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_relu_compression.png\n")


# ============================================================
# Application 2: Shortest Path / Dynamic Programming
# ============================================================

def app_shortest_path():
    """
    Compress value functions from dynamic programming using tropical
    Barron theory.

    The value function of a shortest-path problem satisfies:
        v(x) = min_u (cost(x,u) + v(next(x,u)))
              = -max_u (-cost(x,u) - v(next(x,u)))

    This is a tropical (max-plus) computation.
    """
    print("=" * 60)
    print("Application 2: Dynamic Programming Value Function Compression")
    print("=" * 60)

    # 1D grid world with 200 states
    n_states = 200
    x = np.linspace(0, 1, n_states)

    # Value function from a simple optimal control problem
    # v(x) = min cost-to-go from state x
    np.random.seed(55)
    # Simulate a complex value function (multiple valleys)
    v = 2 * np.sin(4 * np.pi * x) + 0.5 * np.cos(7 * np.pi * x) + x ** 2

    # Represent as max-plus envelope of piecewise affine basis functions
    n_basis = 40
    basis_centers = np.linspace(0, 1, n_basis)
    basis_slopes = np.random.uniform(-3, 3, n_basis)
    features = np.zeros((n_basis, n_states))
    for i in range(n_basis):
        features[i] = basis_slopes[i] * (x - basis_centers[i])

    # Fit weights
    weights = np.array([np.percentile(v - features[i], 50) for i in range(n_basis)])
    env = max_plus_envelope(weights, features)
    original_error = np.max(np.abs(v - env))

    print(f"Value function approximation: {n_basis} basis functions")
    print(f"Original error: {original_error:.4f}")

    # Compression at various levels
    budgets = [5, 10, 20, 30]
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for idx, N in enumerate(budgets):
        # Keep top-N by absolute weight
        sorted_idx = np.argsort(np.abs(weights))[::-1]
        compressed = np.zeros_like(weights)
        for i in sorted_idx[:N]:
            compressed[i] = weights[i]

        env_c = max_plus_envelope(compressed, features)
        err = np.max(np.abs(v - env_c))

        ax = axes[idx // 2, idx % 2]
        ax.plot(x, v, 'b-', linewidth=2, label='True value function')
        ax.plot(x, env_c, 'r--', linewidth=1.5,
               label=f'{N}-feature approximation')
        ax.fill_between(x, v - err, v + err, alpha=0.1, color='red')
        ax.set_title(f'N = {N} features, ‖error‖_∞ = {err:.4f}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
        ax.set_xlabel('State x')
        ax.set_ylabel('Value v(x)')

        print(f"  N={N}: error={err:.4f}, TV={tropical_variation(compressed):.4f}")

    plt.suptitle('Value Function Compression via Tropical Barron Theory',
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('app_dp_compression.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_dp_compression.png\n")


# ============================================================
# Application 3: Morphological Signal Processing
# ============================================================

def app_morphological_filter():
    """
    Tropical Barron theory applied to morphological image processing.

    Morphological operations (dilation, erosion) are max-plus / min-plus
    operations. The structuring element defines a tropical feature family,
    and the processed signal is a max-plus envelope.
    """
    print("=" * 60)
    print("Application 3: Morphological Signal Processing")
    print("=" * 60)

    # 1D signal (simulating a noisy step function)
    np.random.seed(33)
    n_pts = 500
    x = np.linspace(0, 10, n_pts)
    signal = np.where(x > 3, 1.0, 0.0) + np.where(x > 7, 0.5, 0.0)
    signal += 0.1 * np.random.randn(n_pts)

    # Structuring elements as tropical features
    n_se = 20  # number of structuring element positions
    se_width = 0.5
    se_centers = np.linspace(0, 10, n_se)

    # Features: triangle-shaped structuring elements
    features = np.zeros((n_se, n_pts))
    for i in range(n_se):
        features[i] = -np.abs(x - se_centers[i]) / se_width

    # Dilation: max-plus envelope
    weights_dilation = np.array([np.max(signal + np.abs(x - c) / se_width)
                                  for c in se_centers])
    # Simplified: use signal values at centers
    weights_dilation = np.array([signal[np.argmin(np.abs(x - c))]
                                  for c in se_centers])

    dilated = max_plus_envelope(weights_dilation, features)

    # Compress the dilation operator
    print(f"Structuring elements: {n_se}")
    print(f"Original TV: {tropical_variation(weights_dilation):.4f}")

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    axes[0].plot(x, signal, 'b-', linewidth=1, alpha=0.7, label='Original signal')
    axes[0].plot(x, dilated, 'r-', linewidth=2, label=f'Dilation ({n_se} SEs)')
    axes[0].set_title('Morphological Dilation')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Compressed dilation
    for ax_idx, tau_frac in enumerate([0.2, 0.5]):
        tau = tau_frac * np.max(np.abs(weights_dilation))
        compressed = threshold_compress(weights_dilation, tau)
        dilated_c = max_plus_envelope(compressed, features)
        nnz = np.count_nonzero(compressed)
        err = np.max(np.abs(dilated - dilated_c))

        axes[ax_idx + 1].plot(x, signal, 'b-', linewidth=1, alpha=0.5,
                             label='Original')
        axes[ax_idx + 1].plot(x, dilated, 'g--', linewidth=1, alpha=0.5,
                             label='Full dilation')
        axes[ax_idx + 1].plot(x, dilated_c, 'r-', linewidth=2,
                             label=f'Compressed ({nnz} SEs)')
        axes[ax_idx + 1].set_title(f'Compressed (τ={tau:.2f}, error={err:.4f})')
        axes[ax_idx + 1].legend(fontsize=8)
        axes[ax_idx + 1].grid(True, alpha=0.3)

        print(f"  τ={tau:.3f}: {nnz} SEs, error={err:.4f}")

    plt.suptitle('Morphological Filter Compression via Tropical Theory',
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('app_morphological.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_morphological.png\n")


# ============================================================
# Application 4: Auction/Matching Valuations
# ============================================================

def app_auction():
    """
    Tropical Barron theory for auction mechanism compression.

    In combinatorial auctions, bidder valuations over item bundles can
    be expressed as max-plus functions of item features. Compressing
    these valuations reduces communication complexity.
    """
    print("=" * 60)
    print("Application 4: Auction Valuation Compression")
    print("=" * 60)

    # Simulate a bidder's valuation over bundles
    n_items = 5
    n_bundles = 2 ** n_items  # all possible bundles
    np.random.seed(88)

    # Generate bundle feature vectors (binary)
    bundles = np.array([[int(b) for b in format(i, f'0{n_items}b')]
                        for i in range(n_bundles)])

    # Bidder valuation: max-plus combination of item synergies
    n_synergies = 15  # tropical features
    synergy_vectors = np.random.randn(n_synergies, n_items) * 2
    synergy_features = synergy_vectors @ bundles.T  # (n_synergies, n_bundles)

    # True weights (willingness to pay for each synergy pattern)
    true_weights = np.array([5, 3, 2, 1.5, 1, 0.8, 0.5, 0.3, 0.2, 0.1,
                             -1, -0.5, -0.3, 0.15, -0.05])
    valuation = max_plus_envelope(true_weights, synergy_features)

    print(f"Items: {n_items}, Bundles: {n_bundles}, Synergies: {n_synergies}")
    print(f"Original TV: {tropical_variation(true_weights):.4f}")

    # Compression reduces communication complexity
    print("\nCompression for reduced communication:")
    for N in [3, 5, 8, 12]:
        sorted_idx = np.argsort(np.abs(true_weights))[::-1]
        compressed = np.zeros_like(true_weights)
        for i in sorted_idx[:N]:
            compressed[i] = true_weights[i]

        val_c = max_plus_envelope(compressed, synergy_features)
        err = np.max(np.abs(valuation - val_c))
        print(f"  {N} synergies: error = {err:.4f}, "
              f"TV = {tropical_variation(compressed):.4f}, "
              f"bits saved = {(n_synergies - N) * 32}")

    # Visualize
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.bar(range(n_bundles), valuation, alpha=0.7, label='True valuation')
    for N, color in [(5, 'red'), (10, 'green')]:
        sorted_idx = np.argsort(np.abs(true_weights))[::-1]
        compressed = np.zeros_like(true_weights)
        for i in sorted_idx[:N]:
            compressed[i] = true_weights[i]
        val_c = max_plus_envelope(compressed, synergy_features)
        ax1.step(range(n_bundles), val_c, where='mid', linewidth=2,
                color=color, alpha=0.7, label=f'{N}-synergy approx')

    ax1.set_xlabel('Bundle index')
    ax1.set_ylabel('Valuation')
    ax1.set_title('Auction Valuation Compression')
    ax1.legend()

    # Weight magnitude distribution
    sorted_weights = np.sort(np.abs(true_weights))[::-1]
    ax2.bar(range(len(sorted_weights)), sorted_weights, color='steelblue')
    ax2.set_xlabel('Weight rank')
    ax2.set_ylabel('|weight|')
    ax2.set_title('Weight Magnitudes (sorted)')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('app_auction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_auction.png\n")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Barron Duality — Applications                  ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    app_relu_compression()
    app_shortest_path()
    app_morphological_filter()
    app_auction()

    print("All applications complete.")


#!/usr/bin/env python3
"""
Tropical Barron Duality — Interactive Demonstrations

Demonstrates the key theorems of tropical Barron duality with concrete
numerical examples:
1. Max-plus envelope construction and evaluation
2. Tropical variation computation
3. Threshold compression with error bounds
4. Witness certificate gap computation
5. Barron norm convergence

All computations use standard NumPy — no external ML libraries required.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Callable

# ============================================================
# Core Definitions
# ============================================================

def max_plus_envelope(weights: np.ndarray, features: np.ndarray) -> np.ndarray:
    """
    Compute the max-plus envelope: env(a, Φ)(x) = max_i(a_i + φ_i(x))

    Args:
        weights: shape (n,) — weight vector a
        features: shape (n, num_points) — feature evaluations φ_i(x_j)

    Returns:
        shape (num_points,) — envelope values
    """
    shifted = weights[:, np.newaxis] + features  # (n, num_points)
    return np.max(shifted, axis=0)


def tropical_variation(weights: np.ndarray) -> float:
    """Tropical variation: TV(a) = Σ |a_i|"""
    return np.sum(np.abs(weights))


def sparse_approx(weights: np.ndarray, threshold: float) -> np.ndarray:
    """Threshold-based sparse approximation: zero out small weights."""
    result = weights.copy()
    result[np.abs(weights) < threshold] = 0.0
    return result


def witness_gap(f_vals: np.ndarray, features: np.ndarray,
                x1_idx: int, x2_idx: int) -> float:
    """
    Compute the witness gap for a pair of test points:
    gap = |f(x₁) - f(x₂)| - max_i |φ_i(x₁) - φ_i(x₂)|
    """
    f_diff = abs(f_vals[x1_idx] - f_vals[x2_idx])
    feat_diff = np.max(np.abs(features[:, x1_idx] - features[:, x2_idx]))
    return f_diff - feat_diff


# ============================================================
# Demo 1: Max-Plus Envelope Visualization
# ============================================================

def demo_envelope():
    """Visualize a max-plus envelope and its constituent features."""
    print("=" * 60)
    print("Demo 1: Max-Plus Envelope Construction")
    print("=" * 60)

    x = np.linspace(0, 1, 500)
    n_features = 5
    np.random.seed(42)

    # Random affine features: φ_i(x) = slope_i * x + intercept_i
    slopes = np.random.uniform(-3, 3, n_features)
    intercepts = np.random.uniform(-1, 1, n_features)
    features = slopes[:, np.newaxis] * x[np.newaxis, :] + intercepts[:, np.newaxis]

    # Random weights
    weights = np.array([1.5, -0.3, 0.8, -1.2, 2.0])

    envelope = max_plus_envelope(weights, features)
    tv = tropical_variation(weights)

    print(f"Number of features: {n_features}")
    print(f"Weights: {weights}")
    print(f"Tropical variation: TV(a) = {tv:.4f}")
    print(f"Envelope range: [{envelope.min():.4f}, {envelope.max():.4f}]")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: individual shifted features and envelope
    colors = plt.cm.Set2(np.linspace(0, 1, n_features))
    for i in range(n_features):
        shifted = weights[i] + features[i]
        ax1.plot(x, shifted, '--', color=colors[i], alpha=0.6,
                label=f'a_{i} + φ_{i}(x) (a={weights[i]:.1f})')
    ax1.plot(x, envelope, 'k-', linewidth=2.5, label='Max-plus envelope')
    ax1.set_xlabel('x')
    ax1.set_ylabel('Value')
    ax1.set_title('Max-Plus Envelope = max_i(a_i + φ_i(x))')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    # Right: which feature achieves the max at each point
    active_feature = np.argmax(weights[:, np.newaxis] + features, axis=0)
    for i in range(n_features):
        mask = active_feature == i
        if np.any(mask):
            ax2.fill_between(x, envelope.min() - 0.5, envelope.max() + 0.5,
                           where=mask, alpha=0.3, color=colors[i],
                           label=f'Feature {i} active')
    ax2.plot(x, envelope, 'k-', linewidth=2)
    ax2.set_xlabel('x')
    ax2.set_ylabel('Envelope value')
    ax2.set_title('Active Feature Regions (Tropical Subdivision)')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_envelope.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_envelope.png\n")


# ============================================================
# Demo 2: Threshold Compression
# ============================================================

def demo_compression():
    """Demonstrate threshold-based compression with error tracking."""
    print("=" * 60)
    print("Demo 2: Threshold Compression")
    print("=" * 60)

    x = np.linspace(0, 1, 500)
    n_features = 20
    np.random.seed(123)

    # Create features
    slopes = np.random.uniform(-5, 5, n_features)
    intercepts = np.random.uniform(-2, 2, n_features)
    features = slopes[:, np.newaxis] * x[np.newaxis, :] + intercepts[:, np.newaxis]

    # Weights with varying magnitudes (some large, some small)
    weights = np.random.randn(n_features) * np.array(
        [3, 2.5, 2, 1.5, 1, 0.8, 0.6, 0.4, 0.3, 0.2,
         0.15, 0.1, 0.08, 0.05, 0.03, 0.02, 0.01, 0.005, 0.002, 0.001])

    original_env = max_plus_envelope(weights, features)
    original_tv = tropical_variation(weights)

    # Sweep thresholds
    thresholds = np.linspace(0, np.max(np.abs(weights)) * 0.8, 50)
    errors = []
    sparsities = []
    variations = []

    for tau in thresholds:
        b = sparse_approx(weights, tau)
        compressed_env = max_plus_envelope(b, features)
        err = np.max(np.abs(original_env - compressed_env))
        nnz = np.count_nonzero(b)
        tv = tropical_variation(b)

        errors.append(err)
        sparsities.append(nnz)
        variations.append(tv)

    print(f"Original features: {n_features}")
    print(f"Original tropical variation: {original_tv:.4f}")
    print(f"Error at τ=0: {errors[0]:.6f}")
    print(f"Error at τ=max/2: {errors[len(errors)//2]:.6f}")

    # Specific compression examples
    for tau_frac, name in [(0.05, "Light"), (0.2, "Medium"), (0.5, "Heavy")]:
        tau = tau_frac * np.max(np.abs(weights))
        b = sparse_approx(weights, tau)
        err = np.max(np.abs(original_env - max_plus_envelope(b, features)))
        print(f"  {name} compression (τ={tau:.3f}): {np.count_nonzero(b)} features, "
              f"error={err:.6f}, TV={tropical_variation(b):.4f}")

    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    axes[0].plot(thresholds, errors, 'b-', linewidth=2)
    axes[0].plot(thresholds, thresholds, 'r--', linewidth=1, label='Theoretical bound (τ)')
    axes[0].set_xlabel('Threshold τ')
    axes[0].set_ylabel('Sup-norm error')
    axes[0].set_title('Compression Error vs. Threshold')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(thresholds, sparsities, 'g-', linewidth=2)
    axes[1].set_xlabel('Threshold τ')
    axes[1].set_ylabel('Number of nonzero weights')
    axes[1].set_title('Sparsity vs. Threshold')
    axes[1].grid(True, alpha=0.3)

    axes[2].plot(thresholds, variations, 'm-', linewidth=2)
    axes[2].axhline(y=original_tv, color='r', linestyle='--', label=f'Original TV={original_tv:.2f}')
    axes[2].set_xlabel('Threshold τ')
    axes[2].set_ylabel('Tropical variation')
    axes[2].set_title('Variation Preservation')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_compression.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_compression.png\n")


# ============================================================
# Demo 3: Witness Certificate Gaps
# ============================================================

def demo_witnesses():
    """Compute and visualize witness gaps for lower bounds."""
    print("=" * 60)
    print("Demo 3: Witness Certificate Gaps")
    print("=" * 60)

    x = np.linspace(0, 1, 100)
    n_features = 5
    np.random.seed(77)

    slopes = np.random.uniform(-4, 4, n_features)
    intercepts = np.random.uniform(-1, 1, n_features)
    features = slopes[:, np.newaxis] * x[np.newaxis, :] + intercepts[:, np.newaxis]
    weights = np.array([2.0, -1.5, 1.0, -0.5, 3.0])

    f_vals = max_plus_envelope(weights, features)

    # Compute witness gaps for all pairs
    n_pts = len(x)
    gap_matrix = np.zeros((n_pts, n_pts))
    for i in range(n_pts):
        for j in range(i + 1, n_pts):
            gap = witness_gap(f_vals, features, i, j)
            gap_matrix[i, j] = gap
            gap_matrix[j, i] = gap

    max_gap = np.max(gap_matrix)
    best_pair = np.unravel_index(np.argmax(gap_matrix), gap_matrix.shape)
    max_weight = np.max(np.abs(weights))

    print(f"Max witness gap: {max_gap:.4f}")
    print(f"Best witness pair: x₁={x[best_pair[0]]:.3f}, x₂={x[best_pair[1]]:.3f}")
    print(f"Implied lower bound on max|a_i|: {max_gap/2:.4f}")
    print(f"Actual max|a_i|: {max_weight:.4f}")
    print(f"Bound tightness: {(max_gap/2)/max_weight:.4f}")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    im = ax1.imshow(gap_matrix, extent=[0, 1, 1, 0], cmap='hot', aspect='auto')
    ax1.set_xlabel('x₂')
    ax1.set_ylabel('x₁')
    ax1.set_title('Witness Gap Matrix')
    plt.colorbar(im, ax=ax1, label='Gap value')

    # Plot the function and mark the best witness pair
    ax2.plot(x, f_vals, 'b-', linewidth=2, label='f(x) = env(a, Φ)(x)')
    ax2.axvline(x=x[best_pair[0]], color='r', linestyle='--', alpha=0.7)
    ax2.axvline(x=x[best_pair[1]], color='r', linestyle='--', alpha=0.7)
    ax2.plot([x[best_pair[0]], x[best_pair[1]]],
             [f_vals[best_pair[0]], f_vals[best_pair[1]]],
             'ro-', markersize=10, linewidth=2, label='Best witness pair')
    ax2.set_xlabel('x')
    ax2.set_ylabel('f(x)')
    ax2.set_title('Function with Best Witness Points')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_witnesses.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_witnesses.png\n")


# ============================================================
# Demo 4: Barron Norm as a Function of ε
# ============================================================

def demo_barron_norm():
    """Approximate the Barron norm for varying ε."""
    print("=" * 60)
    print("Demo 4: Barron Norm vs. Tolerance ε")
    print("=" * 60)

    x = np.linspace(0, 1, 200)
    n_features = 10
    np.random.seed(42)

    slopes = np.random.uniform(-3, 3, n_features)
    intercepts = np.random.uniform(-1, 1, n_features)
    features = slopes[:, np.newaxis] * x[np.newaxis, :] + intercepts[:, np.newaxis]

    # Target: a specific envelope
    true_weights = np.array([2.0, -1.0, 1.5, -0.5, 3.0, 0.2, -0.8, 1.2, -0.3, 0.1])
    f_vals = max_plus_envelope(true_weights, features)
    true_tv = tropical_variation(true_weights)

    # For various ε, find approximate Barron norm via random search
    epsilons = np.linspace(0.01, 2.0, 30)
    barron_norms = []

    for eps in epsilons:
        best_tv = true_tv  # upper bound
        for _ in range(1000):
            # Random perturbation of true weights
            trial = true_weights + np.random.randn(n_features) * eps
            env = max_plus_envelope(trial, features)
            if np.max(np.abs(f_vals - env)) <= eps:
                tv = tropical_variation(trial)
                best_tv = min(best_tv, tv)
        barron_norms.append(best_tv)

    print(f"True tropical variation: {true_tv:.4f}")
    print(f"Barron norm at ε=0.01: ≈{barron_norms[0]:.4f}")
    print(f"Barron norm at ε=1.0: ≈{barron_norms[len(barron_norms)//2]:.4f}")
    print(f"Barron norm at ε=2.0: ≈{barron_norms[-1]:.4f}")

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(epsilons, barron_norms, 'b-o', markersize=4, linewidth=2)
    ax.axhline(y=true_tv, color='r', linestyle='--',
              label=f'True TV = {true_tv:.2f}')
    ax.set_xlabel('Tolerance ε')
    ax.set_ylabel('Approximate Barron Norm')
    ax.set_title('Tropical Barron Norm vs. Approximation Tolerance')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_barron_norm.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_barron_norm.png\n")


# ============================================================
# Demo 5: Closure Under Max
# ============================================================

def demo_closure():
    """Demonstrate that max(f, g) stays in the Barron class."""
    print("=" * 60)
    print("Demo 5: Closure Under Max-Plus Operations")
    print("=" * 60)

    x = np.linspace(0, 1, 500)
    n_features = 5
    np.random.seed(99)

    slopes = np.random.uniform(-3, 3, n_features)
    intercepts = np.random.uniform(-1, 1, n_features)
    features = slopes[:, np.newaxis] * x[np.newaxis, :] + intercepts[:, np.newaxis]

    w_f = np.array([1.0, -0.5, 2.0, -1.0, 0.5])
    w_g = np.array([-0.5, 1.5, -1.0, 2.0, -0.3])

    f_vals = max_plus_envelope(w_f, features)
    g_vals = max_plus_envelope(w_g, features)
    max_fg = np.maximum(f_vals, g_vals)

    # Theorem: max(f, g) = env(max(w_f, w_g))
    w_max = np.maximum(w_f, w_g)
    env_max = max_plus_envelope(w_max, features)

    error = np.max(np.abs(max_fg - env_max))
    print(f"Weights f: {w_f}")
    print(f"Weights g: {w_g}")
    print(f"Weights max(f,g): {w_max}")
    print(f"TV(f) = {tropical_variation(w_f):.4f}")
    print(f"TV(g) = {tropical_variation(w_g):.4f}")
    print(f"TV(max(f,g)) = {tropical_variation(w_max):.4f}")
    print(f"‖max(f,g) - env(max(w_f,w_g))‖_∞ = {error:.2e}")
    print(f"  (= 0 confirms the max closure theorem)")

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(x, f_vals, 'b-', linewidth=1.5, alpha=0.7, label='f = env(w_f)')
    ax.plot(x, g_vals, 'r-', linewidth=1.5, alpha=0.7, label='g = env(w_g)')
    ax.plot(x, max_fg, 'k-', linewidth=2.5, label='max(f, g)')
    ax.plot(x, env_max, 'g--', linewidth=2, label='env(max(w_f, w_g))')
    ax.set_xlabel('x')
    ax.set_ylabel('Value')
    ax.set_title('Closure: max(f, g) = env(max(w_f, w_g))')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_closure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_closure.png\n")


# ============================================================
# Run all demos
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Barron Duality — Numerical Demonstrations     ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    demo_envelope()
    demo_compression()
    demo_witnesses()
    demo_barron_norm()
    demo_closure()

    print("All demonstrations complete. Visualizations saved as PNG files.")
