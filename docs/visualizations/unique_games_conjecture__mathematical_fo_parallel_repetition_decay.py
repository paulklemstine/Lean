#!/usr/bin/env python3
"""Visualization: Parallel Repetition Decay for Unique Games."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Parallel repetition decay curves
    r_values = np.arange(1, 21)
    base_values = [0.99, 0.95, 0.9, 0.8, 0.7, 0.5]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(base_values)))

    for v, color in zip(base_values, colors):
        decay = v ** r_values
        ax1.plot(r_values, decay, 'o-', color=color, markersize=4,
                label=f'v = {v}', linewidth=2)

    ax1.set_xlabel('Repetitions (r)', fontsize=13)
    ax1.set_ylabel('Value$^r$', fontsize=13)
    ax1.set_title('Parallel Repetition: Exponential Decay', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_yscale('log')
    ax1.set_ylim(1e-6, 1.5)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.5)

    # Right: Gap ratio (1-ε)/ε as function of ε
    eps_values = np.linspace(0.01, 0.49, 200)
    gap_ratios = (1 - eps_values) / eps_values

    ax2.plot(eps_values, gap_ratios, 'b-', linewidth=2.5)
    ax2.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Ratio = 1')
    ax2.axvline(x=0.5, color='gray', linestyle=':', alpha=0.5, label='ε = 1/2')
    ax2.set_xlabel('ε (soundness parameter)', fontsize=13)
    ax2.set_ylabel('Gap Ratio (1-ε)/ε', fontsize=13)
    ax2.set_title('UGC Gap Ratio Divergence', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 30)

    plt.tight_layout()
    plt.savefig('viz_parallel_rep.png', dpi=150, bbox_inches='tight')
    print("Saved viz_parallel_rep.png")

if __name__ == "__main__":
    main()
