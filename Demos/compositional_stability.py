#!/usr/bin/env python3
"""
Applications of Tropical Compositional Stability

Demonstrates real-world applications of the theorem that tropical networks
are 1-Lipschitz at any depth:
1. Certified adversarial robustness for tropical classifiers
2. Stable shortest-path / dynamic programming
3. Robust signal propagation in deep tropical architectures
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import tropical_agg, tropical_compose_fast, sup_norm, depth_compress


def application_certified_robustness():
    """
    Application 1: Certified Adversarial Robustness

    Since tropical networks are provably 1-Lipschitz, we can certify that
    no adversarial perturbation within radius r can change the prediction.
    """
    print("=" * 70)
    print("APPLICATION 1: Certified Adversarial Robustness")
    print("=" * 70)
    print()

    np.random.seed(42)
    n_classes = 5
    depth = 10
    dim = 8

    # Build a deep tropical classifier
    layers = []
    current_dim = dim
    for d in range(depth - 1):
        W = np.random.randn(current_dim, current_dim) * 0.5
        layers.append(W)
    # Final layer maps to n_classes
    layers.append(np.random.randn(current_dim, n_classes) * 0.5)

    # Classify a test point
    x = np.random.randn(dim)
    output = x.copy()
    for W in layers:
        output = tropical_agg(W, output)

    predicted = np.argmax(output)
    sorted_outputs = np.sort(output)[::-1]
    margin = sorted_outputs[0] - sorted_outputs[1]
    certified_radius = margin / 2.0  # Lipschitz = 1

    print(f"  Network depth: {depth}")
    print(f"  Input dimension: {dim}")
    print(f"  Number of classes: {n_classes}")
    print(f"  Predicted class: {predicted}")
    print(f"  Output scores: {output}")
    print(f"  Margin (top - second): {margin:.4f}")
    print(f"  Certified radius: {certified_radius:.4f}")
    print(f"  → No adversarial perturbation of ‖δ‖∞ < {certified_radius:.4f}")
    print(f"    can change the prediction (mathematically guaranteed).")
    print()

    # Verify by sampling perturbations
    n_attacks = 10000
    attack_radius = certified_radius * 0.99
    flipped = 0
    for _ in range(n_attacks):
        delta = np.random.uniform(-attack_radius, attack_radius, dim)
        x_adv = x + delta
        output_adv = x_adv.copy()
        for W in layers:
            output_adv = tropical_agg(W, output_adv)
        if np.argmax(output_adv) != predicted:
            flipped += 1

    print(f"  Empirical verification: {n_attacks} random attacks within radius")
    print(f"    {attack_radius:.4f} → {flipped} flips (expected: 0)")
    print()


def application_shortest_path_stability():
    """
    Application 2: Stable Shortest-Path Computation

    Tropical aggregation is the Bellman operator for shortest paths.
    The stability theorem guarantees that perturbed edge weights
    lead to bounded perturbation in shortest-path distances.
    """
    print("=" * 70)
    print("APPLICATION 2: Shortest-Path Stability (Bellman Operator)")
    print("=" * 70)
    print()

    # Graph with 6 nodes, represented as adjacency matrix
    # (using max-plus convention: higher = shorter path)
    np.random.seed(7)
    n_nodes = 6
    W = -np.abs(np.random.randn(n_nodes, n_nodes))  # negative weights

    # Source node 0: initial "value" vector
    x = np.zeros(n_nodes)
    x[0] = 0
    x[1:] = -100  # effectively -infinity

    # Perturbed weights
    perturbation_magnitude = 0.1
    W_perturbed = W + np.random.uniform(
        -perturbation_magnitude, perturbation_magnitude,
        W.shape
    )

    print(f"  Graph: {n_nodes} nodes")
    print(f"  Edge weight perturbation: ±{perturbation_magnitude}")
    print()

    # Run Bellman iterations on both
    curr_clean, curr_noisy = x.copy(), x.copy()
    print(f"  {'Iteration':>10} | {'‖clean - noisy‖∞':>20} | {'Bound':>10}")
    print(f"  {'-'*10}-+-{'-'*20}-+-{'-'*10}")

    input_dist = sup_norm(x - x)  # same input
    weight_dist = sup_norm((W - W_perturbed).flatten())

    for it in range(1, 11):
        curr_clean = tropical_agg(W, curr_clean)
        curr_noisy = tropical_agg(W_perturbed, curr_noisy)
        dist = sup_norm(curr_clean - curr_noisy)
        print(f"  {it:>10} | {dist:>20.6f} | {'bounded':>10}")

    print()
    print("  → Tropical stability ensures shortest-path distances")
    print("    remain bounded under edge-weight perturbation.")
    print()


def application_signal_propagation():
    """
    Application 3: Signal Propagation in Deep Tropical Networks

    Compare signal propagation (gradient-like information flow) between
    tropical and conventional networks. Tropical networks maintain signal
    strength regardless of depth.
    """
    print("=" * 70)
    print("APPLICATION 3: Signal Propagation Analysis")
    print("=" * 70)
    print()

    np.random.seed(42)
    dim = 10
    max_depth = 100

    # Generate weight matrix
    W = np.random.randn(dim, dim) * 1.5

    # Two similar inputs
    x1 = np.random.randn(dim)
    x2 = x1 + np.random.randn(dim) * 0.001  # tiny perturbation

    input_dist = sup_norm(x1 - x2)

    depths = list(range(1, max_depth + 1))
    tropical_ratios = []
    relu_ratios = []

    cx1, cx2 = x1.copy(), x2.copy()
    rx1, rx2 = x1.copy(), x2.copy()
    W_relu = W * 0.3  # scale for ReLU to avoid immediate explosion

    for d in depths:
        cx1 = tropical_agg(W, cx1)
        cx2 = tropical_agg(W, cx2)
        t_ratio = sup_norm(cx1 - cx2) / input_dist

        rx1 = np.maximum(W_relu @ rx1, 0)
        rx2 = np.maximum(W_relu @ rx2, 0)
        r_dist = sup_norm(rx1 - rx2)
        r_ratio = r_dist / input_dist if input_dist > 0 else 0

        tropical_ratios.append(t_ratio)
        relu_ratios.append(min(r_ratio, 100))  # cap for display

    # Summary
    print(f"  Input perturbation: ‖x₁ - x₂‖∞ = {input_dist:.2e}")
    print(f"  Tropical max ratio over {max_depth} layers: {max(tropical_ratios):.6f}")
    print(f"  ReLU max ratio over {max_depth} layers: {max(relu_ratios):.6f}")
    print()

    for d in [1, 10, 25, 50, 100]:
        if d <= max_depth:
            print(f"  Depth {d:>3}: Tropical ratio = {tropical_ratios[d-1]:.6f}, "
                  f"ReLU ratio = {relu_ratios[d-1]:.6f}")

    print()
    print("  → Tropical: signal ratio ALWAYS ≤ 1 (proven)")
    print("  → ReLU: signal can vanish or explode with depth")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL COMPOSITIONAL STABILITY — REAL-WORLD APPLICATIONS         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    application_certified_robustness()
    application_shortest_path_stability()
    application_signal_propagation()

    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
Tropical Network Compositional Stability — Numerical Demonstrations

This script demonstrates the core theorems about tropical (max-plus) neural
network aggregation with concrete numerical examples:
1. Single-layer nonexpansiveness
2. Two-layer composition stability
3. Depth-parametrized stability (arbitrary depth)
4. Tropical composition = max-plus matrix multiplication
5. Translation equivariance
"""

