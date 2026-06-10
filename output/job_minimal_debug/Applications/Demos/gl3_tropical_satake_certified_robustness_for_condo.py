#!/usr/bin/env python3
"""
Demonstration of GL₃ Tropical Satake Condorcet Robustness

This script illustrates the formally verified theorem: if one class is a Condorcet
winner by sufficient margin over all opponents, then it remains the unique Condorcet
winner under any perturbation that shifts pairwise gaps by less than that margin.

We demonstrate with concrete 3-class and 5-class examples, showing:
1. How pairwise score gaps define a tournament
2. How perturbation affects the tournament structure
3. The certified robustness radius from the theorem
4. Sharpness: a perturbation that breaks the winner when margin is insufficient
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations

# ──────────────────────────────────────────────────────
# Core definitions (matching the Lean formalization)
# ──────────────────────────────────────────────────────

def pairwise_gap(scores, c, j, x):
    """PairwiseGap s c j x = s(c, x) - s(j, x)"""
    return scores[c](x) - scores[j](x)


def is_condorcet_winner(scores, c, x, classes):
    """CondorcetWinner: c beats every other class in pairwise comparison."""
    return all(pairwise_gap(scores, c, j, x) > 0 for j in classes if j != c)


def min_margin(scores, c, x, classes):
    """Minimum pairwise gap from c to any opponent."""
    gaps = [pairwise_gap(scores, c, j, x) for j in classes if j != c]
    return min(gaps) if gaps else float('inf')


def max_gap_perturbation(scores, x, x_prime, classes):
    """Maximum absolute change in any pairwise gap."""
    max_pert = 0
    for i in classes:
        for j in classes:
            if i != j:
                g_orig = pairwise_gap(scores, i, j, x)
                g_pert = pairwise_gap(scores, i, j, x_prime)
                max_pert = max(max_pert, abs(g_pert - g_orig))
    return max_pert


# ──────────────────────────────────────────────────────
# Example 1: Three-class tournament with linear scores
# ──────────────────────────────────────────────────────

def demo_three_class():
    """
    Three classes with linear score functions on R^2.
    Class 0 is a clear Condorcet winner.
    """
    print("=" * 60)
    print("EXAMPLE 1: Three-Class Linear Tournament")
    print("=" * 60)

    # Score functions: s_c(x) = w_c · x + b_c
    weights = {
        0: np.array([3.0, 2.0]),   # Class 0 (strong)
        1: np.array([1.0, 1.5]),   # Class 1
        2: np.array([0.5, 1.0]),   # Class 2
    }
    biases = {0: 1.0, 1: 0.5, 2: 0.0}

    scores = {
        c: (lambda x, w=weights[c], b=biases[c]: np.dot(w, x) + b)
        for c in range(3)
    }
    classes = [0, 1, 2]
    x = np.array([1.0, 1.0])

    # Check Condorcet winner
    print(f"\nInput x = {x}")
    print(f"Scores: {[scores[c](x) for c in classes]}")
    print(f"\nPairwise gaps from class 0:")
    for j in [1, 2]:
        gap = pairwise_gap(scores, 0, j, x)
        print(f"  g(0, {j}) = {gap:.4f}")

    m = min_margin(scores, 0, x, classes)
    print(f"\nMinimum margin: m = {m:.4f}")
    print(f"Class 0 is Condorcet winner: {is_condorcet_winner(scores, 0, x, classes)}")

    # For linear scores, the gap perturbation is bounded by
    # |g(c,j,x') - g(c,j,x)| = |(w_c - w_j) · (x' - x)| ≤ ‖w_c - w_j‖₁ · ‖x' - x‖∞
    # The Lipschitz constant for each pair:
    lip_constants = {}
    for i in classes:
        for j in classes:
            if i != j:
                lip_constants[(i, j)] = np.sum(np.abs(weights[i] - weights[j]))

    K_max = max(lip_constants.values())
    print(f"\nMax Lipschitz constant (L1 of weight diff): K = {K_max:.4f}")
    print(f"Certified robustness radius: ε < m / K = {m / K_max:.4f}")

    # Demonstrate robustness within the radius
    epsilon = m / K_max * 0.9  # 90% of the critical radius
    print(f"\nTesting with ε = {epsilon:.4f} (90% of critical radius):")
    np.random.seed(42)
    n_tests = 1000
    all_robust = True
    for _ in range(n_tests):
        perturbation = np.random.uniform(-epsilon, epsilon, size=2)
        x_prime = x + perturbation
        if not is_condorcet_winner(scores, 0, x_prime, classes):
            all_robust = False
            break
    print(f"  Class 0 remains Condorcet winner in all {n_tests} trials: {all_robust}")

    # Show sharpness: perturbation just beyond critical radius
    epsilon_break = m / K_max * 1.1
    print(f"\nTesting with ε = {epsilon_break:.4f} (110% of critical radius):")
    broken = False
    for _ in range(n_tests):
        # Adversarial direction: maximize gap change for weakest opponent
        weakest_j = 1 if pairwise_gap(scores, 0, 1, x) < pairwise_gap(scores, 0, 2, x) else 2
        # Direction that maximizes (w_j - w_0) · perturbation
        diff = weights[weakest_j] - weights[0]
        direction = np.sign(diff) * epsilon_break
        x_prime = x + direction
        if not is_condorcet_winner(scores, 0, x_prime, classes):
            broken = True
            break
    print(f"  Found adversarial perturbation that breaks winner: {broken}")

    return scores, classes, x, m, K_max


def demo_visualization(scores, classes, x, m, K_max):
    """Visualize the robustness region and tournament structure."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Score landscape
    ax = axes[0]
    grid_x = np.linspace(-1, 3, 100)
    grid_y = np.linspace(-1, 3, 100)
    X, Y = np.meshgrid(grid_x, grid_y)

    # Color by argmax (Condorcet winner = argmax for linear scores)
    Z = np.zeros_like(X)
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            pt = np.array([X[i, j], Y[i, j]])
            s = [scores[c](pt) for c in classes]
            Z[i, j] = np.argmax(s)

    ax.contourf(X, Y, Z, levels=[-0.5, 0.5, 1.5, 2.5],
                colors=['#2196F3', '#FF9800', '#4CAF50'], alpha=0.3)
    ax.plot(*x, 'k*', markersize=15, label=f'x = ({x[0]}, {x[1]})')

    # Draw robustness ball
    r = m / K_max
    circle = plt.Circle(x, r, fill=False, color='red', linewidth=2,
                        linestyle='--', label=f'Cert. radius = {r:.3f}')
    ax.add_patch(circle)

    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_title('Score Regions & Certified Ball')
    ax.legend(fontsize=8)
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')

    # Panel 2: Tournament graph
    ax = axes[1]
    n = len(classes)
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False) + np.pi / 2
    pos = {c: (np.cos(a), np.sin(a)) for c, a in zip(classes, angles)}
    colors = ['#2196F3', '#FF9800', '#4CAF50']

    for c in classes:
        circle = plt.Circle(pos[c], 0.15, color=colors[c], alpha=0.8)
        ax.add_patch(circle)
        ax.text(*pos[c], str(c), ha='center', va='center',
                fontsize=14, fontweight='bold', color='white')

    for i, j in combinations(classes, 2):
        gap = pairwise_gap(scores, i, j, x)
        winner, loser = (i, j) if gap > 0 else (j, i)
        dx = pos[loser][0] - pos[winner][0]
        dy = pos[loser][1] - pos[winner][1]
        ax.annotate('', xy=(pos[loser][0] - 0.18 * dx / np.sqrt(dx**2 + dy**2),
                           pos[loser][1] - 0.18 * dy / np.sqrt(dx**2 + dy**2)),
                   xytext=(pos[winner][0] + 0.18 * dx / np.sqrt(dx**2 + dy**2),
                           pos[winner][1] + 0.18 * dy / np.sqrt(dx**2 + dy**2)),
                   arrowprops=dict(arrowstyle='->', lw=2, color='black'))
        mid_x = (pos[i][0] + pos[j][0]) / 2
        mid_y = (pos[i][1] + pos[j][1]) / 2
        ax.text(mid_x + 0.1, mid_y + 0.1, f'{abs(gap):.2f}',
                fontsize=9, ha='center', color='gray')

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Tournament at x (edge = margin)')

    # Panel 3: Margin vs perturbation
    ax = axes[2]
    epsilons = np.linspace(0, m / K_max * 1.5, 200)
    margins_after = []
    for eps in epsilons:
        # Worst-case margin after perturbation of size eps
        worst_margin = m - K_max * eps
        margins_after.append(worst_margin)

    ax.plot(epsilons, margins_after, 'b-', linewidth=2, label='Worst-case margin')
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.7, label='Critical threshold')
    ax.axvline(x=m / K_max, color='green', linestyle=':', alpha=0.7,
               label=f'Critical ε = {m/K_max:.3f}')
    ax.fill_between(epsilons, margins_after, 0,
                    where=[mg > 0 for mg in margins_after],
                    alpha=0.1, color='blue')

    ax.set_xlabel('Perturbation ε')
    ax.set_ylabel('Minimum margin after perturbation')
    ax.set_title('Robustness Certificate')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Bridges/GL3/condorcet_robustness_demo.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nVisualization saved to condorcet_robustness_demo.png")


