#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Probability Landscape

Shows how infinitesimal perturbations create a two-level structure in probability:
a "standard" level visible at macroscopic scale, and an "infinitesimal" level that
resolves ties between events with equal standard probability.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction

def create_probability_landscape():
    """Create the main probability landscape visualization."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Standard vs Non-Archimedean weights
    ax1 = axes[0, 0]
    outcomes = ['A', 'B', 'C', 'D', 'E', 'F']
    n = len(outcomes)
    std_weights = [1/n] * n
    # Non-Archimedean: base 1/6, with infinitesimal perturbations
    perturbations = [0.03, -0.01, 0.02, -0.02, 0.01, -0.03]  # visual stand-in for ε
    na_weights = [1/n + p for p in perturbations]

    x = np.arange(n)
    width = 0.35
    bars1 = ax1.bar(x - width/2, std_weights, width, label='Standard (ℝ)', color='#2196F3', alpha=0.8)
    bars2 = ax1.bar(x + width/2, na_weights, width, label='Non-Arch (F)', color='#FF5722', alpha=0.8)
    ax1.axhline(y=1/n, color='gray', linestyle='--', alpha=0.5)
    ax1.set_xticks(x)
    ax1.set_xticklabels(outcomes)
    ax1.set_ylabel('Weight')
    ax1.set_title('Standard vs Non-Archimedean Weights\n(infinitesimal differences resolve ties)')
    ax1.legend()
    ax1.set_ylim(0, 0.25)

    # Panel 2: Conditional probability P(A|{x}) for each singleton
    ax2 = axes[0, 1]
    # In a 6-element uniform space, P({x} | {x,y}) = 1/2 for all x,y (standard)
    # In non-Archimedean, P({x} | {x,y}) = w(x)/(w(x)+w(y)) which varies
    pairs = [('A','B'), ('B','C'), ('C','D'), ('D','E'), ('E','F'), ('A','F')]
    std_cond = [0.5] * len(pairs)
    na_cond = []
    for p in pairs:
        i, j = outcomes.index(p[0]), outcomes.index(p[1])
        wi, wj = na_weights[i], na_weights[j]
        na_cond.append(wi / (wi + wj))

    x2 = np.arange(len(pairs))
    pair_labels = [f'P({p[0]}|{{{p[0]},{p[1]}}})'  for p in pairs]
    ax2.bar(x2 - width/2, std_cond, width, label='Standard', color='#2196F3', alpha=0.8)
    ax2.bar(x2 + width/2, na_cond, width, label='Non-Archimedean', color='#FF5722', alpha=0.8)
    ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xticks(x2)
    ax2.set_xticklabels(pair_labels, rotation=45, ha='right', fontsize=8)
    ax2.set_ylabel('Conditional Probability')
    ax2.set_title('Conditional Probability: Infinitesimals\nBreak Standard Degeneracies')
    ax2.legend()
    ax2.set_ylim(0.4, 0.6)

    # Panel 3: Markov inequality bound vs actual probability
    ax3 = axes[1, 0]
    n_pts = 10
    weights = np.ones(n_pts) / n_pts
    X_vals = np.arange(1, n_pts + 1, dtype=float)
    EX = np.sum(weights * X_vals)

    thresholds = np.linspace(1, n_pts, 50)
    actual_probs = []
    markov_bounds = []
    for a in thresholds:
        actual = np.sum(weights[X_vals >= a])
        bound = EX / a
        actual_probs.append(actual)
        markov_bounds.append(min(bound, 1.0))

    ax3.fill_between(thresholds, markov_bounds, alpha=0.3, color='#FF5722', label='Markov bound E[X]/a')
    ax3.step(thresholds, actual_probs, where='post', color='#2196F3', linewidth=2, label='Actual P(X ≥ a)')
    ax3.set_xlabel('Threshold a')
    ax3.set_ylabel('Probability')
    ax3.set_title('Non-Archimedean Markov Inequality\n(holds for any ordered field)')
    ax3.legend()
    ax3.set_ylim(0, 1.1)

    # Panel 4: The "regularity" advantage
    ax4 = axes[1, 1]
    # Show that in ℝ, as n→∞, singleton probability → 0
    # In non-Archimedean, singleton probability → ε (positive infinitesimal)
    ns = np.arange(2, 51)
    real_singleton = 1.0 / ns
    # Represent infinitesimal as a small positive constant for visualization
    eps_visual = 0.005

    ax4.plot(ns, real_singleton, 'b-', linewidth=2, label='ℝ: P({x}) = 1/n → 0')
    ax4.axhline(y=eps_visual, color='#FF5722', linestyle='-', linewidth=2,
                label='Non-Arch: P({x}) = ε > 0 (infinitesimal)')
    ax4.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
    ax4.fill_between(ns, 0, eps_visual, alpha=0.2, color='#FF5722')
    ax4.annotate('Infinitesimal gap\n(ε is positive but\nsmaller than any 1/n)',
                xy=(30, eps_visual/2), fontsize=9, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
    ax4.set_xlabel('Number of outcomes n')
    ax4.set_ylabel('Singleton probability')
    ax4.set_title('Regularity: Non-Archimedean Probability\nKeeps Every Point Positive')
    ax4.legend(loc='upper right')
    ax4.set_ylim(-0.02, 0.55)

    plt.tight_layout()
    plt.savefig('probability_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved probability_landscape.png")


if __name__ == "__main__":
    create_probability_landscape()
