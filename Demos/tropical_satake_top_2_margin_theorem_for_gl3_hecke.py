#!/usr/bin/env python3
"""
Tropical Satake Top-2 Margin Theorem — Interactive Demo
========================================================

This script demonstrates the formally verified theorems about top-2 label
robustness for GL₃ tropical Satake classifiers. It provides:

1. Visualization of the top-2 partition of score space
2. Numerical verification of the margin theorem
3. Max-plus score perturbation examples
4. Sharp counterperturbation construction

All results correspond to theorems proven in Lean 4 in
  Bridges/TropicalSatake/TropicalSatakeTop2Margin.lean
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import combinations
import os

# ---------------------------------------------------------------------------
# Core definitions (matching the Lean formalization)
# ---------------------------------------------------------------------------

def is_top2_set(x, A):
    """
    Check if A (a set of indices) is a valid top-2 set for score vector x.
    Matches: IsTop2Set x A ≡ A.card = 2 ∧ ∀ i ∈ A, ∀ j ∉ A, x j < x i
    """
    if len(A) != 2:
        return False
    complement = set(range(3)) - A
    return all(x[j] < x[i] for i in A for j in complement)


def find_top2_set(x):
    """Find the unique top-2 set if it exists, else return None."""
    for pair in combinations(range(3), 2):
        A = set(pair)
        if is_top2_set(x, A):
            return A
    return None


def top2_margin(x, c):
    """
    Minimum margin from excluded class c to the top-2 pair.
    The top-2 set is stable under ε-perturbation iff this exceeds 2ε.
    """
    others = [i for i in range(3) if i != c]
    return min(x[i] - x[c] for i in others)


def maxplus_score(W, v):
    """
    Max-plus score: for each class i, compute max over (t, w) in W[i] of v[t] + w.
    This is the tropical analogue of a linear score function.
    """
    return np.array([max(v(t) + w for t, w in W[i]) for i in range(3)])


# ---------------------------------------------------------------------------
# Demo 1: Top-2 partition of score space
# ---------------------------------------------------------------------------

def demo_top2_partition():
    """
    Visualize which pairs of classes form the top-2 set as scores vary.
    We fix x[2] = 0 and vary (x[0], x[1]) to show the partition.
    """
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))
    
    N = 500
    x0 = np.linspace(-3, 3, N)
    x1 = np.linspace(-3, 3, N)
    X0, X1 = np.meshgrid(x0, x1)
    
    # Color map: which pair is the top-2 set?
    # {0,1} = both above x[2]=0: x[0]>0 and x[1]>0
    # {0,2} = x[0]>x[1] and 0>x[1]: x[0]>x[1] and x[1]<0
    # {1,2} = x[1]>x[0] and 0>x[0]: x[1]>x[0] and x[0]<0
    # Boundaries: where two scores are equal
    
    colors = np.zeros((N, N, 3))
    labels = np.zeros((N, N), dtype=int)
    
    for i in range(N):
        for j in range(N):
            x = np.array([X0[i, j], X1[i, j], 0.0])
            A = find_top2_set(x)
            if A == {0, 1}:
                colors[i, j] = [0.2, 0.6, 0.9]  # blue
                labels[i, j] = 1
            elif A == {0, 2}:
                colors[i, j] = [0.9, 0.3, 0.2]  # red
                labels[i, j] = 2
            elif A == {1, 2}:
                colors[i, j] = [0.3, 0.8, 0.3]  # green
                labels[i, j] = 3
            else:
                colors[i, j] = [0.9, 0.9, 0.9]  # gray = no unique top-2
                labels[i, j] = 0
    
    ax.imshow(colors, extent=[-3, 3, -3, 3], origin='lower', aspect='equal')
    
    # Draw boundary lines
    ax.plot([-3, 3], [0, 0], 'k-', linewidth=1.5, alpha=0.7)
    ax.plot([0, 0], [-3, 3], 'k-', linewidth=1.5, alpha=0.7)
    ax.plot([-3, 3], [-3, 3], 'k-', linewidth=1.5, alpha=0.7)
    
    # Labels
    ax.text(1.5, 1.5, 'Top-2 = {0,1}\nexcluded: 2', fontsize=11,
            ha='center', va='center', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    ax.text(2.0, -1.5, 'Top-2 = {0,2}\nexcluded: 1', fontsize=11,
            ha='center', va='center', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    ax.text(-1.5, 2.0, 'Top-2 = {1,2}\nexcluded: 0', fontsize=11,
            ha='center', va='center', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    ax.set_xlabel('Score x[0]', fontsize=13)
    ax.set_ylabel('Score x[1]', fontsize=13)
    ax.set_title('Top-2 Set Partition of Score Space (x[2] = 0)\n'
                 'Gray = no unique top-2 set (boundary)', fontsize=14)
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'top2_partition.png'), dpi=150)
    plt.close()
    print("✓ Saved top2_partition.png")


# ---------------------------------------------------------------------------
# Demo 2: Margin theorem — perturbation stability
# ---------------------------------------------------------------------------

def demo_margin_stability():
    """
    Demonstrate the sharp margin theorem:
    - Top-2 set is stable under ε-perturbation iff min margin > 2ε
    - Show the stability region and counterexample construction
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left panel: stability under perturbation
    ax = axes[0]
    x = np.array([3.0, 2.0, 0.0])  # Top-2 = {0,1}, excluded = 2
    excluded = 2
    margin = top2_margin(x, excluded)
    
    ax.set_title(f'Top-2 Stability Under Perturbation\n'
                 f'x = {x}, margin = {margin:.1f}', fontsize=12)
    
    eps_values = np.linspace(0, 2.0, 200)
    n_trials = 500
    stability = []
    
    for eps in eps_values:
        stable_count = 0
        for _ in range(n_trials):
            perturbation = np.random.uniform(-eps, eps, 3)
            y = x + perturbation
            A = find_top2_set(y)
            if A == {0, 1}:
                stable_count += 1
        stability.append(stable_count / n_trials)
    
    ax.plot(eps_values, stability, 'b-', linewidth=2)
    ax.axvline(x=margin/2, color='r', linestyle='--', linewidth=2,
               label=f'ε = margin/2 = {margin/2:.2f}')
    ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
    ax.fill_between(eps_values, 0, 1,
                    where=[e <= margin/2 for e in eps_values],
                    alpha=0.15, color='green', label='Guaranteed stable (2ε < margin)')
    ax.set_xlabel('Perturbation radius ε', fontsize=12)
    ax.set_ylabel('Fraction preserving top-2 = {0,1}', fontsize=12)
    ax.legend(fontsize=10)
    ax.set_ylim(-0.05, 1.1)
    
    # Right panel: counterperturbation construction
    ax = axes[1]
    x = np.array([3.0, 1.5, 0.0])
    excluded = 2
    margin_0 = x[0] - x[2]  # 3.0
    margin_1 = x[1] - x[2]  # 1.5
    
    ax.set_title(f'Counterperturbation Construction\n'
                 f'x = {x}, margins: {margin_0:.1f}, {margin_1:.1f}', fontsize=12)
    
    # The weaker margin is 1.5, so ε = 0.75 should break stability
    eps = margin_1 / 2  # = 0.75
    
    # Construct the extremal perturbation: y[1] = x[1] - ε, y[2] = x[2] + ε
    y_counter = np.array([x[0], x[1] - eps, x[2] + eps])
    
    classes = ['Class 0', 'Class 1', 'Class 2']
    bar_width = 0.3
    positions = np.arange(3)
    
    bars_x = ax.bar(positions - bar_width/2, x, bar_width, label='Original x',
                    color=['#4a90d9', '#4a90d9', '#d94a4a'], alpha=0.8)
    bars_y = ax.bar(positions + bar_width/2, y_counter, bar_width,
                    label=f'Perturbed y (ε={eps:.2f})',
                    color=['#7ab8f5', '#7ab8f5', '#f57a7a'], alpha=0.8,
                    edgecolor='black', linewidth=1.5)
    
    ax.set_xticks(positions)
    ax.set_xticklabels(classes, fontsize=11)
    ax.set_ylabel('Score', fontsize=12)
    ax.legend(fontsize=10)
    
    # Annotate: y[1] = y[2] means top-2 is no longer unique
    ax.annotate(f'y[1] = {y_counter[1]:.2f}\ny[2] = {y_counter[2]:.2f}\nTied!',
                xy=(1.5, max(y_counter[1], y_counter[2]) + 0.1),
                fontsize=10, ha='center',
                bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'margin_stability.png'), dpi=150)
    plt.close()
    print("✓ Saved margin_stability.png")