# ──────────────────────────────────────────────────────
# Example 2: Five-class tournament (GL3-inspired)
# ──────────────────────────────────────────────────────

def demo_five_class_gl3():
    """
    Five classes with score functions mimicking tropical Satake structure.
    Demonstrates the GL3 certified robustness theorem with explicit constants.
    """
    print("\n" + "=" * 60)
    print("EXAMPLE 2: Five-Class GL₃ Tropical Satake Tournament")
    print("=" * 60)

    d = 3       # dimension parameter (GL3)
    K = 1.5     # Lipschitz constant
    dim = 4     # input dimension

    # Score functions with tropical-inspired structure
    # s_c(x) = max over weight vectors (simulating tropical Satake scores)
    np.random.seed(123)
    weight_matrices = {}
    for c in range(5):
        weight_matrices[c] = np.random.randn(3, dim) + (2.0 if c == 0 else 0.0)

    def tropical_score(c, x):
        # max of affine functions (tropical polynomial)
        return np.max(weight_matrices[c] @ x)

    scores = {c: (lambda x, c=c: tropical_score(c, x)) for c in range(5)}
    classes = list(range(5))
    x = np.ones(dim)

    print(f"\nInput dimension: {dim}")
    print(f"Number of classes: 5")
    print(f"GL3 parameters: K = {K}, d = {d}")
    print(f"\nScores at x = {x}:")
    for c in classes:
        print(f"  s_{c}(x) = {scores[c](x):.4f}")

    print(f"\nPairwise gap matrix (row beats column):")
    print(f"{'':>6}", end='')
    for j in classes:
        print(f"  c={j:>4}", end='')
    print()
    for i in classes:
        print(f"c={i:>2}:", end='')
        for j in classes:
            if i == j:
                print(f"{'---':>8}", end='')
            else:
                gap = pairwise_gap(scores, i, j, x)
                print(f"{gap:>8.3f}", end='')
        print()

    m = min_margin(scores, 0, x, classes)
    print(f"\nMinimum margin from class 0: m = {m:.4f}")
    print(f"Class 0 is Condorcet winner: {is_condorcet_winner(scores, 0, x, classes)}")

    if m > 0:
        # GL3 certified radius
        delta = 2 * K * d
        epsilon_cert = m / delta
        print(f"\nGL₃ perturbation bound: δ = 2Kd·ε = {delta}·ε")
        print(f"Certified robustness radius: ε < m/(2Kd) = {epsilon_cert:.4f}")

        # Monte Carlo verification
        np.random.seed(42)
        n_tests = 2000
        eps_test = epsilon_cert * 0.5
        all_robust = True
        for _ in range(n_tests):
            pert = np.random.uniform(-eps_test, eps_test, size=dim)
            x_prime = x + pert
            if not is_condorcet_winner(scores, 0, x_prime, classes):
                all_robust = False
                break
        print(f"\nMonte Carlo ({n_tests} trials, ε = {eps_test:.4f}):")
        print(f"  Class 0 remains winner: {all_robust}")


