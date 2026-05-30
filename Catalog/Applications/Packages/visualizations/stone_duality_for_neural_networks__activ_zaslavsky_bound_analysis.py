"""
Visualization 2: Zaslavsky Bound vs 2^k Bound

Shows how the Zaslavsky bound (dimension-dependent) compares to the
naive 2^k bound. This visualizes the key insight that low-dimensional
inputs constrain the number of linear regions far below the theoretical
maximum, explaining why depth matters for expressivity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def zaslavsky_bound(n, k):
    """sum_{i=0}^{min(n,k)} C(k,i)"""
    return sum(comb(k, i) for i in range(min(n, k) + 1))


def plot_zaslavsky():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    k_values = np.arange(0, 21)

    # Left plot: Zaslavsky bound for different dimensions
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))

    for idx, n in enumerate([1, 2, 3, 5, 10]):
        bounds = [zaslavsky_bound(n, k) for k in k_values]
        ax1.semilogy(k_values, bounds, 'o-', color=colors[idx],
                     label=f'n={n}', markersize=4, linewidth=2)

    two_pow = [2**k for k in k_values]
    ax1.semilogy(k_values, two_pow, 'k--', linewidth=2, alpha=0.5,
                 label='2^k (naive)')

    ax1.set_xlabel('k (number of hyperplanes)', fontsize=12)
    ax1.set_ylabel('Maximum regions (log scale)', fontsize=12)
    ax1.set_title('Zaslavsky Bound vs Dimension', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right plot: Ratio of Zaslavsky to 2^k
    ax2 = axes[1]

    for idx, n in enumerate([1, 2, 3, 5, 10]):
        ratios = [zaslavsky_bound(n, k) / (2**k) if 2**k > 0 else 1
                  for k in k_values]
        ax2.plot(k_values, ratios, 'o-', color=colors[idx],
                 label=f'n={n}', markersize=4, linewidth=2)

    ax2.axhline(y=1, color='k', linestyle='--', alpha=0.5, label='Ratio = 1')
    ax2.set_xlabel('k (number of hyperplanes)', fontsize=12)
    ax2.set_ylabel('Zaslavsky / 2^k', fontsize=12)
    ax2.set_title('Efficiency Ratio: How Much Dimension Constrains\n'
                  'Expressivity Below the Maximum', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1.1)

    fig.suptitle('The Zaslavsky Bound: Dimension Controls Expressivity\n'
                 '(Lower ratio = more "wasted" neurons)',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_zaslavsky.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_zaslavsky.png")


if __name__ == "__main__":
    plot_zaslavsky()
