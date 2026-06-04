#!/usr/bin/env python3
"""
Visualization: Realizable Complexity Shadows

Plots the lattice of realizable (exponent, crossings) pairs,
showing the triangle inequality and parity constraints.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    max_c = 15
    realizable_e = []
    realizable_c = []
    unrealizable_e = []
    unrealizable_c = []

    for c in range(max_c + 1):
        for e in range(-c, c + 1):
            if abs(e) <= c and (e + c) % 2 == 0:
                realizable_e.append(e)
                realizable_c.append(c)
            else:
                unrealizable_e.append(e)
                unrealizable_c.append(c)

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Plot unrealizable points
    ax.scatter(unrealizable_e, unrealizable_c, c='lightgray', s=20,
               alpha=0.5, label='Not realizable', zorder=1)

    # Plot realizable points colored by coherence ratio
    coherence = [abs(e) / c if c > 0 else 0
                 for e, c in zip(realizable_e, realizable_c)]
    sc = ax.scatter(realizable_e, realizable_c, c=coherence, cmap='RdYlGn_r',
                    s=40, edgecolors='black', linewidths=0.5,
                    label='Realizable', zorder=2, vmin=0, vmax=1)

    # Draw boundary lines |e| = c
    e_line = np.linspace(-max_c, max_c, 100)
    ax.plot(e_line, np.abs(e_line), 'r--', linewidth=1.5, alpha=0.7,
            label='Boundary: |e| = c')

    # Mark special points
    special = {
        (0, 0): 'Trivial\n(identity)',
        (3, 3): 'Maximally\ncoherent',
        (0, 4): 'Balanced\n(confused)',
    }
    for (e, c), label in special.items():
        ax.annotate(label, (e, c), textcoords="offset points",
                    xytext=(15, 10), fontsize=8,
                    arrowprops=dict(arrowstyle='->', color='black'))

    plt.colorbar(sc, ax=ax, label='Coherence ratio |e|/c')
    ax.set_xlabel('Exponent sum (e)', fontsize=12)
    ax.set_ylabel('Crossing count (c)', fontsize=12)
    ax.set_title('Complexity Shadow Lattice\n'
                 'Realizable iff |e| ≤ c and e + c even', fontsize=14)
    ax.legend(loc='upper left')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('shadow_lattice.png', dpi=150, bbox_inches='tight')
    print("Saved shadow_lattice.png")


if __name__ == "__main__":
    main()