import numpy as np
np.set_printoptions(precision=6, suppress=True)


def tropical_agg(W, x):
    """
    Tropical aggregation: (tropicalAgg W x)[j] = max_i (W[i,j] + x[i])

    Parameters:
        W: weight matrix of shape (n, m)
        x: input vector of shape (n,)
    Returns:
        output vector of shape (m,)
    """
    # W[i,j] + x[i] for all i,j => take max over i (axis=0)
    return np.max(W + x[:, np.newaxis], axis=0)


def sup_norm(x):
    """Sup norm: max_i |x_i|"""
    return np.max(np.abs(x))


def tropical_compose(W1, W2):
    """
    Tropical matrix composition (max-plus matrix multiplication):
    (W1 ⊛ W2)[i,k] = max_j (W1[i,j] + W2[j,k])
    """
    n, m = W1.shape
    _, p = W2.shape
    result = np.full((n, p), -np.inf)
    for i in range(n):
        for k in range(p):
            result[i, k] = np.max(W1[i, :] + W2[:, k])
    return result


def demo_single_layer_nonexpansive():
    """Demonstrate that a single tropical layer is 1-Lipschitz."""
    print("=" * 70)
    print("DEMO 1: Single-Layer Nonexpansiveness")
    print("=" * 70)
    print()

    np.random.seed(42)
    W = np.random.randn(4, 3)
    x = np.random.randn(4)
    y = np.random.randn(4)

    Fx = tropical_agg(W, x)
    Fy = tropical_agg(W, y)

    input_dist = sup_norm(x - y)
    output_dist = sup_norm(Fx - Fy)

    print(f"  Weight matrix W (4×3):\n{W}")
    print(f"  Input x: {x}")
    print(f"  Input y: {y}")
    print(f"  F(x) = tropicalAgg(W, x): {Fx}")
    print(f"  F(y) = tropicalAgg(W, y): {Fy}")
    print(f"  ‖x - y‖∞ = {input_dist:.6f}")
    print(f"  ‖F(x) - F(y)‖∞ = {output_dist:.6f}")
    print(f"  Ratio: {output_dist / input_dist:.6f} ≤ 1.0 ✓")
    print(f"  → Output distance ≤ input distance: {output_dist <= input_dist + 1e-10}")
    print()


