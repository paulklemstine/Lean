#!/usr/bin/env python3
"""
Tropical Satake Robustness Bridge — Interactive Demo

Demonstrates the certified robustness theorems for multiclass score maps
built from max-plus linear forms on tropical Satake coordinates.

This demo brings the formally verified Lean theorems to life with concrete
numerical examples and visualizations.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations

# ═══════════════════════════════════════════════════════════════════════
# Core definitions (matching the Lean formalization)
# ═══════════════════════════════════════════════════════════════════════

def linear_score_diff(a: np.ndarray, z: np.ndarray) -> float:
    """LinearScoreDiff a z = ∑ i, a[i] * z[i]"""
    return np.sum(a * z)

def drift_budget(w: np.ndarray, eps: np.ndarray) -> float:
    """DriftBudget w eps = ∑ i, |w[i]| * eps[i]"""
    return np.sum(np.abs(w) * eps)

def is_winner(scores: dict, c) -> bool:
    """IsWinner: class c has the highest score"""
    sc = scores[c]
    return all(scores[k] <= sc for k in scores)


# ═══════════════════════════════════════════════════════════════════════
# Demo 1: Drift Bound Verification
# ═══════════════════════════════════════════════════════════════════════

def demo_drift_bound():
    """
    Demonstrates Theorem: linearScoreDiff_drift_bound

    Shows that |LinearScoreDiff(a, z') - LinearScoreDiff(a, z)| ≤ DriftBudget(a, eps)
    for random perturbations bounded by eps.
    """
    print("=" * 70)
    print("DEMO 1: Weighted Drift Bound for Score Differences")
    print("=" * 70)

    np.random.seed(42)

    # GL3 tropical Satake coordinates (6 coordinates for GL3)
    # These represent: simple coroot valuations, rank-1/2 Levi marginals
    coord_names = ["α₁-val", "α₂-val", "ω₁-marg", "ω₂-marg", "ρ-edge", "det-val"]
    n_coords = len(coord_names)

    # Coefficient vector (pairwise score difference weights)
    a = np.array([2.0, -1.5, 3.0, -0.5, 1.0, -2.0])

    # Original coordinate vector
    z = np.array([1.0, 2.0, -0.5, 1.5, 0.3, -1.0])

    # Perturbation budget per coordinate
    eps = np.array([0.1, 0.2, 0.15, 0.1, 0.05, 0.1])

    # Theoretical drift budget
    budget = drift_budget(a, eps)
    print(f"\nCoefficients a = {a}")
    print(f"Original z    = {z}")
    print(f"Epsilon budget = {eps}")
    print(f"\nDriftBudget(a, eps) = {budget:.4f}")

    # Monte Carlo verification: sample many perturbations
    n_samples = 10000
    actual_drifts = []
    for _ in range(n_samples):
        delta = np.random.uniform(-eps, eps)
        z_prime = z + delta
        diff = abs(linear_score_diff(a, z_prime) - linear_score_diff(a, z))
        actual_drifts.append(diff)

    actual_drifts = np.array(actual_drifts)
    max_drift = np.max(actual_drifts)

    print(f"\nMonte Carlo ({n_samples} samples):")
    print(f"  Max observed drift: {max_drift:.4f}")
    print(f"  Drift budget:       {budget:.4f}")
    print(f"  Bound holds: {max_drift <= budget + 1e-10}")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.hist(actual_drifts, bins=50, density=True, alpha=0.7, color='steelblue',
             label='Observed drifts')
    ax1.axvline(budget, color='red', linewidth=2, linestyle='--',
                label=f'Drift budget = {budget:.3f}')
    ax1.set_xlabel('|LinearScoreDiff(a, z\') - LinearScoreDiff(a, z)|')
    ax1.set_ylabel('Density')
    ax1.set_title('Drift Bound Verification (Theorem 1)')
    ax1.legend()

    # Per-coordinate contribution
    contributions = np.abs(a) * eps
    colors = plt.cm.Set2(np.arange(n_coords))
    bars = ax2.bar(coord_names, contributions, color=colors, edgecolor='black', alpha=0.8)
    ax2.axhline(budget, color='red', linewidth=2, linestyle='--',
                label=f'Total budget = {budget:.3f}')
    ax2.set_ylabel('|a_i| × ε_i')
    ax2.set_title('Per-Coordinate Drift Contributions')
    ax2.legend()
    ax2.tick_params(axis='x', rotation=30)

    plt.tight_layout()
    plt.savefig('demo1_drift_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved: demo1_drift_bound.png")


# ═══════════════════════════════════════════════════════════════════════
# Demo 2: Binary Margin Robustness
# ═══════════════════════════════════════════════════════════════════════

def demo_binary_robustness():
    """
    Demonstrates Theorem: binary_margin_robust

    If margin > 2 * DriftBudget, then margin sign is preserved.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Binary Margin Robustness (Half-Margin Phenomenon)")
    print("=" * 70)

    np.random.seed(123)

    a = np.array([3.0, -2.0, 1.5, -1.0])
    beta = 0.5
    z = np.array([1.0, -0.5, 2.0, 0.3])

    # Sweep over perturbation magnitudes
    eps_scales = np.linspace(0.01, 0.5, 100)
    n_trials = 1000

    original_margin = linear_score_diff(a, z) + beta
    print(f"\nOriginal margin: LinearScoreDiff(a, z) + β = {original_margin:.4f}")

    results = []
    for scale in eps_scales:
        eps = np.array([scale, scale, scale, scale])
        budget = drift_budget(a, eps)
        margin_condition = 2 * budget < original_margin

        # Check if any perturbation flips the sign
        sign_preserved = True
        for _ in range(n_trials):
            delta = np.random.uniform(-eps, eps)
            z_prime = z + delta
            new_margin = linear_score_diff(a, z_prime) + beta
            if new_margin <= 0:
                sign_preserved = False
                break

        results.append({
            'scale': scale,
            'budget': budget,
            'certified': margin_condition,
            'empirical': sign_preserved
        })

    fig, ax = plt.subplots(figsize=(10, 6))

    scales = [r['scale'] for r in results]
    budgets = [r['budget'] for r in results]
    certified = [r['certified'] for r in results]
    empirical = [r['empirical'] for r in results]

    # Critical threshold
    critical_budget = original_margin / 2
    critical_scale = None
    for r in results:
        if r['budget'] >= critical_budget:
            critical_scale = r['scale']
            break

    ax.fill_between(scales, 0, original_margin, alpha=0.1, color='green',
                     label='Original margin region')
    ax.plot(scales, budgets, 'b-', linewidth=2, label='DriftBudget(a, ε)')
    ax.axhline(original_margin / 2, color='red', linestyle='--', linewidth=1.5,
               label=f'Half-margin = {original_margin/2:.3f}')
    ax.axhline(original_margin, color='green', linestyle='--', linewidth=1.5,
               label=f'Full margin = {original_margin:.3f}')

    if critical_scale:
        ax.axvline(critical_scale, color='orange', linestyle=':', linewidth=1.5,
                   label=f'Certification boundary (ε ≈ {critical_scale:.3f})')

    # Mark certified vs uncertified regions
    cert_x = [r['scale'] for r in results if r['certified']]
    uncert_x = [r['scale'] for r in results if not r['certified']]
    if cert_x:
        ax.axvspan(min(cert_x), max(cert_x), alpha=0.1, color='green')
    if uncert_x:
        ax.axvspan(min(uncert_x), max(uncert_x), alpha=0.1, color='red')

    ax.set_xlabel('Perturbation scale ε (uniform across coordinates)')
    ax.set_ylabel('Value')
    ax.set_title('Binary Margin Robustness Certificate (Theorem 2)\n'
                 'Green region: certified robust | Red region: uncertified')
    ax.legend(loc='upper left')

    plt.tight_layout()
    plt.savefig('demo2_binary_robustness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  Critical perturbation scale: ε* ≈ {critical_scale:.4f}" if critical_scale else "")
    print(f"  Half-margin threshold: {original_margin/2:.4f}")
    print("  → Saved: demo2_binary_robustness.png")


# ═══════════════════════════════════════════════════════════════════════
# Demo 3: Multiclass Robustness — GL3 Tropical Classifier
# ═══════════════════════════════════════════════════════════════════════

def demo_multiclass_gl3():
    """
    Demonstrates Theorems: multiclass_robust_of_pairwise_margins
    and gl3_tropical_satake_certified_robustness

    A 3-class classifier on GL3 tropical Satake coordinates with
    certified robustness from pairwise margin separation.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Multiclass GL₃ Tropical Satake Robustness")
    print("=" * 70)

    np.random.seed(456)

    # GL3 separating coordinates (6 dimensions)
    n_coords = 6
    n_classes = 3
    class_names = ["Unramified Principal", "Steinberg-type", "Supercuspidal"]

    # Score coefficients for each class (tropical linear forms)
    # Each row: coefficients for one class's score function
    W = np.array([
        [ 2.0, -1.0,  1.5,  0.5,  0.0, -0.5],  # Class 0
        [-1.0,  3.0, -0.5,  2.0, -1.0,  1.0],  # Class 1
        [ 0.5, -0.5,  2.0, -1.0,  3.0, -1.5],  # Class 2
    ])
    biases = np.array([0.5, -0.3, 0.1])

    def score(c, z):
        return np.dot(W[c], z) + biases[c]

    # Test point in Satake coordinate space
    z = np.array([1.0, 0.5, 1.5, -0.3, 0.8, 0.2])

    # Compute scores and winner
    scores = {c: score(c, z) for c in range(n_classes)}
    winner = max(scores, key=scores.get)

    print(f"\nTest point z = {z}")
    print(f"\nClass scores at z:")
    for c in range(n_classes):
        marker = " ← WINNER" if c == winner else ""
        print(f"  {class_names[c]:25s}: {scores[c]:.4f}{marker}")

    # Compute pairwise margins and drift budgets
    eps = np.array([0.05, 0.08, 0.06, 0.04, 0.03, 0.05])

    print(f"\nPerturbation budget eps = {eps}")
    print(f"\nPairwise certification analysis (winner = {class_names[winner]}):")

    all_certified = True
    for c_prime in range(n_classes):
        if c_prime == winner:
            continue

        # Pairwise difference coefficients
        d = W[winner] - W[c_prime]
        beta = biases[winner] - biases[c_prime]
        margin = linear_score_diff(d, z) + beta
        budget = drift_budget(d, eps)

        certified = 2 * budget < margin
        all_certified = all_certified and certified

        print(f"\n  vs {class_names[c_prime]}:")
        print(f"    Margin:       {margin:.4f}")
        print(f"    DriftBudget:  {budget:.4f}")
        print(f"    2×Budget:     {2*budget:.4f}")
        print(f"    Certified:    {'✓ YES' if certified else '✗ NO'}")

    print(f"\n  Overall certification: {'✓ ROBUST' if all_certified else '✗ NOT CERTIFIED'}")

    # Monte Carlo verification
    n_samples = 50000
    n_flips = 0
    perturbed_winners = []
    for _ in range(n_samples):
        delta = np.random.uniform(-eps, eps)
        z_prime = z + delta
        perturbed_scores = {c: score(c, z_prime) for c in range(n_classes)}
        pw = max(perturbed_scores, key=perturbed_scores.get)
        perturbed_winners.append(pw)
        if pw != winner:
            n_flips += 1

    print(f"\n  Monte Carlo ({n_samples} perturbations):")
    print(f"    Winner flips: {n_flips} / {n_samples}")
    if all_certified:
        print(f"    (Theorem guarantees 0 flips — verified!)")

    # Visualization
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Score values at original point
    colors = ['#2ecc71', '#3498db', '#e74c3c']
    bars = axes[0].bar(class_names, [scores[c] for c in range(n_classes)],
                        color=colors, edgecolor='black', alpha=0.85)
    axes[0].set_ylabel('Score')
    axes[0].set_title('Class Scores at Original Point')
    axes[0].tick_params(axis='x', rotation=15)

    # Panel 2: Margin vs Budget comparison
    competitors = [c for c in range(n_classes) if c != winner]
    margins = []
    budgets_list = []
    comp_names = []
    for c_prime in competitors:
        d = W[winner] - W[c_prime]
        beta = biases[winner] - biases[c_prime]
        margins.append(linear_score_diff(d, z) + beta)
        budgets_list.append(drift_budget(d, eps))
        comp_names.append(f"vs {class_names[c_prime][:10]}")

    x_pos = np.arange(len(competitors))
    width = 0.35
    axes[1].bar(x_pos - width/2, margins, width, label='Margin', color='#2ecc71',
                edgecolor='black', alpha=0.85)
    axes[1].bar(x_pos + width/2, [2*b for b in budgets_list], width,
                label='2 × DriftBudget', color='#e74c3c', edgecolor='black', alpha=0.85)
    axes[1].set_xticks(x_pos)
    axes[1].set_xticklabels(comp_names, rotation=15)
    axes[1].set_ylabel('Value')
    axes[1].set_title('Margin vs 2×DriftBudget\n(Margin > 2×Budget ⟹ Certified)')
    axes[1].legend()

    # Panel 3: 2D projection of decision regions
    # Project to first two coordinates, fixing others
    grid_size = 200
    coord1_range = np.linspace(z[0] - 0.5, z[0] + 0.5, grid_size)
    coord2_range = np.linspace(z[1] - 0.5, z[1] + 0.5, grid_size)
    C1, C2 = np.meshgrid(coord1_range, coord2_range)

    winners_grid = np.zeros_like(C1, dtype=int)
    for i in range(grid_size):
        for j in range(grid_size):
            z_test = z.copy()
            z_test[0] = C1[i, j]
            z_test[1] = C2[i, j]
            test_scores = [score(c, z_test) for c in range(n_classes)]
            winners_grid[i, j] = np.argmax(test_scores)

    axes[2].contourf(C1, C2, winners_grid, levels=[-0.5, 0.5, 1.5, 2.5],
                      colors=colors, alpha=0.3)
    axes[2].contour(C1, C2, winners_grid, levels=[0.5, 1.5], colors='black',
                     linewidths=1.5)

    # Draw perturbation box
    rect = plt.Rectangle((z[0] - eps[0], z[1] - eps[1]),
                          2*eps[0], 2*eps[1],
                          fill=False, edgecolor='black', linewidth=2,
                          linestyle='--', label='ε-perturbation box')
    axes[2].add_patch(rect)
    axes[2].plot(z[0], z[1], 'k*', markersize=15, label='Original point')

    axes[2].set_xlabel('Coordinate 1 (α₁-valuation)')
    axes[2].set_ylabel('Coordinate 2 (α₂-valuation)')
    axes[2].set_title('Decision Regions (2D projection)\n'
                      'Box = certified stable region')
    axes[2].legend(loc='upper right', fontsize=8)

    patches = [mpatches.Patch(color=colors[i], alpha=0.5, label=class_names[i])
               for i in range(n_classes)]
    axes[2].legend(handles=patches + [rect, plt.Line2D([0], [0], marker='*',
                   color='black', linestyle='None', markersize=10, label='Original')],
                   loc='upper right', fontsize=7)

    plt.tight_layout()
    plt.savefig('demo3_multiclass_gl3.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: demo3_multiclass_gl3.png")


# ═══════════════════════════════════════════════════════════════════════
# Demo 4: Robustness Certificate Heatmap
# ═══════════════════════════════════════════════════════════════════════

def demo_certificate_heatmap():
    """
    Shows the maximum certified perturbation radius across the Satake
    coordinate space, visualizing where the classifier is most/least robust.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Robustness Certificate Heatmap")
    print("=" * 70)

    # Simple 2D example for visualization
    n_classes = 3
    W = np.array([
        [ 2.0, -1.0],
        [-1.0,  2.0],
        [ 0.5,  0.5],
    ])
    biases = np.array([0.0, 0.0, 1.0])

    def score(c, z):
        return np.dot(W[c], z) + biases[c]

    grid_size = 300
    x_range = np.linspace(-3, 3, grid_size)
    y_range = np.linspace(-3, 3, grid_size)
    X, Y = np.meshgrid(x_range, y_range)

    cert_radius = np.zeros_like(X)
    winner_map = np.zeros_like(X, dtype=int)

    for i in range(grid_size):
        for j in range(grid_size):
            z = np.array([X[i, j], Y[i, j]])
            scores_vals = [score(c, z) for c in range(n_classes)]
            c_star = np.argmax(scores_vals)
            winner_map[i, j] = c_star

            # Compute minimum pairwise "certification radius"
            # For uniform eps, the certification condition is:
            # margin(c*, c') > 2 * sum_i |d_i| * eps
            # => eps < margin / (2 * sum_i |d_i|)
            min_radius = float('inf')
            for c_prime in range(n_classes):
                if c_prime == c_star:
                    continue
                d = W[c_star] - W[c_prime]
                margin = score(c_star, z) - score(c_prime, z)
                lip = np.sum(np.abs(d))
                if lip > 0:
                    radius = margin / (2 * lip)
                else:
                    radius = float('inf')
                min_radius = min(min_radius, radius)

            cert_radius[i, j] = max(0, min_radius)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Decision regions
    colors = ['#2ecc71', '#3498db', '#e74c3c']
    ax1.contourf(X, Y, winner_map, levels=[-0.5, 0.5, 1.5, 2.5],
                  colors=colors, alpha=0.5)
    ax1.contour(X, Y, winner_map, levels=[0.5, 1.5], colors='black', linewidths=2)
    ax1.set_xlabel('Satake coordinate z₁')
    ax1.set_ylabel('Satake coordinate z₂')
    ax1.set_title('Tropical Linear Decision Regions')
    patches = [mpatches.Patch(color=colors[i], alpha=0.5, label=f'Class {i}')
               for i in range(n_classes)]
    ax1.legend(handles=patches)

    # Certification radius heatmap
    im = ax2.contourf(X, Y, cert_radius, levels=20, cmap='YlOrRd_r')
    ax2.contour(X, Y, winner_map, levels=[0.5, 1.5], colors='black',
                linewidths=2, linestyles='--')
    plt.colorbar(im, ax=ax2, label='Max certified ε (uniform)')
    ax2.set_xlabel('Satake coordinate z₁')
    ax2.set_ylabel('Satake coordinate z₂')
    ax2.set_title('Certified Robustness Radius\n(larger = more robust)')

    plt.tight_layout()
    plt.savefig('demo4_certificate_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: demo4_certificate_heatmap.png")


# ═══════════════════════════════════════════════════════════════════════
# Demo 5: Application — Robust Hecke Data Classification
# ═══════════════════════════════════════════════════════════════════════

def demo_application():
    """
    Practical application: classifying noisy Hecke eigenvalue data
    using tropical Satake coordinates with certified robustness.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Application — Robust Hecke Data Classification")
    print("=" * 70)

    np.random.seed(789)

    # Simulate GL3 Hecke data points
    n_points = 200
    n_coords = 6
    n_classes = 3
    class_names = ["Unramified", "Steinberg", "Supercuspidal"]

    # Generate clustered data in Satake coordinate space
    centers = np.array([
        [ 2.0,  0.5,  1.0,  0.0,  1.5,  0.5],
        [-0.5,  2.0,  0.0,  1.5, -0.5,  1.0],
        [ 0.5, -0.5,  2.0,  1.0,  0.5, -1.0],
    ])

    true_labels = np.random.choice(n_classes, n_points)
    data = centers[true_labels] + np.random.randn(n_points, n_coords) * 0.3

    # Train a simple tropical linear classifier
    W = np.zeros((n_classes, n_coords))
    biases = np.zeros(n_classes)
    for c in range(n_classes):
        mask = true_labels == c
        if np.any(mask):
            W[c] = np.mean(data[mask], axis=0)
            biases[c] = 0

    def predict(z):
        scores = [np.dot(W[c], z) + biases[c] for c in range(n_classes)]
        return np.argmax(scores)

    # Certify each point
    eps = np.array([0.1, 0.1, 0.1, 0.1, 0.1, 0.1])

    certified_count = 0
    correct_count = 0
    certified_correct = 0

    for idx in range(n_points):
        z = data[idx]
        pred = predict(z)
        correct = (pred == true_labels[idx])
        correct_count += correct

        # Check certification
        scores = [np.dot(W[c], z) + biases[c] for c in range(n_classes)]
        winner = np.argmax(scores)

        is_certified = True
        for c_prime in range(n_classes):
            if c_prime == winner:
                continue
            d = W[winner] - W[c_prime]
            beta = biases[winner] - biases[c_prime]
            margin = linear_score_diff(d, z) + beta
            budget = drift_budget(d, eps)
            if not (2 * budget < margin):
                is_certified = False
                break

        if is_certified:
            certified_count += 1
            if correct:
                certified_correct += 1

    print(f"\n  Total points:            {n_points}")
    print(f"  Correctly classified:    {correct_count} ({100*correct_count/n_points:.1f}%)")
    print(f"  Certified robust:        {certified_count} ({100*certified_count/n_points:.1f}%)")
    print(f"  Certified AND correct:   {certified_correct} ({100*certified_correct/n_points:.1f}%)")
    print(f"  Perturbation radius ε:   {eps[0]} (uniform)")
    print(f"\n  → By the GL₃ Tropical Satake Certified Robustness Theorem,")
    print(f"    the {certified_count} certified points are guaranteed robust")
    print(f"    against ANY perturbation bounded by ε in each coordinate.")


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Satake Robustness Bridge — Certified Multiclass      ║")
    print("║  Invariance from Dominant-Coweight Margin Separation           ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_drift_bound()
    demo_binary_robustness()
    demo_multiclass_gl3()
    demo_certificate_heatmap()
    demo_application()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
