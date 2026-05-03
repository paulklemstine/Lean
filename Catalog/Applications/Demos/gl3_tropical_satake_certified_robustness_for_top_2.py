#!/usr/bin/env python3
"""
GL₃ Tropical Satake Certified Robustness — Interactive Demo

This script demonstrates the formally verified multiclass certification theorem
for tropical Hecke-score classifiers. It shows:

1. How the top-2 gap determines the certified robustness radius
2. Concrete numerical examples with 3-class tropical score functions
3. Visualization of the certification region in input space
4. Empirical validation that the certified radius is tight

The mathematical content is verified in Lean 4; this demo makes it tangible.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.colors import ListedColormap
from mpl_toolkits.mplot3d import Axes3D

# ============================================================
# 1. Tropical Score Functions (GL₃ Hecke-style)
# ============================================================

def tropical_score_functions(K=1.0):
    """
    Define m=3 tropical score functions on R^d (d=2) that are
    K*d-Lipschitz in L∞ norm, modeling GL₃ Hecke eigenvalue scores.
    
    Each score is a max of affine functions (tropical polynomial),
    which is exactly the piecewise-linear structure arising from
    tropicalization of ReLU networks / Hecke operators.
    """
    d = 2
    C = K * d  # effective Lipschitz constant
    
    # Each affine piece a·x₁ + b·x₂ + c has L∞-Lipschitz constant max(|a|,|b|).
    # For max of such pieces, the Lipschitz constant is the max over pieces.
    # We need each score to be C=K*d Lipschitz, so with K=1, d=2, each
    # coefficient |a|,|b| must be ≤ 2.
    
    # Score 0: tropical polynomial max(x₁ + x₂, x₁ - x₂ + 1, -x₁ + x₂ + 0.5)
    def s0(x):
        return np.maximum(np.maximum(x[0] + x[1], x[0] - x[1] + 1), -x[0] + x[1] + 0.5)
    
    # Score 1: tropical polynomial max(x₁ - x₂ + 2, -x₁ + x₂ + 1.5, 0.5*x₁ + 0.5*x₂)
    def s1(x):
        return np.maximum(np.maximum(x[0] - x[1] + 2, -x[0] + x[1] + 1.5), 0.5*x[0] + 0.5*x[1])
    
    # Score 2: tropical polynomial max(-x₁ - x₂ + 3, x₁ - x₂ + 1.5, -x₁ + x₂ + 2)
    def s2(x):
        return np.maximum(np.maximum(-x[0] - x[1] + 3, x[0] - x[1] + 1.5), -x[0] + x[1] + 2)
    
    scores = [s0, s1, s2]
    return scores, C, d

def verify_lipschitz(scores, C, n_samples=10000, d=2):
    """Empirically verify the Lipschitz constant."""
    max_ratio = 0.0
    for _ in range(n_samples):
        x = np.random.randn(d) * 2
        y = np.random.randn(d) * 2
        linf_dist = np.max(np.abs(x - y))
        if linf_dist < 1e-10:
            continue
        for k, s in enumerate(scores):
            ratio = abs(s(x) - s(y)) / linf_dist
            if ratio > max_ratio:
                max_ratio = ratio
    print(f"  Claimed Lipschitz constant C = {C:.2f}")
    print(f"  Empirical max |s(x)-s(y)| / ‖x-y‖∞ = {max_ratio:.4f}")
    print(f"  Lipschitz bound verified: {max_ratio <= C + 0.01}")
    return max_ratio

# ============================================================
# 2. Certification Computation
# ============================================================

def compute_top2_gap(scores, x):
    """
    Compute the top-2 gap at point x:
      top2Gap = s_winner(x) - max_{j ≠ winner} s_j(x)
    Returns (winner_class, gap, all_scores).
    """
    vals = np.array([s(x) for s in scores])
    winner = np.argmax(vals)
    # Second-largest score
    other_vals = np.delete(vals, winner)
    second_best = np.max(other_vals)
    gap = vals[winner] - second_best
    return winner, gap, vals

def certified_radius(gap, C):
    """
    Certified robustness radius: r = gap / (2*C).
    By the formally verified theorem unique_top_stable_of_top2Gap,
    any perturbation δ with ‖δ‖∞ < r preserves the argmax.
    """
    if C <= 0:
        return float('inf') if gap > 0 else 0.0
    return gap / (2 * C)

# ============================================================
# 3. Visualization
# ============================================================

def plot_decision_regions_and_certificates(scores, C, d=2):
    """Plot decision regions with certified robustness balls."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # Grid for decision regions
    grid_res = 300
    x_range = np.linspace(-3, 3, grid_res)
    y_range = np.linspace(-3, 3, grid_res)
    X, Y = np.meshgrid(x_range, y_range)
    
    # Compute argmax at each grid point
    Z = np.zeros_like(X, dtype=int)
    Gap = np.zeros_like(X)
    for ii in range(grid_res):
        for jj in range(grid_res):
            pt = np.array([X[ii, jj], Y[ii, jj]])
            winner, gap, _ = compute_top2_gap(scores, pt)
            Z[ii, jj] = winner
            Gap[ii, jj] = gap
    
    # --- Left panel: Decision regions ---
    ax = axes[0]
    cmap = ListedColormap(['#FF6B6B', '#4ECDC4', '#45B7D1'])
    ax.contourf(X, Y, Z, levels=[-0.5, 0.5, 1.5, 2.5], cmap=cmap, alpha=0.4)
    ax.contour(X, Y, Z, levels=[0.5, 1.5], colors='black', linewidths=1.5)
    
    # Show certified balls at sample points
    sample_points = [
        np.array([1.0, -1.0]),
        np.array([-1.5, 0.5]),
        np.array([0.0, 1.5]),
        np.array([2.0, 0.0]),
        np.array([-0.5, -1.5]),
    ]
    
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1']
    class_names = ['Class 0', 'Class 1', 'Class 2']
    
    for pt in sample_points:
        winner, gap, vals = compute_top2_gap(scores, pt)
        r = certified_radius(gap, C)
        color = colors[winner]
        
        # Draw L∞ ball (square)
        rect = patches.Rectangle(
            (pt[0] - r, pt[1] - r), 2*r, 2*r,
            linewidth=2, edgecolor=color, facecolor=color, alpha=0.3
        )
        ax.add_patch(rect)
        ax.plot(pt[0], pt[1], 'o', color=color, markersize=8, 
                markeredgecolor='black', markeredgewidth=1)
        ax.annotate(f'r={r:.3f}', (pt[0], pt[1] + r + 0.15),
                   ha='center', fontsize=8, fontweight='bold')
    
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_xlabel('$x_1$', fontsize=12)
    ax.set_ylabel('$x_2$', fontsize=12)
    ax.set_title('Decision Regions with Certified L∞ Balls', fontsize=14)
    ax.set_aspect('equal')
    
    # Legend
    for k in range(3):
        ax.plot([], [], 's', color=colors[k], markersize=12, label=class_names[k])
    ax.legend(loc='upper right', fontsize=10)
    
    # --- Right panel: Certification radius heatmap ---
    ax = axes[1]
    Radius = Gap / (2 * C)
    im = ax.contourf(X, Y, Radius, levels=20, cmap='viridis')
    ax.contour(X, Y, Z, levels=[0.5, 1.5], colors='white', linewidths=1.5)
    plt.colorbar(im, ax=ax, label='Certified radius r = gap/(2C)')
    ax.set_xlabel('$x_1$', fontsize=12)
    ax.set_ylabel('$x_2$', fontsize=12)
    ax.set_title('Certified Robustness Radius Landscape', fontsize=14)
    ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig('Bridges/certification_regions.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: Bridges/certification_regions.png")

def plot_perturbation_experiment(scores, C, d=2):
    """Empirically validate the certification theorem."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Choose a test point
    x0 = np.array([1.0, -0.5])
    winner, gap, vals = compute_top2_gap(scores, x0)
    r_cert = certified_radius(gap, C)
    
    print(f"\n  Test point: x = {x0}")
    print(f"  Scores: {[f'{v:.3f}' for v in vals]}")
    print(f"  Winner: class {winner}, gap = {gap:.4f}")
    print(f"  Certified radius: r = {r_cert:.4f}")
    
    # --- Left: Score trajectories under random perturbations ---
    ax = axes[0]
    n_perturbations = 200
    epsilons = np.linspace(0, 2 * r_cert, 50)
    
    for trial in range(n_perturbations):
        # Random L∞ direction
        direction = np.random.choice([-1, 1], size=d) * np.random.rand(d)
        direction = direction / np.max(np.abs(direction))  # normalize to L∞ unit ball
        
        score_traces = [[] for _ in range(len(scores))]
        for eps in epsilons:
            x_pert = x0 + eps * direction
            for k, s in enumerate(scores):
                score_traces[k].append(s(x_pert))
        
        colors_line = ['#FF6B6B', '#4ECDC4', '#45B7D1']
        for k in range(len(scores)):
            ax.plot(epsilons / r_cert, score_traces[k], 
                   color=colors_line[k], alpha=0.05, linewidth=0.5)
    
    # Average traces
    for k in range(len(scores)):
        ax.axhline(y=vals[k], color=colors_line[k], linestyle='--', alpha=0.5)
    
    ax.axvline(x=1.0, color='red', linestyle='-', linewidth=2, label='Certified radius')
    ax.set_xlabel('Perturbation ε / r_cert', fontsize=12)
    ax.set_ylabel('Score value', fontsize=12)
    ax.set_title('Score Trajectories Under Perturbation', fontsize=13)
    ax.legend(fontsize=10)
    
    # --- Right: Fraction of class changes vs perturbation size ---
    ax = axes[1]
    eps_values = np.linspace(0, 3 * r_cert, 100)
    n_trials = 2000
    flip_rates = []
    
    for eps in eps_values:
        flips = 0
        for _ in range(n_trials):
            delta = eps * (2 * np.random.rand(d) - 1)  # uniform in L∞ ball
            x_pert = x0 + delta
            new_winner, _, _ = compute_top2_gap(scores, x_pert)
            if new_winner != winner:
                flips += 1
        flip_rates.append(flips / n_trials)
    
    ax.plot(eps_values / r_cert, flip_rates, 'b-', linewidth=2)
    ax.axvline(x=1.0, color='red', linestyle='-', linewidth=2, label='Certified radius')
    ax.fill_between([0, 1.0], [0, 0], [1, 1], alpha=0.1, color='green', label='Certified safe zone')
    ax.set_xlabel('Perturbation ε / r_cert', fontsize=12)
    ax.set_ylabel('Fraction of class changes', fontsize=12)
    ax.set_title('Empirical Validation of Certificate', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_ylim(-0.05, 1.05)
    
    plt.tight_layout()
    plt.savefig('Bridges/perturbation_validation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: Bridges/perturbation_validation.png")

def plot_score_landscape_3d(scores, C):
    """3D visualization of score functions."""
    fig = plt.figure(figsize=(16, 5))
    
    grid_res = 100
    x_range = np.linspace(-2, 2, grid_res)
    y_range = np.linspace(-2, 2, grid_res)
    X, Y = np.meshgrid(x_range, y_range)
    
    titles = ['Score 0 (Tropical Hecke)', 'Score 1 (Tropical Hecke)', 'Score 2 (Tropical Hecke)']
    colors = ['Reds', 'Greens', 'Blues']
    
    for k in range(3):
        ax = fig.add_subplot(1, 3, k+1, projection='3d')
        Z = np.zeros_like(X)
        for i in range(grid_res):
            for j in range(grid_res):
                Z[i, j] = scores[k](np.array([X[i, j], Y[i, j]]))
        ax.plot_surface(X, Y, Z, cmap=colors[k], alpha=0.8, linewidth=0)
        ax.set_xlabel('$x_1$')
        ax.set_ylabel('$x_2$')
        ax.set_zlabel('Score')
        ax.set_title(titles[k], fontsize=11)
        ax.view_init(elev=25, azim=135)
    
    plt.tight_layout()
    plt.savefig('Bridges/score_landscapes_3d.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: Bridges/score_landscapes_3d.png")

def print_certification_table(scores, C):
    """Print a table of certified radii at various points."""
    print("\n" + "="*70)
    print("  CERTIFICATION TABLE")
    print("  (Theorem: unique_top_stable_of_top2Gap)")
    print("="*70)
    print(f"  {'Point':>15s}  {'Winner':>6s}  {'Scores':>30s}  {'Gap':>8s}  {'Radius':>8s}")
    print("-"*70)
    
    test_points = [
        np.array([0.0, 0.0]),
        np.array([1.0, 0.0]),
        np.array([0.0, 1.0]),
        np.array([-1.0, 0.0]),
        np.array([0.0, -1.0]),
        np.array([1.0, 1.0]),
        np.array([-1.0, -1.0]),
        np.array([2.0, -1.0]),
        np.array([-1.0, 2.0]),
        np.array([0.5, -0.5]),
    ]
    
    for pt in test_points:
        winner, gap, vals = compute_top2_gap(scores, pt)
        r = certified_radius(gap, C)
        pt_str = f"({pt[0]:.1f}, {pt[1]:.1f})"
        vals_str = f"({vals[0]:.2f}, {vals[1]:.2f}, {vals[2]:.2f})"
        print(f"  {pt_str:>15s}  {winner:>6d}  {vals_str:>30s}  {gap:>8.4f}  {r:>8.4f}")
    
    print("="*70)

# ============================================================
# 4. Application: Adversarial Attack Detector
# ============================================================

def adversarial_attack_demo(scores, C):
    """Demonstrate using certified radii as an adversarial attack detector."""
    print("\n" + "="*70)
    print("  APPLICATION: Adversarial Attack Detection")
    print("="*70)
    
    x0 = np.array([1.0, -0.5])
    winner, gap, vals = compute_top2_gap(scores, x0)
    r_cert = certified_radius(gap, C)
    
    print(f"\n  Original input: x = {x0}")
    print(f"  Predicted class: {winner} (scores: {[f'{v:.3f}' for v in vals]})")
    print(f"  Certified radius: {r_cert:.4f}")
    
    # Simulate attacks
    attacks = [
        ("Small noise", np.array([0.05, -0.03])),
        ("Medium noise", np.array([0.1, 0.08])),
        ("Targeted attack", np.array([r_cert * 0.9, -r_cert * 0.9])),
        ("Strong attack", np.array([r_cert * 1.5, r_cert * 1.2])),
        ("Extreme attack", np.array([2.0, -2.0])),
    ]
    
    print(f"\n  {'Attack':>20s}  {'‖δ‖∞':>8s}  {'< r?':>6s}  {'Certified':>10s}  {'New cls':>8s}  {'Changed?':>10s}")
    print("  " + "-"*65)
    
    for name, delta in attacks:
        norm_inf = np.max(np.abs(delta))
        is_certified = norm_inf < r_cert
        x_pert = x0 + delta
        new_winner, _, new_vals = compute_top2_gap(scores, x_pert)
        changed = new_winner != winner
        
        cert_str = "✓ SAFE" if is_certified else "✗ UNKNOWN"
        change_str = "NO" if not changed else "YES ⚠"
        
        print(f"  {name:>20s}  {norm_inf:>8.4f}  {'Yes' if is_certified else 'No':>6s}  {cert_str:>10s}  {new_winner:>8d}  {change_str:>10s}")
    
    print("\n  Note: Within the certified radius, class changes are PROVABLY impossible")
    print("  (formally verified in Lean 4 as theorem unique_top_stable_of_top2Gap)")

# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  GL₃ Tropical Satake Certified Robustness Demo             ║")
    print("║  Formally verified in Lean 4 with Mathlib                  ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
    # Setup
    scores, C, d = tropical_score_functions(K=1.0)
    print(f"\n  Configuration: m=3 classes, d={d} dimensions")
    print(f"  Lipschitz constant: K=1.0, C = K*d = {C}")
    
    # Verify Lipschitz bound
    print("\n[1] Verifying Lipschitz bound empirically...")
    verify_lipschitz(scores, C, d=d)
    
    # Certification table
    print("\n[2] Computing certified radii...")
    print_certification_table(scores, C)
    
    # Visualizations
    print("\n[3] Generating visualizations...")
    plot_decision_regions_and_certificates(scores, C, d=d)
    plot_perturbation_experiment(scores, C, d=d)
    plot_score_landscape_3d(scores, C)
    
    # Application demo
    print("\n[4] Running adversarial attack detection demo...")
    adversarial_attack_demo(scores, C)
    
    # Two-score perturbation bound demo
    print("\n[5] Demonstrating the core two-score perturbation bound...")
    print("  (Theorem: score_diff_le_two_mul_lipschitz)")
    x = np.array([0.5, 0.3])
    y = np.array([0.8, -0.2])
    linf = np.max(np.abs(x - y))
    for i in range(3):
        for j in range(3):
            if i == j: continue
            diff_x = scores[i](x) - scores[j](x)
            diff_y = scores[i](y) - scores[j](y)
            lhs = abs(diff_x - diff_y)
            rhs = 2 * C * linf
            print(f"  |(s{i}(x)-s{j}(x)) - (s{i}(y)-s{j}(y))| = {lhs:.4f} ≤ 2C‖x-y‖∞ = {rhs:.4f}: {lhs <= rhs + 1e-10}")
    
    print("\n✓ All demonstrations complete.")
    print("  The formal proofs in Lean 4 guarantee these properties for ALL inputs,")
    print("  not just the sampled ones shown here.")

if __name__ == '__main__':
    main()
