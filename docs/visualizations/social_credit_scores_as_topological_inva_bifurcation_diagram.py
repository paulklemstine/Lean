#!/usr/bin/env python3
"""
Bifurcation Diagram of the Logistic Scoring Map

Visualizes the phase transition: for a < 1, scores collapse to 0.
At a = 1, a non-trivial fixed point emerges. For a > 3, period-doubling
cascades lead to chaos.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_bifurcation_diagram(
    a_min: float = 0.0,
    a_max: float = 4.0,
    n_params: int = 2000,
    n_warmup: int = 500,
    n_plot: int = 200,
) -> tuple:
    a_values = np.linspace(a_min, a_max, n_params)
    all_a = []
    all_x = []

    for a in a_values:
        x = 0.5
        for _ in range(n_warmup):
            x = a * x * (1 - x)
        for _ in range(n_plot):
            x = a * x * (1 - x)
            all_a.append(a)
            all_x.append(x)

    return np.array(all_a), np.array(all_x)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Full bifurcation diagram
    a_vals, x_vals = compute_bifurcation_diagram()
    axes[0].scatter(a_vals, x_vals, s=0.01, c='navy', alpha=0.3)
    axes[0].axvline(x=1.0, color='red', linestyle='--', alpha=0.7, label='a = 1 (bifurcation)')
    axes[0].axvline(x=3.0, color='orange', linestyle='--', alpha=0.7, label='a = 3 (period-2)')

    # Plot the analytical fixed point x* = 1 - 1/a
    a_range = np.linspace(1.01, 4.0, 500)
    x_star = 1 - 1/a_range
    axes[0].plot(a_range, x_star, 'r-', linewidth=1.5, alpha=0.5, label='x* = 1-1/a')
    axes[0].plot([0, 4], [0, 0], 'g-', linewidth=1.5, alpha=0.5, label='x* = 0')

    axes[0].set_xlabel('Parameter a', fontsize=12)
    axes[0].set_ylabel('Score (attractor)', fontsize=12)
    axes[0].set_title('Logistic Scoring Map: Bifurcation Diagram', fontsize=13)
    axes[0].legend(fontsize=9)
    axes[0].set_xlim(0, 4)
    axes[0].set_ylim(-0.05, 1.05)

    # Zoom into the phase transition at a = 1
    a_vals_zoom, x_vals_zoom = compute_bifurcation_diagram(0.5, 1.5, 1000, 200, 50)
    axes[1].scatter(a_vals_zoom, x_vals_zoom, s=0.5, c='navy', alpha=0.5)
    axes[1].axvline(x=1.0, color='red', linestyle='--', alpha=0.7, label='Phase transition')

    a_zoom = np.linspace(1.01, 1.5, 200)
    axes[1].plot(a_zoom, 1 - 1/a_zoom, 'r-', linewidth=2, label='x* = 1-1/a')
    axes[1].plot([0.5, 1.5], [0, 0], 'g-', linewidth=2, label='x* = 0')

    axes[1].set_xlabel('Parameter a', fontsize=12)
    axes[1].set_ylabel('Score (attractor)', fontsize=12)
    axes[1].set_title('Phase Transition Detail (a ≈ 1)', fontsize=13)
    axes[1].legend(fontsize=10)
    axes[1].set_xlim(0.5, 1.5)
    axes[1].set_ylim(-0.1, 0.5)

    plt.tight_layout()
    plt.savefig('viz_bifurcation.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_bifurcation.png")


if __name__ == "__main__":
    main()
