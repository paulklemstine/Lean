#!/usr/bin/env python3
"""
Tropical Satake Margin Theorem — Interactive Demo
==================================================

This script demonstrates the formally verified theorems from
TropicalSatakeMargin.lean with concrete numerical examples and
visualizations.

The core result: for a multiclass linear score classifier with weight
vectors W_1, ..., W_κ ∈ ℝⁿ, if the winning class has margin exceeding
  (‖W_a‖₁ + ‖W_b‖₁) · ε
over every competitor b, then the argmax is preserved under any
coordinatewise ε-perturbation of the feature vector.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches
from itertools import combinations

# ─── Core functions matching the Lean definitions ───────────────────

def score(w, phi):
    """Inner product ⟨w, φ⟩ = Σ_i w_i · φ_i."""
    return np.dot(w, phi)

def l1_norm(w):
    """ℓ¹ norm ‖w‖₁ = Σ_i |w_i|."""
    return np.sum(np.abs(w))

def pairwise_margin(W, phi, a, b):
    """score(W_a, φ) - score(W_b, φ)."""
    return score(W[a], phi) - score(W[b], phi)

def certified_radius(W, phi, a):
    """
    Maximum ε such that class a remains the argmax under
    coordinatewise ε-perturbation.

    ε* = min_{b ≠ a} [score(W_a, φ) - score(W_b, φ)] / [‖W_a‖₁ + ‖W_b‖₁]
    """
    n_classes = len(W)
    radii = []
    for b in range(n_classes):
        if b == a:
            continue
        gap = pairwise_margin(W, phi, a, b)
        denom = l1_norm(W[a]) + l1_norm(W[b])
        if denom == 0:
            radii.append(float('inf') if gap > 0 else 0.0)
        else:
            radii.append(gap / denom)
    return min(radii) if radii else float('inf')


# ─── Example 1: GL₃ Tropical Satake Test Family ────────────────────

def demo_gl3_test_family():
    """
    Demonstrate with a 3-class, 5-dimensional classifier inspired by
    GL₃ tropical Satake data.

    Coordinates correspond to:
      0: simple coroot α₁ edge valuation
      1: simple coroot α₂ edge valuation
      2: rank-2 Levi mixed moment
      3-4: additional support coordinates
    """
    print("=" * 65)
    print("Example 1: GL₃ Tropical Satake Test Family")
    print("=" * 65)

    # Weight vectors T(h_a) for three Hecke data classes
    W = np.array([
        [ 3.0,  1.0,  2.0,  0.5, -0.5],   # Class 0: T(h₀)
        [-1.0,  2.0, -1.0,  1.0,  0.0],   # Class 1: T(h₁)
        [ 0.0, -1.0,  1.0, -0.5,  2.0],   # Class 2: T(h₂)
    ])

    phi = np.array([1.0, 0.5, 0.8, 0.3, 0.2])

    print(f"\nFeature vector φ = {phi}")
    print(f"\nWeight vectors (tropical Satake test vectors):")
    for c in range(3):
        print(f"  W_{c} = T(h_{c}) = {W[c]}")
        print(f"    score(W_{c}, φ) = {score(W[c], phi):.4f}")
        print(f"    ‖W_{c}‖₁ = {l1_norm(W[c]):.4f}")

    # Find the argmax
    scores = [score(W[c], phi) for c in range(3)]
    a = int(np.argmax(scores))
    print(f"\nArgmax class: {a} (score = {scores[a]:.4f})")

    # Compute certified radius
    eps_star = certified_radius(W, phi, a)
    print(f"\nCertified robustness radius ε* = {eps_star:.6f}")
    print(f"  Any perturbation with |φ_i - ψ_i| ≤ {eps_star:.6f} preserves class {a}")

    # Verify: detailed pairwise analysis
    print(f"\nPairwise margin analysis:")
    for b in range(3):
        if b == a:
            continue
        gap = pairwise_margin(W, phi, a, b)
        denom = l1_norm(W[a]) + l1_norm(W[b])
        ratio = gap / denom if denom > 0 else float('inf')
        print(f"  vs class {b}:")
        print(f"    margin = {gap:.4f}")
        print(f"    ‖W_{a}‖₁ + ‖W_{b}‖₁ = {denom:.4f}")
        print(f"    normalized margin = {ratio:.6f}")

    # Demonstrate with actual perturbation
    print(f"\n--- Verification with random perturbation ---")
    np.random.seed(42)
    eps_test = eps_star * 0.99  # Just inside the certified radius
    perturbation = np.random.uniform(-eps_test, eps_test, size=5)
    psi = phi + perturbation

    print(f"  ε_test = {eps_test:.6f} (99% of ε*)")
    print(f"  ψ = φ + perturbation = {psi}")
    print(f"  max |φ_i - ψ_i| = {np.max(np.abs(perturbation)):.6f}")

    perturbed_scores = [score(W[c], psi) for c in range(3)]
    perturbed_argmax = int(np.argmax(perturbed_scores))
    print(f"  Perturbed scores: {[f'{s:.4f}' for s in perturbed_scores]}")
    print(f"  Perturbed argmax: {perturbed_argmax} {'✓' if perturbed_argmax == a else '✗'}")

    return W, phi, a, eps_star


# ─── Example 2: Lipschitz Transfer Lemma Visualization ─────────────

def demo_lipschitz_bound(W, phi, a):
    """Visualize how the score perturbation bound tightens with ε."""
    print("\n" + "=" * 65)
    print("Example 2: Lipschitz Transfer Bound Visualization")
    print("=" * 65)

    n_trials = 2000
    epsilons = np.linspace(0, 0.5, 50)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Score perturbation vs bound for each class
    ax = axes[0]
    colors = ['#2196F3', '#FF5722', '#4CAF50']
    for c in range(len(W)):
        actual_diffs = []
        bounds = []
        for eps in epsilons:
            diffs = []
            for _ in range(n_trials // len(epsilons)):
                perturbation = np.random.uniform(-eps, eps, size=len(phi))
                psi = phi + perturbation
                diffs.append(abs(score(W[c], phi) - score(W[c], psi)))
            actual_diffs.append(max(diffs) if diffs else 0)
            bounds.append(l1_norm(W[c]) * eps)

        ax.plot(epsilons, bounds, '-', color=colors[c],
                label=f'‖W_{c}‖₁ · ε = {l1_norm(W[c]):.1f}ε', linewidth=2)
        ax.scatter(epsilons, actual_diffs, color=colors[c], alpha=0.5, s=15,
                   label=f'max |Δscore_{c}| (empirical)')

    ax.set_xlabel('Perturbation bound ε', fontsize=12)
    ax.set_ylabel('|score(w, φ) - score(w, ψ)|', fontsize=12)
    ax.set_title('Lipschitz Transfer Lemma', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Right: Margin erosion under perturbation
    ax = axes[1]
    eps_range = np.linspace(0, 0.5, 200)
    for b in range(len(W)):
        if b == a:
            continue
        original_gap = pairwise_margin(W, phi, a, b)
        budget = [(l1_norm(W[a]) + l1_norm(W[b])) * eps for eps in eps_range]
        guaranteed_gap = [original_gap - bud for bud in budget]
        critical_eps = original_gap / (l1_norm(W[a]) + l1_norm(W[b]))

        ax.plot(eps_range, guaranteed_gap, '-', linewidth=2,
                label=f'Gap vs class {b} (lower bound)')
        ax.axvline(x=critical_eps, linestyle='--', alpha=0.5,
                   label=f'ε* vs class {b} = {critical_eps:.4f}')

    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('Perturbation bound ε', fontsize=12)
    ax.set_ylabel('Guaranteed margin gap', fontsize=12)
    ax.set_title('Margin Erosion Under Perturbation', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Bridges/fig_lipschitz_and_margin.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: Bridges/fig_lipschitz_and_margin.png")


# ─── Example 3: Multiclass Argmax Invariance Map ───────────────────

def demo_argmax_map():
    """
    Visualize the certified robustness region in 2D feature space.
    """
    print("\n" + "=" * 65)
    print("Example 3: Multiclass Argmax Invariance Map (2D)")
    print("=" * 65)

    # 3-class classifier in 2D
    W = np.array([
        [ 2.0,  1.0],   # Class 0
        [-1.0,  2.5],   # Class 1
        [ 0.5, -1.5],   # Class 2
    ])

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Create grid
    x = np.linspace(-3, 3, 400)
    y = np.linspace(-3, 3, 400)
    X, Y = np.meshgrid(x, y)

    # Compute argmax and certified radius at each point
    argmax_map = np.zeros_like(X, dtype=int)
    radius_map = np.zeros_like(X)

    for i in range(len(x)):
        for j in range(len(y)):
            phi = np.array([X[j, i], Y[j, i]])
            scores_val = [score(W[c], phi) for c in range(3)]
            a = int(np.argmax(scores_val))
            argmax_map[j, i] = a
            radius_map[j, i] = max(certified_radius(W, phi, a), 0)

    # Left: Decision regions
    ax = axes[0]
    colors_map = ['#BBDEFB', '#FFCCBC', '#C8E6C9']
    cmap = plt.matplotlib.colors.ListedColormap(colors_map)
    ax.contourf(X, Y, argmax_map, levels=[-0.5, 0.5, 1.5, 2.5], cmap=cmap)

    # Draw decision boundaries
    for a_cls, b_cls in combinations(range(3), 2):
        diff = W[a_cls] - W[b_cls]
        # Boundary: diff · φ = 0
        if abs(diff[1]) > 1e-10:
            x_line = np.linspace(-3, 3, 100)
            y_line = -diff[0] / diff[1] * x_line
            mask = (y_line > -3) & (y_line < 3)
            ax.plot(x_line[mask], y_line[mask], 'k-', linewidth=1.5, alpha=0.7)

    # Mark a specific point and its certified region
    phi_demo = np.array([1.5, 0.5])
    a_demo = int(np.argmax([score(W[c], phi_demo) for c in range(3)]))
    eps_demo = certified_radius(W, phi_demo, a_demo)

    rect = plt.Rectangle(
        (phi_demo[0] - eps_demo, phi_demo[1] - eps_demo),
        2 * eps_demo, 2 * eps_demo,
        fill=False, edgecolor='red', linewidth=2, linestyle='--'
    )
    ax.add_patch(rect)
    ax.plot(*phi_demo, 'r*', markersize=15, zorder=5)
    ax.annotate(f'ε* = {eps_demo:.3f}', xy=phi_demo,
                xytext=(phi_demo[0] + 0.3, phi_demo[1] + 0.5),
                fontsize=10, color='red',
                arrowprops=dict(arrowstyle='->', color='red'))

    patches = [mpatches.Patch(color=colors_map[c], label=f'Class {c}') for c in range(3)]
    ax.legend(handles=patches, loc='lower left')
    ax.set_xlabel('φ₁', fontsize=12)
    ax.set_ylabel('φ₂', fontsize=12)
    ax.set_title('Decision Regions & Certified Box', fontsize=14)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    # Right: Certified radius heatmap
    ax = axes[1]
    im = ax.contourf(X, Y, radius_map, levels=20, cmap='viridis')
    plt.colorbar(im, ax=ax, label='Certified ε*')

    for a_cls, b_cls in combinations(range(3), 2):
        diff = W[a_cls] - W[b_cls]
        if abs(diff[1]) > 1e-10:
            x_line = np.linspace(-3, 3, 100)
            y_line = -diff[0] / diff[1] * x_line
            mask = (y_line > -3) & (y_line < 3)
            ax.plot(x_line[mask], y_line[mask], 'w-', linewidth=1.5, alpha=0.7)

    ax.set_xlabel('φ₁', fontsize=12)
    ax.set_ylabel('φ₂', fontsize=12)
    ax.set_title('Certified Robustness Radius Map', fontsize=14)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('Bridges/fig_argmax_invariance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: Bridges/fig_argmax_invariance.png")
    print(f"\n  Demo point φ = {phi_demo}")
    print(f"  Argmax class = {a_demo}, certified radius ε* = {eps_demo:.6f}")


# ─── Example 4: Separation Property ────────────────────────────────

def demo_separation():
    """
    Demonstrate that injectivity of the test map T implies
    the existence of distinguishing features.
    """
    print("\n" + "=" * 65)
    print("Example 4: Separation Property (Theorem 4)")
    print("=" * 65)

    # Three distinct Hecke data points mapped to 5D test vectors
    T = {
        'h0': np.array([ 3.0,  1.0,  2.0,  0.5, -0.5]),
        'h1': np.array([-1.0,  2.0, -1.0,  1.0,  0.0]),
        'h2': np.array([ 0.0, -1.0,  1.0, -0.5,  2.0]),
    }

    print("\nTest map T (tropical Satake vectors):")
    for h, v in T.items():
        print(f"  T({h}) = {v}")

    # Check injectivity
    all_distinct = True
    for (h1, v1), (h2, v2) in combinations(T.items(), 2):
        if np.allclose(v1, v2):
            all_distinct = False
            print(f"  WARNING: T({h1}) = T({h2})")
    print(f"\n  T is injective: {all_distinct}")

    # Find distinguishing coordinates
    print("\nDistinguishing coordinates:")
    for (h1, v1), (h2, v2) in combinations(T.items(), 2):
        diff_coords = [i for i in range(len(v1)) if v1[i] != v2[i]]
        print(f"  {h1} vs {h2}: coordinates {diff_coords} differ")

        # Construct witness feature vector (basis vector at first differing coord)
        i0 = diff_coords[0]
        phi_witness = np.zeros(len(v1))
        phi_witness[i0] = 1.0
        s1 = score(v1, phi_witness)
        s2 = score(v2, phi_witness)
        print(f"    φ = e_{i0}: score(T({h1}), φ) = {s1}, score(T({h2}), φ) = {s2}")


# ─── Example 5: Real-World Application Scenario ────────────────────

def demo_application():
    """
    Simulate a real-world application: certifying robustness of an
    automorphic-form classifier under noisy observations.
    """
    print("\n" + "=" * 65)
    print("Example 5: Noisy Observation Robustness Certificate")
    print("=" * 65)

    np.random.seed(123)
    n_features = 10
    n_classes = 5

    # Random weight matrix (simulating tropical Satake test vectors)
    W = np.random.randn(n_classes, n_features) * 2

    # Clean feature vector
    phi = np.random.randn(n_features)

    # Compute scores and argmax
    scores_val = [score(W[c], phi) for c in range(n_classes)]
    a = int(np.argmax(scores_val))

    print(f"\n  Number of features: {n_features}")
    print(f"  Number of classes: {n_classes}")
    print(f"  True class (argmax): {a}")
    print(f"  Scores: {[f'{s:.3f}' for s in scores_val]}")

    eps_star = certified_radius(W, phi, a)
    print(f"\n  Certified radius ε* = {eps_star:.6f}")

    # Monte Carlo verification
    n_mc = 10000
    epsilons_test = [eps_star * r for r in [0.5, 0.9, 0.99, 1.0, 1.01, 1.1, 1.5]]
    print(f"\n  Monte Carlo verification ({n_mc} trials per ε):")
    print(f"  {'ε':>10s}  {'ε/ε*':>8s}  {'argmax preserved':>18s}")
    print(f"  {'-'*10}  {'-'*8}  {'-'*18}")

    for eps_test in epsilons_test:
        preserved = 0
        for _ in range(n_mc):
            perturbation = np.random.uniform(-eps_test, eps_test, size=n_features)
            psi = phi + perturbation
            perturbed_scores = [score(W[c], psi) for c in range(n_classes)]
            if int(np.argmax(perturbed_scores)) == a:
                preserved += 1
        ratio = eps_test / eps_star if eps_star > 0 else float('inf')
        pct = preserved / n_mc * 100
        marker = "✓ (guaranteed)" if ratio <= 1.0 else ""
        print(f"  {eps_test:10.6f}  {ratio:8.4f}  {pct:16.1f}%  {marker}")


# ─── Main ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔" + "═" * 63 + "╗")
    print("║  Tropical Satake Margin Theorem — Numerical Demonstrations   ║")
    print("║  Formally verified in Lean 4 (TropicalSatakeMargin.lean)     ║")
    print("╚" + "═" * 63 + "╝")

    W, phi, a, eps_star = demo_gl3_test_family()
    demo_lipschitz_bound(W, phi, a)
    demo_argmax_map()
    demo_separation()
    demo_application()

    print("\n" + "=" * 65)
    print("All demonstrations complete.")
    print("=" * 65)
