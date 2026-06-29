#!/usr/bin/env python3
"""
GL3 Kemeny–Young Certified Robustness — Demonstration

This script demonstrates the formally verified robustness theorem for
Kemeny–Young aggregation over 3 candidates. It computes certified
robustness radii for concrete score vectors and visualizes the winner
regions in pairwise-margin space.

The key result: if a classifier produces scores for 3 classes, and the
Kemeny-optimal ranking has a score gap Δ over all competitors, then the
winner label is preserved under any perturbation of size < Δ / (12·Kd),
where Kd is the Lipschitz constant of the score map.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import permutations

# =============================================================================
# Core definitions matching the Lean formalization
# =============================================================================

RANKINGS = [
    (0, 1, 2),  # r012: 0 ≻ 1 ≻ 2
    (0, 2, 1),  # r021: 0 ≻ 2 ≻ 1
    (1, 0, 2),  # r102: 1 ≻ 0 ≻ 2
    (1, 2, 0),  # r120: 1 ≻ 2 ≻ 0
    (2, 0, 1),  # r201: 2 ≻ 0 ≻ 1
    (2, 1, 0),  # r210: 2 ≻ 1 ≻ 0
]

RANKING_NAMES = ["0≻1≻2", "0≻2≻1", "1≻0≻2", "1≻2≻0", "2≻0≻1", "2≻1≻0"]


def margin(scores, i, j):
    """Pairwise margin: score[i] - score[j]."""
    return scores[i] - scores[j]


def kemeny_score(scores, ranking):
    """
    Kemeny score of a ranking given class scores.
    Sum of margin(σ(i), σ(j)) for all pairs i < j in the ranking.
    """
    s = 0.0
    for i in range(3):
        for j in range(i + 1, 3):
            s += margin(scores, ranking[i], ranking[j])
    return s


def kemeny_score_from_margins(m01, m02, m12, ranking_idx):
    """
    Kemeny score from the three basic margins, using the closed-form formulas
    proved in the Lean formalization.
    """
    formulas = [
        lambda: m01 + m02 + m12,   # r012
        lambda: m01 + m02 - m12,   # r021
        lambda: -m01 + m02 + m12,  # r102
        lambda: -m01 - m02 + m12,  # r120
        lambda: m01 - m02 - m12,   # r201
        lambda: -m01 - m02 - m12,  # r210
    ]
    return formulas[ranking_idx]()


def find_kemeny_winner(scores):
    """Find the ranking with the highest Kemeny score."""
    best_idx = 0
    best_score = kemeny_score(scores, RANKINGS[0])
    for i in range(1, 6):
        s = kemeny_score(scores, RANKINGS[i])
        if s > best_score:
            best_score = s
            best_idx = i
    return best_idx, best_score


def kemeny_gap(scores):
    """Gap between best and second-best Kemeny scores."""
    all_scores = [kemeny_score(scores, r) for r in RANKINGS]
    all_scores.sort(reverse=True)
    return all_scores[0] - all_scores[1]


def certified_radius(scores, Kd):
    """
    Certified robustness radius: Δ / (12 · Kd).
    Any perturbation within this radius preserves the Kemeny winner.
    """
    gap = kemeny_gap(scores)
    if Kd <= 0 or gap <= 0:
        return 0.0
    return gap / (12.0 * Kd)


# =============================================================================
# Demo 1: Concrete numerical example
# =============================================================================

def demo_concrete_example():
    print("=" * 70)
    print("DEMO 1: Concrete Kemeny Robustness Example")
    print("=" * 70)

    scores = np.array([3.0, 1.0, 0.5])
    Kd = 1.0

    print(f"\nClass scores: h = {scores}")
    print(f"Lipschitz constant: Kd = {Kd}")

    m01 = scores[0] - scores[1]
    m02 = scores[0] - scores[2]
    m12 = scores[1] - scores[2]
    print(f"\nPairwise margins:")
    print(f"  m01 = {m01:.2f}, m02 = {m02:.2f}, m12 = {m12:.2f}")

    print(f"\nKemeny scores for all 6 rankings:")
    all_scores = []
    for i, (r, name) in enumerate(zip(RANKINGS, RANKING_NAMES)):
        s = kemeny_score(scores, r)
        s_formula = kemeny_score_from_margins(m01, m02, m12, i)
        all_scores.append(s)
        marker = " ← WINNER" if i == 0 else ""
        print(f"  {name}: score = {s:.2f} (formula check: {s_formula:.2f}){marker}")

    winner_idx, winner_score = find_kemeny_winner(scores)
    gap = kemeny_gap(scores)
    radius = certified_radius(scores, Kd)

    print(f"\nKemeny winner: ranking {RANKING_NAMES[winner_idx]}")
    print(f"  Top class: {RANKINGS[winner_idx][0]}")
    print(f"  Winner score: {winner_score:.2f}")
    print(f"  Gap Δ = {gap:.2f}")
    print(f"  Certified radius = Δ/(12·Kd) = {gap:.2f}/{12*Kd:.1f} = {radius:.4f}")
    print(f"\n  → Any perturbation with |h(y,i) - h(x,i)| ≤ {Kd}·ε")
    print(f"    preserves the winner for ε < {radius:.4f}")

    # Verify by Monte Carlo
    print(f"\n  Verification: 10000 random perturbations within radius...")
    n_trials = 10000
    n_preserved = 0
    for _ in range(n_trials):
        eps = radius * 0.99
        delta = np.random.uniform(-Kd * eps, Kd * eps, 3)
        perturbed = scores + delta
        pw, _ = find_kemeny_winner(perturbed)
        if RANKINGS[pw][0] == RANKINGS[winner_idx][0]:
            n_preserved += 1
    print(f"  Winner preserved: {n_preserved}/{n_trials} ({100*n_preserved/n_trials:.1f}%)")


# =============================================================================
# Demo 2: Winner region visualization
# =============================================================================

def demo_winner_regions():
    print("\n" + "=" * 70)
    print("DEMO 2: Winner Region Visualization")
    print("=" * 70)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Winner regions in (m01, m12) space with m02 = m01 + m12
    ax = axes[0]
    N = 500
    m01_range = np.linspace(-3, 3, N)
    m12_range = np.linspace(-3, 3, N)
    M01, M12 = np.meshgrid(m01_range, m12_range)
    M02 = M01 + M12  # constraint: m02 = m01 + m12 (consistent margins)

    winner_map = np.zeros_like(M01, dtype=int)
    for i in range(N):
        for j in range(N):
            scores_all = [
                kemeny_score_from_margins(M01[i, j], M02[i, j], M12[i, j], k)
                for k in range(6)
            ]
            winner_map[i, j] = np.argmax(scores_all)

    # Color by top class
    top_class_map = np.array([[RANKINGS[winner_map[i, j]][0]
                                for j in range(N)] for i in range(N)])

    colors = ['#e74c3c', '#2ecc71', '#3498db']
    cmap = plt.matplotlib.colors.ListedColormap(colors)
    ax.pcolormesh(M01, M12, top_class_map, cmap=cmap, shading='auto', alpha=0.6)
    ax.set_xlabel('m₀₁ (margin: class 0 vs class 1)', fontsize=12)
    ax.set_ylabel('m₁₂ (margin: class 1 vs class 2)', fontsize=12)
    ax.set_title('Kemeny Winner Regions\n(consistent margins: m₀₂ = m₀₁ + m₁₂)', fontsize=13)
    ax.axhline(0, color='gray', lw=0.5)
    ax.axvline(0, color='gray', lw=0.5)

    patches = [mpatches.Patch(color=colors[i], label=f'Class {i} wins', alpha=0.6)
               for i in range(3)]
    ax.legend(handles=patches, loc='upper left', fontsize=10)

    # Mark the example point
    ex_scores = np.array([3.0, 1.0, 0.5])
    ex_m01 = ex_scores[0] - ex_scores[1]
    ex_m12 = ex_scores[1] - ex_scores[2]
    ax.plot(ex_m01, ex_m12, 'k*', markersize=15, label='Example point')

    # Draw certified radius circle
    Kd = 1.0
    gap = kemeny_gap(ex_scores)
    radius = certified_radius(ex_scores, Kd)
    # In margin space, perturbation of each margin ≤ 2Kd*ε
    margin_radius = 2 * Kd * radius
    circle = plt.Circle((ex_m01, ex_m12), margin_radius, fill=False,
                          color='black', linewidth=2, linestyle='--')
    ax.add_patch(circle)
    ax.set_aspect('equal')

    # Plot 2: Certified radius as a function of gap
    ax2 = axes[1]
    Kd_values = [0.5, 1.0, 2.0, 5.0]
    gaps = np.linspace(0.01, 5.0, 200)

    for Kd_val in Kd_values:
        radii = gaps / (12 * Kd_val)
        ax2.plot(gaps, radii, linewidth=2, label=f'Kd = {Kd_val}')

    ax2.set_xlabel('Kemeny gap Δ', fontsize=12)
    ax2.set_ylabel('Certified radius ε*', fontsize=12)
    ax2.set_title('Certified Radius = Δ / (12·Kd)', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 5)
    ax2.set_ylim(0, 1)

    plt.tight_layout()
    plt.savefig('Bridges/kemeny_robustness_demo.png', dpi=150, bbox_inches='tight')
    print("\n  Saved: Bridges/kemeny_robustness_demo.png")
    plt.close()


# =============================================================================
# Demo 3: Score perturbation tracking
# =============================================================================

def demo_perturbation_tracking():
    print("\n" + "=" * 70)
    print("DEMO 3: Score Perturbation Tracking")
    print("=" * 70)

    scores = np.array([3.0, 1.0, 0.5])
    Kd = 1.0
    gap = kemeny_gap(scores)
    rad = certified_radius(scores, Kd)

    print(f"\n  Base scores: {scores}")
    print(f"  Gap: {gap:.3f}, Certified radius: {rad:.4f}")

    fig, ax = plt.subplots(figsize=(10, 6))

    epsilons = np.linspace(0, rad * 1.5, 100)
    n_samples = 200

    winner_idx, _ = find_kemeny_winner(scores)
    original_top = RANKINGS[winner_idx][0]

    preservation_rates = []
    for eps in epsilons:
        preserved = 0
        for _ in range(n_samples):
            delta = np.random.uniform(-Kd * eps, Kd * eps, 3)
            perturbed = scores + delta
            pw, _ = find_kemeny_winner(perturbed)
            if RANKINGS[pw][0] == original_top:
                preserved += 1
        preservation_rates.append(preserved / n_samples)

    ax.plot(epsilons, preservation_rates, 'b-', linewidth=2, label='Empirical preservation rate')
    ax.axvline(rad, color='red', linestyle='--', linewidth=2,
               label=f'Certified radius = {rad:.4f}')
    ax.axhline(1.0, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('Perturbation magnitude ε', fontsize=12)
    ax.set_ylabel('Winner preservation rate', fontsize=12)
    ax.set_title('Kemeny Winner Preservation Under Perturbation', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('Bridges/kemeny_perturbation_tracking.png', dpi=150, bbox_inches='tight')
    print("  Saved: Bridges/kemeny_perturbation_tracking.png")
    plt.close()


# =============================================================================
# Demo 4: Application — Election robustness
# =============================================================================

def demo_election_application():
    print("\n" + "=" * 70)
    print("DEMO 4: Application — Election Robustness Certification")
    print("=" * 70)

    print("\n  Scenario: Three candidates in a ranked-choice election.")
    print("  Voter preferences produce aggregate scores, but individual")
    print("  vote counts have measurement uncertainty (e.g., ±2% error).")

    # Simulated election with 1000 voters
    np.random.seed(42)
    n_voters = 1000
    # True preference strengths
    true_scores = np.array([420.0, 350.0, 230.0])  # Raw vote counts for top position
    measurement_noise = 0.02  # 2% measurement uncertainty

    Kd = measurement_noise * np.max(true_scores)

    print(f"\n  Raw scores: {true_scores}")
    print(f"  Measurement uncertainty: ±{measurement_noise*100:.0f}%")
    print(f"  Effective Kd: {Kd:.2f}")

    winner_idx, winner_score = find_kemeny_winner(true_scores)
    gap = kemeny_gap(true_scores)
    rad = certified_radius(true_scores, Kd)

    print(f"\n  Kemeny winner: Candidate {RANKINGS[winner_idx][0]}")
    print(f"  Ranking: {RANKING_NAMES[winner_idx]}")
    print(f"  Score gap: {gap:.1f}")
    print(f"  Certified radius: {rad:.4f}")
    print(f"\n  → The election result is CERTIFIED ROBUST:")
    print(f"    Even if each candidate's score is off by up to")
    print(f"    {Kd * rad:.2f} votes, the Kemeny winner is unchanged.")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    demo_concrete_example()
    demo_winner_regions()
    demo_perturbation_tracking()
    demo_election_application()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
