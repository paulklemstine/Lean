"""
Visualization: Formula Leaves vs 2^Depth Bound

Shows the proven bound that formula leaves ≤ 2^depth
for various formula structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def generate_formula_data():
    """Generate (depth, leaves) pairs for various formula structures."""
    data = []

    # Complete binary trees (tight examples)
    for d in range(8):
        data.append(('Complete tree', d, 2**d))

    # Left-skewed chains (x1 AND (x2 AND (x3 AND ...)))
    for d in range(1, 8):
        data.append(('Left chain', d, d + 1))

    # Balanced but not full
    for d in range(2, 8):
        data.append(('Sparse balanced', d, d + 2))

    return data


def plot_formula_depth_bound():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left plot: leaves vs depth for different structures
    ax1 = axes[0]
    depths = np.arange(0, 8)
    bound = 2**depths

    ax1.fill_between(depths, bound, alpha=0.15, color='red',
                     label='Forbidden region (leaves > 2^depth)')
    ax1.plot(depths, bound, 'r-', linewidth=2, label='Bound: 2^depth')

    data = generate_formula_data()
    markers = {'Complete tree': 'o', 'Left chain': 's', 'Sparse balanced': '^'}
    colors = {'Complete tree': '#2196F3', 'Left chain': '#4CAF50', 'Sparse balanced': '#FF9800'}

    for label in ['Complete tree', 'Left chain', 'Sparse balanced']:
        pts = [(d, l) for (lab, d, l) in data if lab == label]
        ds, ls = zip(*pts)
        ax1.scatter(ds, ls, marker=markers[label], color=colors[label],
                   s=80, label=label, zorder=5)

    ax1.set_xlabel('Formula Depth', fontsize=12)
    ax1.set_ylabel('Number of Leaves', fontsize=12)
    ax1.set_title('Formula Leaves ≤ 2^Depth (Proved)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_yscale('log', base=2)
    ax1.set_ylim(0.5, 256)
    ax1.grid(True, alpha=0.3)

    # Right plot: Shannon counting argument
    ax2 = axes[1]
    ns = np.arange(1, 16)
    num_functions = np.array([2**(2**n) for n in ns], dtype=float)
    shannon_bound = np.array([2**n / (n + 1) for n in ns])

    ax2.semilogy(ns, [2**n for n in ns], 'b-o', label='2^n (inputs)', markersize=5)
    ax2.semilogy(ns, shannon_bound, 'r-s', label='2^n/(n+1) (Shannon bound)', markersize=5)
    ax2.semilogy(ns, [n+1 for n in ns], 'g-^', label='n+1', markersize=5)

    ax2.set_xlabel('Number of Variables (n)', fontsize=12)
    ax2.set_ylabel('Formula Size', fontsize=12)
    ax2.set_title('Shannon Counting Lower Bound', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_formula_depth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_formula_depth.png")


if __name__ == "__main__":
    plot_formula_depth_bound()
