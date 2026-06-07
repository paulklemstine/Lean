#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy and Query Complexity

Produces three plots:
1. Oracle hierarchy as a directed graph
2. Query complexity gap (derivative queries vs vanishing order)
3. Spectral reconstruction accuracy
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def plot_query_complexity_gap():
    """Plot the derivative query gap: order r requires r+1 queries."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Query results for different vanishing orders
    max_order = 6
    for r in range(max_order + 1):
        queries = list(range(max_order + 2))
        results = [0.0] * r + [math.factorial(r)] + [0.0] * (max_order + 1 - r)
        ax1.scatter(queries, [r] * len(queries),
                   c=['red' if i < r else ('green' if i == r else 'gray') for i in queries],
                   s=100, zorder=5)
        ax1.plot([r, r], [-0.5, max_order + 0.5], 'k--', alpha=0.2)

    ax1.set_xlabel('Query index k (derivative order)', fontsize=12)
    ax1.set_ylabel('True vanishing order r', fontsize=12)
    ax1.set_title('Derivative Query Gap\n(Red = uninformative zero, Green = first nonzero)', fontsize=13)
    ax1.set_xlim(-0.5, max_order + 1.5)
    ax1.set_ylim(-0.5, max_order + 0.5)

    red_patch = mpatches.Patch(color='red', label='Query returns 0 (uninformative)')
    green_patch = mpatches.Patch(color='green', label='First nonzero (determines order)')
    gray_patch = mpatches.Patch(color='gray', label='Subsequent queries')
    ax1.legend(handles=[red_patch, green_patch, gray_patch], loc='upper left', fontsize=9)

    # Right: Query complexity function
    orders = list(range(0, 12))
    query_counts = [r + 1 for r in orders]

    ax2.bar(orders, query_counts, color='steelblue', alpha=0.8, edgecolor='navy')
    ax2.plot(orders, query_counts, 'ro-', markersize=6)
    ax2.set_xlabel('Vanishing order r', fontsize=12)
    ax2.set_ylabel('Queries needed (r + 1)', fontsize=12)
    ax2.set_title('Sharp Query Complexity Bound\n(Exactly r+1 derivative queries needed)', fontsize=13)

    plt.tight_layout()
    plt.savefig('query_complexity_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: query_complexity_gap.png")


def plot_spectral_reconstruction():
    """Plot spectral reconstruction of the Liouville function."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Compute Liouville function
    N = 50

    def omega(n):
        """Number of prime factors with multiplicity."""
        if n <= 1:
            return 0
        count = 0
        temp = n
        for p in range(2, n + 1):
            while temp % p == 0:
                count += 1
                temp //= p
        return count

    liouville = [(-1)**omega(n) for n in range(N + 1)]

    # Reconstruct from prime powers
    def reconstruct(n):
        if n <= 0:
            return 0
        if n == 1:
            return 1
        result = 1
        temp = n
        for p in range(2, n + 1):
            if temp <= 1:
                break
            k = 0
            while temp % p == 0:
                k += 1
                temp //= p
            if k > 0:
                result *= (-1)**k  # Liouville at prime power
        return result

    reconstructed = [reconstruct(n) for n in range(N + 1)]

    ns = list(range(1, N + 1))
    ax1.bar(ns, liouville[1:], color='steelblue', alpha=0.7, label='Direct λ(n)')
    ax1.scatter(ns, reconstructed[1:], color='red', s=20, zorder=5,
               label='Reconstructed from prime powers')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('λ(n)', fontsize=12)
    ax1.set_title('Spectral Reconstruction: Liouville Function\nRecovered from prime power values', fontsize=13)
    ax1.legend()

    # Cumulative sum (summatory Liouville)
    cumsum = np.cumsum(liouville[1:])
    ax2.plot(ns, cumsum, 'b-', linewidth=1.5, label='L(x) = Σ_{n≤x} λ(n)')
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.fill_between(ns, cumsum, 0, alpha=0.2, color='steelblue')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('L(x)', fontsize=12)
    ax2.set_title('Summatory Liouville Function\n(Related to RH: L(x) = O(x^{1/2+ε}) ⟺ RH)', fontsize=13)
    ax2.legend()

    plt.tight_layout()
    plt.savefig('spectral_reconstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spectral_reconstruction.png")


def plot_oracle_hierarchy():
    """Plot the oracle hierarchy as a visual diagram."""
    fig, ax = plt.subplots(figsize=(10, 8))

    levels = [
        (0, 'No Oracle', 'Cannot access\nL-function data', '#e0e0e0'),
        (1, 'Point Evaluation', 'Evaluates L(s)\nCannot detect zeros', '#ffcdd2'),
        (2, 'Derivative Oracle', 'Detects vanishing order\nBSD analytic rank', '#c8e6c9'),
        (3, 'Zero Certificate', 'Decides RH up to height T\nComplete zero lists', '#bbdefb'),
    ]

    barriers = [
        (0.5, 'Cannot even evaluate', '#999'),
        (1.5, 'BARRIER: Point queries\ncannot detect vanishing order', '#d32f2f'),
        (2.5, 'BARRIER: Local derivatives\ncannot determine global zeros', '#d32f2f'),
    ]

    for y, name, desc, color in levels:
        rect = mpatches.FancyBboxPatch((1, y - 0.35), 6, 0.7,
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(4, y + 0.1, f'Level {y}: {name}', ha='center', va='center',
               fontsize=14, fontweight='bold')
        ax.text(4, y - 0.15, desc, ha='center', va='center',
               fontsize=10, style='italic')

    for y, desc, color in barriers:
        ax.annotate('', xy=(4, y + 0.35), xytext=(4, y - 0.35),
                   arrowprops=dict(arrowstyle='->', color='green', lw=2))
        ax.text(8.5, y, desc, ha='center', va='center',
               fontsize=9, color=color, fontweight='bold',
               bbox=dict(boxstyle='round', facecolor='#fff3e0', edgecolor=color, alpha=0.8))

    ax.set_xlim(-0.5, 12)
    ax.set_ylim(-0.8, 3.8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Oracle Spectral Algebra: The Oracle Hierarchy\n'
                '(Each level is strictly more powerful than the previous)',
                fontsize=16, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oracle_hierarchy.png")


if __name__ == "__main__":
    plot_oracle_hierarchy()
    plot_query_complexity_gap()
    plot_spectral_reconstruction()
    print("\nAll visualizations generated!")
