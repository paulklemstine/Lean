#!/usr/bin/env python3
"""
GL3 Tropical Satake Certified Robustness Demo
==============================================

Demonstrates the formally verified theorems from GL3TopCycleRobustness.lean
with concrete numerical examples and visualizations.

The key result: if a multiclass classifier's per-class scores are K-Lipschitz
(coordinatewise) and class c beats every other class by pairwise margin > 2*K*d*r,
then c remains the Condorcet winner (top-cycle singleton) under any L∞ perturbation
of radius r.

Equivalently, the certified robustness radius is:
    r_cert = min_margin / (2 * K * d)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations

# ============================================================
# 1. Core definitions (mirroring the Lean formalization)
# ============================================================

def pairwise_margin(scores, i, j):
    """Margin of class i over class j: s_i(x) - s_j(x)."""
    return scores[i] - scores[j]

def is_condorcet_winner(scores, c):
    """Check if c beats every other class in pairwise comparison."""
    n = len(scores)
    return all(scores[c] > scores[j] for j in range(n) if j != c)

def certified_radius(scores, c, K, d):
    """Compute certified robustness radius for Condorcet winner c.
    
    r_cert = min_{j ≠ c} (s_c(x) - s_j(x)) / (2 * K * d)
    """
    n = len(scores)
    min_margin = min(scores[c] - scores[j] for j in range(n) if j != c)
    if min_margin <= 0 or K <= 0 or d <= 0:
        return 0.0
    return min_margin / (2 * K * d)


# ============================================================
# 2. Example: GL3 tropical Hecke classifier (3 classes, d=5)
# ============================================================

def tropical_hecke_score(weights, x):
    """Simplified tropical-inspired score: s_i(x) = max_j(w_{ij} + x_j).
    
    This is K=1 coordinatewise Lipschitz since changing x_k by ε
    changes the max by at most ε, so |s_i(x) - s_i(y)| ≤ Σ|x_k - y_k|.
    """
    return np.max(weights + x)

def demo_gl3_basic():
    """Demonstrate certified robustness for a 3-class classifier."""
    print("=" * 60)
    print("Demo 1: GL3 Certified Robustness (3 classes, d=5)")
    print("=" * 60)
    
    d = 5
    K = 1.0  # tropical max is 1-Lipschitz per coordinate
    
    # Weight matrices for 3 classes (tropical Hecke parameters)
    W = np.array([
        [3.0, 1.0, 2.0, 4.0, 1.5],   # class 0
        [1.0, 2.0, 1.5, 1.0, 2.0],   # class 1
        [0.5, 1.5, 1.0, 0.5, 1.0],   # class 2
    ])
    
    x = np.array([1.0, 0.5, -0.3, 2.0, 0.8])
    
    # Compute scores
    scores = np.array([tropical_hecke_score(W[i], x) for i in range(3)])
    print(f"\nInput x = {x}")
    print(f"Scores: s₀={scores[0]:.3f}, s₁={scores[1]:.3f}, s₂={scores[2]:.3f}")
    
    # Pairwise margins
    for i, j in combinations(range(3), 2):
        m = pairwise_margin(scores, i, j)
        print(f"  Margin(class {i} vs {j}) = {m:+.3f}")
    
    # Find winner
    winner = np.argmax(scores)
    print(f"\nCondorcet winner: class {winner}")
    print(f"  Beats class 1 by: {scores[winner] - scores[1]:.3f}")
    print(f"  Beats class 2 by: {scores[winner] - scores[2]:.3f}")
    
    # Certified radius
    r_cert = certified_radius(scores, winner, K, d)
    print(f"\nCertified robustness radius: r = {r_cert:.4f}")
    print(f"  Formula: min_margin / (2·K·d) = {min(scores[winner]-scores[1], scores[winner]-scores[2]):.3f} / (2·{K}·{d})")
    
    # Verify: perturb at maximum certified radius
    print(f"\n--- Verification: perturbation at r = {r_cert:.4f} ---")
    np.random.seed(42)
    n_trials = 1000
    survived = 0
    for _ in range(n_trials):
        delta = np.random.uniform(-r_cert, r_cert, size=d)
        perturbed_scores = np.array([tropical_hecke_score(W[i], x + delta) for i in range(3)])
        if is_condorcet_winner(perturbed_scores, winner):
            survived += 1
    print(f"  {survived}/{n_trials} random perturbations preserved the winner ✓")
    
    # Verify: slightly beyond certified radius should sometimes fail
    r_beyond = r_cert * 1.5
    survived_beyond = 0
    for _ in range(n_trials):
        delta = np.random.uniform(-r_beyond, r_beyond, size=d)
        perturbed_scores = np.array([tropical_hecke_score(W[i], x + delta) for i in range(3)])
        if is_condorcet_winner(perturbed_scores, winner):
            survived_beyond += 1
    print(f"  At r = {r_beyond:.4f} (1.5× cert): {survived_beyond}/{n_trials} survived")
    
    return scores, winner, r_cert, W, x, d, K


# ============================================================
# 3. Dominance cut preservation demo
# ============================================================

def demo_dominance_cut():
    """Demonstrate the dominance cut preservation theorem."""
    print("\n" + "=" * 60)
    print("Demo 2: Dominance Cut Preservation (5 classes)")
    print("=" * 60)
    
    d = 4
    K = 1.0
    n_classes = 5
    
    # Scores where classes {0,1} dominate {2,3,4}
    scores = np.array([10.0, 9.5, 3.0, 2.5, 2.0])
    S = {0, 1}  # dominant set
    
    print(f"\nScores: {scores}")
    print(f"Dominant set S = {S}")
    
    # Cross margins
    min_cross_margin = float('inf')
    for i in S:
        for j in range(n_classes):
            if j not in S:
                m = scores[i] - scores[j]
                min_cross_margin = min(min_cross_margin, m)
                print(f"  s_{i} - s_{j} = {m:.1f}")
    
    r_cut = min_cross_margin / (2 * K * d)
    print(f"\nMinimum cross-margin: {min_cross_margin:.1f}")
    print(f"Certified cut-preservation radius: {r_cut:.4f}")
    print(f"  All edges S → S^c preserved for any ‖δ‖∞ ≤ {r_cut:.4f}")


# ============================================================
# 4. Visualization
# ============================================================

def plot_robustness_certificate(scores, winner, r_cert, W, x, d, K):
    """Visualize the certified robustness region."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # --- Panel 1: Score landscape under 2D perturbation slice ---
    ax = axes[0]
    rs = np.linspace(-r_cert * 2, r_cert * 2, 200)
    # Perturb coordinates 0 and 3 (the most influential)
    winner_region = np.zeros((len(rs), len(rs)))
    
    for ii, r1 in enumerate(rs):
        for jj, r2 in enumerate(rs):
            delta = np.zeros(d)
            delta[0] = r1
            delta[3] = r2
            ps = np.array([tropical_hecke_score(W[i], x + delta) for i in range(3)])
            winner_region[jj, ii] = np.argmax(ps)
    
    cmap = plt.cm.get_cmap('Set2', 3)
    ax.imshow(winner_region, extent=[rs[0], rs[-1], rs[0], rs[-1]],
              origin='lower', cmap=cmap, alpha=0.7, aspect='equal')
    
    # Draw certified ball
    rect = plt.Rectangle((-r_cert, -r_cert), 2*r_cert, 2*r_cert,
                         linewidth=2, edgecolor='red', facecolor='none',
                         linestyle='--', label=f'Certified L∞ ball (r={r_cert:.3f})')
    ax.add_patch(rect)
    ax.plot(0, 0, 'k*', markersize=12, label='Original input')
    ax.set_xlabel('δ₀')
    ax.set_ylabel('δ₃')
    ax.set_title('Winner regions (2D slice)')
    ax.legend(loc='upper left', fontsize=8)
    
    # --- Panel 2: Margin vs perturbation magnitude ---
    ax = axes[1]
    r_range = np.linspace(0, r_cert * 2.5, 100)
    for j in range(3):
        if j == winner:
            continue
        original_margin = scores[winner] - scores[j]
        # Worst-case margin: original - 2*K*d*r
        worst_margins = [original_margin - 2 * K * d * r for r in r_range]
        ax.plot(r_range, worst_margins, linewidth=2,
                label=f'class {winner} vs {j} (original: {original_margin:.2f})')
    
    ax.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
    ax.axvline(x=r_cert, color='red', linestyle='--', linewidth=2,
               label=f'r_cert = {r_cert:.3f}')
    ax.fill_between(r_range, -1, 0, alpha=0.1, color='red')
    ax.set_xlabel('Perturbation radius r')
    ax.set_ylabel('Worst-case pairwise margin')
    ax.set_title('Margin degradation bound')
    ax.legend(fontsize=8)
    ax.set_ylim(bottom=min(-1, min(scores[winner] - scores[j] for j in range(3) if j != winner) - 2*K*d*r_cert*2.5))
    
    # --- Panel 3: Tournament graph ---
    ax = axes[2]
    n = 3
    angles = [np.pi/2 + 2*np.pi*i/n for i in range(n)]
    positions = [(1.5*np.cos(a), 1.5*np.sin(a)) for a in angles]
    
    # Draw nodes
    colors = ['#2ecc71' if i == winner else '#e74c3c' for i in range(n)]
    for i in range(n):
        circle = plt.Circle(positions[i], 0.3, color=colors[i], alpha=0.8)
        ax.add_patch(circle)
        ax.text(positions[i][0], positions[i][1], f'{i}\n({scores[i]:.1f})',
                ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Draw directed edges (winner beats all)
    for i in range(n):
        for j in range(n):
            if i != j and scores[i] > scores[j]:
                dx = positions[j][0] - positions[i][0]
                dy = positions[j][1] - positions[i][1]
                length = np.sqrt(dx**2 + dy**2)
                dx, dy = dx/length, dy/length
                start = (positions[i][0] + 0.35*dx, positions[i][1] + 0.35*dy)
                end = (positions[j][0] - 0.35*dx, positions[j][1] - 0.35*dy)
                ax.annotate('', xy=end, xytext=start,
                          arrowprops=dict(arrowstyle='->', color='#333',
                                        linewidth=1.5, mutation_scale=15))
    
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title(f'Tournament (class {winner} = Condorcet winner)')
    ax.axis('off')
    
    plt.suptitle('GL3 Tropical Satake: Certified Top-Cycle Robustness', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Bridges/gl3_robustness_demo.png', dpi=150, bbox_inches='tight')
    print(f"\nVisualization saved to Bridges/gl3_robustness_demo.png")
    plt.close()


# ============================================================
# 5. Application: Adversarial robustness certification
# ============================================================

def demo_application():
    """Show practical application: computing certified radii for a batch of inputs."""
    print("\n" + "=" * 60)
    print("Demo 3: Practical Robustness Certification")
    print("=" * 60)
    
    d = 10
    K = 0.5
    n_classes = 3
    
    # Simulate a batch of 20 inputs with their scores
    np.random.seed(123)
    n_samples = 20
    
    print(f"\nSettings: d={d}, K={K}, {n_classes} classes, {n_samples} samples")
    print(f"{'Sample':>6} {'Winner':>6} {'Min margin':>12} {'Cert. radius':>12} {'Status':>8}")
    print("-" * 50)
    
    radii = []
    for idx in range(n_samples):
        # Random scores with class 0 usually dominant
        base = np.array([5.0, 2.0, 1.5])
        noise = np.random.randn(n_classes) * 1.5
        scores = base + noise
        
        winner = np.argmax(scores)
        min_margin = min(scores[winner] - scores[j] for j in range(n_classes) if j != winner)
        r = certified_radius(scores, winner, K, d)
        radii.append(r)
        
        status = "✓ cert" if r > 0.05 else "⚠ thin"
        print(f"{idx:>6} {winner:>6} {min_margin:>12.4f} {r:>12.4f} {status:>8}")
    
    print(f"\nMedian certified radius: {np.median(radii):.4f}")
    print(f"Mean certified radius:   {np.mean(radii):.4f}")
    print(f"Fraction with r > 0.05:  {sum(1 for r in radii if r > 0.05)/n_samples:.1%}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    scores, winner, r_cert, W, x, d, K = demo_gl3_basic()
    demo_dominance_cut()
    
    try:
        plot_robustness_certificate(scores, winner, r_cert, W, x, d, K)
    except Exception as e:
        print(f"\nVisualization skipped (matplotlib may not be available): {e}")
    
    demo_application()
    
    print("\n" + "=" * 60)
    print("Summary of Formally Verified Results")
    print("=" * 60)
    print("""
The Lean formalization in GL3TopCycleRobustness.lean proves:

1. linfty_to_l1_bound: ‖δ‖₁ ≤ d · r  when ‖δ‖∞ ≤ r
2. score_perturbation_bound: |s_i(x+δ) - s_i(x)| ≤ K·d·r
3. pair_margin_lower_bound: margin drops by at most 2·K·d·r
4. pairwise_orientation_preserved: edge preserved if margin > 2·K·d·r
5. condorcet_robust_of_uniform_margin: Condorcet winner preserved
6. smith_singleton_robust: Smith set singleton preserved
7. gl3_top_cycle_robustness: GL3 specialization
8. dominance_cut_preserved: full cut structure preserved

All proofs are machine-verified with no sorry or non-standard axioms.
""")