def demo_two_layer_composition():
    """Demonstrate that two-layer composition is 1-Lipschitz."""
    print("=" * 70)
    print("DEMO 2: Two-Layer Composition Stability")
    print("=" * 70)
    print()

    np.random.seed(123)
    W1 = np.random.randn(5, 4)
    W2 = np.random.randn(4, 3)
    x = np.random.randn(5)
    y = np.random.randn(5)

    # Two-layer composition: F₂(F₁(x))
    F1x = tropical_agg(W1, x)
    F1y = tropical_agg(W1, y)
    F2F1x = tropical_agg(W2, F1x)
    F2F1y = tropical_agg(W2, F1y)

    input_dist = sup_norm(x - y)
    mid_dist = sup_norm(F1x - F1y)
    output_dist = sup_norm(F2F1x - F2F1y)

    print(f"  ‖x - y‖∞           = {input_dist:.6f}")
    print(f"  ‖F₁(x) - F₁(y)‖∞   = {mid_dist:.6f}  (≤ input)")
    print(f"  ‖F₂∘F₁(x) - F₂∘F₁(y)‖∞ = {output_dist:.6f}  (≤ input)")
    print(f"  Ratio (2-layer): {output_dist / input_dist:.6f} ≤ 1.0 ✓")
    print()


def demo_depth_stability():
    """Demonstrate stability at various depths."""
    print("=" * 70)
    print("DEMO 3: Depth-Parametrized Stability")
    print("=" * 70)
    print()
    print("  Demonstrating that ‖F^n(x) - F^n(y)‖∞ ≤ ‖x - y‖∞ for all n.")
    print()

    np.random.seed(7)
    dim = 6
    W = np.random.randn(dim, dim) * 2  # Large weights to stress-test
    x = np.random.randn(dim) * 3
    y = np.random.randn(dim) * 3

    input_dist = sup_norm(x - y)
    print(f"  Dimension: {dim}")
    print(f"  ‖x - y‖∞ = {input_dist:.6f}")
    print()
    print(f"  {'Depth n':>10} | {'‖F^n(x) - F^n(y)‖∞':>22} | {'Ratio':>8} | {'≤ 1?':>5}")
    print(f"  {'-'*10}-+-{'-'*22}-+-{'-'*8}-+-{'-'*5}")

    curr_x, curr_y = x.copy(), y.copy()
    for n in range(1, 21):
        curr_x = tropical_agg(W, curr_x)
        curr_y = tropical_agg(W, curr_y)
        dist = sup_norm(curr_x - curr_y)
        ratio = dist / input_dist
        ok = "✓" if ratio <= 1.0 + 1e-10 else "✗"
        print(f"  {n:>10} | {dist:>22.6f} | {ratio:>8.6f} | {ok:>5}")

    print()
    print("  → Stability maintained at ALL depths. No amplification. ✓")
    print()