# ---------------------------------------------------------------------------
# Demo 3: Max-plus score model
# ---------------------------------------------------------------------------

def demo_maxplus_robustness():
    """
    Demonstrate the max-plus top-2 robustness theorem with a concrete
    tropical Satake-like score model.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Define a max-plus model with 4 test functions
    # W[i] = list of (test_index, weight) pairs
    W = {
        0: [(0, 1.0), (1, 0.5), (2, -0.3)],  # Class 0 scores
        1: [(1, 0.8), (2, 1.2), (3, 0.1)],    # Class 1 scores
        2: [(0, -0.5), (3, 0.3)],              # Class 2 scores
    }
    
    # Base test valuation
    v_base = {0: 2.0, 1: 1.5, 2: 1.0, 3: 0.5}
    v_func = lambda t: v_base.get(t, 0.0)
    
    scores_base = maxplus_score(W, v_func)
    top2 = find_top2_set(scores_base)
    excluded = list(set(range(3)) - top2)[0]
    margin = top2_margin(scores_base, excluded)
    
    print(f"\nMax-plus model:")
    print(f"  Base scores: {scores_base}")
    print(f"  Top-2 set: {top2}")
    print(f"  Excluded class: {excluded}")
    print(f"  Margin: {margin:.4f}")
    print(f"  Critical ε (= margin/2): {margin/2:.4f}")
    
    # Left: sweep η and check stability
    ax = axes[0]
    eta_values = np.linspace(0, margin, 200)
    n_trials = 300
    
    stability = []
    for eta in eta_values:
        stable_count = 0
        for _ in range(n_trials):
            perturbation = {t: np.random.uniform(-eta, eta) for t in v_base}
            w_func = lambda t, p=perturbation: v_base.get(t, 0.0) + p.get(t, 0.0)
            scores_w = maxplus_score(W, w_func)
            A_w = find_top2_set(scores_w)
            if A_w == top2:
                stable_count += 1
        stability.append(stable_count / n_trials)
    
    ax.plot(eta_values, stability, 'b-', linewidth=2)
    ax.axvline(x=margin/2, color='r', linestyle='--', linewidth=2,
               label=f'η = margin/2 = {margin/2:.3f}')
    ax.fill_between(eta_values, 0, 1,
                    where=[e <= margin/2 for e in eta_values],
                    alpha=0.15, color='green', label='Guaranteed stable (2η < margin)')
    ax.set_xlabel('Test perturbation radius η', fontsize=12)
    ax.set_ylabel('Fraction preserving top-2 set', fontsize=12)
    ax.set_title('Max-Plus Top-2 Stability\nvs. Test Perturbation', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_ylim(-0.05, 1.1)
    
    # Right: visualize score trajectories under perturbation
    ax = axes[1]
    n_paths = 50
    eta = margin * 0.8
    
    for _ in range(n_paths):
        perturbation = {t: np.random.uniform(-eta, eta) for t in v_base}
        w_func = lambda t, p=perturbation: v_base.get(t, 0.0) + p.get(t, 0.0)
        scores_w = maxplus_score(W, w_func)
        
        A_w = find_top2_set(scores_w)
        color = 'blue' if A_w == top2 else 'red'
        alpha = 0.3
        
        for i in range(3):
            ax.plot([i - 0.1, i + 0.1],
                    [scores_base[i], scores_w[i]],
                    color=color, alpha=alpha, linewidth=0.8)
    
    # Plot base scores
    ax.scatter(range(3), scores_base, s=100, c='black', zorder=5, label='Base scores')
    ax.set_xticks(range(3))
    ax.set_xticklabels([f'Class {i}' for i in range(3)], fontsize=11)
    ax.set_ylabel('Score', fontsize=12)
    ax.set_title(f'Score Trajectories Under Perturbation\n'
                 f'η = {eta:.3f} (blue = stable, red = changed)', fontsize=13)
    ax.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'maxplus_robustness.png'), dpi=150)
    plt.close()
    print("✓ Saved maxplus_robustness.png")


# ---------------------------------------------------------------------------
# Demo 4: Sharp threshold verification
# ---------------------------------------------------------------------------

def demo_sharp_threshold():
    """
    Verify the sharpness of the 2ε threshold by showing that at exactly
    the critical perturbation, the top-2 set can be destroyed.
    """
    print("\n" + "="*60)
    print("SHARP THRESHOLD VERIFICATION")
    print("="*60)
    
    x = np.array([5.0, 3.0, 1.0])
    top2 = find_top2_set(x)
    excluded = 2
    margins = [x[0] - x[2], x[1] - x[2]]
    min_margin = min(margins)
    critical_eps = min_margin / 2
    
    print(f"\nScore vector: x = {x}")
    print(f"Top-2 set: {top2}")
    print(f"Excluded class: {excluded}")
    print(f"Margins to excluded: {margins}")
    print(f"Minimum margin: {min_margin}")
    print(f"Critical ε = min_margin/2 = {critical_eps}")
    
    # Below threshold: always stable
    eps_below = critical_eps - 0.01
    print(f"\n--- ε = {eps_below:.3f} (below threshold) ---")
    print(f"  2ε = {2*eps_below:.3f} < min_margin = {min_margin}")
    print(f"  Theorem guarantees: top-2 ALWAYS preserved ✓")
    
    # At threshold: construct counterperturbation
    eps_at = critical_eps
    # Weaker margin is x[1] - x[2] = 2.0, so a=1
    a = 1  # weaker member
    y = np.array([x[0], x[1] - eps_at, x[2] + eps_at])
    print(f"\n--- ε = {eps_at:.3f} (at threshold) ---")
    print(f"  Counterperturbation: y = {y}")
    print(f"  |y - x| = {np.abs(y - x)}")
    print(f"  y[1] - y[2] = {y[1] - y[2]:.6f}")
    print(f"  Top-2 preserved? {find_top2_set(y) == top2}")
    print(f"  Theorem predicts: counterperturbation EXISTS ✓")
    
    # Above threshold on both margins: no counterperturbation possible
    eps_safe = min_margin / 2 - 0.5
    print(f"\n--- ε = {eps_safe:.3f} (safely below threshold) ---")
    n_trials = 10000
    all_stable = True
    for _ in range(n_trials):
        perturbation = np.random.uniform(-eps_safe, eps_safe, 3)
        y = x + perturbation
        if find_top2_set(y) != top2:
            all_stable = False
            break
    print(f"  {n_trials} random perturbations: all preserved = {all_stable}")
    print(f"  Theorem guarantees: ALWAYS preserved ✓")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    print("="*60)
    print("TROPICAL SATAKE TOP-2 MARGIN THEOREM — DEMO")
    print("="*60)
    
    demo_top2_partition()
    demo_margin_stability()
    demo_maxplus_robustness()
    demo_sharp_threshold()
    
    print("\n" + "="*60)
    print("All demos complete. See generated PNG files for visualizations.")
    print("="*60)
