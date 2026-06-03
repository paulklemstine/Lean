#!/usr/bin/env python3
"""
Visualization: The Periodic Table of Finite Groups

Creates a color-coded periodic table showing groups organized by order (rows)
and chemical series (columns), with center-valence shown as cell intensity.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def factorize(n):
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def num_groups_estimate(n):
    """Rough estimate of number of groups of order n."""
    if n == 1: return 1
    factors = factorize(n)
    if len(factors) == 1:
        p, a = list(factors.items())[0]
        # p-groups
        if a == 1: return 1
        if a == 2: return 2
        if a == 3: return 5
        if a == 4: return 14 if p == 2 else 15
        return max(15, a * a)
    # Multiple primes
    count = 1
    for p, a in factors.items():
        if a == 1: count *= 1
        elif a == 2: count *= 2
        elif a == 3: count *= 5
        else: count *= max(5, a * a)
    # Account for semidirect products
    return max(count, len(factors) + 1)


def classify_order(n):
    """Classify the 'dominant' group type for order n."""
    if n == 1: return "Vacuum", 1.0
    if is_prime(n): return "Prime Element", 1.0
    factors = factorize(n)
    if len(factors) == 1:
        p, a = list(factors.items())[0]
        if a == 2:
            return "Noble Gas", 1.0  # Both groups of order p^2 are abelian
        if a == 3:
            return "Alkali Metal", 0.6  # 3 abelian, 2 non-abelian nilpotent
        return "Alkali Metal", 0.4  # Higher p-groups mostly nilpotent
    if len(factors) == 2:
        return "Compound", 0.7  # Two prime factors → solvable (Burnside)
    # Check if order is divisible by enough primes for non-solvability
    if n >= 60 and n % 60 == 0:
        return "Radioactive", 0.3  # Could contain A_5 as quotient
    if len(factors) >= 3:
        return "Compound", 0.5
    return "Noble Gas", 0.8


# Color scheme matching chemical analogy
COLORS = {
    "Vacuum": "#f0f0f0",
    "Prime Element": "#ff6b6b",
    "Noble Gas": "#4ecdc4",
    "Alkaline Earth": "#45b7d1",
    "Alkali Metal": "#f9ca24",
    "Compound": "#a29bfe",
    "Radioactive": "#fd79a8",
}

def main():
    fig, ax = plt.subplots(1, 1, figsize=(16, 10))

    # Create grid for orders 1-100
    max_order = 100
    cols = 10
    rows = (max_order + cols - 1) // cols

    for n in range(1, max_order + 1):
        row = (n - 1) // cols
        col = (n - 1) % cols

        series, intensity = classify_order(n)
        color = COLORS[series]

        # Draw cell
        rect = mpatches.FancyBboxPatch(
            (col * 1.5, (rows - 1 - row) * 1.3),
            1.3, 1.1,
            boxstyle="round,pad=0.05",
            facecolor=color,
            edgecolor='gray',
            alpha=0.5 + 0.5 * intensity,
            linewidth=0.5
        )
        ax.add_patch(rect)

        # Order number
        ax.text(col * 1.5 + 0.65, (rows - 1 - row) * 1.3 + 0.75,
                str(n), ha='center', va='center',
                fontsize=9, fontweight='bold')

        # Estimated group count
        ng = num_groups_estimate(n)
        ax.text(col * 1.5 + 0.65, (rows - 1 - row) * 1.3 + 0.35,
                f"~{ng}g" if ng > 1 else "1g",
                ha='center', va='center', fontsize=6, color='gray')

    # Legend
    legend_patches = [
        mpatches.Patch(color=COLORS["Prime Element"], label="Prime Element (p)"),
        mpatches.Patch(color=COLORS["Noble Gas"], label="Noble Gas (cyclic)"),
        mpatches.Patch(color=COLORS["Alkali Metal"], label="Alkali Metal (nilpotent)"),
        mpatches.Patch(color=COLORS["Compound"], label="Compound (solvable)"),
        mpatches.Patch(color=COLORS["Radioactive"], label="Radioactive (non-solvable)"),
    ]
    ax.legend(handles=legend_patches, loc='upper right', fontsize=9,
              title="Chemical Series", title_fontsize=10)

    ax.set_xlim(-0.5, cols * 1.5 + 0.5)
    ax.set_ylim(-0.5, rows * 1.3 + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("The Periodic Table of Finite Groups (Orders 1–100)",
                 fontsize=16, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig("periodic_table_groups.png", dpi=150, bbox_inches='tight')
    print("Saved: periodic_table_groups.png")

if __name__ == "__main__":
    main()
