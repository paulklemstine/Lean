#!/usr/bin/env python3
"""
Visualization: Ultrafilter Color Selection and Residue Classes

Demonstrates how ultrafilters partition ℕ by selecting one color
from any finite coloring, and one residue class from any modulus.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Ultrafilter Selection: Color Classes and Residue Classes',
                 fontsize=14, fontweight='bold')

    N = 500

    # Plot 1: 2-coloring by parity
    ax1 = axes[0, 0]
    xs = np.arange(N)
    colors_parity = ['blue' if x % 2 == 0 else 'red' for x in xs]
    ax1.scatter(xs, [x % 2 for x in xs], c=colors_parity, s=2, alpha=0.5)
    ax1.set_xlabel('n')
    ax1.set_ylabel('c(n)')
    ax1.set_title('2-Coloring: Parity\nUltrafilter selects ONE class')
    ax1.set_yticks([0, 1])
    ax1.set_yticklabels(['Even (blue)', 'Odd (red)'])

    # Plot 2: 3-coloring by mod 3
    ax2 = axes[0, 1]
    color_map = {0: 'blue', 1: 'green', 2: 'red'}
    colors_mod3 = [color_map[x % 3] for x in xs]
    ax2.scatter(xs, [x % 3 for x in xs], c=colors_mod3, s=2, alpha=0.5)
    ax2.set_xlabel('n')
    ax2.set_ylabel('c(n)')
    ax2.set_title('3-Coloring: mod 3\nUltrafilter selects ONE residue class')
    ax2.set_yticks([0, 1, 2])

    # Plot 3: Residue class densities for different moduli
    ax3 = axes[1, 0]
    moduli = [2, 3, 5, 7, 11]
    for m in moduli:
        densities = []
        for r in range(m):
            count = sum(1 for i in range(N) if i % m == r)
            densities.append(count / N)
        ax3.bar([f"m={m},r={r}" for r in range(m)], densities,
                alpha=0.6, label=f'mod {m}')

    ax3.set_xlabel('Residue class')
    ax3.set_ylabel('Density')
    ax3.set_title('Residue Class Densities\n(Equal by symmetry → ultrafilter breaks tie)')
    ax3.tick_params(axis='x', rotation=90, labelsize=6)

    # Plot 4: Standard part illustration
    ax4 = axes[1, 1]
    # Sequence f(i) = i mod 5
    f_vals = [i % 5 for i in range(N)]
    window = 50
    for m in range(5):
        running = []
        for start in range(0, N - window, 5):
            count = sum(1 for i in range(start, start + window) if f_vals[i] == m)
            running.append(count / window)
        ax4.plot(range(0, N - window, 5), running,
                 label=f'Density of f=={m}', linewidth=1.5)

    ax4.axhline(y=0.5, color='black', linestyle=':', label='Majority threshold')
    ax4.set_xlabel('Window start')
    ax4.set_ylabel('Density')
    ax4.set_title('Standard Part: f(i) = i mod 5\nUltrafilter selects one value')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_ultrafilter_selection.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_ultrafilter_selection.png")


if __name__ == "__main__":
    main()
