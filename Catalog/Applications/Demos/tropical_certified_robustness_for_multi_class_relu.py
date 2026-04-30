#!/usr/bin/env python3
"""
Tropical Certified Robustness: Multi-Class Demo
=================================================

This script demonstrates the multi-class tropical certified robustness theorem
with concrete neural network examples. It computes certificate radii and
visualizes how the tropical distance between logits determines the safe region
around a correctly-classified input.

Key idea: For a k-class ReLU network with Lipschitz constant K and tropical
degree d, the certified robustness radius at a correctly-classified point x is:

    r* = min_{j ≠ i} |f(x,i) - f(x,j)| / (2·K·d)

where i is the predicted class. Within this ball, the classification is provably
preserved.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.colors import ListedColormap
import os

# ─────────────────────────────────────────────────
# 1. Define a simple multi-class ReLU network
# ─────────────────────────────────────────────────

def relu(x):
    return np.maximum(0, x)

class SimpleReLUNetwork:
    """A 3-class ReLU network: ℝ² → ℝ³ with one hidden layer."""

    def __init__(self, seed=42):
        rng = np.random.RandomState(seed)
        # Hidden layer: 2 → 8
        self.W1 = rng.randn(2, 8) * 0.8
        self.b1 = rng.randn(8) * 0.3
        # Output layer: 8 → 3
        self.W2 = rng.randn(8, 3) * 0.5
        self.b2 = rng.randn(3) * 0.2

    def forward(self, x):
        """Compute logits f(x) ∈ ℝ³."""
        h = relu(x @ self.W1 + self.b1)
        return h @ self.W2 + self.b2

    def predict(self, x):
        """Return predicted class."""
        return np.argmax(self.forward(x), axis=-1)

    def lipschitz_bound(self):
        """Compute an upper bound on the Lipschitz constant.

        For a ReLU network, K ≤ ∏ ||W_l||_op (product of operator norms).
        """
        s1 = np.linalg.svd(self.W1, compute_uv=False)[0]
        s2 = np.linalg.svd(self.W2, compute_uv=False)[0]
        return s1 * s2

    def tropical_degree(self):
        """Tropical degree bound: number of hidden neurons (an upper bound on
        the number of linear regions along any 1D slice)."""
        return self.W1.shape[1]  # = 8


def compute_certificate_radius(logits, predicted_class, K, d):
    """Compute the tropical certified robustness radius.

    r* = min_{j ≠ i} |f(x,i) - f(x,j)| / (2·K·d)

    Parameters
    ----------
    logits : array of shape (k,), the network outputs f(x)
    predicted_class : int, the predicted class i
    K : float, Lipschitz constant
    d : int, tropical degree

    Returns
    -------
    r_star : float, certified robustness radius
    pairwise_gaps : dict mapping j → |f(x,i) - f(x,j)|
    pairwise_radii : dict mapping j → |f(x,i) - f(x,j)| / (2Kd)
    """
    k = len(logits)
    i = predicted_class
    pairwise_gaps = {}
    pairwise_radii = {}

    for j in range(k):
        if j == i:
            continue
        gap = abs(logits[i] - logits[j])
        radius = gap / (2 * K * d)
        pairwise_gaps[j] = gap
        pairwise_radii[j] = radius

    r_star = min(pairwise_radii.values())
    return r_star, pairwise_gaps, pairwise_radii


# ─────────────────────────────────────────────────
# 2. Visualization: Decision Regions & Certificates
# ─────────────────────────────────────────────────

def plot_decision_regions_with_certificates(net, test_points, xlim=(-3, 3), ylim=(-3, 3),
                                             resolution=300, filename="tropical_robustness.png"):
    """Visualize decision boundaries and certified robustness balls."""
    K = net.lipschitz_bound()
    d = net.tropical_degree()

    # Create mesh for decision regions
    xx, yy = np.meshgrid(
        np.linspace(xlim[0], xlim[1], resolution),
        np.linspace(ylim[0], ylim[1], resolution)
    )
    grid = np.c_[xx.ravel(), yy.ravel()]
    predictions = net.predict(grid).reshape(xx.shape)

    # Set up figure
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    colors = ['#4ECDC4', '#FF6B6B', '#45B7D1']
    cmap = ListedColormap(colors)
    class_names = ['Class 0', 'Class 1', 'Class 2']

    # ── Left panel: Decision regions with certificate balls ──
    ax = axes[0]
    ax.contourf(xx, yy, predictions, levels=[-0.5, 0.5, 1.5, 2.5], colors=colors, alpha=0.3)
    ax.contour(xx, yy, predictions, levels=[0.5, 1.5], colors='gray', linewidths=1.5, linestyles='--')

    for idx, x in enumerate(test_points):
        logits = net.forward(x.reshape(1, -1))[0]
        pred = np.argmax(logits)
        r_star, gaps, radii = compute_certificate_radius(logits, pred, K, d)

        # Plot the point
        ax.plot(x[0], x[1], 'o', color=colors[pred], markersize=10,
                markeredgecolor='black', markeredgewidth=2, zorder=5)

        # Plot the certificate ball
        circle = plt.Circle((x[0], x[1]), r_star, fill=False,
                           color=colors[pred], linewidth=2.5, linestyle='-', zorder=4)
        ax.add_patch(circle)

        # Label with radius
        ax.annotate(f'r*={r_star:.3f}',
                   xy=(x[0], x[1] + r_star + 0.15),
                   ha='center', fontsize=9, fontweight='bold',
                   color=colors[pred],
                   bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

    ax.set_xlim(xlim)
    ax.set_ylim(ylim)
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Decision Regions & Tropical Certificate Balls', fontsize=14, fontweight='bold')
    ax.set_aspect('equal')

    # Legend
    legend_elements = [patches.Patch(facecolor=c, alpha=0.5, label=n)
                      for c, n in zip(colors, class_names)]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=10)

    # ── Right panel: Pairwise gaps bar chart ──
    ax2 = axes[1]

    # Compute gaps for all test points
    bar_data = []
    for idx, x in enumerate(test_points):
        logits = net.forward(x.reshape(1, -1))[0]
        pred = np.argmax(logits)
        r_star, gaps, radii = compute_certificate_radius(logits, pred, K, d)
        bar_data.append((idx, pred, gaps, radii, r_star))

    n_points = len(test_points)
    bar_width = 0.35
    x_pos = np.arange(n_points)

    for idx, (_, pred, gaps, radii, r_star) in enumerate(bar_data):
        for j_idx, (j, gap) in enumerate(sorted(gaps.items())):
            offset = (j_idx - 0.5) * bar_width
            bar = ax2.bar(idx + offset, radii[j], bar_width * 0.9,
                         color=colors[j], alpha=0.7, edgecolor='black', linewidth=0.5)

        # Mark r* with a horizontal line
        ax2.hlines(r_star, idx - 0.5, idx + 0.5, colors='red',
                  linewidth=2, linestyle='--', zorder=5, label='r*' if idx == 0 else '')

    ax2.set_xticks(x_pos)
    ax2.set_xticklabels([f'Point {i+1}' for i in range(n_points)], fontsize=10)
    ax2.set_ylabel('Certificate Radius', fontsize=12)
    ax2.set_title('Pairwise Radii & Certificate r*', fontsize=14, fontweight='bold')

    # Legend for right panel
    legend_elements2 = [patches.Patch(facecolor=c, alpha=0.7, label=f'vs {n}')
                       for c, n in zip(colors, class_names)]
    legend_elements2.append(plt.Line2D([0], [0], color='red', linewidth=2,
                                        linestyle='--', label='r* (min)'))
    ax2.legend(handles=legend_elements2, loc='upper right', fontsize=9)

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {filename}")


# ─────────────────────────────────────────────────
# 3. Numerical Verification
# ─────────────────────────────────────────────────

def verify_certificate(net, x, n_samples=10000, seed=123):
    """Empirically verify the certificate by sampling random perturbations.

    For each perturbation within the certificate ball, check that the
    classification is preserved.
    """
    rng = np.random.RandomState(seed)
    logits = net.forward(x.reshape(1, -1))[0]
    pred = np.argmax(logits)
    K = net.lipschitz_bound()
    d = net.tropical_degree()
    r_star, gaps, radii = compute_certificate_radius(logits, pred, K, d)

    print(f"\n{'='*60}")
    print(f"Verifying certificate at x = {x}")
    print(f"{'='*60}")
    print(f"  Predicted class: {pred}")
    print(f"  Logits: {logits}")
    print(f"  Lipschitz bound K = {K:.4f}")
    print(f"  Tropical degree d = {d}")
    print(f"  Certificate radius r* = {r_star:.6f}")
    print(f"  Pairwise gaps: {gaps}")
    print(f"  Pairwise radii: {radii}")

    # Sample random perturbations within the ball
    perturbations = rng.randn(n_samples, 2)
    norms = np.linalg.norm(perturbations, axis=1, keepdims=True)
    # Scale to be uniformly distributed within the ball of radius r*
    scales = rng.uniform(0, r_star, size=(n_samples, 1))
    perturbations = perturbations / norms * scales

    perturbed_points = x + perturbations
    perturbed_preds = net.predict(perturbed_points)
    violations = np.sum(perturbed_preds != pred)

    print(f"\n  Sampled {n_samples} perturbations within r* ball:")
    print(f"  Classification preserved: {n_samples - violations}/{n_samples}")
    if violations == 0:
        print(f"  ✓ Certificate verified empirically!")
    else:
        print(f"  ✗ {violations} violations found (should not happen!)")

    # Also test at the boundary
    boundary_perturbations = perturbations / np.linalg.norm(perturbations, axis=1, keepdims=True) * r_star
    boundary_points = x + boundary_perturbations
    boundary_preds = net.predict(boundary_points)
    boundary_violations = np.sum(boundary_preds != pred)
    print(f"\n  Sampled {n_samples} points on r* boundary:")
    print(f"  Classification preserved: {n_samples - boundary_violations}/{n_samples}")

    return violations == 0


# ─────────────────────────────────────────────────
# 4. Scaling Analysis: How k affects the certificate
# ─────────────────────────────────────────────────

def analyze_scaling(n_classes_list=[3, 5, 10, 20, 50], n_trials=50, seed=42):
    """Analyze how the certificate radius scales with the number of classes."""
    rng = np.random.RandomState(seed)

    results = {}
    for k in n_classes_list:
        radii = []
        for trial in range(n_trials):
            # Random k-class network
            W1 = rng.randn(2, 8) * 0.8
            b1 = rng.randn(8) * 0.3
            W2 = rng.randn(8, k) * 0.5
            b2 = rng.randn(k) * 0.2

            x = rng.randn(1, 2)
            h = relu(x @ W1 + b1)
            logits = (h @ W2 + b2)[0]

            pred = np.argmax(logits)
            K = np.linalg.svd(W1, compute_uv=False)[0] * np.linalg.svd(W2, compute_uv=False)[0]
            d = 8

            try:
                r_star, _, _ = compute_certificate_radius(logits, pred, K, d)
                radii.append(r_star)
            except ValueError:
                continue

        results[k] = radii

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    positions = list(range(len(n_classes_list)))
    bp = ax.boxplot([results[k] for k in n_classes_list], positions=positions,
                    patch_artist=True, widths=0.6)

    colors_box = plt.cm.viridis(np.linspace(0.2, 0.8, len(n_classes_list)))
    for patch, color in zip(bp['boxes'], colors_box):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)

    ax.set_xticks(positions)
    ax.set_xticklabels([str(k) for k in n_classes_list])
    ax.set_xlabel('Number of Classes (k)', fontsize=12)
    ax.set_ylabel('Certificate Radius r*', fontsize=12)
    ax.set_title('Tropical Certificate Radius vs Number of Classes', fontsize=14, fontweight='bold')
    ax.set_yscale('log')

    # Add median trend line
    medians = [np.median(results[k]) for k in n_classes_list]
    ax.plot(positions, medians, 'r--o', linewidth=2, markersize=8, label='Median r*')
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('tropical_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_scaling.png")

    return results


# ─────────────────────────────────────────────────
# 5. Main
# ─────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  TROPICAL CERTIFIED ROBUSTNESS: MULTI-CLASS DEMONSTRATION")
    print("=" * 70)

    # Create network
    net = SimpleReLUNetwork(seed=42)
    K = net.lipschitz_bound()
    d = net.tropical_degree()
    print(f"\nNetwork: 2D input → 8 hidden (ReLU) → 3 output")
    print(f"Lipschitz bound K = {K:.4f}")
    print(f"Tropical degree d = {d}")

    # Test points
    test_points = np.array([
        [0.5, 0.5],
        [-1.0, 0.8],
        [1.5, -0.5],
        [0.0, -1.0],
        [-0.5, -0.5],
    ])

    # Visualization
    print("\n" + "-" * 40)
    print("Generating decision region visualization...")
    plot_decision_regions_with_certificates(net, test_points)

    # Verify certificates
    print("\n" + "-" * 40)
    print("Empirical certificate verification:")
    all_verified = True
    for x in test_points:
        if not verify_certificate(net, x):
            all_verified = False

    print("\n" + "=" * 60)
    if all_verified:
        print("✓ ALL CERTIFICATES VERIFIED SUCCESSFULLY")
    else:
        print("✗ SOME CERTIFICATES FAILED (this should not happen)")
    print("=" * 60)

    # Scaling analysis
    print("\n" + "-" * 40)
    print("Analyzing scaling with number of classes...")
    results = analyze_scaling()

    # Summary table
    print("\n" + "-" * 40)
    print("Summary: Certificate Radius Statistics")
    print(f"{'Classes':>8} {'Median r*':>12} {'Mean r*':>12} {'Min r*':>12}")
    print("-" * 50)
    for k in sorted(results.keys()):
        r = results[k]
        print(f"{k:>8} {np.median(r):>12.6f} {np.mean(r):>12.6f} {np.min(r):>12.6f}")

    print("\n✓ Demo complete. See tropical_robustness.png and tropical_scaling.png")


if __name__ == "__main__":
    main()
