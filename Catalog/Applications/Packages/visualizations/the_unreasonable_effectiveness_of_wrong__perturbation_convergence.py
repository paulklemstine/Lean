#!/usr/bin/env python3
"""Visualization: Perturbation Series Convergence

Shows how partial sums of a perturbation chain converge to the true value,
with error bounds shrinking geometrically.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_convergence():
    """Plot perturbation series convergence with error bounds."""
    ratios = [0.3, 0.5, 0.7, 0.9]
    c0 = 1.0
    n_terms = 25
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Perturbation Series Convergence\n'
                 'Partial sums converge to truth with geometric error decay',
                 fontsize=14, fontweight='bold')
    
    for ax, ratio in zip(axes.flat, ratios):
        true_sum = c0 / (1 - ratio)
        
        corrections = [c0 * ratio ** k for k in range(n_terms)]
        partial_sums = np.cumsum(corrections)
        
        # Error bounds
        error_bounds = [c0 * ratio ** n / (1 - ratio) for n in range(1, n_terms + 1)]
        
        ns = np.arange(1, n_terms + 1)
        
        ax.axhline(y=true_sum, color='red', linestyle='--', alpha=0.7, label=f'True sum = {true_sum:.3f}')
        ax.plot(ns, partial_sums, 'b.-', label='Partial sums', markersize=4)
        ax.fill_between(ns, partial_sums - error_bounds, partial_sums + error_bounds,
                        alpha=0.2, color='blue', label='Error bound')
        
        ax.set_xlabel('Number of terms')
        ax.set_ylabel('Value')
        ax.set_title(f'Ratio r = {ratio}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
    print("Saved convergence_plot.png")


if __name__ == "__main__":
    plot_convergence()
