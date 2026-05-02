#!/usr/bin/env python3
"""
Top-k Certified Robustness Demo
================================

Demonstrates the formally verified top-k robustness certificate for multiclass
piecewise-linear networks. This script:

1. Computes kthLargest, topkGap, and topKSet for concrete score vectors
2. Visualizes how perturbation affects the top-k gap
3. Shows a certified robustness radius computation for a simple 2D network
4. Demonstrates the compositional theorem with max-pooling aggregation

All mathematical claims correspond to formally verified Lean 4 theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations

# ── Core Definitions ──────────────────────────────────────────────────────

def kth_largest(scores, k):
    """
    k-th largest value (0-indexed) of a score vector.
    Corresponds to the Lean definition:
      kthLargest s k = sup_{|S|=k+1} inf_{i in S} s(i)
    which equals the (k+1)-th largest element when sorted descending.
    """
    sorted_desc = np.sort(scores)[::-1]
    if k < len(scores):
        return sorted_desc[k]
    return 0.0


def topk_gap(scores, k):
    """
    Gap between the k-th and (k+1)-th largest values.
    topkGap s k = kthLargest s (k-1) - kthLargest s k
    """
    return kth_largest(scores, k - 1) - kth_largest(scores, k)


def topk_set(scores, k):
    """
    Set of indices whose score exceeds the (k+1)-th largest.
    Under positive gap, this has exactly k elements.
    """
    threshold = kth_largest(scores, k)
    return set(i for i in range(len(scores)) if scores[i] > threshold)


def certified_radius(scores, k, K, d):
    """
    Certified L∞ radius: within this ball, the top-k set is guaranteed invariant.
    r = topkGap(scores, k) / (2 * K * d)
    """
    gap = topk_gap(scores, k)
    if K * d <= 0:
        return float('inf') if gap > 0 else 0.0
    return gap / (2 * K * d)


# ── Demo 1: Basic Order Statistics ────────────────────────────────────────

def demo_basic():
    print("=" * 70)
    print("DEMO 1: Basic Order Statistics")
    print("=" * 70)

    scores = np.array([5.0, 4.0, 2.0, 1.0])
    C = len(scores)
    print(f"\nScore vector: {scores}  (C = {C})")
    print(f"Classes:       {list(range(C))}")
    print()

    for k in range(C):
        print(f"  kthLargest(s, {k}) = {kth_largest(scores, k):.1f}  "
              f"(the {k+1}-th largest value)")

    print()
    for k in range(1, C):
        gap = topk_gap(scores, k)
        tset = topk_set(scores, k)
        print(f"  topkGap(s, {k}) = {gap:.1f},  topKSet(s, {k}) = {tset}")

    # Example with ties
    print("\n--- With ties ---")
    scores_tied = np.array([5.0, 3.0, 3.0, 1.0])
    print(f"Score vector: {scores_tied}")
    for k in range(1, C):
        gap = topk_gap(scores_tied, k)
        tset = topk_set(scores_tied, k)
        print(f"  topkGap(s, {k}) = {gap:.1f},  topKSet(s, {k}) = {tset}  "
              f"{'(gap = 0, set may not have card k)' if gap == 0 else ''}")


# ── Demo 2: Perturbation and Gap Degradation ──────────────────────────────

def demo_perturbation():
    print("\n" + "=" * 70)
    print("DEMO 2: Gap Degradation Under Perturbation")
    print("=" * 70)

    scores = np.array([8.0, 5.0, 3.0, 1.0])
    k = 2
    gap_original = topk_gap(scores, k)
    topk_original = topk_set(scores, k)

    print(f"\nOriginal scores: {scores}")
    print(f"topkGap(s, {k}) = {gap_original:.1f}")
    print(f"topKSet(s, {k}) = {topk_original}")

    # Apply perturbations of increasing magnitude
    print(f"\n{'ε':>6} | {'Gap after':>10} | {'Gap bound':>10} | {'TopKSet':>15} | {'Preserved?':>10}")
    print("-" * 65)

    np.random.seed(42)
    for eps in [0.0, 0.3, 0.5, 0.8, 1.0, 1.5, 2.0]:
        # Random perturbation bounded by ε
        delta = np.random.uniform(-eps, eps, size=len(scores))
        perturbed = scores + delta

        gap_perturbed = topk_gap(perturbed, k)
        gap_bound = gap_original - 2 * eps  # Theorem: gap degrades by at most 2ε
        topk_perturbed = topk_set(perturbed, k)
        preserved = topk_perturbed == topk_original

        print(f"{eps:6.2f} | {gap_perturbed:10.3f} | {gap_bound:10.3f} | "
              f"{str(topk_perturbed):>15} | {'✓' if preserved else '✗':>10}")

    print(f"\n  Theorem guarantee: gap degrades by at most 2ε")
    print(f"  Certificate: top-{k} set preserved when 2ε < gap = {gap_original:.1f}, i.e., ε < {gap_original/2:.1f}")


# ── Demo 3: Certified Radius Visualization ────────────────────────────────

def demo_certified_radius():
    print("\n" + "=" * 70)
    print("DEMO 3: Certified Radius for a 2D Network")
    print("=" * 70)

    # Simple 2D → 4-class network: f(x) = W @ x + b
    d = 2
    C = 4
    W = np.array([
        [2.0, 1.0],
        [1.0, 2.0],
        [-1.0, 0.5],
        [0.5, -1.0]
    ])
    b = np.array([1.0, 0.5, -0.5, 0.0])

    def f(x):
        return W @ x + b

    # Lipschitz bound: |f(x+δ)_i - f(x)_i| = |W_i · δ| ≤ ||W_i||_1 * ||δ||_∞
    # In the K*d*||δ|| form: K = max ||W_i||_1 / d
    K = max(np.sum(np.abs(W[i])) for i in range(C)) / d

    x0 = np.array([1.0, 0.5])
    scores = f(x0)

    print(f"\n  Network: f(x) = W·x + b, d = {d}, C = {C}")
    print(f"  Lipschitz constant K = {K:.2f}")
    print(f"  Input point x₀ = {x0}")
    print(f"  Scores f(x₀) = {scores}")

    for k in range(1, C):
        gap = topk_gap(scores, k)
        tset = topk_set(scores, k)
        radius = certified_radius(scores, k, K, d)
        print(f"\n  k = {k}: gap = {gap:.2f}, topKSet = {tset}, "
              f"certified radius = {radius:.4f}")

    # Visualization
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    for idx, k in enumerate([1, 2, 3]):
        ax = axes[idx]
        gap = topk_gap(scores, k)
        radius = certified_radius(scores, k, K, d)

        # Plot the decision regions
        xx, yy = np.meshgrid(np.linspace(-1, 3, 200), np.linspace(-1, 2, 200))
        grid = np.column_stack([xx.ravel(), yy.ravel()])

        topk_labels = np.zeros(len(grid))
        for i, pt in enumerate(grid):
            s = f(pt)
            ts = topk_set(s, k)
            topk_labels[i] = sum(2**j for j in ts) if len(ts) == k else -1

        topk_labels = topk_labels.reshape(xx.shape)
        ax.contourf(xx, yy, topk_labels, levels=20, alpha=0.3, cmap='tab20')
        ax.plot(x0[0], x0[1], 'k*', markersize=15, zorder=5)

        if radius > 0 and radius < 10:
            circle = plt.Circle(x0, radius, fill=False, color='red',
                              linewidth=2, linestyle='--')
            ax.add_patch(circle)
            ax.set_title(f'Top-{k} Regions (r = {radius:.3f})', fontsize=12)
        else:
            ax.set_title(f'Top-{k} Regions (gap = {gap:.2f})', fontsize=12)

        ax.set_xlabel('x₁')
        ax.set_ylabel('x₂')
        ax.set_aspect('equal')

    plt.suptitle('Certified Top-k Robustness Regions', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/topk_certified_regions.png', dpi=150, bbox_inches='tight')
    print(f"\n  → Saved visualization to demos/topk_certified_regions.png")


# ── Demo 4: Compositional Theorem with Aggregation ────────────────────────

def demo_composition():
    print("\n" + "=" * 70)
    print("DEMO 4: Compositional Theorem with 1-Lipschitz Aggregation")
    print("=" * 70)

    d = 3
    m = 6
    C = 4

    # Hidden layer: h(x) = ReLU(V @ x + c)
    np.random.seed(123)
    V = np.random.randn(m, d) * 0.5
    c = np.random.randn(m) * 0.1

    def h(x):
        return np.maximum(V @ x + c, 0)

    # Aggregation: A(z) = W_agg @ z  (1-Lipschitz if ||W_agg||_{∞→∞} ≤ 1)
    W_agg_raw = np.random.randn(C, m) * 0.3
    # Normalize rows to make it 1-Lipschitz in L∞ → L∞
    for i in range(C):
        row_l1 = np.sum(np.abs(W_agg_raw[i]))
        if row_l1 > 1:
            W_agg_raw[i] /= row_l1

    def A(z):
        return W_agg_raw @ z

    is_1lip = all(np.sum(np.abs(W_agg_raw[i])) <= 1.0 + 1e-10 for i in range(C))
    print(f"\n  Aggregator A is 1-Lipschitz: {is_1lip}")

    # Lipschitz constant for h: K such that |h(x+δ)_j - h(x)_j| ≤ K * d * ||δ||_∞
    # For ReLU(V·x + c): |ReLU(a) - ReLU(b)| ≤ |a - b|, and |V_j · δ| ≤ ||V_j||_1 * ||δ||_∞
    K_h = max(np.sum(np.abs(V[j])) for j in range(m)) / d

    x0 = np.array([1.0, 0.5, -0.3])
    scores = A(h(x0))

    print(f"  Network: A ∘ ReLU ∘ V, d={d}, m={m}, C={C}")
    print(f"  K = {K_h:.3f}")
    print(f"  Input x₀ = {x0}")
    print(f"  Composed scores = {scores.round(3)}")

    for k in range(1, C):
        gap = topk_gap(scores, k)
        tset = topk_set(scores, k)
        radius = certified_radius(scores, k, K_h, d)
        print(f"\n  k = {k}: gap = {gap:.4f}, topKSet = {tset}, "
              f"certified radius = {radius:.4f}")

    # Empirical verification
    k = 2
    radius = certified_radius(scores, k, K_h, d)
    topk_original = topk_set(scores, k)
    n_samples = 10000
    n_violated = 0

    for _ in range(n_samples):
        delta = np.random.uniform(-radius * 0.99, radius * 0.99, size=d)
        perturbed_scores = A(h(x0 + delta))
        if topk_set(perturbed_scores, k) != topk_original:
            n_violated += 1

    print(f"\n  Empirical verification (k={k}, radius={radius:.4f}):")
    print(f"  {n_samples} random perturbations within 0.99×radius: "
          f"{n_violated} violations (should be 0)")


# ── Demo 5: Gap Degradation Plot ──────────────────────────────────────────

def demo_gap_plot():
    print("\n" + "=" * 70)
    print("DEMO 5: Gap Degradation Visualization")
    print("=" * 70)

    scores = np.array([10.0, 7.0, 4.0, 2.0, 1.0])
    C = len(scores)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left panel: gap vs perturbation magnitude
    ax = axes[0]
    epsilons = np.linspace(0, 5, 100)

    for k in range(1, C):
        gap_original = topk_gap(scores, k)
        gap_bounds = np.maximum(gap_original - 2 * epsilons, 0)

        # Monte Carlo worst-case gaps
        np.random.seed(k * 42)
        actual_gaps = []
        for eps in epsilons:
            gaps_mc = []
            for _ in range(50):
                delta = np.random.uniform(-eps, eps, size=C)
                gaps_mc.append(topk_gap(scores + delta, k))
            actual_gaps.append(np.min(gaps_mc))

        ax.plot(epsilons, gap_bounds, '--', label=f'k={k} bound', alpha=0.7)
        ax.plot(epsilons, actual_gaps, '-', label=f'k={k} worst', alpha=0.5)

    ax.set_xlabel('Perturbation magnitude ε', fontsize=12)
    ax.set_ylabel('Top-k gap', fontsize=12)
    ax.set_title('Gap Degradation: Bound vs Actual', fontsize=13)
    ax.legend(fontsize=9, ncol=2)
    ax.axhline(y=0, color='red', linestyle=':', alpha=0.5)
    ax.grid(True, alpha=0.3)

    # Right panel: certified radius for different k values
    ax = axes[1]
    K_values = np.linspace(0.1, 5, 50)
    d = 10

    for k in range(1, C):
        radii = [certified_radius(scores, k, K, d) for K in K_values]
        ax.plot(K_values, radii, label=f'k={k}, gap={topk_gap(scores,k):.0f}')

    ax.set_xlabel('Lipschitz constant K', fontsize=12)
    ax.set_ylabel('Certified radius', fontsize=12)
    ax.set_title(f'Certified Radius vs K (d={d})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Top-k Robustness Certificate Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/topk_gap_analysis.png', dpi=150, bbox_inches='tight')
    print(f"  → Saved visualization to demos/topk_gap_analysis.png")


# ── Demo 6: Sup-of-Infima Definition Verification ────────────────────────

def demo_sup_inf():
    print("\n" + "=" * 70)
    print("DEMO 6: Sup-of-Infima Definition Verification")
    print("=" * 70)

    scores = np.array([7.0, 3.0, 5.0, 1.0, 4.0])
    C = len(scores)
    print(f"\n  Scores: {scores}  (sorted: {np.sort(scores)[::-1]})")

    for k in range(C):
        # Compute via sorting
        sorted_val = np.sort(scores)[::-1][k]

        # Compute via sup-of-infima
        sup_inf_val = max(
            min(scores[list(S)])
            for S in combinations(range(C), k + 1)
        )

        print(f"  k={k}: sorted[{k}] = {sorted_val:.1f}, "
              f"sup-inf = {sup_inf_val:.1f}  "
              f"{'✓' if abs(sorted_val - sup_inf_val) < 1e-10 else '✗'}")


# ── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Top-k Certified Robustness for Multiclass Neural Networks          ║")
    print("║  Formally Verified in Lean 4 with Mathlib                           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_basic()
    demo_perturbation()
    demo_sup_inf()
    demo_certified_radius()
    demo_composition()
    demo_gap_plot()

    print("\n" + "=" * 70)
    print("All demos complete. Visualizations saved in demos/")
    print("=" * 70)
