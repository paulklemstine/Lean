#!/usr/bin/env python3
"""
Visualization: Incompressibility Bound

Shows how the fraction of compressible words drops exponentially
as the compression savings increase.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Compressible fraction vs savings for different alphabet sizes
    ax1 = axes[0]
    n = 100  # word length
    savings_range = range(0, 50)

    for k, color, marker in [(2, '#e74c3c', 'o'), (4, '#3498db', 's'),
                              (10, '#2ecc71', '^'), (25, '#9b59b6', 'D')]:
        fractions = []
        for s in savings_range:
            frac = k ** (-s) if s > 0 else 1.0
            fractions.append(frac)
        ax1.plot(list(savings_range), fractions, f'{marker}-', color=color,
                 linewidth=1.5, markersize=4, label=f'k={k}', markevery=5)

    ax1.set_xlabel('Compression savings (characters)', fontsize=12)
    ax1.set_ylabel('Max compressible fraction', fontsize=12)
    ax1.set_title(f'Compressible Fraction vs Savings\n(n={n})', fontsize=13)
    ax1.set_yscale('log')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(1e-60, 2)

    # Plot 2: Pigeonhole illustration for small parameters
    ax2 = axes[1]
    n_small = 8
    k_small = 3
    total = k_small ** n_small

    savings_vals = list(range(0, n_small + 1))
    compressible = [min(total, k_small ** (n_small - s)) for s in savings_vals]
    incompressible = [total - c for c in compressible]

    x = np.arange(len(savings_vals))
    width = 0.35
    bars1 = ax2.bar(x - width/2, compressible, width, color='#3498db',
                    alpha=0.8, label='Compressible (upper bound)')
    bars2 = ax2.bar(x + width/2, incompressible, width, color='#e74c3c',
                    alpha=0.8, label='Incompressible (lower bound)')

    ax2.set_xlabel('Compression savings', fontsize=12)
    ax2.set_ylabel('Number of words', fontsize=12)
    ax2.set_title(f'Pigeonhole Bound\n(n={n_small}, k={k_small}, total={total})',
                  fontsize=13)
    ax2.set_xticks(x)
    ax2.set_xticklabels(savings_vals)
    ax2.legend(fontsize=10)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('incompressibility.png', dpi=150, bbox_inches='tight')
    print("Saved incompressibility.png")


if __name__ == "__main__":
    main()
