#!/usr/bin/env python3
"""
Visualization: Pareto Frontier of Cost-Error Tradeoffs

Generates a plot showing how different proof amplification chains
create different cost-error tradeoff curves, and the combined
Pareto frontier.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def amplified_error(base_error: float, k: int) -> float:
    return base_error ** k

def amplified_cost(unit_cost: float, k: int) -> float:
    return k * unit_cost

def tropical_cost_of_error(eps: float) -> float:
    return -math.log(eps) if eps > 0 else float('inf')


def main():
    chains = [
        ("Fast/Weak (ε=0.4, c=0.5)", 0.4, 0.5, 'tab:blue'),
        ("Balanced (ε=0.3, c=1.0)", 0.3, 1.0, 'tab:orange'),
        ("Slow/Strong (ε=0.1, c=2.0)", 0.1, 2.0, 'tab:green'),
    ]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left plot: Error vs Cost (log scale for error)
    ax1 = axes[0]
    max_k = 25

    for name, base_err, unit_c, color in chains:
        costs = [amplified_cost(unit_c, k) for k in range(1, max_k + 1)]
        errors = [amplified_error(base_err, k) for k in range(1, max_k + 1)]
        ax1.semilogy(costs, errors, 'o-', color=color, label=name, markersize=4)

    # Compute and plot Pareto frontier
    all_points = []
    for _, base_err, unit_c, _ in chains:
        for k in range(1, max_k + 1):
            all_points.append((amplified_cost(unit_c, k), amplified_error(base_err, k)))

    all_points.sort(key=lambda p: p[0])
    frontier = []
    min_err = float('inf')
    for c, e in all_points:
        if e < min_err:
            frontier.append((c, e))
            min_err = e

    fc, fe = zip(*frontier)
    ax1.semilogy(fc, fe, 'k--', linewidth=2, label='Pareto Frontier', alpha=0.7)

    ax1.set_xlabel('Total Cost', fontsize=12)
    ax1.set_ylabel('Soundness Error (log scale)', fontsize=12)
    ax1.set_title('Cost-Error Tradeoff Curves', fontsize=14)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Right plot: Tropical cost vs Economic cost
    ax2 = axes[1]

    for name, base_err, unit_c, color in chains:
        costs = [amplified_cost(unit_c, k) for k in range(1, max_k + 1)]
        trop_costs = [k * tropical_cost_of_error(base_err) for k in range(1, max_k + 1)]
        ax2.plot(costs, trop_costs, 'o-', color=color, label=name, markersize=4)

    ax2.set_xlabel('Economic Cost (k · c)', fontsize=12)
    ax2.set_ylabel('Tropical Cost (k · τ(ε))', fontsize=12)
    ax2.set_title('Tropical vs Economic Cost (Both Linear!)', fontsize=14)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('pareto_frontier.png', dpi=150, bbox_inches='tight')
    print("Saved: pareto_frontier.png")


if __name__ == "__main__":
    main()
