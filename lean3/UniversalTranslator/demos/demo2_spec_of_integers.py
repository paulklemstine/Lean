#!/usr/bin/env python3
"""
Demo 2: Visualizing Spec(ℤ) — The Prime Spectrum of the Integers
=================================================================
Shows the prime spectrum of ℤ as a topological space with the
Zariski topology. The generic point (0) is dense; each (p) is closed.

Run: python demo2_spec_of_integers.py
Output: spec_integers.png
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True

def create_spec_integers():
    fig, axes = plt.subplots(2, 1, figsize=(16, 10), gridspec_kw={'height_ratios': [3, 2]})

    # === Panel 1: Spec(ℤ) as a topological space ===
    ax = axes[0]
    ax.set_xlim(-2, 22)
    ax.set_ylim(-1.5, 4)
    ax.axis('off')
    ax.set_title('Spec(ℤ) — The Prime Spectrum of the Integers',
                 fontsize=20, fontweight='bold', fontfamily='serif', pad=20)

    primes = [p for p in range(2, 50) if is_prime(p)][:8]

    # Draw the generic point (0) as a large cloud encompassing everything
    cloud = mpatches.FancyBboxPatch((-1.5, -0.5), 21, 3.5,
                boxstyle="round,pad=0.5", facecolor='#e8f4f8',
                edgecolor='#0f3460', linewidth=2, linestyle='--', alpha=0.3)
    ax.add_patch(cloud)
    ax.text(10, 2.7, 'closure of (0) = all of Spec(ℤ)',
            fontsize=11, ha='center', va='center', color='#0f3460',
            style='italic', fontfamily='serif')

    # Generic point
    ax.plot(0, 1.5, 'o', markersize=20, color='#e94560', zorder=10,
            markeredgecolor='#1a1a2e', markeredgewidth=2)
    ax.text(0, 0.5, '(0)\ngeneric\npoint', fontsize=10, ha='center', va='top',
            color='#e94560', fontweight='bold', fontfamily='serif')

    # Closed points (primes)
    for i, p in enumerate(primes):
        x = 2.5 + i * 2.2
        ax.plot(x, 1.5, 's', markersize=16, color='#0f3460', zorder=10,
                markeredgecolor='#1a1a2e', markeredgewidth=1.5)
        ax.text(x, 0.5, f'({p})', fontsize=11, ha='center', va='top',
                color='#0f3460', fontweight='bold', fontfamily='serif')
        # Show each closed point has singleton closure
        circle = plt.Circle((x, 1.5), 0.4, fill=False, edgecolor='#533483',
                            linewidth=1.5, linestyle='-', zorder=5)
        ax.add_patch(circle)

    ax.text(19.5, 1.5, '· · ·', fontsize=20, ha='center', va='center',
            color='#0f3460')

    # Legend
    legend_elements = [
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='#e94560',
                   markersize=12, label='Generic point (0) — dense, not closed'),
        plt.Line2D([0], [0], marker='s', color='w', markerfacecolor='#0f3460',
                   markersize=12, label='Closed points (p) — maximal ideals'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=11,
              framealpha=0.9, fancybox=True)

    # === Panel 2: Basic open sets D(n) ===
    ax2 = axes[1]
    ax2.set_xlim(-2, 22)
    ax2.set_ylim(-0.5, 3.5)
    ax2.axis('off')
    ax2.set_title('Basic Open Sets D(n) in the Zariski Topology',
                  fontsize=16, fontweight='bold', fontfamily='serif', pad=10)

    # D(6) = Spec(ℤ) \ {(2), (3)} — primes not containing 6
    # Show three examples of basic opens
    examples = [
        (6, 'D(6) = Spec(ℤ) \\ {(2), (3)}', [2, 3]),
        (10, 'D(10) = Spec(ℤ) \\ {(2), (5)}', [2, 5]),
        (30, 'D(30) = Spec(ℤ) \\ {(2), (3), (5)}', [2, 3, 5]),
    ]

    colors = ['#2196F3', '#4CAF50', '#FF9800']

    for j, (n, label, excluded) in enumerate(examples):
        y = 2.5 - j * 1.0
        ax2.text(-1, y, label, fontsize=11, ha='left', va='center',
                color=colors[j], fontweight='bold', fontfamily='serif')

        for i, p in enumerate(primes):
            x = 10 + i * 1.5
            if p in excluded:
                ax2.plot(x, y, 'x', markersize=10, color='#cccccc',
                        markeredgewidth=2, zorder=10)
            else:
                ax2.plot(x, y, 'o', markersize=8, color=colors[j],
                        zorder=10, markeredgecolor='#1a1a2e', markeredgewidth=1)

    # Prime labels
    for i, p in enumerate(primes):
        x = 10 + i * 1.5
        ax2.text(x, 3.2, f'({p})', fontsize=9, ha='center', va='center',
                color='#333333', fontfamily='serif')

    plt.tight_layout()
    plt.savefig('spec_integers.png', dpi=200, bbox_inches='tight',
                facecolor='white')
    print("✓ Saved spec_integers.png")
    plt.close()

if __name__ == '__main__':
    create_spec_integers()