# ──────────────────────────────────────────────────────
# Example 3: Sharpness demonstration
# ──────────────────────────────────────────────────────

def demo_sharpness():
    """
    Demonstrate that the margin threshold is sharp:
    when margin = δ, an adversary can flip the tournament outcome.
    """
    print("\n" + "=" * 60)
    print("EXAMPLE 3: Sharpness of the Margin Threshold")
    print("=" * 60)

    # Two very close classes and one distant class
    scores = {
        0: lambda x: 2.0 * x[0] + 1.0 * x[1] + 0.5,
        1: lambda x: 1.9 * x[0] + 1.1 * x[1] + 0.45,  # Very close to class 0
        2: lambda x: 0.5 * x[0] + 0.5 * x[1],
    }
    classes = [0, 1, 2]
    x = np.array([1.0, 1.0])

    m = min_margin(scores, 0, x, classes)
    print(f"\nInput x = {x}")
    print(f"Scores: {[scores[c](x) for c in classes]}")
    print(f"Min margin from class 0: m = {m:.4f}")

    # The gap between class 0 and class 1 is small
    g01 = pairwise_gap(scores, 0, 1, x)
    print(f"Gap(0,1) = {g01:.4f} (this is the weak link)")
    print(f"Gap(0,2) = {pairwise_gap(scores, 0, 2, x):.4f}")

    # Find perturbation that flips g(0,1)
    # g(0,1,x') = (2.0 - 1.9)(x'_0) + (1.0 - 1.1)(x'_1) + (0.5 - 0.45)
    #           = 0.1 x'_0 - 0.1 x'_1 + 0.05
    # To make this ≤ 0: need 0.1 x'_0 - 0.1 x'_1 ≤ -0.05
    # i.e., x'_0 - x'_1 ≤ -0.5
    # From x = (1,1), perturb to x' = (1 - 0.25, 1 + 0.25) = (0.75, 1.25)
    # g(0,1,x') = 0.1(0.75) - 0.1(1.25) + 0.05 = 0.075 - 0.125 + 0.05 = 0

    x_adv = np.array([0.75, 1.25])
    print(f"\nAdversarial x' = {x_adv} (‖x'-x‖∞ = {np.max(np.abs(x_adv - x)):.4f})")
    print(f"Gap(0,1) at x' = {pairwise_gap(scores, 0, 1, x_adv):.4f}")
    print(f"Class 0 still Condorcet winner at x': {is_condorcet_winner(scores, 0, x_adv, classes)}")

    # Slightly larger perturbation
    x_adv2 = np.array([0.7, 1.3])
    print(f"\nLarger adversarial x' = {x_adv2} (‖x'-x‖∞ = {np.max(np.abs(x_adv2 - x)):.4f})")
    print(f"Gap(0,1) at x' = {pairwise_gap(scores, 0, 1, x_adv2):.4f}")
    print(f"Class 0 still Condorcet winner at x': {is_condorcet_winner(scores, 0, x_adv2, classes)}")

    # This matches the formal theorem not_condorcetStable_of_small_margin:
    # the margin g(0,1,x) = 0.05 is small, and the adversary can make g(0,1,x') ≤ 0
    print(f"\n→ This demonstrates the sharpness theorem:")
    print(f"  When the margin ({g01:.4f}) is small relative to the perturbation budget,")
    print(f"  the Condorcet winner can be overturned.")


