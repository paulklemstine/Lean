#!/usr/bin/env python3
"""
Visualization: Compositional Proof Acceleration

Shows how proof composition shifts the phase transition threshold
but cannot eliminate it.
"""

import math


def generate_composition_plot():
    """Generate plot of compositional acceleration."""
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Compositional Proof Acceleration', fontsize=14, fontweight='bold')

    # Plot 1: Threshold shift with composition levels
    ax1 = axes[0]
    k_values = [2, 5, 10]
    m_values = np.arange(1, 11)
    for k in k_values:
        thresholds = [(k + 1) * m for m in m_values]
        ax1.plot(m_values, thresholds, 'o-', label=f'k={k}', linewidth=2, markersize=6)
    ax1.set_xlabel('Composition Levels m')
    ax1.set_ylabel('Critical Threshold n_c = (k+1)·m')
    ax1.set_title('Threshold Shifts Linearly')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Coverage ratio with composition
    ax2 = axes[1]
    b, k = 2, 3
    n_values = np.arange(1, 40)
    for m in [1, 2, 3, 5]:
        effective_bound = b ** ((k + 1) * m)
        ratios = [min(1.0, effective_bound / b**n) for n in n_values]
        n_c = (k + 1) * m
        ax2.plot(n_values, ratios, '-', label=f'm={m} (n_c={n_c})', linewidth=2)
        ax2.axvline(x=n_c, linestyle=':', alpha=0.3)
    ax2.set_xlabel('Statement Complexity n')
    ax2.set_ylabel('Coverage Ratio')
    ax2.set_title(f'Coverage with Composition (b={b}, k={k})')
    ax2.set_yscale('log')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('composition_plots.png', dpi=150, bbox_inches='tight')
    print("Saved: composition_plots.png")


if __name__ == "__main__":
    generate_composition_plot()
