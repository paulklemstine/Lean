#!/usr/bin/env python3
"""
Visualization: Tropical Barriers and Strategy Selection

Shows how tropical barriers persist under strategy selection and scale
under repetition.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Barrier persistence under selection
    ax1 = axes[0]
    strategies = ['Strategy A', 'Strategy B', 'Strategy C', 'Strategy D', 'Strategy E']
    costs = [3.2, 4.1, 2.8, 5.5, 3.7]
    barrier = min(costs)

    colors = ['#4CAF50' if c == barrier else '#2196F3' for c in costs]
    bars = ax1.bar(strategies, costs, color=colors, edgecolor='black', linewidth=0.5)
    ax1.axhline(y=barrier, color='red', linestyle='--', linewidth=2,
                label=f'Barrier B = {barrier}')
    ax1.set_ylabel('Tropical Cost', fontsize=12)
    ax1.set_title('Tropical Barrier:\nNo Strategy Breaks Below B', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_ylim(0, max(costs) * 1.2)
    for bar, cost in zip(bars, costs):
        ax1.text(bar.get_x() + bar.get_width() / 2., bar.get_height() + 0.1,
                f'{cost}', ha='center', va='bottom', fontsize=10)

    # Panel 2: Barrier scaling under repetition
    ax2 = axes[1]
    ks = np.arange(1, 11)

    for name, cost in [('Best (B=2.8)', 2.8), ('Average (3.7)', 3.7), ('Worst (5.5)', 5.5)]:
        total_costs = ks * cost
        errors = np.exp(-total_costs)
        ax2.semilogy(ks, errors, 'o-', label=name, markersize=5)

    # Barrier line
    barrier_errors = np.exp(-ks * barrier)
    ax2.fill_between(ks, barrier_errors, 1, alpha=0.1, color='red')
    ax2.semilogy(ks, barrier_errors, 'r--', linewidth=2,
                 label=f'Barrier bound exp(-k·{barrier})')

    ax2.set_xlabel('Rounds (k)', fontsize=12)
    ax2.set_ylabel('Achievable Error (log scale)', fontsize=12)
    ax2.set_title('Barrier Scaling:\nLinear in Tropical ↔ Exponential in Error', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_barriers.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_barriers.png")


if __name__ == "__main__":
    main()
