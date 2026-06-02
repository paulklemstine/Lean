#!/usr/bin/env python3
"""
Visualization: Depth-Complexity Gap in Modal Formulas

Plots the relationship between modal depth and formula size,
demonstrating the orthogonality of these two complexity measures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_depth_recursive(formula_type, *args):
    """Compute depth given formula type and args."""
    if formula_type == 'var':
        return 0
    elif formula_type == 'bot':
        return 0
    elif formula_type == 'imp':
        return max(args[0], args[1])
    elif formula_type == 'box':
        return args[0] + 1
    return 0


def generate_formulas_at_depth(d, max_n=20):
    """Generate (depth, size) pairs for formulas at depth d with varying size."""
    sizes = []
    for n in range(max_n):
        # size of □^d(wideFormula(n)) = 2n + 1 + d
        size = 2 * n + 1 + d
        sizes.append((d, size))
    return sizes


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Depth vs Size for different depth levels
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 6))
    for d in range(6):
        pairs = generate_formulas_at_depth(d, 15)
        depths, sizes = zip(*pairs)
        ax1.scatter(sizes, depths, c=[colors[d]], s=30, alpha=0.8, label=f'd={d}')
        ax1.plot(sizes, depths, c=colors[d], alpha=0.4, linewidth=1)

    ax1.set_xlabel('Formula Size', fontsize=12)
    ax1.set_ylabel('Modal Depth', fontsize=12)
    ax1.set_title('Depth-Complexity Gap\n(each depth level has unbounded size)', fontsize=11)
    ax1.legend(fontsize=9, title='Depth')
    ax1.grid(True, alpha=0.3)

    # Plot 2: Reflective Orbit
    ax2 = axes[1]
    target_d = 5
    steps = list(range(8))
    depths_orbit = [s for s in steps]  # depth(□^n p) = n when depth(p) = 0

    ax2.plot(steps, depths_orbit, 'b-o', markersize=8, linewidth=2, label='depth(□ⁿp)')
    ax2.axhline(y=target_d, color='r', linestyle='--', linewidth=1.5, label=f'target d={target_d}')
    ax2.fill_between(steps, 0, target_d, alpha=0.1, color='green')
    ax2.axvline(x=target_d, color='orange', linestyle=':', linewidth=2,
                label=f'fixed point n={target_d}')

    ax2.set_xlabel('Iteration n', fontsize=12)
    ax2.set_ylabel('Depth', fontsize=12)
    ax2.set_title('Reflective Orbit\n(first passage through depth level)', fontsize=11)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Axiom Hierarchy
    ax3 = axes[2]
    axioms = ['T', 'K', '4', 'Löb']
    ax_depths = [1, 1, 2, 2]
    ax_sizes = [4, 10, 6, 8]
    ax_colors = ['#2196F3', '#2196F3', '#FF5722', '#FF5722']

    bars = ax3.bar(axioms, ax_depths, color=ax_colors, edgecolor='black', linewidth=1.2)

    # Add size labels on bars
    for bar, s in zip(bars, ax_sizes):
        ax3.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
                f'size={s}', ha='center', va='bottom', fontsize=10)

    ax3.set_ylabel('Modal Depth', fontsize=12)
    ax3.set_title('Axiom Depth Hierarchy\n(blue=one-step, red=iterated)', fontsize=11)
    ax3.set_ylim(0, 2.8)
    ax3.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('refltt_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: refltt_visualization.png")


if __name__ == '__main__':
    main()
