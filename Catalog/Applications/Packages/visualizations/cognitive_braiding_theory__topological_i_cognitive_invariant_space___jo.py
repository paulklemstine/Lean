#!/usr/bin/env python3
"""
Visualization: Cognitive Invariant Space

Plots the (writhe, entropy) invariant space showing all realizable
cognitive complexity classes and their properties.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def realize_invariant(target_writhe: int, target_crossings: int):
    """Compute the cognitive invariant for a given (writhe, crossings) pair."""
    entropy = target_crossings * math.log(2)
    return target_writhe, entropy


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: The (writhe, entropy) invariant space
    ax1 = axes[0]
    max_n = 10
    writhes = []
    entropies = []
    colors = []

    for n in range(0, max_n + 1):
        for w in range(-n, n + 1, 2):
            wr, ent = realize_invariant(w, n)
            writhes.append(wr)
            entropies.append(ent)
            if w == 0:
                colors.append('blue')       # balanced
            elif abs(w) == n:
                colors.append('red')        # maximally biased
            else:
                colors.append('green')      # intermediate

    ax1.scatter(writhes, entropies, c=colors, s=40, alpha=0.8, edgecolors='black', linewidth=0.5)

    # Draw the boundary |writhe| ≤ n, entropy = n * log2
    n_vals = np.linspace(0, max_n, 100)
    entropy_vals = n_vals * math.log(2)
    ax1.plot(n_vals, entropy_vals, 'k--', alpha=0.3, label='|writhe| = crossings')
    ax1.plot(-n_vals, entropy_vals, 'k--', alpha=0.3)
    ax1.fill_betweenx(entropy_vals, -n_vals, n_vals, alpha=0.05, color='gray')

    balanced_patch = mpatches.Patch(color='blue', label='Balanced (writhe=0)')
    biased_patch = mpatches.Patch(color='red', label='Maximally biased')
    inter_patch = mpatches.Patch(color='green', label='Intermediate')
    ax1.legend(handles=[balanced_patch, biased_patch, inter_patch], fontsize=9)

    ax1.set_xlabel('Writhe (directional bias)', fontsize=12)
    ax1.set_ylabel('Cognitive Entropy (bits)', fontsize=12)
    ax1.set_title('Cognitive Invariant Space', fontsize=14)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Jones entropy vs parameter A
    ax2 = axes[1]
    a_vals = np.linspace(0.1, 4.0, 200)

    for n in [2, 3, 4, 5]:
        jones_entropies = []
        for a in a_vals:
            # Compute Jones entropy for n crossings, all positive
            exponents = [2 * k - n for k in range(n + 1)]
            # Degeneracy: C(n, k) states have exponent 2k - n
            from math import comb
            weights = [comb(n, k) * abs(a ** (2 * k - n)) for k in range(n + 1)]
            total = sum(weights)
            probs = [w / total for w in weights]
            entropy = -sum(p * math.log2(p) if p > 0 else 0 for p in probs)
            jones_entropies.append(entropy)

        ax2.plot(a_vals, jones_entropies, label=f'n = {n}', linewidth=2)
        ax2.axhline(y=n, color='gray', linestyle=':', alpha=0.3)

    ax2.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='A=1 (uniform)')
    ax2.set_xlabel('Parameter A', fontsize=12)
    ax2.set_ylabel('Jones Entropy H_A (bits)', fontsize=12)
    ax2.set_title('Jones Polynomial Entropy', fontsize=14)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('cognitive_braiding_invariants.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cognitive_braiding_invariants.png")


if __name__ == "__main__":
    main()
