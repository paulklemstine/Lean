#!/usr/bin/env python3
"""
GL3 Tropical Satake Certified Robustness for IRV Classifiers — Demonstration

This script demonstrates the certified robustness theory for instant-runoff
voting (IRV) classifiers with concrete numerical examples and visualizations.

The core theorem: if every round of IRV elimination has a score gap ≥ γ
between the loser and the runner-up, then any uniform perturbation of scores
by at most ε (with 2ε < γ) preserves the entire elimination order and hence
the winner.

When the scores come from a K-Lipschitz map (e.g., a tropical/GL3 Satake
score map), the certified robustness radius is r = γ / (2K) in L∞ input space.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations


# ─── Core IRV Functions ───────────────────────────────────────────────────────

def irv_elimination_order(v):
    """
    Compute the IRV elimination order on score vector v.
    Returns a list [first_eliminated, ..., winner].
    """
    m = len(v)
    active = list(range(m))
    order = []
    for _ in range(m - 1):
        # Find the candidate with minimum score among active
        loser = min(active, key=lambda i: v[i])
        order.append(loser)
        active.remove(loser)
    order.append(active[0])  # winner
    return order


def irv_winner(v):
    """Return the IRV winner (last surviving candidate)."""
    return irv_elimination_order(v)[-1]


def round_gaps(v):
    """
    Compute the gap at each elimination round.
    Returns list of (loser, gap) for each round.
    """
    m = len(v)
    active = list(range(m))
    gaps = []
    for _ in range(m - 1):
        scores = [(v[i], i) for i in active]
        scores.sort()
        loser = scores[0][1]
        gap = scores[1][0] - scores[0][0] if len(scores) > 1 else float('inf')
        gaps.append((loser, gap))
        active.remove(loser)
    return gaps


def min_round_gap(v):
    """Minimum gap across all elimination rounds."""
    gaps = round_gaps(v)
    return min(g for _, g in gaps)


def certified_radius(v, K):
    """
    Certified L∞ robustness radius for a K-Lipschitz score map.
    Any input perturbation within this radius preserves the IRV winner.
    """
    gamma = min_round_gap(v)
    return gamma / (2 * K)


# ─── Example 1: Basic 4-candidate IRV ─────────────────────────────────────────

def example_basic():
    print("=" * 70)
    print("Example 1: Basic 4-candidate IRV with certified robustness")
    print("=" * 70)

    # Score vector for 4 candidates
    v = np.array([1.0, 3.5, 2.0, 5.0])
    m = len(v)
    candidate_names = ['A', 'B', 'C', 'D']

    print(f"\nScores: {dict(zip(candidate_names, v))}")

    order = irv_elimination_order(v)
    gaps = round_gaps(v)

    print("\nElimination order:")
    for round_num, (loser, gap) in enumerate(gaps, 1):
        print(f"  Round {round_num}: Eliminate {candidate_names[loser]} "
              f"(score {v[loser]:.2f}, gap to runner-up: {gap:.2f})")
    print(f"  Winner: {candidate_names[order[-1]]}")

    gamma = min_round_gap(v)
    print(f"\nMinimum round gap γ = {gamma:.4f}")
    print(f"Certified score perturbation budget ε < γ/2 = {gamma/2:.4f}")

    # Test with random perturbations
    K = 2.0  # Lipschitz constant
    r = certified_radius(v, K)
    print(f"\nFor K={K} Lipschitz score map:")
    print(f"  Certified L∞ input radius r = γ/(2K) = {r:.4f}")

    n_trials = 10000
    n_failures = 0
    original_winner = irv_winner(v)

    for _ in range(n_trials):
        # Perturb within certified radius
        eps = gamma / 2 * 0.99  # just inside the certified bound
        delta = np.random.uniform(-eps, eps, m)
        v_perturbed = v + delta
        if irv_winner(v_perturbed) != original_winner:
            n_failures += 1

    print(f"\n  Tested {n_trials} random perturbations within certified radius:")
    print(f"  Winner changes: {n_failures} (expected: 0)")

    # Now test outside certified radius
    n_failures_outside = 0
    for _ in range(n_trials):
        eps = gamma  # well outside certified bound (2ε = 2γ > γ)
        delta = np.random.uniform(-eps, eps, m)
        v_perturbed = v + delta
        if irv_winner(v_perturbed) != original_winner:
            n_failures_outside += 1

    print(f"\n  Tested {n_trials} random perturbations OUTSIDE certified radius:")
    print(f"  Winner changes: {n_failures_outside} "
          f"({100*n_failures_outside/n_trials:.1f}%)")
    print()


# ─── Example 2: Visualization of robustness region ────────────────────────────

def example_visualization():
    print("=" * 70)
    print("Example 2: Visualizing the certified robustness region (3 candidates)")
    print("=" * 70)

    # 3 candidates with fixed score for candidate C
    v = np.array([1.0, 2.5, 4.0])
    gamma = min_round_gap(v)
    eps_cert = gamma / 2

    print(f"\nBase scores: A={v[0]}, B={v[1]}, C={v[2]}")
    print(f"Elimination order: {['A','B','C'][irv_elimination_order(v)[0]]} → "
          f"{['A','B','C'][irv_elimination_order(v)[1]]} → "
          f"Winner: {['A','B','C'][irv_elimination_order(v)[2]]}")
    print(f"Minimum round gap γ = {gamma}")
    print(f"Certified ε = γ/2 = {eps_cert}")

    # Create a grid of perturbations to scores A and B
    n_grid = 200
    eps_range = np.linspace(-2.0, 2.0, n_grid)
    winner_map = np.zeros((n_grid, n_grid), dtype=int)

    for i, da in enumerate(eps_range):
        for j, db in enumerate(eps_range):
            v_pert = v.copy()
            v_pert[0] += da
            v_pert[1] += db
            winner_map[j, i] = irv_winner(v_pert)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Winner regions
    ax = axes[0]
    cmap = plt.cm.get_cmap('Set1', 3)
    im = ax.imshow(winner_map, extent=[eps_range[0], eps_range[-1],
                                        eps_range[0], eps_range[-1]],
                   origin='lower', cmap=cmap, vmin=0, vmax=2, aspect='equal')
    # Draw certified region
    rect = plt.Rectangle((-eps_cert, -eps_cert), 2*eps_cert, 2*eps_cert,
                          linewidth=2, edgecolor='white', facecolor='none',
                          linestyle='--', label=f'Certified region (ε={eps_cert})')
    ax.add_patch(rect)
    ax.plot(0, 0, 'w+', markersize=15, markeredgewidth=2)
    ax.set_xlabel('Perturbation to score A (δ_A)')
    ax.set_ylabel('Perturbation to score B (δ_B)')
    ax.set_title('IRV Winner Under Score Perturbation\n(score C fixed)')
    ax.legend(loc='upper left', fontsize=9)
    cbar = plt.colorbar(im, ax=ax, ticks=[0, 1, 2])
    cbar.ax.set_yticklabels(['A', 'B', 'C'])

    # Plot 2: Elimination order stability
    order_map = np.zeros((n_grid, n_grid), dtype=int)
    base_order = tuple(irv_elimination_order(v))

    for i, da in enumerate(eps_range):
        for j, db in enumerate(eps_range):
            v_pert = v.copy()
            v_pert[0] += da
            v_pert[1] += db
            order = tuple(irv_elimination_order(v_pert))
            order_map[j, i] = 1 if order == base_order else 0

    ax = axes[1]
    ax.imshow(order_map, extent=[eps_range[0], eps_range[-1],
                                  eps_range[0], eps_range[-1]],
              origin='lower', cmap='RdYlGn', vmin=0, vmax=1, aspect='equal')
    rect2 = plt.Rectangle((-eps_cert, -eps_cert), 2*eps_cert, 2*eps_cert,
                           linewidth=2, edgecolor='blue', facecolor='none',
                           linestyle='--', label=f'Certified region')
    ax.add_patch(rect2)
    ax.plot(0, 0, 'b+', markersize=15, markeredgewidth=2)
    ax.set_xlabel('Perturbation to score A (δ_A)')
    ax.set_ylabel('Perturbation to score B (δ_B)')
    ax.set_title('Elimination Order Stability\n(green = same order as base)')
    ax.legend(loc='upper left', fontsize=9)

    plt.tight_layout()
    plt.savefig('Bridges/irv_robustness_regions.png', dpi=150, bbox_inches='tight')
    print("\nSaved: Bridges/irv_robustness_regions.png")
    plt.close()


# ─── Example 3: Tropical Lipschitz score map ──────────────────────────────────

def example_tropical():
    print("\n" + "=" * 70)
    print("Example 3: Tropical (max-plus) Lipschitz score map")
    print("=" * 70)

    # Simulate a tropical max-plus affine score map:
    #   s_i(x) = max_j (W_{ij} + x_j)
    # This is 1-Lipschitz in L∞ since
    #   |s_i(x') - s_i(x)| ≤ max_j |x'_j - x_j| = ||x'-x||_∞

    d, m = 5, 4  # 5 input dims, 4 classes
    np.random.seed(42)
    W = np.random.randn(m, d) * 2  # Weight matrix

    def tropical_score(x):
        """Tropical (max-plus) affine score: s_i(x) = max_j(W_{ij} + x_j)"""
        return np.max(W + x[np.newaxis, :], axis=1)

    K = 1.0  # Tropical max-plus is 1-Lipschitz in L∞

    x = np.array([1.0, -0.5, 2.0, 0.3, -1.0])
    v = tropical_score(x)

    print(f"\nInput x = {x}")
    print(f"Scores s(x) = {v.round(4)}")

    order = irv_elimination_order(v)
    gaps = round_gaps(v)
    names = ['Class 0', 'Class 1', 'Class 2', 'Class 3']

    print("\nIRV elimination:")
    for rnd, (loser, gap) in enumerate(gaps, 1):
        print(f"  Round {rnd}: Eliminate {names[loser]} "
              f"(score {v[loser]:.4f}, gap {gap:.4f})")
    print(f"  Winner: {names[order[-1]]}")

    gamma = min_round_gap(v)
    r = certified_radius(v, K)
    print(f"\nMinimum round gap γ = {gamma:.4f}")
    print(f"Lipschitz constant K = {K}")
    print(f"Certified L∞ input radius r = γ/(2K) = {r:.4f}")
    print(f"\nMeaning: ANY input x' with ||x' - x||_∞ < {r:.4f}")
    print(f"is GUARANTEED to produce the same IRV winner ({names[order[-1]]})")

    # Verify empirically
    n_trials = 10000
    n_fail = 0
    original_winner = irv_winner(v)
    for _ in range(n_trials):
        delta_x = np.random.uniform(-r * 0.99, r * 0.99, d)
        x_pert = x + delta_x
        v_pert = tropical_score(x_pert)
        if irv_winner(v_pert) != original_winner:
            n_fail += 1
    print(f"\nEmpirical verification: {n_trials} trials within certified radius")
    print(f"Winner changes: {n_fail} (theorem guarantees 0)")
    print()


# ─── Example 4: Comparison with argmax robustness ─────────────────────────────

def example_comparison():
    print("=" * 70)
    print("Example 4: IRV vs argmax robustness comparison")
    print("=" * 70)

    # For argmax, the robustness radius is simply (v_winner - v_runner-up) / (2K)
    # For IRV, we need the minimum round gap across ALL rounds

    np.random.seed(123)
    m = 6  # 6 candidates
    n_examples = 5

    print(f"\n{'Example':<10} {'Argmax radius':<15} {'IRV radius':<15} {'Ratio':<10}")
    print("-" * 50)

    for ex in range(n_examples):
        v = np.sort(np.random.exponential(2.0, m))
        # Add some spread
        v = v + np.arange(m) * 0.5

        # Argmax robustness: gap between winner and runner-up
        sorted_v = np.sort(v)
        argmax_gap = sorted_v[-1] - sorted_v[-2]

        # IRV robustness: minimum round gap
        irv_gap = min_round_gap(v)

        K = 1.0
        r_argmax = argmax_gap / (2 * K)
        r_irv = irv_gap / (2 * K)
        ratio = r_irv / r_argmax if r_argmax > 0 else float('inf')

        print(f"  {ex+1:<8} {r_argmax:<15.4f} {r_irv:<15.4f} {ratio:<10.4f}")

    print(f"\nNote: IRV radius ≤ argmax radius because IRV requires stability")
    print(f"at EVERY elimination round, not just the final comparison.")
    print(f"The IRV certificate is stronger: it guarantees not just the winner,")
    print(f"but the ENTIRE elimination ordering is preserved.")
    print()


# ─── Example 5: Scaling with number of candidates ─────────────────────────────

def example_scaling():
    print("=" * 70)
    print("Example 5: How certified radius scales with number of candidates")
    print("=" * 70)

    np.random.seed(42)
    ms = [3, 5, 10, 20, 50, 100]
    K = 1.0

    print(f"\n{'m (candidates)':<18} {'min gap γ':<15} {'cert. radius r':<18} "
          f"{'γ/m':<12}")
    print("-" * 63)

    radii = []
    for m in ms:
        # Scores uniformly spaced with noise
        v = np.arange(m, dtype=float) + np.random.randn(m) * 0.1
        gamma = min_round_gap(v)
        r = certified_radius(v, K)
        radii.append(r)
        print(f"  {m:<16} {gamma:<15.6f} {r:<18.6f} {gamma/m:<12.6f}")

    print(f"\nFor uniformly-spaced scores, the gap scales as O(1/1) = O(1),")
    print(f"so the certified radius stays roughly constant.")
    print()

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ms, radii, 'bo-', linewidth=2, markersize=8)
    ax.set_xlabel('Number of candidates (m)', fontsize=12)
    ax.set_ylabel('Certified L∞ radius', fontsize=12)
    ax.set_title('Certified Robustness Radius vs. Number of Candidates\n'
                 '(K=1 Lipschitz, uniformly spaced scores)', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.set_xscale('log')
    plt.tight_layout()
    plt.savefig('Bridges/irv_scaling.png', dpi=150, bbox_inches='tight')
    print("Saved: Bridges/irv_scaling.png")
    plt.close()


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    example_basic()
    example_visualization()
    example_tropical()
    example_comparison()
    example_scaling()

    print("\n" + "=" * 70)
    print("Summary of Formally Verified Results (Lean 4 + Mathlib)")
    print("=" * 70)
    print("""
The following theorems are machine-verified in Bridges/IRVStability.lean:

1. eliminationOrderOn_stable:
   If EliminationGapCertified S v γ and ∀i, |v'i - vi| ≤ ε and 2ε < γ,
   then the full elimination order is preserved under perturbation.

2. irvWinner_stable:
   Under the same hypotheses, the IRV winner is preserved.

3. irvWinner_certified_robust:
   For a K-Lipschitz score map s, if EliminationGapCertified for s(x)
   with gap γ, then any input x' with ||x'-x||_∞ ≤ r preserves the
   IRV winner whenever 2Kr < γ.

These proofs are complete (no sorry) and checked by the Lean kernel.
""")
