#!/usr/bin/env python3
"""
Tropical Certified Robustness for Ordered Top-2 Decisions
=========================================================

This demo illustrates the formally verified theorem: for a multiclass classifier
with C ≥ 3 classes and Lipschitz score functions, the ordered top-2 decision
(winner + runner-up identity) is provably stable under L∞ perturbations
within a computable certified radius.

Key idea: The ordered top-2 decision (a, b) is determined by finitely many
strict inequalities on score differences. The minimum slack over these
inequalities — the "ordered top-2 margin" — divided by the effective
Lipschitz constant gives a certified radius of robustness.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches


# ============================================================
# Core definitions matching the Lean formalization
# ============================================================

def score_diff(f, i, j, x):
    """scoreDiff: f_i(x) - f_j(x)"""
    return f[i](x) - f[j](x)


def is_ordered_top2(f, a, b, x, C):
    """
    Check the IsOrderedTop2 predicate:
    - a ≠ b
    - f_a(x) > f_j(x) for all j ≠ a  (a is unique winner)
    - f_b(x) > f_j(x) for all j ≠ a, j ≠ b  (b is unique runner-up)
    """
    if a == b:
        return False
    scores = np.array([f[i](x) for i in range(C)])
    for j in range(C):
        if j != a and scores[a] <= scores[j]:
            return False
    for j in range(C):
        if j != a and j != b and scores[b] <= scores[j]:
            return False
    return True


def winner_margin(f, a, x, C):
    """Minimum gap between winner a and all other classes."""
    gaps = [f[a](x) - f[j](x) for j in range(C) if j != a]
    return min(gaps)


def runner_up_margin(f, a, b, x, C):
    """Minimum gap between runner-up b and all classes except a and b."""
    gaps = [f[b](x) - f[j](x) for j in range(C) if j != a and j != b]
    if not gaps:
        return float('inf')
    return min(gaps)


def ordered_top2_margin(f, a, b, x, C):
    """The ordered top-2 margin: min of winner and runner-up margins."""
    return min(winner_margin(f, a, x, C), runner_up_margin(f, a, b, x, C))


def certified_radius(f, a, b, x, C, K_eff):
    """Certified L∞ radius for ordered top-2 stability."""
    margin = ordered_top2_margin(f, a, b, x, C)
    if K_eff <= 0:
        return float('inf') if margin > 0 else 0.0
    return margin / K_eff


# ============================================================
# Demo 1: Linear classifier with 4 classes in 2D
# ============================================================

def demo_linear_classifier():
    print("=" * 70)
    print("Demo 1: Linear Classifier with 4 Classes in 2D")
    print("=" * 70)

    C, d = 4, 2
    W = np.array([[2.0, 1.0], [-1.0, 2.0], [-1.0, -1.5], [1.5, -2.0]])
    biases = np.array([0.0, 0.5, -0.3, 0.2])
    f = {i: (lambda x, i=i: W[i] @ x + biases[i]) for i in range(C)}

    x0 = np.array([1.0, 0.5])
    scores = np.array([f[i](x0) for i in range(C)])
    print(f"\nTest point: x = {x0}")
    print(f"Scores: {scores}")

    sorted_idx = np.argsort(-scores)
    a, b = sorted_idx[0], sorted_idx[1]
    print(f"Winner (a) = class {a}, Runner-up (b) = class {b}")
    print(f"Verified IsOrderedTop2: {is_ordered_top2(f, a, b, x0, C)}")

    w_margin = winner_margin(f, a, x0, C)
    r_margin = runner_up_margin(f, a, b, x0, C)
    margin = ordered_top2_margin(f, a, b, x0, C)
    print(f"\nWinner margin:    {w_margin:.4f}")
    print(f"Runner-up margin: {r_margin:.4f}")
    print(f"Ordered top-2 margin: {margin:.4f}")

    K_eff = max(np.sum(np.abs(W[i] - W[j])) for i in range(C) for j in range(C) if i != j)
    print(f"Effective Lipschitz constant K_eff = {K_eff:.4f}")

    radius = certified_radius(f, a, b, x0, C, K_eff)
    print(f"Certified L∞ radius: {radius:.4f}")

    # Empirical verification
    n_samples = 10000
    violations = 0
    for _ in range(n_samples):
        delta = np.random.uniform(-radius * 0.999, radius * 0.999, size=d)
        if not is_ordered_top2(f, a, b, x0 + delta, C):
            violations += 1
    print(f"\nEmpirical verification: {violations}/{n_samples} violations within certified ball")

    # ---- Visualization ----
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    ax = axes[0]
    grid_size = 200
    xx, yy = np.meshgrid(np.linspace(-2, 3, grid_size), np.linspace(-2, 3, grid_size))
    grid_points = np.column_stack([xx.ravel(), yy.ravel()])

    top2_labels = np.zeros(len(grid_points))
    for idx, pt in enumerate(grid_points):
        scores_pt = np.array([f[i](pt) for i in range(C)])
        si = np.argsort(-scores_pt)
        top2_labels[idx] = si[0] * C + si[1]

    top2_grid = top2_labels.reshape(xx.shape)
    unique_labels = np.unique(top2_labels)
    cmap = plt.cm.get_cmap('tab20', len(unique_labels))

    ax.contourf(xx, yy, top2_grid, levels=len(unique_labels), cmap=cmap, alpha=0.3)
    ax.contour(xx, yy, top2_grid, levels=len(unique_labels), colors='gray', linewidths=0.5)

    rect = patches.Rectangle(
        (x0[0] - radius, x0[1] - radius), 2 * radius, 2 * radius,
        linewidth=2, edgecolor='red', facecolor='red', alpha=0.15,
        label=f'Certified L∞ ball (r={radius:.3f})'
    )
    ax.add_patch(rect)
    ax.plot(*x0, 'r*', markersize=15, label=f'Test point, top-2=({a},{b})')

    ax.set_xlabel('$x_1$', fontsize=12)
    ax.set_ylabel('$x_2$', fontsize=12)
    ax.set_title('Ordered Top-2 Decision Regions\nwith Certified Robustness Ball', fontsize=13)
    ax.legend(fontsize=10, loc='lower right')
    ax.set_xlim(-2, 3)
    ax.set_ylim(-2, 3)

    # Plot 2: Score gaps vs perturbation
    ax2 = axes[1]
    epsilons = np.linspace(0, radius * 1.5, 200)
    winner_gaps_worst = []
    runner_gaps_worst = []
    for eps in epsilons:
        worst_wg = float('inf')
        worst_rg = float('inf')
        for direction in [np.array([1, 0]), np.array([-1, 0]),
                         np.array([0, 1]), np.array([0, -1]),
                         np.array([1, 1])/np.sqrt(2), np.array([-1, -1])/np.sqrt(2),
                         np.array([1, -1])/np.sqrt(2), np.array([-1, 1])/np.sqrt(2)]:
            delta = eps * direction / max(np.max(np.abs(direction)), 1e-10)
            x_pert = x0 + delta
            wg = winner_margin(f, a, x_pert, C)
            rg = runner_up_margin(f, a, b, x_pert, C)
            worst_wg = min(worst_wg, wg)
            worst_rg = min(worst_rg, rg)
        winner_gaps_worst.append(worst_wg)
        runner_gaps_worst.append(worst_rg)

    ax2.plot(epsilons, winner_gaps_worst, 'b-', linewidth=2, label='Winner margin (worst)')
    ax2.plot(epsilons, runner_gaps_worst, 'g-', linewidth=2, label='Runner-up margin (worst)')
    ax2.axhline(y=0, color='k', linewidth=0.5)
    ax2.axvline(x=radius, color='r', linewidth=2, linestyle='--',
                label=f'Certified radius = {radius:.3f}')
    ax2.fill_between(epsilons, 0, [min(w, r) for w, r in zip(winner_gaps_worst, runner_gaps_worst)],
                     where=[min(w, r) > 0 for w, r in zip(winner_gaps_worst, runner_gaps_worst)],
                     alpha=0.1, color='green')

    ax2.set_xlabel('Perturbation magnitude $\\|\\delta\\|_\\infty$', fontsize=12)
    ax2.set_ylabel('Score gap', fontsize=12)
    ax2.set_title('Score Margins vs Perturbation Size\n(Robustness = gaps stay positive)', fontsize=13)
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('demos/fig_linear_classifier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Figure saved: demos/fig_linear_classifier.png")


# ============================================================
# Demo 2: ReLU network with 3 classes
# ============================================================

def demo_relu_network():
    print("\n" + "=" * 70)
    print("Demo 2: ReLU Network with 3 Classes in 2D")
    print("=" * 70)

    C, d = 3, 2
    np.random.seed(42)

    hidden_dim = 8
    W1 = np.random.randn(hidden_dim, d) * 0.8
    b1 = np.random.randn(hidden_dim) * 0.3
    W2 = np.random.randn(C, hidden_dim) * 0.5
    b2 = np.random.randn(C) * 0.2

    def network(x):
        h = np.maximum(0, W1 @ x + b1)
        return W2 @ h + b2

    f = {i: (lambda x, i=i: network(x)[i]) for i in range(C)}

    x0 = np.array([0.8, 0.3])
    scores = network(x0)
    print(f"\nTest point: x = {x0}")
    print(f"Scores: {scores}")

    sorted_idx = np.argsort(-scores)
    a, b = sorted_idx[0], sorted_idx[1]
    print(f"Winner (a) = class {a}, Runner-up (b) = class {b}")

    K1 = np.max(np.sum(np.abs(W1), axis=1))
    K2 = np.max(np.sum(np.abs(W2), axis=1))
    K_eff = 2 * K2 * K1

    margin = ordered_top2_margin(f, a, b, x0, C)
    radius = certified_radius(f, a, b, x0, C, K_eff)

    print(f"\nMargins:")
    print(f"  Winner margin:    {winner_margin(f, a, x0, C):.4f}")
    print(f"  Runner-up margin: {runner_up_margin(f, a, b, x0, C):.4f}")
    print(f"  Ordered top-2 margin: {margin:.4f}")
    print(f"Lipschitz constant K_eff = {K_eff:.4f}")
    print(f"Certified L∞ radius: {radius:.6f}")

    n_samples = 20000
    violations = 0
    for _ in range(n_samples):
        delta = np.random.uniform(-radius * 0.999, radius * 0.999, size=d)
        if not is_ordered_top2(f, a, b, x0 + delta, C):
            violations += 1
    print(f"\nEmpirical verification: {violations}/{n_samples} violations within certified ball")

    fig, ax = plt.subplots(1, 1, figsize=(9, 8))
    grid_size = 300
    xmin, xmax = x0[0] - 2, x0[0] + 2
    ymin, ymax = x0[1] - 2, x0[1] + 2
    xx, yy = np.meshgrid(np.linspace(xmin, xmax, grid_size),
                         np.linspace(ymin, ymax, grid_size))

    top2_labels = np.zeros(xx.size)
    for idx in range(xx.size):
        pt = np.array([xx.ravel()[idx], yy.ravel()[idx]])
        s = network(pt)
        si = np.argsort(-s)
        top2_labels[idx] = si[0] * C + si[1]

    top2_grid = top2_labels.reshape(xx.shape)
    n_regions = len(np.unique(top2_labels))
    cmap = plt.cm.get_cmap('Set3', n_regions)
    ax.contourf(xx, yy, top2_grid, levels=n_regions, cmap=cmap, alpha=0.4)
    ax.contour(xx, yy, top2_grid, levels=n_regions, colors='gray', linewidths=0.5)

    rect = patches.Rectangle(
        (x0[0] - radius, x0[1] - radius), 2 * radius, 2 * radius,
        linewidth=2.5, edgecolor='red', facecolor='red', alpha=0.15
    )
    ax.add_patch(rect)
    ax.plot(*x0, 'r*', markersize=18, zorder=5)

    ax.set_xlabel('$x_1$', fontsize=13)
    ax.set_ylabel('$x_2$', fontsize=13)
    ax.set_title(f'ReLU Network: Ordered Top-2 Regions\n'
                 f'Winner={a}, Runner-up={b}, Certified radius={radius:.4f}', fontsize=14)

    plt.tight_layout()
    plt.savefig('demos/fig_relu_network.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Figure saved: demos/fig_relu_network.png")


# ============================================================
# Demo 3: Comparison of robustness certificates
# ============================================================

def demo_comparison():
    print("\n" + "=" * 70)
    print("Demo 3: Argmax vs Ordered Top-2 vs Full Ranking Robustness")
    print("=" * 70)

    C, d = 5, 2
    np.random.seed(123)

    W = np.random.randn(C, d)
    biases = np.random.randn(C) * 0.5
    f = {i: (lambda x, i=i: W[i] @ x + biases[i]) for i in range(C)}

    K_eff = max(np.sum(np.abs(W[i] - W[j])) for i in range(C) for j in range(C) if i != j)

    n_points = 500
    argmax_radii = []
    top2_radii = []
    full_rank_radii = []

    for _ in range(n_points):
        x = np.random.randn(d) * 2
        scores = np.array([f[i](x) for i in range(C)])
        ranking = np.argsort(-scores)

        if any(scores[ranking[i]] == scores[ranking[i+1]] for i in range(C-1)):
            continue

        a, b_idx = ranking[0], ranking[1]

        argmax_margin = min(scores[a] - scores[j] for j in range(C) if j != a)
        argmax_r = argmax_margin / K_eff
        top2_r = certified_radius(f, a, b_idx, x, C, K_eff)
        full_gaps = [scores[ranking[i]] - scores[ranking[i+1]] for i in range(C-1)]
        full_r = min(full_gaps) / K_eff

        argmax_radii.append(argmax_r)
        top2_radii.append(top2_r)
        full_rank_radii.append(full_r)

    argmax_radii = np.array(argmax_radii)
    top2_radii = np.array(top2_radii)
    full_rank_radii = np.array(full_rank_radii)

    print(f"\nStatistics over {len(argmax_radii)} test points:")
    print(f"{'Certificate':<20} {'Mean radius':<15} {'Median':<15} {'Min':<15}")
    print(f"{'Argmax only':<20} {np.mean(argmax_radii):<15.4f} {np.median(argmax_radii):<15.4f} {np.min(argmax_radii):<15.4f}")
    print(f"{'Ordered top-2':<20} {np.mean(top2_radii):<15.4f} {np.median(top2_radii):<15.4f} {np.min(top2_radii):<15.4f}")
    print(f"{'Full ranking':<20} {np.mean(full_rank_radii):<15.4f} {np.median(full_rank_radii):<15.4f} {np.min(full_rank_radii):<15.4f}")

    assert np.all(full_rank_radii <= top2_radii + 1e-10)
    assert np.all(top2_radii <= argmax_radii + 1e-10)
    print("\n✓ Confirmed: full_ranking_radius ≤ top2_radius ≤ argmax_radius (always)")

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax = axes[0]
    ax.scatter(argmax_radii, top2_radii, alpha=0.3, s=10, c='blue', label='Top-2 vs Argmax')
    ax.scatter(argmax_radii, full_rank_radii, alpha=0.3, s=10, c='orange', label='Full vs Argmax')
    lim = max(np.max(argmax_radii), np.max(top2_radii)) * 1.1
    ax.plot([0, lim], [0, lim], 'k--', linewidth=1, label='y = x')
    ax.set_xlabel('Argmax certified radius', fontsize=12)
    ax.set_ylabel('Certified radius', fontsize=12)
    ax.set_title('Robustness Certificate Comparison', fontsize=13)
    ax.legend(fontsize=10)

    ax2 = axes[1]
    ratio_top2 = top2_radii / (argmax_radii + 1e-10)
    ratio_full = full_rank_radii / (argmax_radii + 1e-10)
    ax2.hist(ratio_top2, bins=40, alpha=0.6, label='Top-2 / Argmax', color='blue')
    ax2.hist(ratio_full, bins=40, alpha=0.6, label='Full / Argmax', color='orange')
    ax2.axvline(x=1.0, color='k', linestyle='--', linewidth=1)
    ax2.set_xlabel('Radius ratio (relative to argmax)', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Radius Ratios', fontsize=13)
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('demos/fig_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Figure saved: demos/fig_comparison.png")


# ============================================================
# Demo 4: Selective classification application
# ============================================================

def demo_selective_classification():
    print("\n" + "=" * 70)
    print("Demo 4: Selective Classification with Ordered Top-2 Certificates")
    print("=" * 70)

    C, d = 10, 50
    np.random.seed(7)

    W = np.random.randn(C, d) * 0.3
    b = np.random.randn(C) * 0.1
    f = {i: (lambda x, i=i: W[i] @ x + b[i]) for i in range(C)}

    K_eff = max(np.sum(np.abs(W[i] - W[j])) for i in range(C) for j in range(C) if i != j)

    class_names = ['cat', 'dog', 'bird', 'car', 'truck',
                   'plane', 'ship', 'horse', 'deer', 'frog']

    groups = {
        'animal': {0, 1, 2, 7, 8, 9},
        'vehicle': {3, 4, 5, 6},
    }

    def get_group(cls_id):
        for name, members in groups.items():
            if cls_id in members:
                return name
        return 'unknown'

    n_test = 20
    print(f"\n{'Input':<8} {'Winner':<10} {'Runner-up':<10} {'Margin':<10} "
          f"{'Radius':<10} {'Same grp?':<10} {'Decision'}")
    print("-" * 78)

    for t in range(n_test):
        x = np.random.randn(d) * 1.5
        scores = np.array([f[i](x) for i in range(C)])
        ranking = np.argsort(-scores)
        a, b_idx = ranking[0], ranking[1]

        margin = ordered_top2_margin(f, a, b_idx, x, C)
        radius = margin / K_eff

        same_group = get_group(a) == get_group(b_idx)

        if radius > 0.05:
            if same_group:
                decision = f"CONFIDENT ({get_group(a)})"
            else:
                decision = "ABSTAIN (cross-group)"
        else:
            decision = "ABSTAIN (low margin)"

        print(f"x_{t:<5} {class_names[a]:<10} {class_names[b_idx]:<10} "
              f"{margin:<10.4f} {radius:<10.4f} {'Yes' if same_group else 'No':<10} {decision}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Certified Robustness for Ordered Top-2 Decisions     ║")
    print("║  Companion demos for the formally verified Lean 4 theorems     ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_linear_classifier()
    demo_relu_network()
    demo_comparison()
    demo_selective_classification()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