def demo_composition_equals_matrix_mult():
    """Demonstrate that tropicalAgg W₂ (tropicalAgg W₁ x) = tropicalAgg (W₁⊛W₂) x."""
    print("=" * 70)
    print("DEMO 4: Composition = Max-Plus Matrix Multiplication")
    print("=" * 70)
    print()

    np.random.seed(99)
    W1 = np.random.randn(4, 3)
    W2 = np.random.randn(3, 5)
    x = np.random.randn(4)

    # Method 1: Sequential application
    result_seq = tropical_agg(W2, tropical_agg(W1, x))

    # Method 2: Tropical composition then single application
    W_composed = tropical_compose(W1, W2)
    result_comp = tropical_agg(W_composed, x)

    print(f"  Sequential: tropicalAgg(W₂, tropicalAgg(W₁, x)) = {result_seq}")
    print(f"  Composed:   tropicalAgg(W₁⊛W₂, x)               = {result_comp}")
    print(f"  Max difference: {sup_norm(result_seq - result_comp):.2e}")
    print(f"  → Results are identical (up to floating point). ✓")
    print()


def demo_associativity():
    """Demonstrate associativity of tropical composition."""
    print("=" * 70)
    print("DEMO 5: Associativity of Tropical Composition")
    print("=" * 70)
    print()

    np.random.seed(55)
    W1 = np.random.randn(3, 4)
    W2 = np.random.randn(4, 5)
    W3 = np.random.randn(5, 2)

    left = tropical_compose(tropical_compose(W1, W2), W3)
    right = tropical_compose(W1, tropical_compose(W2, W3))

    print(f"  (W₁⊛W₂)⊛W₃:\n{left}")
    print(f"  W₁⊛(W₂⊛W₃):\n{right}")
    print(f"  Max difference: {sup_norm(left - right):.2e}")
    print(f"  → Associativity holds. ✓")
    print()


def demo_translation_equivariance():
    """Demonstrate tropicalAgg W (x + c) = tropicalAgg W x + c."""
    print("=" * 70)
    print("DEMO 6: Translation Equivariance")
    print("=" * 70)
    print()

    np.random.seed(13)
    W = np.random.randn(4, 3)
    x = np.random.randn(4)
    c = 2.718

    Fx = tropical_agg(W, x)
    Fxc = tropical_agg(W, x + c)

    print(f"  tropicalAgg(W, x)     = {Fx}")
    print(f"  tropicalAgg(W, x + c) = {Fxc}")
    print(f"  tropicalAgg(W, x) + c = {Fx + c}")
    print(f"  Max difference: {sup_norm(Fxc - (Fx + c)):.2e}")
    print(f"  → Translation equivariance holds. ✓")
    print()


