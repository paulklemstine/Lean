#!/usr/bin/env python3
"""
Tropical Satake Voting: Numerical Demo & Visualization

Demonstrates the certified robustness theorem for pairwise one-vs-one
voting classifiers with heterogeneous Lipschitz margin bounds.

The key insight: if a classifier w beats every other class by a margin
exceeding 2 * K(w,j) * r, then w remains the unique Borda/Copeland
winner under any perturbation of radius ≤ r.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations

# ─────────────────────────────────────────────────────────────────────
# Core definitions (mirroring the Lean formalization)
# ─────────────────────────────────────────────────────────────────────

def pair_margin(S, i, j, x):
    """PairMargin S i j x = S(i, x) - S(j, x)"""
    return S[i](x) - S[j](x)

def borda_score(S, n, i, x):
    """Number of classes that i beats at x."""
    return sum(1 for j in range(n) if j != i and pair_margin(S, i, j, x) > 0)

def is_strict_borda_winner(S, n, w, x):
    """Check if w is the unique strict Borda winner at x."""
    w_score = borda_score(S, n, w, x)
    return all(borda_score(S, n, i, x) < w_score for i in range(n) if i != w)

def certified_radius(S, K, n, w, x):
    """Minimum over opponents j of PairMargin(w,j,x) / (2 * K(w,j))."""
    radii = []
    for j in range(n):
        if j != w:
            margin = pair_margin(S, w, j, x)
            lip = K[w][j]
            if lip > 0:
                radii.append(margin / (2 * lip))
            elif margin > 0:
                radii.append(float('inf'))
            else:
                radii.append(0.0)
    return min(radii) if radii else float('inf')

# ─────────────────────────────────────────────────────────────────────
# Example 1: 4-class classifier in 2D with linear scores
# ─────────────────────────────────────────────────────────────────────

def demo_linear_classifier():
    """
    4 classes with linear score functions S_i(x) = w_i · x + b_i.
    We demonstrate the certified robustness radius and verify it empirically.
    """
    print("=" * 70)
    print("DEMO 1: Linear 4-class pairwise voting classifier in R²")
    print("=" * 70)

    n = 4  # number of classes
    d = 2  # input dimension

    # Score function parameters: S_i(x) = weights[i] @ x + biases[i]
    weights = np.array([
        [2.0, 1.0],   # Class 0
        [0.5, -1.0],  # Class 1
        [-1.0, 0.5],  # Class 2
        [0.0, -0.5],  # Class 3
    ])
    biases = np.array([1.0, 0.5, -0.5, 0.0])

    # Score functions
    S = {i: (lambda x, i=i: weights[i] @ x + biases[i]) for i in range(n)}

    # Base point
    x0 = np.array([1.0, 0.5])

    # Compute Lipschitz constants for pairwise margins
    # PairMargin(i,j,x) = (w_i - w_j) · x + (b_i - b_j)
    # |PairMargin(i,j,x') - PairMargin(i,j,x)| = |(w_i - w_j) · (x' - x)|
    # ≤ ||w_i - w_j||_1 * ||x' - x||_∞  (by Hölder)
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i][j] = np.sum(np.abs(weights[i] - weights[j]))

    print(f"\nBase point x₀ = {x0}")
    print(f"\nScores at x₀:")
    for i in range(n):
        print(f"  S_{i}(x₀) = {S[i](x0):.3f}")

    print(f"\nPairwise margins from class 0:")
    for j in range(1, n):
        m = pair_margin(S, 0, j, x0)
        print(f"  PairMargin(0, {j}, x₀) = {m:.3f}")

    print(f"\nBorda scores:")
    for i in range(n):
        print(f"  BordaScore({i}) = {borda_score(S, n, i, x0)}")

    w = 0  # expected winner
    print(f"\nIs class {w} the strict Borda winner? {is_strict_borda_winner(S, n, w, x0)}")

    print(f"\nLipschitz constants K(0, j):")
    for j in range(1, n):
        print(f"  K(0, {j}) = {K[0][j]:.3f}")

    r_cert = certified_radius(S, K, n, w, x0)
    print(f"\nCertified robustness radius: r* = {r_cert:.4f}")

    # Empirical verification: sample random perturbations
    n_samples = 10000
    n_fail_inside = 0
    n_fail_outside = 0
    radii_tested = np.linspace(0, 2 * r_cert, 100)

    print(f"\nEmpirical verification ({n_samples} random perturbations):")
    for _ in range(n_samples):
        # Random perturbation in L∞ ball
        delta = np.random.uniform(-1, 1, d)
        r_test = np.random.uniform(0, 2 * r_cert)
        x_pert = x0 + r_test * delta

        actual_r = np.max(np.abs(x_pert - x0))
        winner_preserved = is_strict_borda_winner(S, n, w, x_pert)

        if actual_r <= r_cert and not winner_preserved:
            n_fail_inside += 1
        if actual_r > r_cert and not winner_preserved:
            n_fail_outside += 1

    print(f"  Failures inside certified radius: {n_fail_inside} (should be 0)")
    print(f"  Failures outside certified radius: {n_fail_outside}")

    # ── Visualization ──
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Plot 1: Decision regions with certified ball
    ax = axes[0]
    grid_range = 3
    xx, yy = np.meshgrid(np.linspace(-grid_range, grid_range, 300),
                         np.linspace(-grid_range, grid_range, 300))
    grid_points = np.column_stack([xx.ravel(), yy.ravel()])

    winners = np.zeros(len(grid_points), dtype=int)
    for idx, pt in enumerate(grid_points):
        scores = [borda_score(S, n, i, pt) for i in range(n)]
        winners[idx] = np.argmax(scores)

    colors = ['#4CAF50', '#2196F3', '#FF9800', '#E91E63']
    cmap = plt.matplotlib.colors.ListedColormap(colors)
    ax.contourf(xx, yy, winners.reshape(xx.shape), levels=[-0.5, 0.5, 1.5, 2.5, 3.5],
                colors=colors, alpha=0.3)
    ax.plot(*x0, 'k*', markersize=15, label=f'x₀ = ({x0[0]}, {x0[1]})')

    # Draw certified radius ball (L∞ = square)
    rect = plt.Rectangle(x0 - r_cert, 2 * r_cert, 2 * r_cert,
                         linewidth=2, edgecolor='black', facecolor='none',
                         linestyle='--', label=f'Certified ball (r={r_cert:.3f})')
    ax.add_patch(rect)

    patches = [mpatches.Patch(color=c, alpha=0.3, label=f'Class {i}')
               for i, c in enumerate(colors)]
    ax.legend(handles=patches + [rect], loc='lower left', fontsize=8)
    ax.set_title('Borda Winner Decision Regions')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_xlim(-grid_range, grid_range)
    ax.set_ylim(-grid_range, grid_range)

    # Plot 2: Pairwise margins vs perturbation radius
    ax = axes[1]
    radii = np.linspace(0, 2 * r_cert, 200)
    for j in range(1, n):
        margin_base = pair_margin(S, 0, j, x0)
        lip = K[0][j]
        upper = margin_base + lip * radii
        lower = margin_base - lip * radii
        ax.fill_between(radii, lower, upper, alpha=0.2, label=f'Margin(0,{j})')
        ax.plot(radii, [margin_base] * len(radii), '--', linewidth=0.5)

    ax.axhline(y=0, color='red', linewidth=1.5, linestyle='-', label='Zero margin')
    ax.axvline(x=r_cert, color='black', linewidth=1.5, linestyle='--', label=f'r* = {r_cert:.3f}')
    ax.set_xlabel('Perturbation radius r')
    ax.set_ylabel('Pairwise margin range')
    ax.set_title('Margin Preservation vs Perturbation')
    ax.legend(fontsize=8)

    # Plot 3: Tournament graph at base point
    ax = axes[2]
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    positions = np.column_stack([np.cos(angles), np.sin(angles)]) * 0.8

    for i in range(n):
        circle = plt.Circle(positions[i], 0.12, color=colors[i], alpha=0.7)
        ax.add_patch(circle)
        ax.text(positions[i][0], positions[i][1], str(i),
                ha='center', va='center', fontsize=14, fontweight='bold', color='white')

    # Draw tournament edges
    for i in range(n):
        for j in range(n):
            if i != j and pair_margin(S, i, j, x0) > 0:
                start = positions[i]
                end = positions[j]
                direction = end - start
                direction = direction / np.linalg.norm(direction)
                ax.annotate('', xy=end - 0.14 * direction, xytext=start + 0.14 * direction,
                           arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    # Highlight winner's outgoing edges
    for j in range(n):
        if j != w and pair_margin(S, w, j, x0) > 0:
            start = positions[w]
            end = positions[j]
            direction = end - start
            direction = direction / np.linalg.norm(direction)
            margin = pair_margin(S, w, j, x0)
            ax.annotate('', xy=end - 0.14 * direction, xytext=start + 0.14 * direction,
                        arrowprops=dict(arrowstyle='->', color='green', lw=3))
            mid = (start + end) / 2 + 0.1 * np.array([-direction[1], direction[0]])
            ax.text(mid[0], mid[1], f'{margin:.2f}', fontsize=8, color='green',
                    ha='center', va='center')

    ax.set_xlim(-1.2, 1.2)
    ax.set_ylim(-1.2, 1.2)
    ax.set_aspect('equal')
    ax.set_title(f'Tournament Graph (Winner: Class {w})')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('Bridges/TropicalSatakeVoting/voting_robustness_demo.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n✓ Visualization saved to Bridges/TropicalSatakeVoting/voting_robustness_demo.png")


# ─────────────────────────────────────────────────────────────────────
# Example 2: Effect of number of classes on certified radius
# ─────────────────────────────────────────────────────────────────────

def demo_scaling():
    """
    How does the certified radius scale with the number of classes?
    With random linear classifiers, more classes → tighter margins → smaller radius.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Certified radius scaling with number of classes")
    print("=" * 70)

    d = 5  # dimension
    np.random.seed(42)
    n_values = list(range(3, 21))
    avg_radii = []

    for n in n_values:
        radii = []
        for trial in range(50):
            # Random linear classifiers
            weights = np.random.randn(n, d) * 2
            biases = np.random.randn(n) * 0.5
            S = {i: (lambda x, i=i: weights[i] @ x + biases[i]) for i in range(n)}
            x0 = np.random.randn(d) * 0.5

            # Find the actual Borda winner
            scores = [borda_score(S, n, i, x0) for i in range(n)]
            w = np.argmax(scores)

            if not is_strict_borda_winner(S, n, w, x0):
                continue

            # Compute Lipschitz constants and certified radius
            K = np.zeros((n, n))
            for i in range(n):
                for j in range(n):
                    K[i][j] = np.sum(np.abs(weights[i] - weights[j]))

            r = certified_radius(S, K, n, w, x0)
            if r > 0 and np.isfinite(r):
                radii.append(r)

        if radii:
            avg_radii.append(np.mean(radii))
        else:
            avg_radii.append(0)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(n_values, avg_radii, 'bo-', linewidth=2, markersize=6)
    ax.set_xlabel('Number of classes (n)', fontsize=12)
    ax.set_ylabel('Average certified radius', fontsize=12)
    ax.set_title('Certified Robustness Radius vs Number of Classes\n(Random linear classifiers in ℝ⁵)', fontsize=13)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('Bridges/TropicalSatakeVoting/radius_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Scaling plot saved to Bridges/TropicalSatakeVoting/radius_scaling.png")


# ─────────────────────────────────────────────────────────────────────
# Example 3: Comparison with argmax robustness
# ─────────────────────────────────────────────────────────────────────

def demo_comparison():
    """
    Compare pairwise voting robustness with direct argmax robustness.
    Shows that they are genuinely different certification mechanisms.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Pairwise voting vs argmax robustness comparison")
    print("=" * 70)

    n = 5
    d = 3
    np.random.seed(123)

    weights = np.array([
        [3.0, 1.0, 0.5],    # Class 0 - strong in dim 0
        [1.0, 2.5, 0.0],    # Class 1 - strong in dim 1
        [0.5, 0.5, 2.0],    # Class 2 - strong in dim 2
        [-0.5, 1.0, 1.0],   # Class 3
        [0.0, -0.5, 0.5],   # Class 4
    ])
    biases = np.array([0.5, 0.0, -0.3, -0.2, 0.1])
    S = {i: (lambda x, i=i: weights[i] @ x + biases[i]) for i in range(n)}

    x0 = np.array([1.0, 0.3, 0.2])

    # Borda winner analysis
    print(f"\nScores at x₀ = {x0}:")
    raw_scores = [S[i](x0) for i in range(n)]
    for i in range(n):
        print(f"  S_{i}(x₀) = {raw_scores[i]:.3f}, BordaScore = {borda_score(S, n, i, x0)}")

    # Argmax winner
    argmax_winner = np.argmax(raw_scores)
    # Borda winner
    borda_scores = [borda_score(S, n, i, x0) for i in range(n)]
    borda_winner = np.argmax(borda_scores)

    print(f"\nArgmax winner: Class {argmax_winner}")
    print(f"Borda winner: Class {borda_winner}")

    # Argmax certified radius: min_{j≠w} (S_w(x) - S_j(x)) / (L_w + L_j)
    # where L_i = ||w_i||_1
    L_individual = [np.sum(np.abs(weights[i])) for i in range(n)]
    argmax_margins = []
    for j in range(n):
        if j != argmax_winner:
            margin = raw_scores[argmax_winner] - raw_scores[j]
            lip = L_individual[argmax_winner] + L_individual[j]
            if lip > 0:
                argmax_margins.append(margin / lip)
    argmax_radius = min(argmax_margins) if argmax_margins else 0

    # Borda certified radius
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i][j] = np.sum(np.abs(weights[i] - weights[j]))
    borda_radius = certified_radius(S, K, n, borda_winner, x0)

    print(f"\nArgmax certified radius: {argmax_radius:.4f}")
    print(f"Borda certified radius:  {borda_radius:.4f}")
    print(f"Ratio (Borda/Argmax):    {borda_radius/argmax_radius:.4f}" if argmax_radius > 0 else "")

    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: margin profiles
    radii = np.linspace(0, max(argmax_radius, borda_radius) * 2.5, 200)

    ax1.set_title('Argmax Margins vs Perturbation', fontsize=12)
    for j in range(n):
        if j != argmax_winner:
            margin = raw_scores[argmax_winner] - raw_scores[j]
            lip = L_individual[argmax_winner] + L_individual[j]
            lower = margin - lip * radii
            ax1.plot(radii, lower, label=f'S_{argmax_winner} - S_{j}')
    ax1.axhline(y=0, color='red', linewidth=1.5, linestyle='-')
    ax1.axvline(x=argmax_radius, color='black', linewidth=1.5, linestyle='--',
                label=f'r* = {argmax_radius:.3f}')
    ax1.set_xlabel('Perturbation radius r')
    ax1.set_ylabel('Minimum margin')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    ax2.set_title('Pairwise Margins (Borda) vs Perturbation', fontsize=12)
    for j in range(n):
        if j != borda_winner:
            margin = pair_margin(S, borda_winner, j, x0)
            lip = K[borda_winner][j]
            lower = margin - lip * radii
            ax2.plot(radii, lower, label=f'Margin({borda_winner},{j})')
    ax2.axhline(y=0, color='red', linewidth=1.5, linestyle='-')
    ax2.axvline(x=borda_radius, color='black', linewidth=1.5, linestyle='--',
                label=f'r* = {borda_radius:.3f}')
    ax2.set_xlabel('Perturbation radius r')
    ax2.set_ylabel('Minimum pairwise margin')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Bridges/TropicalSatakeVoting/comparison_demo.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Comparison plot saved to Bridges/TropicalSatakeVoting/comparison_demo.png")


if __name__ == '__main__':
    demo_linear_classifier()
    demo_scaling()
    demo_comparison()
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
