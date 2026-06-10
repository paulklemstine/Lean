#!/usr/bin/env python3
"""
GL3 Tropical Satake Tournament Robustness — Interactive Demo

This script demonstrates the formally verified robustness theorem for
pairwise-comparison (Condorcet/Copeland) classifiers under score perturbation.

Key idea: if a 3-class classifier's pairwise margins all exceed 2·K·d·r,
then the tournament winner is invariant under L∞ perturbations of radius r.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations

# ─── Core Definitions ───────────────────────────────────────────────────

def gap(scores, i, j):
    """Pairwise gap: S[i] - S[j]."""
    return scores[i] - scores[j]

def is_condorcet_winner(scores, c):
    """Check if class c beats every other class."""
    n = len(scores)
    return all(gap(scores, c, j) > 0 for j in range(n) if j != c)

def pairwise_wins(scores, i):
    """Copeland score: number of classes beaten by i."""
    n = len(scores)
    return sum(1 for j in range(n) if j != i and gap(scores, i, j) > 0)

def min_pairwise_margin(scores, c):
    """Minimum gap from the winner c to any rival."""
    n = len(scores)
    return min(gap(scores, c, j) for j in range(n) if j != c)

def certified_radius(scores, c, K, d):
    """Maximum perturbation radius r such that c remains the Condorcet winner.
    By the theorem: need 2·K·d·r < min_j≠c gap(S, c, j).
    So r_max = min_margin / (2·K·d)."""
    margin = min_pairwise_margin(scores, c)
    if K * d <= 0:
        return float('inf') if margin > 0 else 0.0
    return margin / (2 * K * d)


# ─── Demo 1: Basic Robustness Check ─────────────────────────────────────

def demo_basic():
    """Show that the Condorcet winner survives perturbation within budget."""
    print("=" * 60)
    print("Demo 1: Basic Condorcet Robustness")
    print("=" * 60)

    scores = np.array([5.0, 2.0, 1.0])  # Class 0 dominates
    K, d = 1.0, 1.0

    winner = np.argmax([pairwise_wins(scores, i) for i in range(3)])
    r_cert = certified_radius(scores, winner, K, d)

    print(f"Scores:           {scores}")
    print(f"Condorcet winner: class {winner}")
    print(f"Copeland scores:  {[pairwise_wins(scores, i) for i in range(3)]}")
    print(f"Pairwise gaps from winner:")
    for j in range(3):
        if j != winner:
            print(f"  gap({winner},{j}) = {gap(scores, winner, j):.2f}")
    print(f"Min margin:       {min_pairwise_margin(scores, winner):.2f}")
    print(f"Certified radius: {r_cert:.2f}")
    print()

    # Test with perturbations
    rng = np.random.default_rng(42)
    n_trials = 10000
    radii = [0.5 * r_cert, r_cert * 0.99, r_cert * 1.5]

    for r in radii:
        flips = 0
        for _ in range(n_trials):
            noise = rng.uniform(-K * d * r, K * d * r, size=3)
            perturbed = scores + noise
            if not is_condorcet_winner(perturbed, winner):
                flips += 1
        status = "✓ CERTIFIED" if r < r_cert else "⚠ NOT CERTIFIED"
        print(f"  r = {r:.2f}: {flips}/{n_trials} flips  {status}")

    print()


# ─── Demo 2: Visualization of Robustness Region ──────────────────────────

def demo_visualization():
    """Visualize the certified robustness region in score space."""
    print("=" * 60)
    print("Demo 2: Robustness Region Visualization")
    print("=" * 60)

    scores = np.array([4.0, 1.5, 0.5])
    K, d = 1.0, 1.0
    winner = 0
    r_cert = certified_radius(scores, winner, K, d)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # Panel 1: Score bars with perturbation ranges
    ax = axes[0]
    colors = ['#2196F3', '#FF9800', '#4CAF50']
    labels = ['Class 0', 'Class 1', 'Class 2']
    bars = ax.bar(labels, scores, color=colors, alpha=0.8, edgecolor='black')

    for i, (s, c) in enumerate(zip(scores, colors)):
        ax.errorbar(i, s, yerr=K * d * r_cert, fmt='none',
                     ecolor='red', capsize=8, linewidth=2)

    ax.set_ylabel('Score')
    ax.set_title(f'Scores ± K·d·r (r_cert = {r_cert:.2f})')
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)

    # Panel 2: Pairwise gaps
    ax = axes[1]
    pairs = [(0, 1), (0, 2), (1, 2)]
    pair_labels = ['gap(0,1)', 'gap(0,2)', 'gap(1,2)']
    gaps = [gap(scores, i, j) for i, j in pairs]
    budget = 2 * K * d * r_cert

    bar_colors = ['#2196F3' if g > budget else '#F44336' for g in gaps]
    ax.bar(pair_labels, gaps, color=bar_colors, alpha=0.8, edgecolor='black')
    ax.axhline(y=budget, color='red', linestyle='--', linewidth=2,
               label=f'Perturbation budget = {budget:.2f}')
    ax.set_ylabel('Gap value')
    ax.set_title('Pairwise Gaps vs Budget')
    ax.legend()

    # Panel 3: Monte Carlo stability test
    ax = axes[2]
    test_radii = np.linspace(0, 2 * r_cert, 50)
    rng = np.random.default_rng(123)
    stability_rates = []

    for r in test_radii:
        stable = 0
        trials = 2000
        for _ in range(trials):
            noise = rng.uniform(-K * d * r, K * d * r, size=3)
            perturbed = scores + noise
            if is_condorcet_winner(perturbed, winner):
                stable += 1
        stability_rates.append(stable / trials)

    ax.plot(test_radii, stability_rates, 'b-', linewidth=2)
    ax.axvline(x=r_cert, color='red', linestyle='--', linewidth=2,
               label=f'r_cert = {r_cert:.2f}')
    ax.fill_between(test_radii, stability_rates, alpha=0.15, color='blue')
    ax.set_xlabel('Perturbation radius r')
    ax.set_ylabel('P(winner preserved)')
    ax.set_title('Stability vs Perturbation Radius')
    ax.legend()
    ax.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('Bridges/tournament_robustness_visualization.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  Saved: Bridges/tournament_robustness_visualization.png")
    print()


# ─── Demo 3: Tournament Diagrams ─────────────────────────────────────────

def demo_tournament_diagrams():
    """Show how tournament orientation is preserved under perturbation."""
    print("=" * 60)
    print("Demo 3: Tournament Orientation Stability")
    print("=" * 60)

    scores = np.array([5.0, 3.0, 1.0])
    K, d, r = 1.0, 1.0, 0.8

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    def draw_tournament(ax, sc, title):
        """Draw a tournament on 3 vertices."""
        pos = {0: (0.5, 1), 1: (0, 0), 2: (1, 0)}
        labels = {0: f'C0\n({sc[0]:.1f})', 1: f'C1\n({sc[1]:.1f})',
                  2: f'C2\n({sc[2]:.1f})'}

        for i in range(3):
            circle = plt.Circle(pos[i], 0.12, color=['#2196F3', '#FF9800', '#4CAF50'][i],
                                alpha=0.8, zorder=3)
            ax.add_patch(circle)
            ax.text(pos[i][0], pos[i][1], labels[i], ha='center', va='center',
                    fontsize=9, fontweight='bold', zorder=4)

        for i, j in combinations(range(3), 2):
            g = gap(sc, i, j)
            if g > 0:
                src, dst = i, j
            else:
                src, dst = j, i

            x1, y1 = pos[src]
            x2, y2 = pos[dst]
            dx, dy = x2 - x1, y2 - y1
            norm = np.sqrt(dx**2 + dy**2)
            dx, dy = dx / norm, dy / norm
            ax.annotate('', xy=(x2 - dx * 0.15, y2 - dy * 0.15),
                        xytext=(x1 + dx * 0.15, y1 + dy * 0.15),
                        arrowprops=dict(arrowstyle='->', color='black',
                                        lw=2, mutation_scale=20))

        ax.set_xlim(-0.3, 1.3)
        ax.set_ylim(-0.3, 1.3)
        ax.set_aspect('equal')
        ax.set_title(title, fontsize=12)
        ax.axis('off')

    # Original tournament
    draw_tournament(axes[0], scores, 'Original Tournament')

    # Small perturbation (within budget)
    rng = np.random.default_rng(42)
    noise_small = rng.uniform(-K * d * r * 0.5, K * d * r * 0.5, size=3)
    draw_tournament(axes[1], scores + noise_small,
                    f'Perturbed (r={r*0.5:.1f} < r_cert)')

    # Large perturbation (may flip)
    noise_large = np.array([-1.8, 1.8, 0])  # Deliberately flip 0↔1
    draw_tournament(axes[2], scores + noise_large,
                    'Perturbed (large, edge may flip)')

    plt.tight_layout()
    plt.savefig('Bridges/tournament_orientation_stability.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  Saved: Bridges/tournament_orientation_stability.png")
    print()


# ─── Demo 4: Application — Robust Multiclass Classification ──────────────

def demo_application():
    """Simulate a robust 3-class image classifier using tournament scoring."""
    print("=" * 60)
    print("Demo 4: Robust Multiclass Classification Application")
    print("=" * 60)

    # Simulate a tropical Hecke score map for 100 samples
    rng = np.random.default_rng(2024)
    n_samples = 200
    true_labels = rng.choice(3, size=n_samples)

    # Generate score vectors: true class gets high score
    K, d = 0.5, 1.0
    scores_all = []
    for label in true_labels:
        base = rng.uniform(0, 2, size=3)
        base[label] += rng.uniform(3, 6)  # Boost true class
        scores_all.append(base)
    scores_all = np.array(scores_all)

    # Compute certified radii
    radii = []
    winners = []
    for i, sc in enumerate(scores_all):
        w = max(range(3), key=lambda c: pairwise_wins(sc, c))
        winners.append(w)
        if is_condorcet_winner(sc, w):
            radii.append(certified_radius(sc, w, K, d))
        else:
            radii.append(0.0)

    radii = np.array(radii)
    winners = np.array(winners)
    accuracy = np.mean(winners == true_labels)

    print(f"  Samples:                {n_samples}")
    print(f"  Clean accuracy:         {accuracy:.1%}")
    print(f"  Mean certified radius:  {np.mean(radii):.3f}")
    print(f"  Median certified radius: {np.median(radii):.3f}")
    print(f"  Samples with r > 1.0:   {np.sum(radii > 1.0)}/{n_samples}")
    print(f"  Samples with r > 2.0:   {np.sum(radii > 2.0)}/{n_samples}")

    # Plot histogram of certified radii
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    ax = axes[0]
    ax.hist(radii, bins=30, color='#2196F3', alpha=0.8, edgecolor='black')
    ax.axvline(x=np.median(radii), color='red', linestyle='--', linewidth=2,
               label=f'Median = {np.median(radii):.2f}')
    ax.set_xlabel('Certified perturbation radius')
    ax.set_ylabel('Count')
    ax.set_title('Distribution of Certified Robustness Radii')
    ax.legend()

    # Plot certified accuracy curve
    ax = axes[1]
    test_r = np.linspace(0, np.max(radii) * 1.1, 100)
    cert_acc = [np.mean((radii >= r) & (winners == true_labels)) for r in test_r]
    ax.plot(test_r, cert_acc, 'b-', linewidth=2)
    ax.set_xlabel('Adversarial radius r')
    ax.set_ylabel('Certified accuracy')
    ax.set_title('Certified Accuracy vs Perturbation Budget')
    ax.axhline(y=accuracy, color='gray', linestyle=':', alpha=0.5,
               label=f'Clean accuracy = {accuracy:.1%}')
    ax.legend()

    plt.tight_layout()
    plt.savefig('Bridges/application_certified_accuracy.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  Saved: Bridges/application_certified_accuracy.png")
    print()


# ─── Demo 5: Cycle Detection ─────────────────────────────────────────────

def demo_cycles():
    """Demonstrate the cycle characterization theorem."""
    print("=" * 60)
    print("Demo 5: Condorcet Winner ↔ No 3-Cycle (Fin 3)")
    print("=" * 60)

    examples = [
        ("Transitive (0>1>2)", [5.0, 3.0, 1.0]),
        ("Transitive (2>0>1)", [2.0, 1.0, 5.0]),
        ("Cycle: 0>1, 1>2, 2>0", None),  # Impossible with S[i]-S[j] gaps!
    ]

    # For 3 classes with scores, cycles are actually impossible
    # because gap(0,1) + gap(1,2) + gap(2,0) = 0 always
    print("\n  Key insight: With real-valued scores S[0], S[1], S[2],")
    print("  gap(0,1) + gap(1,2) + gap(2,0) = (S0-S1) + (S1-S2) + (S2-S0) = 0")
    print("  So all three gaps cannot be positive → no 3-cycle is possible!")
    print("  This means a Condorcet winner ALWAYS exists for strict tournaments")
    print("  arising from score functions.\n")

    for name, sc in examples[:2]:
        sc = np.array(sc)
        print(f"  {name}: scores = {sc}")
        for i in range(3):
            wins = pairwise_wins(sc, i)
            is_cw = is_condorcet_winner(sc, i)
            print(f"    Class {i}: wins={wins}, Condorcet={'✓' if is_cw else '✗'}")
        print()


# ─── Main ─────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("\n" + "═" * 60)
    print("  GL3 Tropical Satake Tournament Robustness — Demo Suite")
    print("═" * 60 + "\n")

    demo_basic()
    demo_visualization()
    demo_tournament_diagrams()
    demo_application()
    demo_cycles()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)
