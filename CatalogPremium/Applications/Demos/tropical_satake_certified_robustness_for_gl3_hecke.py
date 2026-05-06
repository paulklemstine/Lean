#!/usr/bin/env python3
"""
Tropical Satake Top-K Robustness: Demonstration and Visualization

This script demonstrates the top-k ranking stability theorem proved in
Bridges/TropicalSatake/TropicalTopKRobustnessGL3.lean

The key theorem: if scores have a gap Δ between the k-th and (k+1)-th ranked
labels, and all scores are perturbed by at most η with 2η < Δ, then the top-k
set is exactly preserved.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def top_k_set(scores, k):
    """Compute the top-k set using the tie-tolerant definition from the Lean formalization.

    A label i is in topKSet(score, k) iff fewer than k labels strictly outscore i.
    """
    n = len(scores)
    result = set()
    for i in range(n):
        count_above = sum(1 for j in range(n) if scores[j] > scores[i])
        if count_above < k:
            result.add(i)
    return result


def top_k_gap(scores, k):
    """Compute the gap Δ between the worst top-k label and the best non-top-k label."""
    tk = top_k_set(scores, k)
    complement = set(range(len(scores))) - tk
    if not complement:
        return float('inf'), tk
    min_topk = min(scores[i] for i in tk)
    max_compl = max(scores[j] for j in complement)
    gap = min_topk - max_compl
    return gap, tk


def verify_theorem(scores, k, eta, num_trials=10000):
    """Empirically verify the top-k robustness theorem with random perturbations."""
    gap, original_topk = top_k_gap(scores, k)
    if len(original_topk) != k:
        return None, None, None, "Skipped: |topKSet| != k (ties at boundary)"
    if gap <= 0:
        return None, None, None, "Skipped: gap not positive"
    preserved_count = 0
    changed_count = 0
    for _ in range(num_trials):
        perturbation = np.random.uniform(-eta, eta, size=len(scores))
        perturbed_scores = scores + perturbation
        perturbed_topk = top_k_set(perturbed_scores, k)
        if perturbed_topk == original_topk:
            preserved_count += 1
        else:
            changed_count += 1
    return gap, gap - 2 * eta, (preserved_count, changed_count), None


# ============================================================================
# Demo 1: Basic theorem illustration
# ============================================================================

def demo_basic():
    print("=" * 70)
    print("DEMO 1: Basic Top-K Robustness Theorem")
    print("=" * 70)
    scores = np.array([10.0, 7.5, 6.0, 2.0, 1.0])
    k = 3
    gap, topk = top_k_gap(scores, k)
    print(f"\nScores: {scores}")
    print(f"k = {k}")
    print(f"Top-{k} set: {topk}")
    print(f"Gap Δ = {gap:.2f}")
    print(f"Maximum safe perturbation η < Δ/2 = {gap/2:.2f}")

    eta_safe = gap / 2 - 0.1
    _, _, counts, _ = verify_theorem(scores, k, eta_safe)
    print(f"\n  η = {eta_safe:.2f} (safe, 2η = {2*eta_safe:.2f} < Δ = {gap:.2f})")
    print(f"  Result: {counts[0]}/{counts[0]+counts[1]} trials preserved top-{k} set")

    eta_unsafe = gap / 2 + 0.5
    _, _, counts, _ = verify_theorem(scores, k, eta_unsafe)
    print(f"\n  η = {eta_unsafe:.2f} (unsafe, 2η = {2*eta_unsafe:.2f} > Δ = {gap:.2f})")
    print(f"  Result: {counts[0]}/{counts[0]+counts[1]} trials preserved top-{k} set")


# ============================================================================
# Demo 2: Visualization of robustness certificate
# ============================================================================

def demo_visualization():
    scores = np.array([10.0, 8.0, 5.5, 2.5, 1.0])
    k = 3
    gap, topk = top_k_gap(scores, k)
    n_labels = len(scores)
    labels = [f"Class {i}" for i in range(n_labels)]

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Original scores
    ax1 = axes[0]
    colors = ['#2196F3' if i in topk else '#FF5722' for i in range(n_labels)]
    ax1.barh(range(n_labels), scores, color=colors)
    ax1.set_yticks(range(n_labels))
    ax1.set_yticklabels(labels)
    ax1.set_xlabel("Score")
    ax1.set_title("Original Scores")
    ax1.annotate('', xy=(scores[3], 2.5), xytext=(scores[2], 2.5),
                 arrowprops=dict(arrowstyle='<->', color='green', lw=2))
    ax1.text((scores[2] + scores[3]) / 2, 2.8, f'Δ = {gap:.1f}',
             ha='center', color='green', fontsize=12, fontweight='bold')
    blue_patch = mpatches.Patch(color='#2196F3', label=f'Top-{k}')
    red_patch = mpatches.Patch(color='#FF5722', label=f'Not top-{k}')
    ax1.legend(handles=[blue_patch, red_patch], loc='lower right')

    # Panel 2: Safe perturbation
    eta_safe = gap / 2 - 0.3
    np.random.seed(42)
    perturbed = scores + np.random.uniform(-eta_safe, eta_safe, n_labels)
    perturbed_topk = top_k_set(perturbed, k)
    colors2 = ['#2196F3' if i in perturbed_topk else '#FF5722' for i in range(n_labels)]
    ax2 = axes[1]
    ax2.barh(range(n_labels), perturbed, color=colors2)
    for i in range(n_labels):
        ax2.plot([scores[i], scores[i]], [i - 0.3, i + 0.3], 'k--', alpha=0.4)
    ax2.set_yticks(range(n_labels))
    ax2.set_yticklabels(labels)
    ax2.set_xlabel("Score")
    ax2.set_title(f"Safe perturbation (η = {eta_safe:.1f})\n2η = {2*eta_safe:.1f} < Δ = {gap:.1f}")
    preserved = perturbed_topk == topk
    ax2.text(0.5, -0.12, f"Top-{k} {'PRESERVED ✓' if preserved else 'CHANGED ✗'}",
             transform=ax2.transAxes, ha='center', fontsize=12,
             color='green' if preserved else 'red', fontweight='bold')

    # Panel 3: Unsafe perturbation
    eta_unsafe = gap / 2 + 0.5
    np.random.seed(7)
    perturbed2 = scores + np.random.uniform(-eta_unsafe, eta_unsafe, n_labels)
    perturbed_topk2 = top_k_set(perturbed2, k)
    colors3 = ['#2196F3' if i in perturbed_topk2 else '#FF5722' for i in range(n_labels)]
    ax3 = axes[2]
    ax3.barh(range(n_labels), perturbed2, color=colors3)
    for i in range(n_labels):
        ax3.plot([scores[i], scores[i]], [i - 0.3, i + 0.3], 'k--', alpha=0.4)
    ax3.set_yticks(range(n_labels))
    ax3.set_yticklabels(labels)
    ax3.set_xlabel("Score")
    ax3.set_title(f"Unsafe perturbation (η = {eta_unsafe:.1f})\n2η = {2*eta_unsafe:.1f} > Δ = {gap:.1f}")
    preserved2 = perturbed_topk2 == topk
    ax3.text(0.5, -0.12, f"Top-{k} {'PRESERVED ✓' if preserved2 else 'CHANGED ✗'}",
             transform=ax3.transAxes, ha='center', fontsize=12,
             color='green' if preserved2 else 'red', fontweight='bold')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/topk_robustness_visualization.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: demos/topk_robustness_visualization.png")


# ============================================================================
# Demo 3: Lipschitz version with GL3-style score family
# ============================================================================

def demo_lipschitz():
    print("\n" + "=" * 70)
    print("DEMO 3: Lipschitz Top-K Robustness (GL₃-style)")
    print("=" * 70)

    n_classes = 6
    W = np.array([
        [3.0, 2.0, 1.0],
        [2.0, 2.0, 2.0],
        [3.0, 1.0, 0.0],
        [1.0, 1.0, 0.0],
        [2.0, 1.0, 1.0],
        [1.0, 0.0, 0.0],
    ])
    K = max(np.sum(np.abs(W[i])) for i in range(n_classes))
    print(f"\nWeight matrix W ({n_classes} classes × 3 coords):")
    for i, w in enumerate(W):
        print(f"  Class {i}: w = {w}, ||w||₁ = {np.sum(np.abs(w)):.1f}")
    print(f"\nLipschitz constant K = max ||w_i||₁ = {K:.1f}")

    x = np.array([1.5, 1.0, 0.5])
    scores = W @ x
    print(f"\nFeature point x = {x}")
    print(f"Scores: {[f'{s:.2f}' for s in scores]}")

    k = 3
    gap, topk = top_k_gap(scores, k)
    print(f"\nTop-{k} set: {topk}")
    print(f"Gap Δ = {gap:.2f}")

    if len(topk) == k:
        epsilon_max = gap / (2 * K)
        print(f"Maximum safe radius ε < Δ/(2K) = {gap:.2f}/{2*K:.1f} = {epsilon_max:.4f}")
        eps_test = epsilon_max * 0.8
        print(f"\nTesting with ε = {eps_test:.4f}:")
        n_trials = 5000
        preserved = 0
        for _ in range(n_trials):
            x_prime = x + np.random.uniform(-eps_test, eps_test, 3)
            scores_prime = W @ x_prime
            if top_k_set(scores_prime, k) == topk:
                preserved += 1
        print(f"  {preserved}/{n_trials} trials preserved top-{k} set")
        print(f"  (Theorem guarantees 100% since 2Kε = {2*K*eps_test:.4f} < Δ = {gap:.2f})")


# ============================================================================
# Demo 4: k=1 recovers argmax stability
# ============================================================================

def demo_argmax_recovery():
    print("\n" + "=" * 70)
    print("DEMO 4: Top-1 = Argmax Stability")
    print("=" * 70)
    scores = np.array([8.0, 5.5, 3.0, 1.0])
    k = 1
    gap, topk = top_k_gap(scores, k)
    print(f"\nScores: {scores}")
    print(f"Argmax (top-1 set): {topk}")
    print(f"Margin Δ = {gap:.2f}")
    eta_safe = gap / 2 - 0.1
    print(f"\nWith η = {eta_safe:.2f} (safe):")
    _, _, counts, _ = verify_theorem(scores, k, eta_safe, num_trials=10000)
    print(f"  {counts[0]}/{counts[0]+counts[1]} trials preserved argmax")
    print("  → Matches classical argmax robustness theorem (k=1 specialization)")


# ============================================================================
# Demo 5: Phase transition plot
# ============================================================================

def demo_phase_transition():
    print("\n" + "=" * 70)
    print("DEMO 5: Phase Transition at η = Δ/2")
    print("=" * 70)
    scores = np.array([10.0, 7.0, 5.0, 2.0, 1.0])
    k = 3
    gap, topk = top_k_gap(scores, k)
    critical_eta = gap / 2

    eta_values = np.linspace(0, critical_eta * 1.5, 50)
    preservation_rates = []
    for eta in eta_values:
        n_trials = 2000
        preserved = 0
        for _ in range(n_trials):
            perturbation = np.random.uniform(-eta, eta, len(scores))
            perturbed = scores + perturbation
            if top_k_set(perturbed, k) == topk:
                preserved += 1
        preservation_rates.append(preserved / n_trials)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(eta_values, preservation_rates, 'b-', linewidth=2, label='Empirical preservation rate')
    ax.axvline(x=critical_eta, color='red', linestyle='--', linewidth=2,
               label=f'Critical η = Δ/2 = {critical_eta:.2f}')
    ax.fill_between(eta_values, preservation_rates,
                    where=[e < critical_eta for e in eta_values],
                    alpha=0.15, color='green')
    ax.fill_between(eta_values, preservation_rates,
                    where=[e >= critical_eta for e in eta_values],
                    alpha=0.15, color='red')
    ax.set_xlabel('Perturbation bound η', fontsize=14)
    ax.set_ylabel(f'Top-{k} preservation rate', fontsize=14)
    ax.set_title(f'Phase Transition in Top-{k} Robustness\n'
                 f'Scores = {list(scores)}, Δ = {gap:.1f}', fontsize=14)
    ax.legend(fontsize=12)
    ax.set_ylim(-0.05, 1.05)
    ax.text(critical_eta * 0.5, 0.5, 'Certified\nRobust\n(Theorem)',
            ha='center', va='center', fontsize=13, color='green', fontweight='bold')
    ax.text(critical_eta * 1.25, 0.5, 'No\nGuarantee',
            ha='center', va='center', fontsize=13, color='red', fontweight='bold')
    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/topk_phase_transition.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/topk_phase_transition.png")


# ============================================================================
# Demo 6: Tie boundary counterexample
# ============================================================================

def demo_tie_counterexample():
    print("\n" + "=" * 70)
    print("DEMO 6: Why |topKSet| = k is Needed (Tie Counterexample)")
    print("=" * 70)
    scores = np.array([10.0, 5.0, 5.0, 0.0])
    k = 2
    gap, topk = top_k_gap(scores, k)
    print(f"\nScores: {scores}")
    print(f"k = {k}")
    print(f"Top-{k} set: {topk} (has {len(topk)} elements, not {k}!)")
    print(f"Gap Δ = {gap:.2f}")
    print(f"The theorem requires |topKSet| = k = {k}, but |topKSet| = {len(topk)}")

    eta = 1.5
    print(f"\nWith η = {eta:.1f} (2η = {2*eta:.1f} < Δ = {gap:.1f}):")
    n_trials = 5000
    preserved = 0
    for _ in range(n_trials):
        p = scores + np.random.uniform(-eta, eta, len(scores))
        if top_k_set(p, k) == topk:
            preserved += 1
    print(f"  {preserved}/{n_trials} trials preserved top-{k} set")
    print(f"  (NOT guaranteed — ties at boundary can break the top-k set)")
    print(f"\n  Counterexample: scores' = [9, 3, 7, -1]")
    scores_ce = np.array([9, 3, 7, -1])
    print(f"  topKSet(scores', {k}) = {top_k_set(scores_ce, k)} ≠ {topk}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Satake Top-K Robustness — Certified Ranking Stability    ║")
    print("║  Formally Verified in Lean 4 + Mathlib                             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_basic()
    demo_visualization()
    demo_lipschitz()
    demo_argmax_recovery()
    demo_phase_transition()
    demo_tie_counterexample()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
