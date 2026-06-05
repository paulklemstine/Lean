#!/usr/bin/env python3
"""
Visualization: Phase Transition in Proof Space

Generates a plot showing the sharp phase transition in proof density
as statement complexity crosses the critical threshold.
"""

import math


def generate_phase_transition_plot():
    """Generate SVG plot of the phase transition."""
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Phase Transitions in Proof Space', fontsize=16, fontweight='bold')

    # Plot 1: Coverage ratio vs complexity for different b
    ax1 = axes[0, 0]
    k = 5
    n_values = np.arange(1, 15)
    for b in [2, 3, 5, 10]:
        ratios = [min(1.0, b**(k+1) / b**n) for n in n_values]
        ax1.plot(n_values, ratios, 'o-', label=f'b={b}', markersize=4)
    ax1.axvline(x=k+1, color='red', linestyle='--', alpha=0.7, label=f'n_c = {k+1}')
    ax1.set_xlabel('Statement Complexity n')
    ax1.set_ylabel('Coverage Ratio ρ(n)')
    ax1.set_title(f'Sharp Phase Transition (k={k})')
    ax1.set_yscale('log')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Entropy gap
    ax2 = axes[0, 1]
    b = 2
    for k in [3, 5, 8, 12]:
        n_c = k + 1
        n_vals = np.arange(1, 25)
        gaps = [max(0, (n - k - 1) * math.log(b)) for n in n_vals]
        ax2.plot(n_vals, gaps, '-', label=f'k={k} (n_c={n_c})', linewidth=2)
    ax2.set_xlabel('Statement Complexity n')
    ax2.set_ylabel('Entropy Gap (nats)')
    ax2.set_title(f'Information-Theoretic Entropy Gap (b={b})')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Plot 3: Hausdorff dimension
    ax3 = axes[1, 0]
    for k in [3, 5, 10, 20]:
        n_vals = np.arange(1, 50)
        dims = [(k+1)/n for n in n_vals]
        ax3.plot(n_vals, dims, '-', label=f'k={k}', linewidth=2)
    ax3.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='d=1 (full dimension)')
    ax3.set_xlabel('Statement Complexity n')
    ax3.set_ylabel('Proof Space Dimension d')
    ax3.set_title('Dimensional Scaling: d = (k+1)/n')
    ax3.set_ylim(0, 3)
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # Plot 4: Boltzmann comparison
    ax4 = axes[1, 1]
    k = 5
    b = 2
    beta = math.log(b)
    delta_e_vals = np.linspace(0, 10, 100)
    boltzmann_vals = [math.exp(-beta * de) for de in delta_e_vals]
    ax4.plot(delta_e_vals, boltzmann_vals, 'b-', linewidth=2, label='Boltzmann e^{-βΔE}')

    # Discrete proof density points
    for m in range(11):
        proof_dens = b**(k+1) / b**(k+1+m)
        ax4.plot(m, proof_dens, 'ro', markersize=8)
    ax4.plot([], [], 'ro', markersize=8, label='Proof density (discrete)')

    ax4.set_xlabel('Energy Gap ΔE = n - n_c')
    ax4.set_ylabel('Density / Weight')
    ax4.set_title(f'Boltzmann Bridge (b={b}, β={beta:.3f})')
    ax4.set_yscale('log')
    ax4.legend()
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('phase_transition_plots.png', dpi=150, bbox_inches='tight')
    plt.savefig('phase_transition_plots.svg', bbox_inches='tight')
    print("Saved: phase_transition_plots.png, phase_transition_plots.svg")


if __name__ == "__main__":
    generate_phase_transition_plot()