# ──────────────────────────────────────────────────────
# Example 4: Application to classifier robustness
# ──────────────────────────────────────────────────────

def demo_application():
    """
    Practical application: certifying a multiclass neural network prediction
    against adversarial perturbation using Condorcet tournament structure.
    """
    print("\n" + "=" * 60)
    print("EXAMPLE 4: Certified Adversarial Robustness for Classifiers")
    print("=" * 60)

    # Simulate a 10-class classifier (e.g., MNIST digits)
    np.random.seed(456)
    n_classes = 10
    dim = 20

    # Generate "logit" functions (linear approximation around a point)
    W = np.random.randn(n_classes, dim)
    # Make class 3 clearly dominant
    W[3] += 1.5
    b = np.random.randn(n_classes) * 0.5
    b[3] += 2.0

    scores = {c: (lambda x, c=c: W[c] @ x + b[c]) for c in range(n_classes)}
    classes = list(range(n_classes))
    x = np.random.randn(dim)

    predicted = max(classes, key=lambda c: scores[c](x))
    print(f"\nPredicted class: {predicted}")
    print(f"Is Condorcet winner: {is_condorcet_winner(scores, predicted, x, classes)}")

    m = min_margin(scores, predicted, x, classes)
    print(f"Minimum margin: {m:.4f}")

    # Compute Lipschitz constants for all pairs
    max_lip = 0
    for i in classes:
        for j in classes:
            if i != j:
                lip = np.sum(np.abs(W[i] - W[j]))  # L1 norm of weight difference
                max_lip = max(max_lip, lip)

    epsilon_cert = m / max_lip if m > 0 else 0
    print(f"Max Lipschitz constant: {max_lip:.4f}")
    print(f"Certified robustness radius (L∞): ε = {epsilon_cert:.6f}")

    # Verify with random perturbations
    n_tests = 5000
    eps_test = epsilon_cert * 0.99
    robust_count = 0
    for _ in range(n_tests):
        pert = np.random.uniform(-eps_test, eps_test, size=dim)
        x_prime = x + pert
        if is_condorcet_winner(scores, predicted, x_prime, classes):
            robust_count += 1

    print(f"\nEmpirical verification ({n_tests} random perturbations at ε = {eps_test:.6f}):")
    print(f"  Winner preserved: {robust_count}/{n_tests} ({100*robust_count/n_tests:.1f}%)")
    print(f"  (Theorem guarantees 100% — any failure would be a bug)")

    # Compare with simple argmax robustness
    print(f"\nComparison:")
    print(f"  Condorcet robustness radius: {epsilon_cert:.6f}")
    # For argmax, the radius is determined by the smallest gap to any class
    argmax_radius = m / max_lip
    print(f"  Argmax robustness radius:    {argmax_radius:.6f}")
    print(f"  (For linear scores, these coincide — the difference emerges")
    print(f"   with nonlinear score functions where tournament structure matters)")


if __name__ == '__main__':
    scores, classes, x, m, K_max = demo_three_class()
    try:
        demo_visualization(scores, classes, x, m, K_max)
    except Exception as e:
        print(f"\nVisualization skipped: {e}")

    demo_five_class_gl3()
    demo_sharpness()
    demo_application()

    print("\n" + "=" * 60)
    print("All demonstrations completed.")
    print("=" * 60)
