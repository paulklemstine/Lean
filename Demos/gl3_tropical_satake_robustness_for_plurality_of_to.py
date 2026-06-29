#!/usr/bin/env python3
"""
Committee Plurality Robustness Demo
====================================

Demonstrates the formally verified committee plurality robustness theorem
from TropicalSatakeCommitteePlurality.lean with concrete numerical examples
and visualizations.

The core insight: if a committee of classifiers has a plurality winner with
margin > 2C (where C is the number of members whose votes can change),
then the winner is guaranteed to be preserved under perturbation.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from typing import List, Tuple, Optional
import os

# ---------------------------------------------------------------------------
# Core definitions matching the Lean formalization
# ---------------------------------------------------------------------------

def vote_count(votes: np.ndarray, label: int) -> int:
    """Number of committee members voting for `label`. Matches `voteCount`."""
    return int(np.sum(votes == label))

def changed_members(v: np.ndarray, v_prime: np.ndarray) -> np.ndarray:
    """Indices of members whose vote changed. Matches `changedMembers`."""
    return np.where(v != v_prime)[0]

def unstable_members(eps: np.ndarray, cert: np.ndarray) -> np.ndarray:
    """Indices of members whose perturbation exceeds certified radius.
    Matches `unstableMembers`."""
    return np.where(eps >= cert)[0]

def plurality_margin(votes: np.ndarray, winner: int, num_labels: int) -> int:
    """Minimum margin of winner over all competitors."""
    w_count = vote_count(votes, winner)
    margins = []
    for y in range(num_labels):
        if y != winner:
            margins.append(w_count - vote_count(votes, y))
    return min(margins) if margins else w_count

def is_plurality_winner(votes: np.ndarray, winner: int, num_labels: int) -> bool:
    """Check if `winner` has strictly more votes than all competitors."""
    w_count = vote_count(votes, winner)
    return all(vote_count(votes, y) < w_count
               for y in range(num_labels) if y != winner)

# ---------------------------------------------------------------------------
# Example 1: Basic committee robustness
# ---------------------------------------------------------------------------

def demo_basic_robustness():
    """Demonstrate the plurality stability theorem with a simple example."""
    print("=" * 70)
    print("EXAMPLE 1: Basic Committee Plurality Robustness")
    print("=" * 70)

    n_members = 15
    n_labels = 3
    # Original votes: 8 for label 0, 4 for label 1, 3 for label 2
    votes = np.array([0]*8 + [1]*4 + [2]*3)
    winner = 0

    print(f"\nCommittee: {n_members} members, {n_labels} labels")
    print(f"Original votes: {votes}")
    print(f"Vote counts: label 0 → {vote_count(votes, 0)}, "
          f"label 1 → {vote_count(votes, 1)}, label 2 → {vote_count(votes, 2)}")
    print(f"Winner: label {winner} with {vote_count(votes, winner)} votes")

    margin = plurality_margin(votes, winner, n_labels)
    print(f"Minimum margin: {margin}")
    print(f"Robustness guarantee: winner preserved if #changed ≤ {margin // 2 - (1 if margin % 2 == 0 else 0)}")
    print(f"  (since margin > 2C is required, C < {margin}/2 = {margin/2})")

    # Scenario A: 1 member changes (within budget)
    print(f"\n--- Scenario A: 1 member changes vote (0 → 1) ---")
    votes_a = votes.copy()
    votes_a[0] = 1  # one member switches from 0 to 1
    C_a = len(changed_members(votes, votes_a))
    print(f"  Changed members: {C_a}")
    print(f"  Margin condition: {margin} > 2×{C_a} = {2*C_a}? {'YES ✓' if margin > 2*C_a else 'NO ✗'}")
    print(f"  New counts: 0→{vote_count(votes_a, 0)}, 1→{vote_count(votes_a, 1)}, 2→{vote_count(votes_a, 2)}")
    print(f"  Winner preserved? {is_plurality_winner(votes_a, winner, n_labels)}")

    # Scenario B: 2 members change (at boundary)
    print(f"\n--- Scenario B: 2 members change vote (0 → 1) ---")
    votes_b = votes.copy()
    votes_b[0] = 1
    votes_b[1] = 1
    C_b = len(changed_members(votes, votes_b))
    print(f"  Changed members: {C_b}")
    print(f"  Margin condition: {margin} > 2×{C_b} = {2*C_b}? {'YES ✓' if margin > 2*C_b else 'NO ✗'}")
    print(f"  New counts: 0→{vote_count(votes_b, 0)}, 1→{vote_count(votes_b, 1)}, 2→{vote_count(votes_b, 2)}")
    print(f"  Winner preserved? {is_plurality_winner(votes_b, winner, n_labels)}")

    # Scenario C: worst case — members switch from winner to runner-up
    print(f"\n--- Scenario C: worst case — 2 switch from winner to runner-up ---")
    votes_c = votes.copy()
    votes_c[0] = 1  # was 0, now 1
    votes_c[1] = 1  # was 0, now 1
    C_c = len(changed_members(votes, votes_c))
    print(f"  Changed members: {C_c}")
    print(f"  Gap change: each switcher moves gap by 2 (loses winner, gains competitor)")
    print(f"  Original gap (0 vs 1): {vote_count(votes, 0) - vote_count(votes, 1)}")
    print(f"  New gap (0 vs 1): {vote_count(votes_c, 0) - vote_count(votes_c, 1)}")
    print(f"  Winner preserved? {is_plurality_winner(votes_c, winner, n_labels)}")

# ---------------------------------------------------------------------------
# Example 2: Certified radius and unstable members
# ---------------------------------------------------------------------------

def demo_certified_radii():
    """Demonstrate the bridge from certified radii to committee robustness."""
    print("\n" + "=" * 70)
    print("EXAMPLE 2: Certified Radii → Committee Robustness")
    print("=" * 70)

    np.random.seed(42)
    n_members = 20
    n_labels = 4
    winner = 0

    # Original votes: clear winner
    votes = np.array([0]*10 + [1]*4 + [2]*3 + [3]*3)
    print(f"\nCommittee: {n_members} members, {n_labels} labels")
    print(f"Vote counts: {[vote_count(votes, y) for y in range(n_labels)]}")
    print(f"Winner: label {winner} with {vote_count(votes, winner)} votes")
    margin = plurality_margin(votes, winner, n_labels)
    print(f"Minimum margin: {margin}")

    # Each member has a certified radius from tropical Satake
    cert_radii = np.random.uniform(0.1, 1.0, n_members)
    # Perturbation magnitudes
    perturbation = np.random.uniform(0.0, 0.8, n_members)

    unstable = unstable_members(perturbation, cert_radii)
    C = len(unstable)
    print(f"\nCertified radii: {np.round(cert_radii, 3)}")
    print(f"Perturbations:   {np.round(perturbation, 3)}")
    print(f"Unstable members (ε ≥ cert): {unstable} ({C} total)")
    print(f"\nMargin condition: {margin} > 2×{C} = {2*C}? "
          f"{'YES ✓ → winner guaranteed preserved' if margin > 2*C else 'NO ✗ → no guarantee'}")

    return votes, cert_radii, perturbation, unstable, n_labels, winner

# ---------------------------------------------------------------------------
# Example 3: Vote-gap perturbation bound (the key lemma)
# ---------------------------------------------------------------------------

def demo_vote_gap_bound():
    """Demonstrate the vote-gap perturbation bound: the key combinatorial lemma."""
    print("\n" + "=" * 70)
    print("EXAMPLE 3: Vote-Gap Perturbation Bound")
    print("=" * 70)
    print("\nThe key lemma: for any labels y, w,")
    print("  voteCount(v', y) - voteCount(v', w)")
    print("    ≤ (voteCount(v, y) - voteCount(v, w)) + 2 × |changedMembers|")

    # Demonstrate tightness
    print("\n--- Tightness example: all changed members switch from w to y ---")
    n = 10
    votes = np.array([0]*6 + [1]*4)  # w=0 has 6, y=1 has 4
    votes_worst = votes.copy()
    votes_worst[0] = 1  # switch from 0 to 1
    votes_worst[1] = 1  # switch from 0 to 1

    C = len(changed_members(votes, votes_worst))
    gap_before = vote_count(votes, 1) - vote_count(votes, 0)
    gap_after = vote_count(votes_worst, 1) - vote_count(votes_worst, 0)

    print(f"  Before: count(y=1)={vote_count(votes, 1)}, count(w=0)={vote_count(votes, 0)}, gap={gap_before}")
    print(f"  After:  count(y=1)={vote_count(votes_worst, 1)}, count(w=0)={vote_count(votes_worst, 0)}, gap={gap_after}")
    print(f"  Changed members: {C}")
    print(f"  Gap increase: {gap_after - gap_before}")
    print(f"  Bound (2C):   {2*C}")
    print(f"  Tight? {gap_after - gap_before == 2*C}")

    # Non-tight example
    print("\n--- Non-tight example: changed members scatter ---")
    votes2 = np.array([0]*6 + [1]*4)
    votes2_pert = votes2.copy()
    votes2_pert[0] = 2  # switch from 0 to 2 (not to y=1)
    votes2_pert[6] = 2  # switch from 1 to 2

    C2 = len(changed_members(votes2, votes2_pert))
    gap2_before = vote_count(votes2, 1) - vote_count(votes2, 0)
    gap2_after = vote_count(votes2_pert, 1) - vote_count(votes2_pert, 0)

    print(f"  Before: count(y=1)={vote_count(votes2, 1)}, count(w=0)={vote_count(votes2, 0)}, gap={gap2_before}")
    print(f"  After:  count(y=1)={vote_count(votes2_pert, 1)}, count(w=0)={vote_count(votes2_pert, 0)}, gap={gap2_after}")
    print(f"  Changed members: {C2}")
    print(f"  Gap increase: {gap2_after - gap2_before}")
    print(f"  Bound (2C):   {2*C2}")
    print(f"  Slack: {2*C2 - (gap2_after - gap2_before)}")

# ---------------------------------------------------------------------------
# Visualization
# ---------------------------------------------------------------------------

def plot_robustness_regions():
    """Visualize the robustness region as a function of margin and changed members."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Robustness region
    ax = axes[0]
    margins = np.arange(0, 21)
    max_C = np.array([(m - 1) // 2 for m in margins])  # largest C with margin > 2C

    ax.fill_between(margins, 0, max_C, alpha=0.3, color='green', label='Winner guaranteed preserved')
    ax.fill_between(margins, max_C, 10, alpha=0.2, color='red', label='No guarantee')
    ax.plot(margins, max_C, 'k-', linewidth=2, label='Boundary: C = ⌊(margin-1)/2⌋')
    ax.set_xlabel('Plurality margin (min votes_w - votes_y)', fontsize=12)
    ax.set_ylabel('Number of changed members (C)', fontsize=12)
    ax.set_title('Committee Plurality Robustness Region', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 10)
    ax.grid(True, alpha=0.3)

    # Right: Example committee vote distribution
    ax = axes[1]
    labels = ['Label 0\n(winner)', 'Label 1', 'Label 2', 'Label 3']
    counts_before = [10, 4, 3, 3]
    counts_after = [8, 6, 3, 3]

    x = np.arange(len(labels))
    width = 0.35
    bars1 = ax.bar(x - width/2, counts_before, width, label='Original', color='steelblue', alpha=0.8)
    bars2 = ax.bar(x + width/2, counts_after, width, label='Perturbed (C=2)', color='coral', alpha=0.8)

    ax.set_ylabel('Vote count', fontsize=12)
    ax.set_title('Vote Distribution Before/After Perturbation', fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend(fontsize=10)
    ax.set_ylim(0, 12)

    # Add margin annotation
    ax.annotate('margin = 6\n2C = 4\nmargin > 2C ✓',
                xy=(0.5, 8), fontsize=10,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.7),
                ha='center')

    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'committee_robustness_regions.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\n[Saved: committee_robustness_regions.png]")

def plot_certified_radii():
    """Visualize the bridge from certified radii to committee stability."""
    np.random.seed(42)
    n = 20
    cert_radii = np.random.uniform(0.1, 1.0, n)
    perturbation = np.random.uniform(0.0, 0.8, n)

    fig, ax = plt.subplots(figsize=(12, 5))
    x = np.arange(n)
    colors = ['green' if p < c else 'red' for p, c in zip(perturbation, cert_radii)]

    ax.bar(x, cert_radii, alpha=0.3, color='blue', label='Certified radius')
    ax.scatter(x, perturbation, c=colors, s=80, zorder=5, edgecolors='black', linewidth=0.5)

    # Add legend patches
    stable_patch = mpatches.Patch(color='green', label='Stable (ε < cert)')
    unstable_patch = mpatches.Patch(color='red', label='Unstable (ε ≥ cert)')
    cert_patch = mpatches.Patch(color='blue', alpha=0.3, label='Certified radius')
    ax.legend(handles=[cert_patch, stable_patch, unstable_patch], fontsize=10)

    unstable_count = sum(1 for p, c in zip(perturbation, cert_radii) if p >= c)
    ax.set_xlabel('Committee member index', fontsize=12)
    ax.set_ylabel('Magnitude', fontsize=12)
    ax.set_title(f'Member Stability Certificates ({unstable_count} unstable members)', fontsize=13)
    ax.set_xticks(x)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'certified_radii_bridge.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("[Saved: certified_radii_bridge.png]")

def plot_composition_diagram():
    """Visualize the two-layer composition: analytic → discrete."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)
    ax.axis('off')

    # Layer 1: Analytic
    rect1 = mpatches.FancyBboxPatch((0.5, 5.5), 9, 2, boxstyle="round,pad=0.1",
                                     facecolor='lightblue', edgecolor='navy', linewidth=2)
    ax.add_patch(rect1)
    ax.text(5, 6.8, 'Layer 1: Analytic / Tropical Satake', ha='center', fontsize=13, fontweight='bold')
    ax.text(5, 6.1, 'For each member i: if ε(i) < certRadius(i),\nthen vote(i) is unchanged under perturbation',
            ha='center', fontsize=10, style='italic')

    # Arrow
    ax.annotate('', xy=(5, 5.3), xytext=(5, 5.5),
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    ax.text(6.5, 4.9, '|changedMembers| ≤ |unstableMembers|',
            fontsize=10, bbox=dict(facecolor='lightyellow', edgecolor='orange'))

    # Layer 2: Discrete
    rect2 = mpatches.FancyBboxPatch((0.5, 2), 9, 2.5, boxstyle="round,pad=0.1",
                                     facecolor='lightgreen', edgecolor='darkgreen', linewidth=2)
    ax.add_patch(rect2)
    ax.text(5, 3.8, 'Layer 2: Discrete Plurality Stability', ha='center', fontsize=13, fontweight='bold')
    ax.text(5, 3.0, 'If margin > 2 × |unstableMembers|,\nthen committee winner is preserved',
            ha='center', fontsize=10, style='italic')

    # Result
    rect3 = mpatches.FancyBboxPatch((1.5, 0.3), 7, 1.2, boxstyle="round,pad=0.1",
                                     facecolor='gold', edgecolor='darkgoldenrod', linewidth=2)
    ax.add_patch(rect3)
    ax.text(5, 0.9, '✓ Committee plurality winner certified robust', ha='center',
            fontsize=12, fontweight='bold')

    ax.annotate('', xy=(5, 1.5), xytext=(5, 2),
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))

    ax.set_title('Two-Layer Composition: From Certified Radii to Committee Robustness',
                 fontsize=14, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'composition_diagram.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("[Saved: composition_diagram.png]")

# ---------------------------------------------------------------------------
# Monte Carlo validation
# ---------------------------------------------------------------------------

def monte_carlo_validation(n_trials=10000):
    """Validate the theorem: if margin > 2C, winner is always preserved."""
    print("\n" + "=" * 70)
    print("MONTE CARLO VALIDATION")
    print("=" * 70)

    np.random.seed(123)
    n_members = 20
    n_labels = 5

    violations = 0
    certified_preserved = 0
    total_with_guarantee = 0

    for _ in range(n_trials):
        # Random votes with a clear winner
        votes = np.random.randint(0, n_labels, n_members)
        winner = np.argmax([vote_count(votes, y) for y in range(n_labels)])

        if not is_plurality_winner(votes, winner, n_labels):
            continue  # skip ties

        margin = plurality_margin(votes, winner, n_labels)

        # Random perturbation: each member changes with probability p
        p_change = np.random.uniform(0.05, 0.3)
        changed = np.random.random(n_members) < p_change
        votes_pert = votes.copy()
        for i in range(n_members):
            if changed[i]:
                new_vote = np.random.randint(0, n_labels)
                votes_pert[i] = new_vote

        C = len(changed_members(votes, votes_pert))

        if margin > 2 * C:
            total_with_guarantee += 1
            if is_plurality_winner(votes_pert, winner, n_labels):
                certified_preserved += 1
            else:
                violations += 1

    print(f"  Trials: {n_trials}")
    print(f"  Cases with margin > 2C guarantee: {total_with_guarantee}")
    print(f"  Winner preserved (as guaranteed): {certified_preserved}")
    print(f"  Violations: {violations}")
    print(f"  → The theorem holds in all {total_with_guarantee} certified cases ✓"
          if violations == 0 else f"  ✗ VIOLATIONS FOUND (this should not happen)")

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    demo_basic_robustness()
    demo_certified_radii()
    demo_vote_gap_bound()
    monte_carlo_validation()

    print("\n" + "=" * 70)
    print("GENERATING VISUALIZATIONS")
    print("=" * 70)
    plot_robustness_regions()
    plot_certified_radii()
    plot_composition_diagram()

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
The formally verified theorem (committee_plurality_robust_of_member_certificates)
guarantees that a committee's plurality winner is preserved under perturbation
whenever:

  1. Each member's vote is unchanged if its perturbation is within its
     certified radius (the analytic/tropical Satake layer).

  2. The winner's margin over every competitor exceeds twice the number
     of unstable members (the discrete committee layer).

The factor of 2 is tight: a single changed member can switch from the winner
to a competitor, simultaneously decreasing the winner's count and increasing
the competitor's count by 1 each, for a gap change of 2.

This bridges single-model tropical Satake certified robustness to ensemble
robustness through a clean composition of analytic and combinatorial layers.
""")
