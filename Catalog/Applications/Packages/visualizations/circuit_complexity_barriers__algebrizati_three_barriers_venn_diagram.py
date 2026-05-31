"""
Visualization: The Three Barriers to P vs NP

Illustrates the relationship between the three complexity barriers
and the space of possible proof techniques.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Circle, FancyArrowPatch
import matplotlib.patches as mpatches


def plot_barriers():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Venn diagram of barriers
    ax1 = axes[0]
    ax1.set_xlim(-3, 3)
    ax1.set_ylim(-3, 3)
    ax1.set_aspect('equal')

    # Three overlapping circles
    circle1 = Circle((-0.8, 0.5), 1.8, fill=True, alpha=0.15,
                     color='#F44336', linewidth=2, edgecolor='#F44336')
    circle2 = Circle((0.8, 0.5), 1.8, fill=True, alpha=0.15,
                     color='#2196F3', linewidth=2, edgecolor='#2196F3')
    circle3 = Circle((0, -0.8), 1.8, fill=True, alpha=0.15,
                     color='#4CAF50', linewidth=2, edgecolor='#4CAF50')

    ax1.add_patch(circle1)
    ax1.add_patch(circle2)
    ax1.add_patch(circle3)

    ax1.text(-1.8, 1.5, 'Relativization', fontsize=11, fontweight='bold',
             color='#D32F2F', ha='center')
    ax1.text(1.8, 1.5, 'Algebrization', fontsize=11, fontweight='bold',
             color='#1565C0', ha='center')
    ax1.text(0, -2.3, 'Natural Proofs', fontsize=11, fontweight='bold',
             color='#2E7D32', ha='center')

    ax1.text(0, 0.2, 'P vs NP\nproof must\navoid ALL', fontsize=9,
             ha='center', va='center', fontweight='bold',
             bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

    ax1.text(-1.5, -0.3, 'Diagonal-\nization', fontsize=8, ha='center', alpha=0.7)
    ax1.text(1.5, -0.3, 'IP=\nPSPACE', fontsize=8, ha='center', alpha=0.7)
    ax1.text(0, -1.3, 'Circuit\nbounds', fontsize=8, ha='center', alpha=0.7)

    ax1.set_title('The Three Barriers (Proved)', fontsize=14)
    ax1.axis('off')

    # Right: Sensitivity vs depth for common functions
    ax2 = axes[1]

    functions = {
        'Parity': [],
        'Majority': [],
        'AND': [],
        'OR': [],
        'Threshold-k': [],
    }

    ns = list(range(2, 13))

    for n in ns:
        # Parity: sensitivity = n, depth = n-1 for optimal formula
        functions['Parity'].append((n, n))
        # AND: sensitivity = n, depth = ceil(log2(n)) for balanced formula
        functions['AND'].append((n, n))
        # OR: sensitivity = n
        functions['OR'].append((n, n))
        # Majority: sensitivity ≈ ceil(n/2)
        functions['Majority'].append((n, (n+1)//2 + 1))

    colors = {'Parity': '#F44336', 'AND': '#2196F3', 'Majority': '#4CAF50',
              'OR': '#FF9800'}

    for name in ['Parity', 'AND', 'Majority']:
        ns_plot, ss = zip(*functions[name])
        ax2.plot(ns_plot, ss, 'o-', label=f's({name})', color=colors[name],
                markersize=5)

    # Plot 2^depth bound line
    ds = np.arange(1, 13)
    ax2.plot(ds, 2**np.ceil(np.log2(ds)), 'k--', alpha=0.5,
            label='2^⌈log₂(n)⌉ (depth bound)')

    ax2.set_xlabel('Number of Variables (n)', fontsize=12)
    ax2.set_ylabel('Sensitivity', fontsize=12)
    ax2.set_title('Function Sensitivity vs n', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_barriers.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_barriers.png")


if __name__ == "__main__":
    plot_barriers()
