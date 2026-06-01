#!/usr/bin/env python3
"""
Cantor Set Attractor Visualization

Shows the iterative construction of the Cantor set through middle-third
removal, demonstrating the attractor dimension collapse.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def cantor_intervals(n_stages: int) -> list:
    intervals = [(0.0, 1.0)]
    for _ in range(n_stages):
        new = []
        for a, b in intervals:
            w = (b - a) / 3
            new.append((a, a + w))
            new.append((b - w, b))
        intervals = new
    return intervals


def main():
    fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [3, 1]})

    n_stages = 7
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, n_stages + 1))

    for stage in range(n_stages + 1):
        intervals = cantor_intervals(stage)
        y = n_stages - stage
        for a, b in intervals:
            axes[0].fill_between([a, b], y - 0.35, y + 0.35,
                               color=colors[stage], alpha=0.8)

    axes[0].set_yticks(range(n_stages + 1))
    axes[0].set_yticklabels([f'Stage {n_stages - i}' for i in range(n_stages + 1)])
    axes[0].set_xlabel('Score', fontsize=12)
    axes[0].set_title('Cantor Set Construction: Middle-Third Removal', fontsize=14)
    axes[0].set_xlim(-0.02, 1.02)

    # Plot measure decay
    stages = list(range(n_stages + 1))
    measures = [(2/3)**n for n in stages]
    n_intervals = [2**n for n in stages]

    ax2 = axes[1]
    ax2.semilogy(stages, measures, 'bo-', linewidth=2, markersize=8, label='Total measure (2/3)ⁿ')
    ax2.set_xlabel('Stage', fontsize=12)
    ax2.set_ylabel('Measure', fontsize=12)
    ax2.set_title('Measure Decay → 0 (Dimension Collapse)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    ax3 = ax2.twinx()
    ax3.semilogy(stages, n_intervals, 'rs--', linewidth=2, markersize=8, label='Number of intervals 2ⁿ')
    ax3.set_ylabel('Count', fontsize=12, color='red')
    ax3.legend(fontsize=10, loc='center right')

    plt.tight_layout()
    plt.savefig('viz_cantor.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_cantor.png")


if __name__ == "__main__":
    main()