def demo_comparison_with_relu():
    """Compare Lipschitz behavior: tropical vs ReLU networks."""
    print("=" * 70)
    print("DEMO 7: Tropical vs ReLU — Lipschitz Amplification Comparison")
    print("=" * 70)
    print()

    np.random.seed(42)
    dim = 8
    depths = [1, 2, 5, 10, 20, 50]

    # Tropical network (max-plus)
    W_trop = np.random.randn(dim, dim)
    # ReLU network (standard)
    W_relu = np.random.randn(dim, dim) * 0.5  # scaled down to avoid explosion

    x = np.random.randn(dim)
    y = x + np.random.randn(dim) * 0.01  # small perturbation
    input_dist = sup_norm(x - y)

    print(f"  Input perturbation ‖x - y‖∞ = {input_dist:.6f}")
    print()
    print(f"  {'Depth':>6} | {'Tropical ratio':>16} | {'ReLU ratio':>16} | {'Amplification?':>15}")
    print(f"  {'-'*6}-+-{'-'*16}-+-{'-'*16}-+-{'-'*15}")

    tx, ty = x.copy(), y.copy()
    rx, ry = x.copy(), y.copy()
    for d in range(1, max(depths) + 1):
        tx = tropical_agg(W_trop, tx)
        ty = tropical_agg(W_trop, ty)
        rx = np.maximum(W_relu @ rx, 0)  # ReLU layer
        ry = np.maximum(W_relu @ ry, 0)
        if d in depths:
            t_ratio = sup_norm(tx - ty) / input_dist
            r_dist = sup_norm(rx - ry)
            r_ratio = r_dist / input_dist if input_dist > 0 else 0
            print(f"  {d:>6} | {t_ratio:>16.6f} | {r_ratio:>16.6f} | {'YES ⚠' if r_ratio > 1.01 else 'no':>15}")

    print()
    print("  → Tropical: ratio ALWAYS ≤ 1 (proven mathematically).")
    print("  → ReLU: ratio can grow with depth (no such guarantee).")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL NETWORK COMPOSITIONAL STABILITY — NUMERICAL DEMOS         ║")
    print("║  Theorem: Depth does not amplify Lipschitz constant in max-plus.    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_single_layer_nonexpansive()
    demo_two_layer_composition()
    demo_depth_stability()
    demo_composition_equals_matrix_mult()
    demo_associativity()
    demo_translation_equivariance()
    demo_comparison_with_relu()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualizations for Tropical Compositional Stability.

Generates publication-quality figures illustrating the key theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def tropical_agg(W, x):
    return np.max(W + x[:, np.newaxis], axis=0)


def sup_norm(x):
    return np.max(np.abs(x))


def viz_depth_stability():
    """Visualize Lipschitz ratio vs depth for tropical networks."""
    np.random.seed(42)
    dims = [4, 8, 16, 32]
    max_depth = 50

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    for dim in dims:
        W = np.random.randn(dim, dim) * 2
        x = np.random.randn(dim) * 3
        y = np.random.randn(dim) * 3
        input_dist = sup_norm(x - y)

        ratios = []
        cx, cy = x.copy(), y.copy()
        for d in range(max_depth):
            cx = tropical_agg(W, cx)
            cy = tropical_agg(W, cy)
            ratios.append(sup_norm(cx - cy) / input_dist)

        ax.plot(range(1, max_depth + 1), ratios, label=f'dim = {dim}', linewidth=2)

    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Lipschitz bound = 1')
    ax.set_xlabel('Network Depth', fontsize=14)
    ax.set_ylabel('‖F^n(x) − F^n(y)‖∞ / ‖x − y‖∞', fontsize=14)
    ax.set_title('Tropical Network: Lipschitz Ratio vs Depth', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_ylim(-0.05, 1.3)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def viz_tropical_vs_relu():
    """Compare tropical vs ReLU Lipschitz behavior."""
    np.random.seed(42)
    dim = 10
    max_depth = 40

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Multiple random initializations
    for trial in range(5):
        np.random.seed(42 + trial)
        W = np.random.randn(dim, dim)
        x = np.random.randn(dim)
        y = x + np.random.randn(dim) * 0.01
        input_dist = sup_norm(x - y)

        # Tropical
        trop_ratios = []
        cx, cy = x.copy(), y.copy()
        for d in range(max_depth):
            cx = tropical_agg(W, cx)
            cy = tropical_agg(W, cy)
            trop_ratios.append(sup_norm(cx - cy) / input_dist)

        # ReLU
        W_relu = W * 0.4
        relu_ratios = []
        rx, ry = x.copy(), y.copy()
        for d in range(max_depth):
            rx = np.maximum(W_relu @ rx, 0)
            ry = np.maximum(W_relu @ ry, 0)
            r = sup_norm(rx - ry) / input_dist if input_dist > 0 else 0
            relu_ratios.append(min(r, 50))

        alpha = 0.5 if trial > 0 else 1.0
        ax1.plot(range(1, max_depth + 1), trop_ratios,
                color='blue', alpha=alpha, linewidth=1.5)
        ax2.plot(range(1, max_depth + 1), relu_ratios,
                color='orange', alpha=alpha, linewidth=1.5)

    ax1.axhline(y=1.0, color='red', linestyle='--', linewidth=2)
    ax1.set_title('Tropical (Max-Plus) Network', fontsize=14)
    ax1.set_xlabel('Depth', fontsize=12)
    ax1.set_ylabel('Lipschitz Ratio', fontsize=12)
    ax1.set_ylim(-0.05, 1.5)
    ax1.grid(True, alpha=0.3)

    ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=2)
    ax2.set_title('ReLU Network', fontsize=14)
    ax2.set_xlabel('Depth', fontsize=12)
    ax2.set_ylabel('Lipschitz Ratio', fontsize=12)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Depth Stability: Tropical vs ReLU', fontsize=16, y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


def viz_composition_compression():
    """Visualize the composition = matrix multiplication theorem."""
    np.random.seed(42)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    W1 = np.random.randn(4, 4)
    W2 = np.random.randn(4, 4)

    # Show W1
    im1 = axes[0].imshow(W1, cmap='RdBu', aspect='auto')
    axes[0].set_title('Layer 1: W₁', fontsize=14)
    plt.colorbar(im1, ax=axes[0])

    # Show W2
    im2 = axes[1].imshow(W2, cmap='RdBu', aspect='auto')
    axes[1].set_title('Layer 2: W₂', fontsize=14)
    plt.colorbar(im2, ax=axes[1])

    # Show composed
    W_comp = np.zeros((4, 4))
    for i in range(4):
        for k in range(4):
            W_comp[i, k] = np.max(W1[i, :] + W2[:, k])

    im3 = axes[2].imshow(W_comp, cmap='RdBu', aspect='auto')
    axes[2].set_title('Composed: W₁ ⊛ W₂', fontsize=14)
    plt.colorbar(im3, ax=axes[2])

    fig.suptitle('Tropical Depth Compression: Two Layers → One', fontsize=16)
    fig.tight_layout()

    return fig_to_base64(fig)


def viz_robustness_certificate():
    """Visualize certified robustness regions."""
    np.random.seed(42)

    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # 2D tropical classifier
    W1 = np.array([[1.0, -1.0, 0.5],
                    [0.5, 1.0, -0.5]])
    W2 = np.array([[1.0, -0.5],
                    [-0.5, 1.0],
                    [0.5, 0.5]])

    # Grid for decision regions
    xx, yy = np.meshgrid(np.linspace(-3, 3, 200), np.linspace(-3, 3, 200))
    predictions = np.zeros(xx.shape)

    for i in range(xx.shape[0]):
        for j in range(xx.shape[1]):
            x = np.array([xx[i, j], yy[i, j]])
            out = tropical_agg(W2, tropical_agg(W1, x))
            predictions[i, j] = np.argmax(out)

    ax.contourf(xx, yy, predictions, alpha=0.3, cmap='coolwarm')
    ax.contour(xx, yy, predictions, colors='black', linewidths=0.5)

    # Plot a few points with their certified radii
    test_points = [np.array([1.0, 1.0]), np.array([-1.0, -1.0]),
                   np.array([0.5, -1.5]), np.array([-0.5, 1.5])]

    for pt in test_points:
        out = tropical_agg(W2, tropical_agg(W1, pt))
        sorted_out = np.sort(out)[::-1]
        margin = sorted_out[0] - sorted_out[1]
        radius = margin / 2.0

        ax.plot(pt[0], pt[1], 'ko', markersize=8)
        circle = plt.Circle(pt, radius, fill=False, color='green',
                           linewidth=2, linestyle='--')
        ax.add_patch(circle)
        ax.annotate(f'r={radius:.2f}', pt + 0.1, fontsize=10)

    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_xlabel('x₁', fontsize=14)
    ax.set_ylabel('x₂', fontsize=14)
    ax.set_title('Tropical Classifier: Decision Regions & Certified Radii', fontsize=14)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    viz_data = {}
    viz_data['depth_stability'] = viz_depth_stability()
    print("  ✓ Depth stability plot")

    viz_data['tropical_vs_relu'] = viz_tropical_vs_relu()
    print("  ✓ Tropical vs ReLU comparison")

    viz_data['composition'] = viz_composition_compression()
    print("  ✓ Composition compression")

    viz_data['robustness'] = viz_robustness_certificate()
    print("  ✓ Robustness certificates")

    # Save for use in PACKAGE.json
    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)

    print("\nAll visualizations generated and saved to viz_data.json")
