"""
Visualization: Möbius Inversion Convergence Analysis

Shows how the contribution of each subgroup H to the generating probability
changes with k. For large k, only the top subgroup contributes significantly,
yielding P_{n,k} → 1.
"""

import numpy as np
import matplotlib.pyplot as plt


def main():
    # Subgroup data for S_3
    # Subgroups with their orders and Möbius values
    subgroups = [
        ('{e}', 1, 3),
        ('⟨(12)⟩', 2, -1),
        ('⟨(13)⟩', 2, -1),
        ('⟨(23)⟩', 2, -1),
        ('A₃', 3, -1),
        ('S₃', 6, 1),
    ]

    ks = np.arange(1, 8)
    n_factorial = 6  # |S_3|

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Individual contributions μ(H)·(|H|/|G|)^k
    ax = axes[0]
    for name, order, mu in subgroups:
        ratio = order / n_factorial
        contributions = [mu * ratio ** k for k in ks]
        style = '-o' if mu > 0 else '--s'
        ax.plot(ks, contributions, style, linewidth=2, markersize=6, label=f'{name} (μ={mu})')

    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax.set_xlabel('k (tuple length)', fontsize=12)
    ax.set_ylabel('μ(H, S₃) · (|H|/|S₃|)^k', fontsize=12)
    ax.set_title('Subgroup Contributions to P_{3,k}', fontsize=13)
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3)

    # Plot 2: Cumulative sum = P_{3,k}
    ax = axes[1]
    probs = []
    for k in ks:
        p = sum(mu * (order / n_factorial) ** k for _, order, mu in subgroups)
        probs.append(p)

    ax.bar(ks, probs, color='steelblue', alpha=0.7, edgecolor='navy')
    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='P = 1')

    for i, (k, p) in enumerate(zip(ks, probs)):
        ax.text(k, p + 0.02, f'{p:.4f}', ha='center', va='bottom', fontsize=9)

    ax.set_xlabel('k (tuple length)', fontsize=12)
    ax.set_ylabel('P_{3,k} = φ_k(S₃) / 6^k', fontsize=12)
    ax.set_title('Generating Probability P_{3,k} for S₃', fontsize=13)
    ax.set_ylim(0, 1.15)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.suptitle('Möbius Inversion: Generating Probability Convergence',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('moebius_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: moebius_convergence.png")


main()
