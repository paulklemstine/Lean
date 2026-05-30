#!/usr/bin/env python3
"""
Visualization 1: H₀ Persistence Barcode of the Prime Point Cloud

This visualizes the persistence barcode for the Rips filtration on primes.
Each horizontal bar represents a connected component, with birth at the
prime value and death when it merges with a neighbor. The Bertrand bar
length bound (gap < birth) is shown as a diagonal boundary.

What this visualizes: The core mathematical object — the prime barcode —
showing how prime gaps translate into topological persistence.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(2, N + 1) if is_prime[i]]


def main():
    N = 200
    primes = sieve_primes(N)

    fig, axes = plt.subplots(2, 1, figsize=(14, 10), height_ratios=[2, 1])

    # --- Top: Barcode diagram ---
    ax = axes[0]
    colors = []
    for i in range(len(primes) - 1):
        gap = primes[i + 1] - primes[i]
        if gap == 2:
            colors.append('#e74c3c')  # Twin primes: red
        elif gap == 4:
            colors.append('#f39c12')  # Cousin primes: orange
        elif gap == 6:
            colors.append('#2ecc71')  # Sexy primes: green
        else:
            colors.append('#3498db')  # Other: blue

    for i in range(len(primes) - 1):
        gap = primes[i + 1] - primes[i]
        ax.barh(i, gap, left=primes[i], height=0.7, color=colors[i],
                alpha=0.8, edgecolor='white', linewidth=0.3)

    ax.set_xlabel('Prime Value', fontsize=12)
    ax.set_ylabel('Bar Index', fontsize=12)
    ax.set_title(f'H₀ Persistence Barcode of Primes ≤ {N}\n'
                 'Each bar represents a connected component; color = gap type',
                 fontsize=14, fontweight='bold')

    # Legend
    patches = [
        mpatches.Patch(color='#e74c3c', label='Gap 2 (twin primes)'),
        mpatches.Patch(color='#f39c12', label='Gap 4 (cousin primes)'),
        mpatches.Patch(color='#2ecc71', label='Gap 6 (sexy primes)'),
        mpatches.Patch(color='#3498db', label='Other gaps'),
    ]
    ax.legend(handles=patches, loc='lower right', fontsize=10)

    # --- Bottom: Gap distribution ---
    ax2 = axes[1]
    gaps = [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]
    unique_gaps = sorted(set(gaps))
    gap_counts = [gaps.count(g) for g in unique_gaps]

    bar_colors = []
    for g in unique_gaps:
        if g == 2:
            bar_colors.append('#e74c3c')
        elif g == 4:
            bar_colors.append('#f39c12')
        elif g == 6:
            bar_colors.append('#2ecc71')
        else:
            bar_colors.append('#3498db')

    ax2.bar(unique_gaps, gap_counts, color=bar_colors, edgecolor='white',
            width=1.5, alpha=0.85)
    ax2.set_xlabel('Gap Size (Bar Persistence)', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Bar Persistences (Gap Sizes)', fontsize=13)

    plt.tight_layout()
    plt.savefig('viz_barcode.png', dpi=150, bbox_inches='tight')
    print("Saved viz_barcode.png")


if __name__ == "__main__":
    main()
